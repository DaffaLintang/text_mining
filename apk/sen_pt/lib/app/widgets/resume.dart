import 'package:flutter/material.dart';

class ResumeWidget extends StatelessWidget {
  ResumeWidget({
    super.key,
    List<dynamic>? positif,
    List<dynamic>? negatif,
    List<String>? topPhrasesPositif,
    List<String>? topPhrasesNegatif,
  }) : topPhrasesPositif =
           topPhrasesPositif ??
           positif?.map((e) => e.toString()).toList() ??
           const [],
       topPhrasesNegatif =
           topPhrasesNegatif ??
           negatif?.map((e) => e.toString()).toList() ??
           const [];

  final List<String> topPhrasesPositif;
  final List<String> topPhrasesNegatif;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Top Phrases',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Positif
          _PhraseSection(
            title: 'Positif',
            phrases: topPhrasesPositif.take(6).toList(),
            chipColor: const Color(0xFF22C55E),
            chipBg: const Color(0xFFDCFCE7),
            titleColor: const Color(0xFF15803D),
            icon: Icons.thumb_up_alt_rounded,
          ),

          const SizedBox(height: 14),

          // Negatif
          _PhraseSection(
            title: 'Negatif',
            phrases: topPhrasesNegatif.take(6).toList(),
            chipColor: const Color(0xFFEF4444),
            chipBg: const Color(0xFFFFE4E4),
            titleColor: const Color(0xFFB91C1C),
            icon: Icons.thumb_down_alt_rounded,
          ),
        ],
      ),
    );
  }
}

class _PhraseSection extends StatelessWidget {
  final String title;
  final List<String> phrases;
  final Color chipColor;
  final Color chipBg;
  final Color titleColor;
  final IconData icon;

  const _PhraseSection({
    required this.title,
    required this.phrases,
    required this.chipColor,
    required this.chipBg,
    required this.titleColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: chipColor, size: 15),
            const SizedBox(width: 6),
            Text(
              'Top Phrases $title',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: titleColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: phrases.map((p) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: chipColor.withAlpha(60), width: 1),
              ),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 12,
                  color: chipColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
