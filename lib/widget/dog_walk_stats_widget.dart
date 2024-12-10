import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  final Map<DateTime, int> walkStats;

  const StatsWidget({super.key, required this.walkStats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: walkStats.entries
          .map(
            (entry) => ListTile(
          title: Text(
            "${entry.key.toLocal()}".split(' ')[0],
            style: const TextStyle(fontSize: 16),
          ),
          trailing: Text(
            "${entry.value}회",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      )
          .toList(),
    );
  }
}
