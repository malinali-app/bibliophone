import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:bernard/azure_blob2.dart';
import 'package:bernard/src/flutter/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension LocalPathDownloadedFile on String {
  String get localPathFull =>
      GlobalConfig.localDirTheir.path + Platform.pathSeparator + this;
}

enum CloudProvider { azure, gcp, aws }

abstract class GlobalConfig {
  GlobalConfig._();
  static late http.Client client;

  static Environment? env;
  static void setEnv(Environment _env) => env = _env;
  static String locale = 'fr';
  static String documentPath = '';
  static String appName = 'bernard';
  static CloudProvider cloudProvider = CloudProvider.azure;
  static void setAppName(String _name) => appName = _name;

  static String appVersion = '';
  static void setAppVersion(String _appVersion) => appVersion = _appVersion;

  static int appBuildVersionInt = 0;
  static void setAppBuildVersionInt(int _appBuildVersion) =>
      appBuildVersionInt = _appBuildVersion;

  static void setDocumentPath(Directory dir) {
    documentPath = dir.path;
    if (localDirTheir.existsSync() == false) {
      Directory(localDirTheir.path).createSync();
    }
    if (localDirMy.existsSync() == false) {
      Directory(localDirMy.path).createSync();
    }
  }

  static String connexionString = '';
  static void setConnexionString(
      SharedPreferences prefs, String _connexionString) async {
    prefs.setString('connexion', _connexionString);
    connexionString = _connexionString;
    AzureBlobAbstract.setConnectionString(_connexionString);
  }

  static String readConnexionString(SharedPreferences prefs) {
    connexionString = prefs.getString('connexion') ?? '';
    return connexionString;
  }

  static Directory get localDirTheir => Directory(documentPath +
      Platform.pathSeparator +
      appName +
      '_' +
      'DO_NOT_DELETE_THEIR');

  static Directory get localDirMy => Directory(documentPath +
      Platform.pathSeparator +
      appName +
      '_' +
      'DO_NOT_DELETE_MY');

  static late AzureBlobConfig _config;
  static set setAzureAudioConfig(AzureBlobConfig cg) => _config = cg;
  static AzureBlobConfig get config => _config;

  static const double borderRadius = 27;
  static const double defaultPadding = 8;
  static GlobalKey<AnimatedListState> audioListKey =
      GlobalKey<AnimatedListState>();
}
