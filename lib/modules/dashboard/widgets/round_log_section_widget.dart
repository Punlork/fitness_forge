import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/models/round_model.dart';
import 'package:forge/modules/home/bloc/home_bloc.dart';

import 'round_card_widget.dart';

class RoundLogSection extends StatelessWidget {
  final HomeReady state;

  const RoundLogSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final rounds = _buildRoundList(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rounds',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...rounds.map(
          (round) => RoundCard(
            round: round,
            state: state,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAddRoundDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Round'),
          ),
        ),
      ],
    );
  }

  List<RoundData> _buildRoundList(HomeReady state) {
    final maxRound = state.computedRound;
    if (maxRound == 0) return const [];

    return List.generate(
      maxRound,
      (i) {
        final roundNum = i + 1;

        final hasCardio = state.intervals.any(
          (interval) => interval.roundNumber == roundNum,
        );
        final workLogs = state.strengthSets
            .where((set) => set.roundNumber == roundNum)
            .toList();

        return RoundData(
          roundNumber: roundNum,
          hasCardio: hasCardio,
          workLogs: workLogs,
        );
      },
    ).reversed.toList();
  }

  void _showAddRoundDialog(BuildContext context) {
    final nextRound = state.computedRound + 1;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Round $nextRound?'),
        content: const Text(
          'Log a new round when you finish a full cycle of cardio + work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<HomeBloc>().add(const AddRoundEvent());
              Navigator.of(ctx).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
