import 'dart:io';

import 'package:bernard/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bernard/src/app_launch/b_package.dart';

class AppDocDirectory extends StatelessWidget {
  const AppDocDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    // watch out for web
    return FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const ColoredBox(color: Colors.black);
          } else if (snap.hasError) {
            debugPrint('${snap.error}');
            return ColoredBox(
                color: Colors.pink,
                child: Text('appDirectory error ${snap.error}'));
          } else if (snap.connectionState != ConnectionState.waiting &&
              !snap.hasData) {
            return const ColoredBox(
                color: Colors.purple, child: Text('no appDirectory'));
          } else if (snap.data == null) {
            return const ColoredBox(
                color: Colors.blue, child: Text('appDirectory null'));
          } else {
            GlobalConfig.setDocumentPath(snap.data!);
            return const PackageInfoWidget();
          }
        });
  }
}
