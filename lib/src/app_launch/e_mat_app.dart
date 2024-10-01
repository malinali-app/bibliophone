import 'package:bernard/src/home_view.dart';
import 'package:bernard/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:bernard/src/settings_view.dart';
import 'package:bernard/src/ui/theme.dart';
import 'package:bernard/src/transcription/transcription.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const VocalMessagesAndRecorderView("Bernard");
      },
      routes: <RouteBase>[
        GoRoute(
            path: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsView();
            }),
        GoRoute(
          path: 'transcription',
          builder: (BuildContext context, GoRouterState state) {
            return TranscriptionView(
              audioFilePath: state.uri.queryParameters['audioFilePath'] ?? '',
              title: state.uri.queryParameters['title'] ?? '',
              text: state.uri.queryParameters['text'] ?? '',
              transcriptionDateString:
                  state.uri.queryParameters['transcriptionDateString'] ?? '',
              audioDateString:
                  state.uri.queryParameters['audioDateString'] ?? '',
            );
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const Iterable<LocalizationsDelegate<dynamic>> delegates = [
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  @override
  Widget build(BuildContext context) {
    // set-up local here (default is fr)
    GlobalConfig.locale = 'fr';

    return MaterialApp.router(
      routerConfig: _router,
      locale: const Locale('fr'),
      localizationsDelegates: delegates,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('es'),
      ],
      title: "Bernard",
      theme: AudioTheme.dartTheme(),
    );
  }
}
