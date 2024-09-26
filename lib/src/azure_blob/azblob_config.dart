import 'dart:io';

class AzureBlobConfig {
  late String azureContainerName;
  late String azureUserFolderName;
  static final AzureBlobConfig _inst = AzureBlobConfig._internal();

  AzureBlobConfig._internal();

  factory AzureBlobConfig(
      {required String containerName,
      required String userFolderName,
      String appName = 'vocal_message'}) {
    _inst.azureContainerName = containerName;
    _inst.azureUserFolderName = userFolderName;
    return _inst;
  }

  String get rootPath => Platform.pathSeparator + azureContainerName + Platform.pathSeparator + azureUserFolderName;
  String get myFilesPath =>
      Platform.pathSeparator + azureContainerName + Platform.pathSeparator + azureUserFolderName + Platform.pathSeparator + 'userSent';

  String get theirFilesPath =>
      Platform.pathSeparator + azureContainerName + Platform.pathSeparator + azureUserFolderName + Platform.pathSeparator + 'mlCreated';
}
