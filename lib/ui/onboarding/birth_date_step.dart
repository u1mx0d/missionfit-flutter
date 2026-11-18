import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import 'onboarding_widgets.dart';

class BirthDateStep extends StatelessWidget {
  const BirthDateStep({
    required this.day,
    required this.month,
    required this.year,
    required this.error,
    required this.onChanged,
    super.key,
  });
  final TextEditingController day;
  final TextEditingController month;
  final TextEditingController year;
  final String? error;
  final VoidCallback onChanged;

  Widget _field(String key, String label, TextEditingController c, int max, int flex) => Expanded(
    flex: flex,
    child: TextField(
      key: Key(key),
      controller: c,
      keyboardType: TextInputType.number,
      maxLength: max,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(labelText: label, counterText: ''),
    ),
  );

  @override
  Widget build(BuildContext context) => StepShell(
    title: 'Doğum tarihin',
    subtitle: 'Kalori hedefini hesaplamak için kullanılır.',
    children: [
      Row(
        children: [
          _field('birth-day', 'GG', day, 2, 10),
          const SizedBox(width: 8),
          _field('birth-month', 'AA', month, 2, 10),
          const SizedBox(width: 8),
          _field('birth-year', 'YYYY', year, 4, 16),
        ],
      ),
      if (error != null)
        StepError(error)
      else
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Yalnızca doğum yılın saklanır; tam tarih 18 yaş kontrolü için kullanılır.',
            style: TextStyle(color: mf(context).textMuted, fontSize: 13),
          ),
        ),
    ],
  );
}
