"""MissionFit 3B maket kareleri (Blender + MPFB).

Kullanım:
  ~/.local/opt/blender/blender -b -P tools/body_map/build_body_map.py -- --out assets/body_map

Seçenekler:
  --frames 72          dönüşteki kare sayısı (5° adım)
  --only 0,18,36       yalnızca bu kareleri üret (deneme için; manifest yazılmaz)
  --height 720         kare yüksekliği (px); genişlik oranla hesaplanır
  --samples 48         Cycles örnek sayısı (denoiser açık)
  --debug DIR          bölge tablosu verisini (npz) ve .blend dosyasını DIR altına yaz

Çıktılar (--out altında):
  shade_NNN.webp  gri tonlu ışıklı görüntü, şeffaf arka plan
  id_NNN.png      kayıpsız gri PNG; kırmızı (=gri) kanal = bölge kimliği × 17,
                  0 = cilt, 1–14 bölge, 255 = boş. Kenar yumuşatması yok.
  manifest.json

Kare 000 ön görünümdür; açı yukarıdan bakınca saat yönünde artar (model -Z
ekseni etrafında döner, kamera ve ışıklar sabittir).
"""

import argparse
import heapq
import json
import math
import os
import struct
import sys
import tempfile
import zlib

import bpy
import numpy as np
from mathutils import Quaternion, Vector

from bl_ext.blender_org.mpfb.services import (
    HumanService,
    LocationService,
    TargetService,
)

HERE = os.path.dirname(os.path.abspath(__file__))
REGIONS = [
    "chest", "shoulders", "biceps", "triceps", "forearms", "abs", "obliques",
    "traps", "lats", "lower_back", "glutes", "quads", "hamstrings", "calves",
]
EMPTY_ID = 15  # 15 × 17 = 255


# ---------------------------------------------------------------------------
# Argümanlar
# ---------------------------------------------------------------------------

def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True)
    p.add_argument("--frames", type=int, default=72)
    p.add_argument("--only", default="")
    p.add_argument("--height", type=int, default=720)
    p.add_argument("--samples", type=int, default=48)
    p.add_argument("--regions", default=os.path.join(HERE, "regions.json"))
    p.add_argument("--debug", default="")
    p.add_argument("--no-shade", action="store_true")
    return p.parse_args(argv)


# ---------------------------------------------------------------------------
# 1. MPFB insanı
# ---------------------------------------------------------------------------

def make_human(cfg):
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o)
    body = cfg["body"]
    macro = TargetService.get_default_macro_info_dict()
    macro.update(body["macro"])
    macro["race"] = dict(body["race"])
    h = HumanService.create_human(macro_detail_dict=macro, feet_on_ground=True)

    targets = dict(body["targets"])
    for name, w in body["targets_lr"].items():
        targets["l-" + name] = w
        targets["r-" + name] = w
    for name, w in targets.items():
        path = TargetService.target_full_path(name)
        if not path:
            raise RuntimeError("MPFB hedefi bulunamadı: " + name)
        TargetService.load_target(h, path, weight=w)

    rig = HumanService.add_builtin_rig(h, "default", import_weights=True)
    TargetService.bake_targets(h)
    pose_rig(rig, body["pose"])
    bpy.context.view_layer.update()
    for m in list(h.modifiers):
        if m.type == 'ARMATURE':
            with bpy.context.temp_override(object=h, active_object=h):
                bpy.ops.object.modifier_apply(modifier=m.name)
        else:
            h.modifiers.remove(m)
    mw = h.matrix_world.copy()
    h.parent = None
    h.matrix_world = mw
    bpy.data.objects.remove(rig)

    # Eklem noktaları (kemik eksenleri için) ve gövde dışı yardımcıların silinmesi.
    vg = json.load(open(LocationService.get_mpfb_data(
        "mesh_metadata/basemesh_vertex_groups.json")))
    co = np.empty(len(h.data.vertices) * 3)
    h.data.vertices.foreach_get("co", co)
    co = co.reshape(-1, 3)
    joints = {}
    for k, rng in vg.items():
        if k.startswith("joint-"):
            a, b = rng[0]
            joints[k[6:]] = co[a:b + 1].mean(0)
    keep = np.zeros(len(co), bool)
    for g in ("body", "helper-l-eye", "helper-r-eye"):
        for a, b in vg[g]:
            keep[a:b + 1] = True
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(h.data)
    bm.verts.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not keep[v.index]], context='VERTS')
    bm.to_mesh(h.data)
    bm.free()
    bone_names = set(rig_bone_names())
    for g in list(h.vertex_groups):
        if g.name not in bone_names:
            h.vertex_groups.remove(g)
    return h, joints


