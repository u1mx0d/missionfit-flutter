#!/usr/bin/env bash
# assets/icon/icon.svg (özgün nokta-matris "M") ve türevlerini üretir; rsvg-convert gerekir.
# Kullanım: tool/gen_icons.sh && dart run flutter_launcher_icons
set -euo pipefail
cd "$(dirname "$0")/../assets/icon"

# mark <pitch> <radius> <cx> <fill> <accent>: 5x5 ızgarada "M"; ortadaki nokta vurgu rengindedir.
mark() {
  local pitch=$1 r=$2 c=$3 fill=$4 accent=$5
  local x0=$(( c - 2 * pitch ))
  local cells="0,0 0,1 0,2 0,3 0,4 4,0 4,1 4,2 4,3 4,4 1,1 3,1 2,2"
  for cell in $cells; do
    local col=${cell%,*} row=${cell#*,}
    local color=$fill
    [ "$cell" = "2,2" ] && color=$accent
    echo "  <circle cx=\"$(( x0 + col * pitch ))\" cy=\"$(( x0 + row * pitch ))\" r=\"$r\" fill=\"$color\"/>"
  done
}

svg() { # <size> <body>
  printf '<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s" viewBox="0 0 %s %s">\n%s\n</svg>\n' "$1" "$1" "$1" "$1" "$2"
}

# Tam ikon: koyu zemin üstünde büyük işaret.
svg 1024 "  <rect width=\"1024\" height=\"1024\" fill=\"#0B0B0B\"/>
$(mark 140 52 512 '#F5F5F5' '#D71921')" > icon.svg
# Adaptive ön plan: şeffaf zemin; flutter_launcher_icons %16 iç boşluk ekler, bu yüzden işaret tuvali doldurur (kenar 710, daire içinde kalır).
svg 1024 "$(mark 150 55 512 '#F5F5F5' '#D71921')" > icon_fg.svg
# Android 13 tema ikonu: tek renk.
svg 1024 "$(mark 150 55 512 '#FFFFFF' '#FFFFFF')" > icon_mono.svg
# Bildirim küçük ikonu: beyaz, şeffaf.
svg 96 "$(mark 18 7 48 '#FFFFFF' '#FFFFFF')" > notification.svg

rsvg-convert -w 1024 -h 1024 icon.svg -o icon.png
rsvg-convert -w 1024 -h 1024 icon_fg.svg -o icon_fg.png
rsvg-convert -w 1024 -h 1024 icon_mono.svg -o icon_mono.png
rsvg-convert -w 96 -h 96 notification.svg -o notification.png
mkdir -p ../../android/app/src/main/res/drawable
cp notification.png ../../android/app/src/main/res/drawable/ic_notification.png
