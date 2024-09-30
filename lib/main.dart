import 'package:flutter/material.dart';
import 'package:bernard/src/globals.dart';
import 'package:bernard/src/app_launch/a_directory.dart';
import 'package:bernard/src/flutter/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfig.setEnv(Environment.prd);
  runApp(const AppDocDirectory());
}
