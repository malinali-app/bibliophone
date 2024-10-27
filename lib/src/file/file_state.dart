import 'dart:io';
import 'package:bibliophone/src/globals.dart';
import 'package:http/http.dart' as http;
import '../azure_blob/audio_file_parser.dart';
import '../azure_blob/azblob_abstract.dart';
import 'file_status.dart';
import 'package:flutter/foundation.dart';

/// Choosing this method because using proper state management would be
/// overkill for the scope of this project.
class FileState {
  const FileState._();
  // ignore: prefer_const_constructors
  static AllFiles allAudioFiles = AllFiles([], []);
}

Future<List<AzureAudioFileParser>> fetchRemoteFiles(
    String azurePath, http.Client client) async {
  final files = await AzureBlobAbstract.fetchFilesInfo(azurePath, client);
  return files;
}

List<String> getOnlyMyLocalAudioFiles() {
  List<FileSystemEntity> files =
      GlobalConfig.localDirMy.listSync(recursive: false);
  files.removeWhere((element) => !element.path.endsWith("wav"));
  files = files.reversed.toList();
  return files.map((e) => e.path).toList();
}

List<String> getOnlyTheirLocalJsonFiles() {
  List<FileSystemEntity> files =
      GlobalConfig.localDirTheir.listSync(recursive: false);
  files.removeWhere((element) => !element.path.endsWith("json"));
  files = files.reversed.toList();
  return files.map((e) => e.path).toList();
}

Future<AllFiles> getLocalAudioFetchFilesAndSetStatus(
    {required bool isConnected, required isConnexionString}) async {
  if (isConnected && isConnexionString) {
    final allAudios =
        await fetchFilesAndSetStatus(GlobalConfig.config.rootPath);
    return allAudios;
  } else {
    return getLocalFilesAndStatusOnly();
  }
}

AllFiles getLocalFilesAndStatusOnly() {
  final myFiles = <MyFileStatus>[];
  final theirFiles = <TheirFileStatus>[];
  final myLocalFiles = getOnlyMyLocalAudioFiles();
  for (final file in myLocalFiles) {
    final temp = MyFileStatus(SyncStatus.localNotSynced, file);
    myFiles.add(temp);
  }
  final theirLocalFiles = getOnlyTheirLocalJsonFiles();
  for (final filePath in theirLocalFiles) {
    final temp = TheirFileStatus(
        SyncStatus.synced, filePath, File(filePath).lastModifiedSync(), 0);
    theirFiles.add(temp);
  }
  return AllFiles(myFiles, theirFiles);
}

Future<AllFiles> fetchFilesAndSetStatus(String azurePath) async {
  final client = http.Client();
  final myFiles = <MyFileStatus>[];
  final theirFiles = <TheirFileStatus>[];
  final myRemoteFiles =
      await fetchRemoteFiles(GlobalConfig.config.cloudPathMy, client);

  final myLocalFiles = getOnlyMyLocalAudioFiles();
  for (final localFile in myLocalFiles) {
    //print('localFile in myLocalFiles');
    if (myRemoteFiles.filesNameOnly.contains(localFile.nameOnly)) {
      // local file exists in azure
      final upFile = MyFileStatus(SyncStatus.synced, localFile);
      myFiles.add(upFile);
    } else {
      // local file does not exists in azure, should be synced
      final upFile = MyFileStatus(SyncStatus.localNotSynced, localFile);
      myFiles.add(upFile);
    }
  }
  debugPrint('myFiles ${myFiles.length}');

  final client2 = http.Client();
  final theirLocalFiles = getOnlyTheirLocalJsonFiles();

  final theirRemoteFiles =
      await fetchRemoteFiles(GlobalConfig.config.cloudPathTheir, client2);
  //print('theirRemoteFiles ${theirRemoteFiles.length}');
  for (final remoteFile in theirRemoteFiles) {
    if (theirLocalFiles.namesOnly.contains(remoteFile.fileName)) {
      // remote file has already been downloaded from azure
      final downFile = TheirFileStatus(
        SyncStatus.synced,
        remoteFile.fileName,
        remoteFile.creationTime,
        remoteFile.contentLength,
      );
      theirFiles.add(downFile);
    } else {
      // remote file has not been downloaded from azure
      // debugPrint('remoteFile $remoteFile');
      final downFile = TheirFileStatus(
        SyncStatus.remoteNotSynced,
        remoteFile.fileName,
        remoteFile.creationTime,
        remoteFile.contentLength,
      );
      theirFiles.add(downFile);
    }
  }
  debugPrint('theirFiles ${theirFiles.length}');
  return AllFiles(myFiles, theirFiles);
}

class AllFiles {
  final List<MyFileStatus> myFiles;
  final List<TheirFileStatus> theirFiles;
  const AllFiles(this.myFiles, this.theirFiles);

  List<FileSyncStatus> get all => [...myFiles, ...theirFiles]
    ..sort((a, b) => a.dateLastModif.compareTo(b.dateLastModif));
}
