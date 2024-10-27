import 'package:bibliophone/src/azure_blob/azblob_abstract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('azblob read', () async {
    final client = http.Client();
    AzureBlobAbstract.setConnectionString('');

    final files =
        await AzureBlobAbstract.fetchFilesInfo("audio/test/userSent", client);
    expect(files.first.path, 'test/audio.wav');
  });
}
