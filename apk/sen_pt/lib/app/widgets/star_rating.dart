import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  const StarRatingWidget({
    Key? key,
    required this.star5,
    required this.star4,
    required this.star3,
    required this.star2,
    required this.star1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = star5 + star4 + star3 + star2 + star1;
    if (total == 0) total = 1; // prevent division by zero

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Bintang',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildRow(5, star5, total),
          const SizedBox(height: 8),
          _buildRow(4, star4, total),
          const SizedBox(height: 8),
          _buildRow(3, star3, total),
          const SizedBox(height: 8),
          _buildRow(2, star2, total),
          const SizedBox(height: 8),
          _buildRow(1, star1, total),
        ],
      ),
    );
  }

  Widget _buildRow(int stars, int count, int total) {
    double pct = count / total;
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$stars',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 2),
            Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade200,
              color: Colors.amber,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
