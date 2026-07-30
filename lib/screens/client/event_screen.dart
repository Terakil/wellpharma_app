import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Événements"),
      ),
      body: const Center(
        child: Text("Aucun événement pour le moment."),
      ),
    );
  }
}
