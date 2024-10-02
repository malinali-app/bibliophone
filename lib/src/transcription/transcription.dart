import 'package:bernard/src/file/file_status.dart';
import 'package:bernard/src/player/player.dart';
import 'package:bernard/src/transcription/find_panel_view.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:bernard/src/messages/audio_bubble.dart';
//import 'package:bernard/src/transcription/find_panel_view.dart';

class TranscriptionView extends StatefulWidget {
  final String audioFilePath;
  final String title;
  final String text;
  final String transcriptionDateString;
  final String audioDateString;
  const TranscriptionView(
      {required this.audioFilePath,
      required this.title,
      required this.text,
      required this.transcriptionDateString,
      required this.audioDateString,
      super.key});

  @override
  State<TranscriptionView> createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<TranscriptionView> {
  final CodeLineEditingController _controller = CodeLineEditingController();
  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
//    print(widget.audioFilePath);
    //  print(widget.audioDateString);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          overflow: TextOverflow.visible,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.transcriptionDateString,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8, color: Colors.black),
                overflow: TextOverflow.visible),
          )
        ],
      ),
      body: Column(
        children: [
          if (widget.audioFilePath.isNotEmpty)
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: PlayerWidget(
                widget.audioFilePath,
                widget.audioDateString,
                syncStatus: SyncStatus.synced,
              ),
            ),
          Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: CodeEditor(
              style: const CodeEditorStyle(fontSize: 15),
              wordWrap: false, // keep the whole line on small screen no \n
              autofocus: true,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              margin: const EdgeInsets.all(8),
              controller: _controller,
              findBuilder: (context, controller, readOnly) =>
                  CodeFindPanelView(controller: controller, readOnly: readOnly),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          // TODO: on save do the syncing saving boogie
        },
      ),
    );
  }
}
