class AnalysisProgress {
  final String status;
  final int percent;
  final String message;
  final DateTime ts;
  final AnalysisResult? result;
  final Resume resume;

  AnalysisProgress({
    required this.status,
    required this.percent,
    required this.message,
    required this.ts,
    this.result,
    required this.resume,
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

    Resume parseResume(Map<String, dynamic> jsonRoot) {
      // Prefer result.summary (current backend), fallback to resume (older/alternate clients)
      final dynamic resultObj = jsonRoot['result'];
      if (resultObj is Map<String, dynamic>) {
        final dynamic summaryObj = resultObj['summary'];
        if (summaryObj is Map<String, dynamic>) {
          try { return Resume.fromJson(summaryObj); } catch (_) {}
        }
      }
      final dynamic resumeObj = jsonRoot['resume'];
      if (resumeObj is Map<String, dynamic>) {
        try { return Resume.fromJson(resumeObj); } catch (_) {}
      }
      return const Resume.empty();
    }

    return AnalysisProgress(
      status: (json['status'] ?? '').toString(),
      percent: parsePercent(json['percent']),
      message: (json['message'] ?? '').toString(),
      ts: parseTs(json['ts']),
      result: parseResult(json['result']),
      resume: parseResume(json),
    );
  }
}

class Resume {
  final String dominantSentiment;
  final int positif;
  final int negatif;
  final List<String> topPhrasesPositif;
  final List<String> topPhrasesNegatif;

  int get total => positif + negatif;

  const Resume({
    required this.dominantSentiment,
    required this.positif,
    required this.negatif,
    required this.topPhrasesPositif,
    required this.topPhrasesNegatif,
  });

  const Resume.empty()
      : dominantSentiment = '',
        positif = 0,
        negatif = 0,
        topPhrasesPositif = const [],
        topPhrasesNegatif = const [];

  factory Resume.fromJson(Map<String, dynamic> json) {
    final counts = (json['counts'] is Map) ? (json['counts'] as Map) : const {};
    final topPhrases = (json['top_phrases'] is Map) ? (json['top_phrases'] as Map) : const {};

    int _asInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) {
        final n = int.tryParse(v);
        return n ?? 0;
      }
      return 0;
    }

    List<String> _asStringList(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return Resume(
      dominantSentiment: (json['dominant_sentiment'] ?? '').toString(),
      positif: _asInt(counts['Positif']),
      negatif: _asInt(counts['Negatif']),
      topPhrasesPositif: _asStringList(topPhrases['Positif']),
      topPhrasesNegatif: _asStringList(topPhrases['Negatif']),
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
