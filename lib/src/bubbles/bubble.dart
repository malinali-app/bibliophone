import 'package:bibliophone/src/file/file_status.dart';
import 'package:bibliophone/src/globals.dart';
import 'package:bibliophone/src/bubbles/audio_bubble.dart';

import 'package:flutter/material.dart';

class BubbleWidget<F extends FileSyncStatus> extends StatelessWidget {
  final F fileSyncStatus;
  const BubbleWidget({Key? key, required this.fileSyncStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        //height: 52,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GlobalConfig.borderRadius - 10),
          color: fileSyncStatus is MyFileStatus
              ? Colors.black
              : Colors.blueGrey[900],
        ),
        child: AudioBubbleWidget(fileSyncStatus as MyFileStatus),
      ),
    );
  }
}
