class AzureBlobConfig {
  late String azureContainerName;
  late String azureUserFolderName;
  static final AzureBlobConfig _inst = AzureBlobConfig._internal();

  AzureBlobConfig._internal();

  factory AzureBlobConfig(
      {required String containerName,
      required String userFolderName,
      String appName = 'vocal'}) {
    _inst.azureContainerName = containerName;
    _inst.azureUserFolderName = userFolderName;
    return _inst;
  }

// keep '/' for azure path do not replace with Platform.pathSeparator
  String get rootPath => '/' + azureContainerName + '/' + azureUserFolderName;
  String get myFilesPath =>
      '/' + azureContainerName + '/' + azureUserFolderName + '/audio';

  String get theirFilesPath =>
      '/' + azureContainerName + '/' + azureUserFolderName + '/transcription';
}
