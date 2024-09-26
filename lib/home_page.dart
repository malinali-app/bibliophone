import 'package:flutter/material.dart';
import 'package:voc_up/home.dart';
import 'package:voc_up/logic.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    if (VocalMessagesConfig.config.rootPath.isEmpty) {
      return const Center(child: Text('Globals.azureRootPath is empty'));
    }
    if (VocalMessagesConfig.documentPath.isEmpty) {
      return const Text('Globals.documentPath is empty');
    }
    return const VocalMessagesAndRecorderView("Voc'up");
  }
}
