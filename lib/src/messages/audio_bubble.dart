import 'dart:async';
import 'dart:math';

import '../../logic.dart';
import '../azure_blob/azblob_abstract.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'text_bubble.dart';

class AudioBubble<F extends FileSyncStatus> extends StatelessWidget {
  final F fileSyncStatus;
  const AudioBubble({Key? key, required this.fileSyncStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (fileSyncStatus is MyFileStatus)
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          Expanded(
            child: Container(
              //height: 52,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    VocalMessagesConfig.borderRadius - 10),
                color: fileSyncStatus is MyFileStatus
                    ? Colors.black
                    : Colors.blueGrey[900],
              ),
              child: fileSyncStatus is MyFileStatus ? AudioBubbleWidgetUserSent(
                  fileSyncStatus as MyFileStatus) : 
                  // synthesis here
                  TextBubbleWidget(fileSyncStatus)
            ),
          ),
          if (fileSyncStatus is TheirFileStatus)
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
        ],
      ),
    );
  }
}


  String prettyAzureLength(int contentLength) {
    debugPrint('contentLength $contentLength');
    final megaBytes = (contentLength * 0.000001);
    num fac = pow(10, 2);
    final d = (megaBytes * fac).round() / fac;

    return '$d Mo';
  }


// ignore: must_be_immutable
class AudioBubbleWidgetUserSent<F extends FileSyncStatus> extends StatefulWidget {
  MyFileStatus fileSyncStatus;
  AudioBubbleWidgetUserSent(this.fileSyncStatus, {Key? key})
      : super(key: key);

  @override
  State<AudioBubbleWidgetUserSent> createState() => _AudioBubbleWidgetState();
}

class _AudioBubbleWidgetState extends State<AudioBubbleWidgetUserSent> {
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

  String prettyDuration(Duration d) {
    var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
    var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
    return min + ":" + sec;
  }




  Future<void> upload() async {
    VocalMessagesConfig.client = http.Client();
    setState(() {
      widget.fileSyncStatus = widget.fileSyncStatus 
          .copyWith(uploadStatus: SyncStatus.localSyncing);
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
        widget.fileSyncStatus = widget.fileSyncStatus 
            .copyWith(uploadStatus: SyncStatus.synced);
      });
      VocalMessagesConfig.client.close();
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${widget.fileSyncStatus.dateLastModif.year}/${widget.fileSyncStatus.dateLastModif.month}/${widget.fileSyncStatus.dateLastModif.day} ${widget.fileSyncStatus.dateLastModif.hour}:${widget.fileSyncStatus.dateLastModif.minute}';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            if (widget.fileSyncStatus.status == SyncStatus.localDefective)
              const Icon(Icons.broken_image, color: Colors.red)
              // display the relevant icon button
             else if (widget.fileSyncStatus.status != SyncStatus.localDefective)
              StreamBuilder<PlayerState>(
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
              ),
            const SizedBox(width: 6),
              // display the progress bar (duration animation not working)
              Expanded(
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
              ),

            // end of the bubble
            // display upload icon if not found in azure or if uploading a progressIndicator
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
        ),
        // not working yet
        // AmplitudeWidget(true, player, widget.filepath),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(height: 20, child: Row(
            children: [
                  TextButton.icon(onPressed: () {
                  }, label: const Text('lorem'), icon: const Icon(Icons.edit),
                  ),
                  TextButton.icon(onPressed: () {
                  }, label: const Text('ipsum'), icon: const Icon(Icons.edit),
                  ),
            ],
          ),),
        )
      ],
    );
  }
}
