import 'dart:async';
import 'dart:math';

import '../../logic.dart';
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
    VocalMessagesConfig.client = http.Client();
    setState(() {
      widget.fileSyncStatus =
          widget.fileSyncStatus.copyWith(uploadStatus: SyncStatus.localSyncing);
    });
    // keep '/' for azure path do not replace with Platform.pathSeparator
    final isUploadOk = await AzureBlobAbstract.uploadAudioWav(
        widget.fileSyncStatus.filePath,
        VocalMessagesConfig.config.myFilesPath +
            '/' +
            widget.fileSyncStatus.filePath.nameOnly,
        VocalMessagesConfig.client);
    if (isUploadOk) {
      setState(() {
        widget.fileSyncStatus =
            widget.fileSyncStatus.copyWith(uploadStatus: SyncStatus.synced);
      });
      VocalMessagesConfig.client.close();
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
              PlayerWidget(
                widget.fileSyncStatus.filePath,
                widget.fileSyncStatus.dateString,
                duration:duration,
                syncStatus: widget.fileSyncStatus.status,
              ),
              syncIcon()
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
                VocalMessagesConfig.client.close();
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

class PlayerWidget extends StatefulWidget {
  final String filePath, dateString;
  final Duration? duration;
  final SyncStatus syncStatus;

  const PlayerWidget(this.filePath, this.dateString,
      {this.duration, this.syncStatus = SyncStatus.synced, super.key})
      : assert(syncStatus != SyncStatus.localDefective &&
            syncStatus != SyncStatus.localNotSynced &&
            syncStatus != SyncStatus.localSyncing);

  @override
  State<PlayerWidget> createState() => _AudioBubbleRawWidget();
}

class _AudioBubbleRawWidget extends State<PlayerWidget> {
  final player = AudioPlayer();
  Duration? duration;

  @override
  void initState() {
    super.initState();
    player.setFilePath(widget.filePath).then((value) {
      if (mounted) {
        setState(() => duration = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 6),
        PlayerIcon(player),
        PlayerProgressBar(player, widget.dateString, duration)
      ],
    );
  }
}

class PlayerIcon extends StatelessWidget {
  final AudioPlayer player;
  const PlayerIcon(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: player.play,
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            onPressed: player.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              player.seek(Duration.zero);
            },
          );
        }
      },
    );
  }
}

class PlayerProgressBar extends StatelessWidget {
  final AudioPlayer player;
  final String dateString;
  final Duration? duration;
  const PlayerProgressBar(this.player, this.dateString, this.duration,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<Duration>(
        stream: player.positionStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: snapshot.data!.inMilliseconds /
                      (duration?.inMilliseconds ?? 1),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (duration != null)
                      Text(
                        prettyDuration(snapshot.data! == Duration.zero
                            ? duration ?? Duration.zero
                            : snapshot.data!),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      dateString,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }
}

String prettyDuration(Duration d) {
  var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
  var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
  return min + ":" + sec;
}
