import 'package:flutter/material.dart';

class LevelSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const LevelSelector({required this.selected, required this.onSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Select level',
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'Junior', child: Text('Junior')),
        PopupMenuItem(value: 'Mid', child: Text('Mid')),
        PopupMenuItem(value: 'Senior', child: Text('Senior')),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selected!,
                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
