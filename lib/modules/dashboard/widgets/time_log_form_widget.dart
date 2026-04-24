import 'package:flutter/material.dart';

class TimedLogForm extends StatefulWidget {
  final int targetDuration;
  final ValueChanged<int> onLog;

  const TimedLogForm({
    super.key,
    required this.targetDuration,
    required this.onLog,
  });

  @override
  State<TimedLogForm> createState() => _TimedLogFormState();
}

class _TimedLogFormState extends State<TimedLogForm> {
  late int _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.targetDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: () => setState(
                () => _duration = (_duration - 5).clamp(5, 300),
              ),
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 24),
            Text(
              '${_duration}s',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 24),
            IconButton.filledTonal(
              onPressed: () => setState(
                () => _duration = (_duration + 5).clamp(5, 300),
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => widget.onLog(_duration),
            child: const Text('Log Duration'),
          ),
        ),
      ],
    );
  }
}
