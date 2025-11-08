class AnalysisJob {
  final String jobId;
  final String progressUrl;
  final String streamUrl;

  AnalysisJob({
    required this.jobId,
    required this.progressUrl,
    required this.streamUrl,
  });

  factory AnalysisJob.fromJson(Map<String, dynamic> json) {
    return AnalysisJob(
      jobId: json['job_id'] ?? '',
      progressUrl: json['progress_url'] ?? '',
      streamUrl: json['stream_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'job_id': jobId,
        'progress_url': progressUrl,
        'stream_url': streamUrl,
      };

  AnalysisJob copyWith({
    String? jobId,
    String? progressUrl,
    String? streamUrl,
  }) {
    return AnalysisJob(
      jobId: jobId ?? this.jobId,
      progressUrl: progressUrl ?? this.progressUrl,
      streamUrl: streamUrl ?? this.streamUrl,
    );
  }

  @override
  String toString() =>
      'AnalysisJob(jobId: $jobId, progressUrl: $progressUrl, streamUrl: $streamUrl)';
}
