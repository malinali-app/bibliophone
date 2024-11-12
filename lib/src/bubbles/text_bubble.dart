import 'dart:io';
import 'package:bibliophone/src/azure_blob/azblob_abstract.dart';
import 'package:bibliophone/src/file/file_status.dart';
import 'package:bibliophone/src/globals.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TextBubbleWidget<TheirFileStatus> extends StatefulWidget {
  TheirFileStatus fileSyncStatus;
  TextBubbleWidget(this.fileSyncStatus, {Key? key}) : super(key: key);

  @override
  State<TextBubbleWidget> createState() => _TextBubbleWidgetState();
}

class _TextBubbleWidgetState extends State<TextBubbleWidget> {
  @override
  void initState() {
    super.initState();
  }

  static const title = '';

  @override
  Widget build(BuildContext context) {
    final text = File(GlobalConfig.localDirTheir.path +
            Platform.pathSeparator +
            (widget.fileSyncStatus as TheirFileStatus).filePath)
        .readAsStringSync();
    print("text $text");
    final dateString =
        '${(widget.fileSyncStatus as TheirFileStatus).dateLastModif.year}/${widget.fileSyncStatus.dateLastModif.month}/${widget.fileSyncStatus.dateLastModif.day} ${widget.fileSyncStatus.dateLastModif.hour}:${widget.fileSyncStatus.dateLastModif.minute}';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        Row(children: [
          if (widget.fileSyncStatus.status == SyncStatus.localDefective)
            const Icon(Icons.broken_image, color: Colors.red),
          if (widget.fileSyncStatus.status == SyncStatus.remoteNotSynced)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                try {
                  GlobalConfig.client = http.Client();
                  setState(() {
                    widget.fileSyncStatus = widget.fileSyncStatus
                        .copyWith(downloadStatus: SyncStatus.localSyncing);
                  });
                  // keep '/' for azure path do not replace with Platform.pathSeparator

                  final name =
                      (widget.fileSyncStatus.azurePath as String).nameOnly;
                  print('name $name');
                  final fileLink = GlobalConfig.config.cloudPathTheir +
                      '/' +
                      (widget.fileSyncStatus.azurePath as String).nameOnly;
                  final content = await AzureBlobAbstract.downloadText(
                      fileLink, GlobalConfig.client);
                  final filePath = GlobalConfig.localDirTheir.path +
                      Platform.pathSeparator +
                      name;
                  final fileSaved = await File(filePath).writeAsBytes(content);

                  setState(() {
                    widget.fileSyncStatus = widget.fileSyncStatus
                        .copyWith(downloadStatus: SyncStatus.synced);
                  });
                  GlobalConfig.client.close();
                }
                //
                on FileSystemException catch (e) {
                  debugPrint('save file exception $e');
                  setState(() {
                    widget.fileSyncStatus = (widget.fileSyncStatus
                            as TheirFileStatus)
                        .copyWith(downloadStatus: SyncStatus.remoteNotSynced);
                  });
                }
              },
            )
          else if (widget.fileSyncStatus.status == SyncStatus.remoteSyncing)
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.fileSyncStatus =
                      (widget.fileSyncStatus as TheirFileStatus).copyWith(
                    downloadStatus: SyncStatus.remoteNotSynced,
                  );
                });
                GlobalConfig.client.close();
              },
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.cancel),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          const SizedBox(width: 6),
          if (widget.fileSyncStatus.status == SyncStatus.remoteSyncing ||
              widget.fileSyncStatus.status == SyncStatus.remoteNotSynced)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.transcribe,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // in the view
                          // TODO : here add metadata in json to fet the azure audio url
                          // hack here for demo
                          // audioFilePath=${widget.fileSyncStatus.filePath}&
                          context.go(
                              '/transcription?title=$title&text=${File(GlobalConfig.localDirTheir.path + Platform.pathSeparator + widget.fileSyncStatus.filePath).readAsStringSync()}&transcriptionDateString=${widget.fileSyncStatus.dateString}&audioDateString=${widget.fileSyncStatus.dateString}');
                        },
                        label: const Text(title),
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
                Text('transcription : $text\n...'),
                TextButton.icon(
                  label: const Text('Action Button'),
                  icon: const Icon(Icons.send, color: Colors.white, size: 22),
                  onPressed: () {
                    // in the view
                    context.go(
                        '/transcription?audioFilePath=${widget.fileSyncStatus.filePath}&audioDateString=${widget.fileSyncStatus.dateString}&text=$text&title=$title&audioDateString=${widget.fileSyncStatus.dateLastModif}');
                  },
                )
              ],
            )
        ]),
        // not working yet
        // AmplitudeWidget(true, player, widget.filepath),
      ],
    );
  }
}
