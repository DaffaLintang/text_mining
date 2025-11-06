class AnalysisProgress {
  final String status;
  final int percent;
  final String message;
  final DateTime ts;
  final AnalysisResult? result;

  AnalysisProgress({
    required this.status,
    required this.percent,
    required this.message,
    required this.ts,
    this.result,
  });

  factory AnalysisProgress.fromJson(Map<String, dynamic> json) {
    return AnalysisProgress(
      status: json['status'],
      percent: json['percent'],
      message: json['message'],
      ts: DateTime.parse(json['ts']),
      result: json['result'] != null
          ? AnalysisResult.fromJson(json['result'])
          : null,
    );
  }
}

class AnalysisResult {
  final String category;
  final int categoryEncoded;
  final int count;
  final List<AnalysisItem> items;

  AnalysisResult({
    required this.category,
    required this.categoryEncoded,
    required this.count,
    required this.items,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      category: json['category'],
      categoryEncoded: json['category_encoded'],
      count: json['count'],
      items: (json['items'] as List)
          .map((item) => AnalysisItem.fromJson(item))
          .toList(),
    );
  }
}

class AnalysisItem {
  final String sentiment;
  final String review;

  AnalysisItem({
    required this.sentiment,
    required this.review,
  });

  factory AnalysisItem.fromJson(Map<String, dynamic> json) {
    return AnalysisItem(
      sentiment: json['sentiment'],
      review: json['review'],
    );
  }
}
