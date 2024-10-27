import 'package:bibliophone/src/azure_blob/azblob_abstract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('azblob upload', () async {
    final client = http.Client();
    AzureBlobAbstract.setConnectionString('');

    final dd = await AzureBlobAbstract.uploadAudioWav(
        'test/audio2.wav', '/audio-test/test/audio2.wav', client);
    expect(dd, isTrue);
  });
}
