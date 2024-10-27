import 'package:flutter/material.dart';
import 'package:bibliophone/src/globals.dart';
import 'package:bibliophone/src/app_launch/a_directory.dart';
import 'package:bibliophone/src/flutter/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfig.setEnv(Environment.dev);
  runApp(const AppDocDirectory());
}
