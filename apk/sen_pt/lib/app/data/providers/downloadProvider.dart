import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sen_pt/app/data/ApiVar.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloadprovider extends GetConnect {
  Future<File> downloadAndSave(String jobId, String filename) async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          await openAppSettings();
          throw Exception('Izin penyimpanan ditolak');
        }
        final manage = await Permission.manageExternalStorage.request();
        if (!manage.isGranted) {
          throw Exception('Izin penyimpanan ditolak');
        }
      }
    }
    
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse("$downloadUrl/$jobId/pdf"));
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      Get.snackbar('Gagal','Terjadi kesalahan.',
                  backgroundColor: Colors.red, colorText: Colors.white);
    }

    String? downloadsDirPath;
    if (Platform.isAndroid) {
      downloadsDirPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
    } else {
      throw Exception('Platform tidak didukung');
    }

    final filePath = p.join(downloadsDirPath, filename);
    final file = File(filePath);
    final sink = file.openWrite();
    await sink.addStream(response);
    await sink.flush();
    await sink.close();
    return file;
  }
}