def rig_bone_names():
    path = LocationService.get_mpfb_data("rigs/standard/weights.default.json")
    return json.load(open(path))["weights"].keys()


def pose_rig(rig, pose):
    """Kemikleri dünya eksenlerine göre döndürür (derece). Sol taraf +X'tir;
    sağ taraf için Y ve Z eksenli dönüşler aynalanır."""
    for entry in pose:
        for side, sgn in (("L", 1), ("R", -1)):
            name = entry["bone"] + "." + side
            pb = rig.pose.bones.get(name)
            if pb is None:
                raise RuntimeError("Kemik yok: " + name)
            ml = pb.bone.matrix_local.to_quaternion()
            q = Quaternion()
            for axis, deg in entry["rot"]:
                vec = {"X": (1, 0, 0), "Y": (0, 1, 0), "Z": (0, 0, 1)}[axis]
                s = 1 if axis == "X" else sgn
                q = Quaternion(vec, math.radians(deg * s)) @ q
            pb.rotation_mode = 'QUATERNION'
            pb.rotation_quaternion = ml.inverted() @ q @ ml
            bpy.context.view_layer.update()


def subdivide(h, levels):
    m = h.modifiers.new("sub", 'SUBSURF')
    m.levels = levels
    m.render_levels = levels
    with bpy.context.temp_override(object=h, active_object=h):
        bpy.ops.object.modifier_apply(modifier=m.name)


# ---------------------------------------------------------------------------
# 2. Bölgeler (regions.json)
# ---------------------------------------------------------------------------

def mesh_arrays(h):
    me = h.data
    nv, nf = len(me.vertices), len(me.polygons)
    co = np.empty(nv * 3)
    me.vertices.foreach_get("co", co)
    fc = np.empty(nf * 3)
    me.polygons.foreach_get("center", fc)
    fn = np.empty(nf * 3)
    me.polygons.foreach_get("normal", fn)
    loop_start = np.empty(nf, np.int64)
    me.polygons.foreach_get("loop_start", loop_start)
    loop_total = np.empty(nf, np.int64)
    me.polygons.foreach_get("loop_total", loop_total)
    lv = np.empty(len(me.loops), np.int64)
    me.loops.foreach_get("vertex_index", lv)
    ev = np.empty(len(me.edges) * 2, np.int64)
    me.edges.foreach_get("vertices", ev)
    return dict(co=co.reshape(-1, 3), fc=fc.reshape(-1, 3), fn=fn.reshape(-1, 3),
                ls=loop_start, lt=loop_total, lv=lv, ev=ev.reshape(-1, 2))


def segment_weights(h, segments):
    """Her köşe için segment ağırlıkları (kemik grubu ağırlıklarının toplamı)."""
    seg_names = list(segments.keys())
    gi_to_seg = {}
    for g in h.vertex_groups:
        base = g.name[:-2] if g.name[-2:] in (".L", ".R") else g.name
        for si, s in enumerate(seg_names):
            if base in segments[s]:
                gi_to_seg[g.index] = si
    nv = len(h.data.vertices)
    w = np.zeros((nv, len(seg_names)))
    for v in h.data.vertices:
        for g in v.groups:
            si = gi_to_seg.get(g.group)
            if si is not None:
                w[v.index, si] += g.weight
    return seg_names, w


def face_mean(arr_v, d):
    """Köşe değerlerinin yüz ortalaması (dörtgen/üçgen karışık)."""
    out = np.zeros((len(d["ls"]),) + arr_v.shape[1:])
    for k in range(4):
        idx = d["lv"][d["ls"] + np.minimum(k, d["lt"] - 1)]
        out += arr_v[idx]
    return out / 4.0


def points_in_poly(u, v, poly):
    poly = np.asarray(poly, float)
    inside = np.zeros(len(u), bool)
    j = len(poly) - 1
    for i in range(len(poly)):
        xi, yi = poly[i]
        xj, yj = poly[j]
        cond = ((yi > v) != (yj > v))
        with np.errstate(divide="ignore", invalid="ignore"):
            xint = (xj - xi) * (v - yi) / (yj - yi) + xi
        inside ^= cond & (u < xint)
        j = i
    return inside


