import 'package:flutter/material.dart';
import 'package:bernard/src/globals.dart';
import 'package:bernard/src/flutter/future_builder2.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
            return SettingsWidget(snap.data!);
          }
        });
  }
}

class SettingsWidget extends StatefulWidget {
  final SharedPreferences prefs;
  const SettingsWidget(this.prefs, {super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  void setConnexionString(String azureBlobConnectionString) {
    GlobalConfig.setConnexionString(
      widget.prefs,
      azureBlobConnectionString,
    );
  }

  TextEditingController _connexionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final connexionString = GlobalConfig.readConnexionString(widget.prefs);
    if (connexionString.isNotEmpty) {
      _connexionController = TextEditingController(text: connexionString);
    }
    _connexionController.addListener(() {
      final String text = _connexionController.text;
      _connexionController.value = _connexionController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    _connexionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () {
            setConnexionString(_connexionController.text);
            context.go('/');
          }),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const RadioListTile(
            value: CloudProvider.azure,
            title: Text('Azure'),
            groupValue: CloudProvider.azure,
            onChanged: null,
            controlAffinity: ListTileControlAffinity.platform,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              scrollPadding: const EdgeInsets.all(20.0),
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'connexion',
                icon: const Icon(Icons.assignment),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // delete keyboard not working, providing option
                    _connexionController.text = '';
                  },
                ),
              ),
              controller: _connexionController,
              onSubmitted: (value) {
                if (_connexionController.text.isNotEmpty) {
                  setConnexionString(value);
                }
              },
            ),
          )
        ],
      )),
    );
  }
}
