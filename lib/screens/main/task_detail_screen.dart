import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details',
            style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: colorScheme.outline, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Execution Date: ${DateFormat('dd/MM/yyyy').format(task.executionDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (task.repeat)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.repeat, color: colorScheme.outline, size: 16),
                    const SizedBox(width: 8),
                    Text('Repeats: Yes',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
