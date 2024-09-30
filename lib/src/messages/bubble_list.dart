import '../file/file_state.dart';
import '../globals.dart';
import 'bubble.dart';
import 'package:flutter/material.dart';

typedef FutureGenerator = Future<AllFiles> Function();

class BubbleList extends StatelessWidget {
  final bool isConnected;
  final FutureGenerator generator;
  // final Function onRerun;
  const BubbleList(this.isConnected, this.generator, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AllFiles>(
        future: generator(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: const CircularProgressIndicator());
          } else if (snap.hasError) {
            debugPrint('${snap.error}');
            return ColoredBox(
                color: Colors.pink,
                child: Text('audioFiles Fetch error ${snap.error}'));
          } else if (snap.connectionState != ConnectionState.waiting &&
              !snap.hasData) {
            return const ColoredBox(
                color: Colors.purple, child: Text('no audioFiles Fetch'));
          } else if (snap.data == null) {
            return const ColoredBox(
                color: Colors.blue, child: Text('audioFiles Fetch null'));
          } else {
            FileState.allAudioFiles = snap.data!;
            return const BubblesListWidget();
          }
        });
  }
}

class BubblesListWidget extends StatelessWidget {
  // final Function onRerun;
  const BubblesListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      initialItemCount: FileState.allAudioFiles.all.length,
      padding: const EdgeInsets.symmetric(vertical: 15),
      key: GlobalConfig.audioListKey,
      itemBuilder: (context, index, animation) {
        return FadeTransition(
          opacity: animation,
          child: BubbleWidget(
            fileSyncStatus: FileState.allAudioFiles.all[index],
            key: ValueKey(FileState.allAudioFiles.all[index]),
          ),
        );
      },
    );
  }
}
