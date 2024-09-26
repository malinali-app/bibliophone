import 'dart:io';

import '../lib/src/azure_blob/azblob_abstract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class UtilsTestFiles {
  static const testFolderPath = 'test/done_test';

  static Future<Directory> createTestFolder() async =>
      await Directory(testFolderPath).create();
  static Future cleanTestFolder() async {
    if (await Directory(testFolderPath).exists()) {
      await Directory(testFolderPath).delete(recursive: true);
    }
  }
}

void main() {
  test('azblob download audio', () async {
    await UtilsTestFiles.cleanTestFolder();
    await UtilsTestFiles.createTestFolder();
    final client = http.Client();
    AzureBlobAbstract.setConnectionString('testAzureConnString');

    final audioContent = await AzureBlobAbstract.downloadAudio(
        '/audio-test/test@macos_MacBook de mac/loaded_by_admin/Phoniks_Message to Earth.mp3',
        client);

    final fileSaved = await File(
            '${UtilsTestFiles.testFolderPath}/Phoniks_Message to Earth.mp3')
        .writeAsBytes(audioContent);
    final lengthByte = await fileSaved.length();
    expect(lengthByte > 3200000, isTrue);
  });
  // SAVE it
}
