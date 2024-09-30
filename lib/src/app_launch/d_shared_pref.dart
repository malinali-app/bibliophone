// Flutter imports:
// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:bernard/src/globals.dart';
import 'package:bernard/src/flutter/future_builder2.dart';
import 'package:bernard/src/app_launch/e_mat_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsFetchWidget extends StatelessWidget {
  const SharedPrefsFetchWidget({super.key});
  Future<SharedPreferences> getSharedPrefs() async =>
      await SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<SharedPreferences>(
        future: getSharedPrefs(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ColoredBoxProgress.greyWithCircularProgressIndic;
          } else if (snap.hasError ||
              (snap.connectionState != ConnectionState.waiting &&
                  !snap.hasData) ||
              snap.data == null) {
            return ColoredBox(
                color: const Color.fromRGBO(92, 107, 192, 1),
                child: Text('getSharedPrefs error ${snap.error}'));
          } else {
            final connexion = GlobalConfig.readConnexionString(snap.data!);
            if (connexion.isNotEmpty) {
              GlobalConfig.setConnexionString(snap.data!, connexion);
            }
            return const MyApp();
          }
        });
  }
}
