import 'package:bernard/src/file/file_status.dart';
import 'package:bernard/src/globals.dart';
import 'package:bernard/src/messages/audio_bubble.dart';

import 'package:flutter/material.dart';
import 'text_bubble.dart';

class BubbleWidget<F extends FileSyncStatus> extends StatelessWidget {
  final F fileSyncStatus;
  const BubbleWidget({Key? key, required this.fileSyncStatus})
      : super(key: key);

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
                  borderRadius:
                      BorderRadius.circular(GlobalConfig.borderRadius - 10),
                  color: fileSyncStatus is MyFileStatus
                      ? Colors.black
                      : Colors.blueGrey[900],
                ),
                child: fileSyncStatus is MyFileStatus
                    ? AudioBubbleWidget(fileSyncStatus as MyFileStatus)
                    :
                    // synthesis here
                    TextBubbleWidget(fileSyncStatus)),
          ),
          if (fileSyncStatus is TheirFileStatus)
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
        ],
      ),
    );
  }
}
