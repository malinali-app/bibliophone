import 'package:bibliophone/src/file/file_status.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerWidget extends StatefulWidget {
  final String filePath, dateString;
  final SyncStatus syncStatus;

  const PlayerWidget(this.filePath, this.dateString,
      {this.syncStatus = SyncStatus.synced, super.key});

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