def classify(h, joints, cfg, debug=None):
    d = mesh_arrays(h)
    seg_names, wv = segment_weights(h, cfg["segments"])
    wf = face_mean(wv, d)
    seg = np.where(wf.sum(1) > 1e-6, wf.argmax(1), -1)
    fc, fn = d["fc"], d["fn"]
    side = np.where(fc[:, 0] >= 0, 1.0, -1.0)
    p = fc * np.array([1, 1, 1]) * np.stack([side, np.ones_like(side), np.ones_like(side)], 1)
    n = fn * np.stack([side, np.ones_like(side), np.ones_like(side)], 1)

    def J(name):
        return np.asarray(joints["l-" + name] if ("l-" + name) in joints else joints[name])

    charts = {}
    # Gövde: dikey eksen etrafında açı (0 = ön orta, 90 = yan, 180 = sırt orta) ve yükseklik z.
    tc = cfg["torso_axis"]
    zs = np.array([k[0] for k in tc])
    ys = np.array([k[1] for k in tc])
    yc = np.interp(p[:, 2], zs, ys)
    ang = np.degrees(np.arctan2(p[:, 0], -(p[:, 1] - yc)))
    charts["torso"] = (ang, p[:, 2])
    # Uzuvlar: eksen etrafında açı (0 ön, +90 dış, ±180 arka, -90 iç) ve eksen boyunca t (0..1).
    # "front" verilirse ön yön, o iki eklem arasındaki vektörün eksene dik bileşenidir
    # (ör. üst kolda dirseğin büküldüğü yön = pazının baktığı yön).
    frames = {}
    for name, lim in cfg["limbs"].items():
        a, b = J(lim["from"]), J(lim["to"])
        ax = b - a
        L = np.linalg.norm(ax)
        ax = ax / L
        ref = np.array([0, -1.0, 0])
        if "front" in lim:
            ref = J(lim["front"][1]) - J(lim["front"][0])
        front = ref - ax * (ref @ ax)
        front /= np.linalg.norm(front)
        lat = np.cross(ax, front)
        if lat[0] < 0:
            lat = -lat
        frames[name] = (a, L, ax, front, lat)
        rel = p - a
        t = rel @ ax / L
        r = rel - np.outer(rel @ ax, ax)
        u = np.degrees(np.arctan2(r @ lat, r @ front))
        charts[name] = (u, t)

    region = np.zeros(len(fc), np.int64)
    part = np.zeros(len(fc), np.int64)
    done = np.zeros(len(fc), bool)
    part_ids = {}
    for rule in cfg["rules"]:
        rid = REGIONS.index(rule["region"]) + 1 if rule["region"] != "skin" else 0
        segs = [seg_names.index(s) for s in rule["segments"]]
        m = np.isin(seg, segs) & ~done
        if "chart" in rule:
            u, v = charts[rule["chart"]]
            m &= points_in_poly(u, v, rule["poly"])
        if "ellipsoid" in rule:
            e = rule["ellipsoid"]
            off = np.asarray(e.get("offset", [0, 0, 0]), float)
            if "limb" in e:
                _, _, ax, front, lat = frames[e["limb"]]
                basis = np.stack([lat, front, ax])  # yarıçaplar: dış, ön, eksen
                c = J(e["joint"]) + off @ basis
                q = ((p - c) @ basis.T) / np.asarray(e["radii"])
            else:
                c = J(e["joint"]) + off
                q = (p - c) / np.asarray(e["radii"])
            m &= (q * q).sum(1) <= 1.0
        if "torso_ang" in rule:
            lo, hi = rule["torso_ang"]
            m &= (ang >= lo) & (ang <= hi)
        if "normal_min" in rule:
            m &= (n @ np.asarray(rule["normal_min"][:3])) >= rule["normal_min"][3]
        key = (rid, rule.get("part", ""))
        part_ids.setdefault(key, len(part_ids) + 1)
        region[m] = rid
        part[m] = part_ids[key] if rid else 0
        done |= m
    # Sol/sağ ayrı kas sayılır (kabartma için).
    part = np.where(part > 0, part * 2 + (side > 0), 0)
    if debug:
        np.savez(os.path.join(debug, "faces.npz"), seg=seg, region=region, part=part,
                 p=p, n=n, **{f"chart_{k}_u": v[0] for k, v in charts.items()},
                 **{f"chart_{k}_v": v[1] for k, v in charts.items()},
                 seg_names=np.array(seg_names))
    return d, region, part


