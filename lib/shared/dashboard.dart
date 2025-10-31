import 'package:flutter/material.dart';

Widget buildDashboardBody({
  required bool isLoading,
  required String? errorText,
  required Future<void> Function() onRefresh,
  required VoidCallback onRetry,
  required int available,
  required int borrowed,
  required int disabled,
  required int pending,
}) {
  const background = Color(0xFF1F1F1F);
  const accent = Color(0xFFD4FF00);
  const availableColor = Color(0xFFB9FF66);
  const borrowingColor = Color(0xFF7AD8FF);
  const disabledColor = Color(0xFF6C6C70);
  const pendingColor = Color(0xFFFFFF99);

  if (isLoading) {
    return Center(
      child: CircularProgressIndicator(color: accent),
    );
  }

  if (errorText != null) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error: $errorText',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    color: accent,
    backgroundColor: background,
    onRefresh: onRefresh,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            buildChartBar('Available', available, availableColor),
            const SizedBox(width: 12),
            buildChartBar('Borrowing', borrowed, borrowingColor),
            const SizedBox(width: 12),
            buildChartBar('Pending', pending, pendingColor),
            const SizedBox(width: 12),
            buildChartBar('Disabled', disabled, disabledColor),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              buildStatCard('Available', available, availableColor),
              buildStatCard('Borrowed', borrowed, borrowingColor),
              buildStatCard('Pending', pending, pendingColor),
              buildStatCard('Disabled', disabled, disabledColor),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildChartBar(String label, int value, Color color) {
  final height = value.clamp(0, 30) * 6.0 + 12;
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
  );
}

Widget buildStatCard(String label, int value, Color color) {
  return Container(
    width: 150,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF2B2B2E),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
