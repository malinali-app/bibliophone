import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:voc_up/messages_ui.dart';
import '../../logic.dart';
import '../azure_blob/azblob_abstract.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class TextBubbleWidget<F extends FileSyncStatus> extends StatefulWidget {
  F fileSyncStatus;
  TextBubbleWidget(this.fileSyncStatus, {Key? key}) : super(key: key);

  @override
  State<TextBubbleWidget> createState() => _TextBubbleWidgetState();
}

class _TextBubbleWidgetState extends State<TextBubbleWidget> {
  @override
  void initState() {
    super.initState();
  }

  final text =
      '\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  static const title = 'lorem add title';

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${widget.fileSyncStatus.dateLastModif.year}/${widget.fileSyncStatus.dateLastModif.month}/${widget.fileSyncStatus.dateLastModif.day} ${widget.fileSyncStatus.dateLastModif.hour}:${widget.fileSyncStatus.dateLastModif.minute}';
    return
        // temp hack for UI mock up
        (2 + 2 == 4)
            ? Column(
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
                          onPressed: () {},
                          label: const Text(title),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                  Text('transcription : $text' + "\n..."),
                  TextButton.icon(
                    label: const Text('Synthétiser et partager'),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      // in the view
                      context.go(
                          '/transcription?audioFilePath=${widget.fileSyncStatus.filePath}&audioDateString=${widget.fileSyncStatus.dateString}&text=$text&title=$title&audioDateString=${widget.fileSyncStatus.dateLastModif}');
                    },
                  )
                ],
              )
            :
            // legacy fetch logic
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  Row(children: [
                    if (widget.fileSyncStatus.status ==
                        SyncStatus.localDefective)
                      const Icon(Icons.broken_image, color: Colors.red),
                    if (widget.fileSyncStatus.status ==
                        SyncStatus.remoteNotSynced)
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          try {} on FileSystemException catch (e) {
                            debugPrint('save file exception $e');
                            setState(() {
                              widget.fileSyncStatus =
                                  (widget.fileSyncStatus as TheirFileStatus)
                                      .copyWith(
                                          downloadStatus:
                                              SyncStatus.remoteNotSynced);
                            });
                          }
                        },
                      )
                    else if (widget.fileSyncStatus.status ==
                        SyncStatus.remoteSyncing)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.fileSyncStatus =
                                (widget.fileSyncStatus as TheirFileStatus)
                                    .copyWith(
                              downloadStatus: SyncStatus.remoteNotSynced,
                            );
                          });
                          VocalMessagesConfig.client.close();
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
                    if (widget.fileSyncStatus.status ==
                            SyncStatus.remoteSyncing ||
                        widget.fileSyncStatus.status ==
                            SyncStatus.remoteNotSynced)
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
                    // else the text
                  ]),
                  // not working yet
                  // AmplitudeWidget(true, player, widget.filepath),
                ],
              );
  }
}