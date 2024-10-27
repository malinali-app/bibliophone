import 'dart:async';
import 'dart:math';

import 'package:bibliophone/src/file/file_status.dart';

import 'package:bibliophone/src/globals.dart';
import 'package:bibliophone/src/player/player.dart';
import '../azure_blob/azblob_abstract.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

String prettyAzureLength(int contentLength) {
  debugPrint('contentLength $contentLength');
  final megaBytes = (contentLength * 0.000001);
  num fac = pow(10, 2);
  final d = (megaBytes * fac).round() / fac;

  return '$d Mo';
}

// ignore: must_be_immutable
class AudioBubbleWidget extends StatefulWidget {
  MyFileStatus fileSyncStatus;
  AudioBubbleWidget(this.fileSyncStatus, {Key? key}) : super(key: key);

  @override
  State<AudioBubbleWidget> createState() => _AudioBubbleWidgetState();
}

class _AudioBubbleWidgetState extends State<AudioBubbleWidget> {
  final player = AudioPlayer();
  Duration? duration;

  @override
  void initState() {
    super.initState();
    player.setFilePath(widget.fileSyncStatus.filePath).then((value) {
      if (mounted) {
        setState(() => duration = value);
      }
    });
  }

  Future<void> upload() async {
    GlobalConfig.client = http.Client();
    setState(() {
      widget.fileSyncStatus =
          widget.fileSyncStatus.copyWith(uploadStatus: SyncStatus.localSyncing);
    });
    // keep '/' for azure path do not replace with Platform.pathSeparator
    final isUploadOk = await AzureBlobAbstract.uploadAudioWav(
        widget.fileSyncStatus.filePath,
        GlobalConfig.config.cloudPathMy +
            '/' +
            widget.fileSyncStatus.filePath.nameOnly,
        GlobalConfig.client);
    if (isUploadOk) {
      setState(() {
        widget.fileSyncStatus =
            widget.fileSyncStatus.copyWith(uploadStatus: SyncStatus.synced);
      });
      GlobalConfig.client.close();
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return (widget.fileSyncStatus.status == SyncStatus.localDefective)
        ? const Icon(Icons.broken_image, color: Colors.red)
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: PlayerWidget(
                      widget.fileSyncStatus.filePath,
                      widget.fileSyncStatus.dateString,
                      syncStatus: widget.fileSyncStatus.status,
                    ),
                  ),
                  syncIcon()
                ],
              ),
              // not working yet
              // AmplitudeWidget(true, player, widget.filepath),
            ],
          );
  }

  Widget syncIcon() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.fileSyncStatus.status == SyncStatus.localNotSynced)
            IconButton(
              icon: const Icon(Icons.upload, color: Colors.lightBlueAccent),
              onPressed: () async => upload(),
            ),
          if (widget.fileSyncStatus.status == SyncStatus.localSyncing)
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.fileSyncStatus = widget.fileSyncStatus
                      .copyWith(uploadStatus: SyncStatus.localNotSynced);
                });
                GlobalConfig.client.close();
                return;
              },
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.cancel),
                  CircularProgressIndicator(),
                ],
              ),
            )
        ],
      );
}
