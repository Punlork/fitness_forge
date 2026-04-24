import 'package:flutter/material.dart';

class RepLogForm extends StatefulWidget {
  final int targetReps;
  final ValueChanged<int> onLog;

  const RepLogForm({
    super.key,
    required this.targetReps,
    required this.onLog,
  });

  @override
  State<RepLogForm> createState() => RepLogFormState();
}

class RepLogFormState extends State<RepLogForm> {
  late int _reps;

  @override
  void initState() {
    super.initState();
    _reps = widget.targetReps;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: () =>
                  setState(() => _reps = (_reps - 1).clamp(1, 999)),
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 24),
            Text(
              '$_reps',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 24),
            IconButton.filledTonal(
              onPressed: () => setState(() => _reps++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => widget.onLog(_reps),
            child: const Text('Log Set'),
          ),
        ),
      ],
    );
  }
}
