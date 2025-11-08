import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:sen_pt/app/data/ApiVar.dart';
import 'package:sen_pt/app/data/models/analysis_models.dart';
import 'package:sen_pt/app/data/models/inputLink_models.dart';


class AnalysisProvider extends GetConnect {

  // Buat job baru
  Future<AnalysisJob?> createJob(Map<String, dynamic> payload) async {
    final response = await post(analyzeUrl, payload);

    if (response.status.hasError) {
      print('Error: ${response.body}');
      return null;
    }

    return AnalysisJob.fromJson(response.body);
  }

  // Dapatkan progress
  Stream<AnalysisProgress> getProgress(String jobId) {
    final controller = StreamController<AnalysisProgress>.broadcast();

    bool canceled = false;
    String? lastKey;
    void emitOnce(AnalysisProgress p) {
      // Include result signature in the dedupe key to differentiate
      // between an earlier terminal tick without result and a later
      // terminal tick that includes the final result payload.
      final resultSig = (p.result == null)
          ? 'nores'
          : 'res:${p.result!.count}:${p.result!.categoryEncoded}:${p.result!.category}';
      final key = '${p.ts.toIso8601String()}|${p.percent}|${p.message}|$resultSig';
      if (key == lastKey) return;
      lastKey = key;
      controller.add(p);
    }

    controller.onCancel = () {
      canceled = true;
    };

    Future<void> connect({int attempt = 0}) async {
      if (canceled) return;
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$progressUrl/$jobId'));
        request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
        final response = await request.close();

        final buffer = StringBuffer();
        final dataEvent = StringBuffer();

        void processBuffer() {
          final text = buffer.toString();
          final lines = text.split('\n');
          final lastComplete = text.endsWith('\n');
          buffer.clear();

          for (var i = 0; i < lines.length; i++) {
            final line = lines[i].trimRight();
            final isLast = i == lines.length - 1;
            if (isLast && !lastComplete) {
              buffer.write(line);
              break;
            }

            if (line.isEmpty) {
              if (dataEvent.isNotEmpty) {
                final payload = dataEvent.toString();
                dataEvent.clear();
                try {
                  print('SSE payload: $payload');
                  final map = jsonDecode(payload) as Map<String, dynamic>;
                  final progress = AnalysisProgress.fromJson(map);
                  print('Parsed progress: ${progress.percent} - ${progress.message}');
                  emitOnce(progress);
                  // Stop reconnecting on terminal states
                  final st = progress.status.toLowerCase();
                  if (progress.percent >= 100 || st == 'completed' || st == 'failed') {
                    canceled = true;
                  }
                } catch (e) {
                  print('SSE parse error: $e');
                }
              }
              continue;
            }

            if (line.startsWith('data:')) {
              final content = line.substring(5).trimLeft();
              if (dataEvent.isNotEmpty) dataEvent.write('\n');
              dataEvent.write(content);
            } else {
              if (dataEvent.isNotEmpty) dataEvent.write('\n');
              dataEvent.write(line);
            }
          }
        }

        late StreamSubscription<List<int>> sub;
        sub = response.listen((chunk) {
          buffer.write(utf8.decode(chunk, allowMalformed: true));
          processBuffer();
        }, onError: (e, st) async {
          print('SSE error: $e');
          await sub.cancel();
          if (!canceled) {
            final delay = Duration(milliseconds: (1000 * (1 << (attempt > 5 ? 5 : attempt))));
            print('Reconnecting SSE in ${delay.inMilliseconds} ms (attempt ${attempt + 1})');
            await Future.delayed(delay);
            connect(attempt: attempt + 1);
          }
        }, onDone: () async {
          buffer.write('\n');
          processBuffer();
          // Flush remaining event
          if (dataEvent.isNotEmpty) {
            final payload = dataEvent.toString();
            dataEvent.clear();
            try {
              print('Final SSE payload: $payload');
              final map = jsonDecode(payload) as Map<String, dynamic>;
              final progress = AnalysisProgress.fromJson(map);
              print('Final parsed progress: ${progress.percent} - ${progress.message}');
              emitOnce(progress);
            } catch (e) {
              print('Final SSE parse error: $e');
            }
          }
          if (!canceled) {
            final delay = Duration(milliseconds: (1000 * (1 << (attempt > 5 ? 5 : attempt))));
            print('SSE done, reconnecting in ${delay.inMilliseconds} ms (attempt ${attempt + 1})');
            await Future.delayed(delay);
            connect(attempt: attempt + 1);
          }
        }, cancelOnError: true);

        controller.onCancel = () async {
          canceled = true;
          await sub.cancel();
        };
      } catch (e) {
        print('SSE connect error: $e');
        if (!canceled) {
          final delay = Duration(milliseconds: (1000 * (1 << (attempt > 5 ? 5 : attempt))));
          print('Reconnect after error in ${delay.inMilliseconds} ms (attempt ${attempt + 1})');
          await Future.delayed(delay);
          connect(attempt: attempt + 1);
        }
      }
    }

    // kick off first connection
    connect();

    return controller.stream;
  }

}