# ---------------------------------------------------------------------------
# 3. Kas kabartması: bölge/parça sınırlarına yumuşak oluk
# ---------------------------------------------------------------------------

def relief(h, d, part, region, cfg):
    rc = cfg["relief"]
    co = d["co"]
    nv = len(co)
    # Köşe etiketi: komşu yüzlerin etiketleri; farklıysa sınır köşesi.
    scale = np.array([rc["region_depth"].get(r, 1.0) for r in ["skin"] + REGIONS])
    vlab = np.full(nv, -1, np.int64)
    boundary = np.zeros(nv, bool)
    vscale = np.full(nv, np.inf)
    vskin = np.zeros(nv, bool)
    fscale = np.where(region > 0, scale[region], np.inf)
    for k in range(4):
        idx = d["lv"][d["ls"] + np.minimum(k, d["lt"] - 1)]
        first = vlab[idx] == -1
        vlab[idx[first]] = part[first]
        boundary[idx[~first & (vlab[idx] != part)]] = True
        np.minimum.at(vscale, idx, fscale)
        vskin[idx[region == 0]] = True
    vscale[~np.isfinite(vscale)] = 0.0
    # Oluk derinliği sınırda belirlenir: komşu kasların en küçük katsayısı; kas–cilt
    # sınırında ayrıca "skin_edge" ile çarpılır. Derinlik en yakın sınırdan taşınır.
    src_depth = rc["depth_m"] * vscale * np.where(vskin, rc["skin_edge"], 1.0)
    # Dijkstra: sınıra uzaklık (kenar uzunluğu ile).
    ev = d["ev"]
    elen = np.linalg.norm(co[ev[:, 0]] - co[ev[:, 1]], axis=1)
    adj = [[] for _ in range(nv)]
    for (a, b), l in zip(ev.tolist(), elen.tolist()):
        adj[a].append((b, l))
        adj[b].append((a, l))
    width = rc["width_m"]
    dl = [math.inf] * nv
    owner = list(range(nv))
    heap = []
    for v in np.nonzero(boundary)[0].tolist():
        dl[v] = 0.0
        heap.append((0.0, v))
    heapq.heapify(heap)
    while heap:
        dv, v = heapq.heappop(heap)
        if dv > dl[v] or dv > width:
            continue
        ov = owner[v]
        for w, l in adj[v]:
            nd = dv + l
            if nd < dl[w]:
                dl[w] = nd
                owner[w] = ov
                heapq.heappush(heap, (nd, w))
    dist = np.minimum(np.array(dl), width)
    x = dist / width
    s = x * x * (3 - 2 * x)
    depth = np.where(np.isfinite(np.array(dl)), src_depth[np.array(owner)], 0.0)
    off = -depth * (1.0 - s)
    # Biraz yumuşat (komşu ortalaması).
    for _ in range(rc["smooth"]):
        acc = np.zeros(nv)
        cnt = np.zeros(nv)
        np.add.at(acc, ev[:, 0], off[ev[:, 1]])
        np.add.at(acc, ev[:, 1], off[ev[:, 0]])
        np.add.at(cnt, ev[:, 0], 1)
        np.add.at(cnt, ev[:, 1], 1)
        off = 0.5 * off + 0.5 * acc / np.maximum(cnt, 1)
    vn = np.empty(nv * 3)
    h.data.vertex_normals.foreach_get("vector", vn)
    vn = vn.reshape(-1, 3)
    new = co + vn * off[:, None]
    h.data.vertices.foreach_set("co", new.ravel())
    h.data.update()


# ---------------------------------------------------------------------------
# 4. Sahne, ışık, kamera
# ---------------------------------------------------------------------------

