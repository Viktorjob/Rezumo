import 'package:flutter/material.dart';

class ConversionStatusIndicator extends StatelessWidget {
  final bool isLoading;
  final String? error;

  const ConversionStatusIndicator({required this.isLoading, this.error, super.key});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text('Conversion in progress...'),
        ],
      );
    }

    if (error != null) {
      return Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text('Error:', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
