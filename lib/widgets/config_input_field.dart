// lib/widgets/config_input_field.dart
import 'package:flutter/material.dart';
import '../main.dart';

class ConfigInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final String unit;
  final String? description;

  const ConfigInputField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.unit,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixText: unit,
          ),
          keyboardType: TextInputType.number,
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              description!,
              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ),
      ],
    );
  }
}