def srgb_to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def setup_scene(h, region, cfg, height):
    sc = bpy.context.scene
    rcfg = cfg["render"]
    me = h.data

    stone = bpy.data.materials.new("stone")
    stone.use_nodes = True
    nt = stone.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    ao = nt.nodes.new("ShaderNodeAmbientOcclusion")
    ao.inputs["Distance"].default_value = rcfg["ao_distance"]
    ao.samples = 16
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = 'RGBA'
    mix.inputs[6].default_value = (*[rcfg["albedo_occluded"]] * 3, 1)
    mix.inputs[7].default_value = (*[rcfg["albedo"]] * 3, 1)
    nt.links.new(ao.outputs["AO"], mix.inputs[0])
    nt.links.new(mix.outputs[2], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rcfg["roughness"]
    stone_mats = [stone] * (EMPTY_ID)
    id_mats = []
    for i in range(EMPTY_ID):
        m = bpy.data.materials.new(f"id_{i:02d}")
        g = srgb_to_linear(i * 17 / 255.0)
        m.diffuse_color = (g, g, g, 1.0)
        id_mats.append(m)
    me.materials.clear()
    for m in stone_mats:
        me.materials.append(m)
    # Malzeme listesi değişince indeksler sıfırlanabilir; en son yazılır.
    me.polygons.foreach_set("material_index", region.astype(np.int32))
    me.polygons.foreach_set("use_smooth", np.ones(len(me.polygons), bool))
    me.update()

    sub = h.modifiers.new("sub", 'SUBSURF')
    sub.levels = sub.render_levels = rcfg["render_subdiv"]

    # Dönüş ekseni: gövdenin ortası.
    piv = bpy.data.objects.new("pivot", None)
    sc.collection.objects.link(piv)
    piv.location = (0.0, rcfg["pivot_y"], 0.0)
    mw = h.matrix_world.copy()
    h.parent = piv
    h.matrix_parent_inverse = piv.matrix_world.inverted()
    h.matrix_world = mw

    H = h.dimensions.z
    cam = bpy.data.cameras.new("cam")
    cam.lens = rcfg["lens_mm"]
    cam.sensor_fit = 'VERTICAL'
    cam.sensor_height = 24.0
    co = bpy.data.objects.new("cam", cam)
    sc.collection.objects.link(co)
    sc.camera = co
    vfov = 2 * math.atan(12.0 / cam.lens)
    dist = (H * rcfg["frame_margin"]) / (2 * math.tan(vfov / 2))
    zc = H * 0.5
    co.location = (0.0, rcfg["pivot_y"] - dist, zc)
    co.rotation_euler = (math.radians(90), 0, 0)

    target = Vector((0, rcfg["pivot_y"], H * 0.55))
    for L in rcfg["lights"]:
        ld = bpy.data.lights.new(L["name"], 'AREA')
        ld.energy = L["energy"]
        ld.size = L["size"]
        ld.shape = 'DISK'
        lo = bpy.data.objects.new(L["name"], ld)
        sc.collection.objects.link(lo)
        lo.location = Vector(L["loc"]) + Vector((0, rcfg["pivot_y"], 0))
        lo.rotation_euler = (target - lo.location).to_track_quat('-Z', 'Y').to_euler()
    w = bpy.data.worlds.new("w")
    sc.world = w
    w.use_nodes = True
    w.node_tree.nodes["Background"].inputs[0].default_value = (*[rcfg["world"]] * 3, 1)

    width = int(round(height * rcfg["aspect"] / 2)) * 2
    sc.render.resolution_x = width
    sc.render.resolution_y = height
    sc.render.resolution_percentage = 100
    sc.render.film_transparent = True
    sc.render.dither_intensity = 0.0
    return piv, stone_mats, id_mats, width


def use_cycles(samples, look, exposure):
    sc = bpy.context.scene
    sc.render.engine = 'CYCLES'
    sc.cycles.samples = samples
    sc.cycles.use_adaptive_sampling = True
    sc.cycles.use_denoising = True
    sc.cycles.denoiser = 'OPENIMAGEDENOISE'
    sc.cycles.max_bounces = 4
    try:
        prefs = bpy.context.preferences.addons['cycles'].preferences
        for kind in ('OPTIX', 'CUDA'):
            try:
                prefs.compute_device_type = kind
                prefs.get_devices()
                if any(dv.type == kind for dv in prefs.devices):
                    for dv in prefs.devices:
                        dv.use = dv.type == kind
                    sc.cycles.device = 'GPU'
                    break
            except TypeError:
                continue
    except KeyError:
        pass
    sc.view_settings.view_transform = 'AgX'
    sc.view_settings.look = look
    sc.view_settings.exposure = exposure
    im = sc.render.image_settings
    im.file_format = 'PNG'
    im.color_mode = 'RGBA'
    im.color_depth = '8'


def use_workbench():
    sc = bpy.context.scene
    sc.render.engine = 'BLENDER_WORKBENCH'
    sh = sc.display.shading
    sh.light = 'FLAT'
    sh.color_type = 'MATERIAL'
    sh.show_cavity = False
    sh.show_shadows = False
    sh.show_object_outline = False
    sh.show_specular_highlight = False
    sh.show_xray = False
    sc.display.render_aa = 'OFF'
    sc.view_settings.view_transform = 'Standard'
    sc.view_settings.look = 'None'
    sc.view_settings.exposure = 0.0
    sc.view_settings.gamma = 1.0
    im = sc.render.image_settings
    im.file_format = 'PNG'
    im.color_mode = 'RGBA'
    im.color_depth = '8'


# ---------------------------------------------------------------------------
# 5. Dosya yazımı
# ---------------------------------------------------------------------------

def load_pixels(path):
    img = bpy.data.images.load(path)
    img.colorspace_settings.name = 'Non-Color'
    w, hgt = img.size
    px = np.empty(w * hgt * 4, np.float32)
    img.pixels.foreach_get(px)
    bpy.data.images.remove(img)
    return np.flipud(px.reshape(hgt, w, 4))


def write_gray_png(path, arr):
    hgt, w = arr.shape
    raw = b"".join(b"\x00" + arr[y].astype(np.uint8).tobytes() for y in range(hgt))

    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, hgt, 8, 0, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def id_from_render(path):
    px = load_pixels(path)
    g = np.round(px[..., 0] * 255.0)
    ids = np.clip(np.round(g / 17.0), 0, 14).astype(np.int64)
    ids[px[..., 3] < 0.5] = EMPTY_ID
    return (ids * 17).astype(np.uint8)


def to_webp(png_path, out_path, quality):
    img = bpy.data.images.load(png_path)
    sc = bpy.context.scene
    im = sc.render.image_settings
    im.file_format = 'WEBP'
    im.color_mode = 'RGBA'
    im.quality = quality
    img.save_render(out_path, scene=sc)
    bpy.data.images.remove(img)
    im.file_format = 'PNG'


# ---------------------------------------------------------------------------

def main():
    args = parse_args()
    cfg = json.load(open(args.regions))
    os.makedirs(args.out, exist_ok=True)
    if args.debug:
        os.makedirs(args.debug, exist_ok=True)
    frames = list(range(args.frames))
    if args.only:
        frames = [int(x) for x in args.only.split(",")]
    step = 360.0 / args.frames

    h, joints = make_human(cfg)
    subdivide(h, cfg["relief"]["subdiv"])
    d, region, part = classify(h, joints, cfg, args.debug or None)
    relief(h, d, part, region, cfg)
    for g in list(h.vertex_groups):
        h.vertex_groups.remove(g)
    piv, stone_mats, id_mats, width = setup_scene(h, region, cfg, args.height)
    if args.debug:
        bpy.ops.wm.save_as_mainfile(filepath=os.path.join(os.path.abspath(args.debug), "body.blend"))
    sc = bpy.context.scene
    tmp_dir = tempfile.TemporaryDirectory(prefix="bodymap_")
    tmp = tmp_dir.name

    if not args.no_shade:
        use_cycles(args.samples, cfg["render"]["look"], cfg["render"]["exposure"])
        for f in frames:
            piv.rotation_euler.z = -math.radians(f * step)
            sc.render.filepath = os.path.join(tmp, f"shade_{f:03d}.png")
            bpy.ops.render.render(write_still=True)
        for f in frames:
            to_webp(os.path.join(tmp, f"shade_{f:03d}.png"),
                    os.path.join(args.out, f"shade_{f:03d}.webp"), cfg["render"]["webp_quality"])

    for i, m in enumerate(id_mats):
        h.data.materials[i] = m
    use_workbench()
    for f in frames:
        piv.rotation_euler.z = -math.radians(f * step)
        p = os.path.join(tmp, f"id_{f:03d}.png")
        sc.render.filepath = p
        bpy.ops.render.render(write_still=True)
        write_gray_png(os.path.join(args.out, f"id_{f:03d}.png"), id_from_render(p))

    if not args.only:
        manifest = {
            "frames": args.frames,
            "stepDegrees": int(step) if step == int(step) else step,
            "width": width,
            "height": args.height,
            "regions": REGIONS,
            "attribution": "MakeHuman / MPFB (CC0)",
        }
        with open(os.path.join(args.out, "manifest.json"), "w") as fh:
            json.dump(manifest, fh, indent=2)
            fh.write("\n")
    tmp_dir.cleanup()
    print("BODY_MAP_DONE", len(frames), "kare", width, "x", args.height)


main()
