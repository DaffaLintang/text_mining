import 'package:flutter/material.dart';
import 'package:sen_pt/app/modules/resultPage/controllers/result_page_controller.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({
    super.key,
    required this.itemCount,
    required this.productName,
    required this.comments,
    required this.sentimen,
    required this.jobId,
    required this.filename,
    required this.resultPageController,
  });

  final int itemCount;
  final String productName;
  final List<String> comments;
  final List<String> sentimen;
  final ResultPageController resultPageController;
  final String jobId;
  final String filename;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Hasil Analisis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    resultPageController.downloadPdf('$jobId', '$filename');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product name
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                productName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  height: 1.3,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFFF0F0F5), height: 20),
          ),

          // Comment list
          SizedBox(
            height: 400,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final isPositif = sentimen[index] == 'Positif';
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isPositif
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFFF5F5),
                    border: Border.all(
                      color: isPositif
                          ? const Color(0xFF22C55E).withAlpha(60)
                          : const Color(0xFFEF4444).withAlpha(60),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPositif
                              ? const Color(0xFF22C55E).withAlpha(30)
                              : const Color(0xFFEF4444).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPositif
                              ? Icons.sentiment_satisfied_alt_rounded
                              : Icons.sentiment_dissatisfied_rounded,
                          color: isPositif
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          comments[index],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D2D3A),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPositif
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          sentimen[index],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
