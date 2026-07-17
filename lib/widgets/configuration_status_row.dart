import 'package:flutter/material.dart';

class ConfigurationStatusRow extends StatelessWidget {
  const ConfigurationStatusRow({
    required this.label,
    required this.status,
    required this.isValid,
    super.key,
  });

  final String label;
  final String status;
  final bool isValid;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_outline : Icons.error_outline,
          size: 20,
          color: isValid
              ? const Color(0xFF80C56A)
              : Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            status,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
