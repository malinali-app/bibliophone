import 'package:bernard/src/azure_blob/azblob_abstract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('fileStatus', () async {
    final client = http.Client();
    AzureBlobAbstract.setConnectionString('');
    final files =
        await AzureBlobAbstract.fetchAudioFilesInfo('/audio-test/test', client);
    files.first.path;
  });
}
