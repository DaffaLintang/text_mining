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
    int parsePercent(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) {
        final n = num.tryParse(v);
        return n == null ? 0 : n.round();
      }
      return 0;
    }

    DateTime parseTs(dynamic v) {
      if (v is String) {
        try { return DateTime.parse(v); } catch (_) {}
      }
      if (v is int) {
        // seconds vs millis heuristic
        if (v > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(v);
        } else if (v > 1000000000) {
          return DateTime.fromMillisecondsSinceEpoch(v * 1000);
        }
      }
      if (v is double) {
        final iv = v.toInt();
        if (iv > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(iv);
        } else if (iv > 1000000000) {
          return DateTime.fromMillisecondsSinceEpoch(iv * 1000);
        }
      }
      return DateTime.now();
    }

    AnalysisResult? parseResult(dynamic v) {
      if (v is Map<String, dynamic>) {
        // Only parse when expected fields exist
        if (v.containsKey('category') && v.containsKey('category_encoded') && v.containsKey('count') && v.containsKey('items')) {
          try { return AnalysisResult.fromJson(v); } catch (_) {}
        }
      }
      return null;
    }

    return AnalysisProgress(
      status: (json['status'] ?? '').toString(),
      percent: parsePercent(json['percent']),
      message: (json['message'] ?? '').toString(),
      ts: parseTs(json['ts']),
      result: parseResult(json['result']),
    );
  }
}

class AnalysisResult {
  final String category;
  final int categoryEncoded;
  final int count;
  final String productName;
  final List<AnalysisItem> items;

  AnalysisResult({
    required this.category,
    required this.categoryEncoded,
    required this.count,
    required this.productName,
    required this.items,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      category: json['category'],
      categoryEncoded: json['category_encoded'],
      count: json['count'],
      productName: json['product_name'],
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
