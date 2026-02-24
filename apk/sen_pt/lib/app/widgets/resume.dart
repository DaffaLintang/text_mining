import 'package:flutter/material.dart';

class ResumeWidget extends StatelessWidget {
  ResumeWidget({
    super.key,
    List<dynamic>? positif,
    List<dynamic>? negatif,
    List<String>? topPhrasesPositif,
    List<String>? topPhrasesNegatif,
  })  : topPhrasesPositif = topPhrasesPositif ?? positif?.map((e) => e.toString()).toList() ?? const [],
        topPhrasesNegatif = topPhrasesNegatif ?? negatif?.map((e) => e.toString()).toList() ?? const [];

  final List<String> topPhrasesPositif;
  final List<String> topPhrasesNegatif;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Color(0xffF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Phrases Positif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[800])),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: topPhrasesPositif.take(6).map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(p, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text('Top Phrases Negatif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[800])),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: topPhrasesNegatif.take(6).map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(30),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(p, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}