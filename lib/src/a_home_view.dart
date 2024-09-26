// ignore: file_names
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'b_record_permission.dart';
import 'messages/audio_list.dart';
import 'messages/audio_state.dart';
import 'globals.dart';
import 'package:flutter/material.dart';

class VocalMessagesAndRecorderView extends StatefulWidget {
  final String title;
  const VocalMessagesAndRecorderView(this.title, {Key? key}) : super(key: key);

  @override
  State<VocalMessagesAndRecorderView> createState() =>
      _VocalMessagesAndRecorderViewState();
}

class _VocalMessagesAndRecorderViewState
    extends State<VocalMessagesAndRecorderView>
    with SingleTickerProviderStateMixin {
  bool isDeviceConnected = false;
  bool isSyncing = false;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // You have set this otherwise it throws AppFolderNotSetException

    initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      final temp = await isInternetAvailable(results.first);
      setState(() => isDeviceConnected = temp);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final dd = await _connectivity.checkConnectivity();
      result = dd.first;
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // better discard the reply
    // if the widget is removed from the tree while the async platform message is in flight
    if (!mounted) {
      return Future.value(null);
    }

    final temp = await isInternetAvailable(result);
    setState(() => isDeviceConnected = temp);
    return;
  }

  Future<bool> isInternetAvailable(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      return false;
    } else {
      return await InternetConnectionChecker().hasConnection;
    }
  }

  Future<bool> areYouSure(String title, String message, BuildContext context,
      {required bool? isDismissible}) async {
    return await showDialog(
      context: context,
      barrierDismissible: isDismissible ?? true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text(
                    'Annuler',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('OK', overflow: TextOverflow.ellipsis),
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final isSureToDelete = await areYouSure(
                  'Attention',
                  'Cette opération va effacer tous les enregistrements.',
                  context,
                  isDismissible: false);
              if (isSureToDelete) {
                VocalMessagesConfig.theirFilesDir.deleteSync(recursive: false);
                VocalMessagesConfig.myFilesDir.deleteSync(recursive: false);
                Directory(VocalMessagesConfig.documentPath).createSync();
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: isDeviceConnected
                ? isSyncing
                    ? const Icon(Icons.cloud_sync_sharp)
                    : const Icon(Icons.sync)
                : const Icon(Icons.signal_wifi_connected_no_internet_4),
            onPressed: isDeviceConnected
                ? () async {
                    setState(() => isSyncing = true);
                    await getLocalAudioFetchFilesAndSetStatus(isDeviceConnected)
                        .then(
                      (value) => setState(() => isSyncing = false),
                    );
                  }
                : null,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(VocalMessagesConfig.defaultPadding),
        child: Column(
          children: [
            Expanded(
              child: AudioList(
                isDeviceConnected,
                () async =>
                    getLocalAudioFetchFilesAndSetStatus(isDeviceConnected),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              height: 8,
            ),
            const SizedBox(height: 12),
            const RecorderPermission(),
          ],
        ),
      ),
    );
  }
}
