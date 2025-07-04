import 'package:flutter/material.dart';


class Hello extends StatelessWidget {
  const Hello({super.key});

  @override
  Widget build(BuildContext context) {
    print("Hello");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle categories'),
      ),
      body: const Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
