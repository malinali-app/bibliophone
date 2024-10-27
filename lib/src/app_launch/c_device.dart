// Dart imports:
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:bibliophone/azure_blob2.dart';
import 'package:bibliophone/src/globals.dart';
import 'package:bibliophone/src/app_launch/d_shared_pref.dart';
import 'package:bibliophone/src/flutter/future_builder2.dart';

class DeviceInfoWidget extends StatelessWidget {
  const DeviceInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<BaseDeviceInfo>(
        future: DeviceHardwareInfo.getBaseDeviceInfo(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ColoredBoxProgress.greyWithCircularProgressIndic;
          } else if (snap.hasError ||
              (snap.connectionState != ConnectionState.waiting &&
                  !snap.hasData)) {
            debugPrint('${snap.error}');
            return ColoredBox(
                color: const Color.fromRGBO(236, 64, 122, 1),
                child: Text('packageInfo error ${snap.error}'));
          } else {
            // set the container used in azure blob and the user folder
            // * this is a hack to have user info based on device
            // + simple than signup/signin
            GlobalConfig.setAzureAudioConfig = AzureBlobConfig(
                containerName: GlobalConfig.appName,
                userFolderName: DeviceHardwareInfo(snap.data!).info.toString());
            return const SharedPrefsFetchWidget();
          }
        });
  }

  Future<String> getDeviceHardwareUuid() async {
    if (kIsWeb) {
      WebBrowserInfo webInfo = await DeviceInfoPlugin().webBrowserInfo;
      return (webInfo.vendor ?? '') +
          (webInfo.userAgent ?? '') +
          webInfo.hardwareConcurrency.toString();
    } else {
      if (Platform.isAndroid) {
        // android_id was removed breaking the build
        final androidIdPlugin = await DeviceInfoPlugin().androidInfo;
        return 'android_${androidIdPlugin.id}';
        // do not use androidId here since no longer allower to fetch it, it is just something else
        // prefer methode above to get the good id
      } else if (Platform.isIOS) {
        final iOSINfo = await DeviceInfoPlugin().iosInfo;
        return 'ios_${iOSINfo.identifierForVendor ?? ''}';
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo info = await DeviceInfoPlugin().macOsInfo;
        return 'macos_${info.systemGUID ?? info.computerName}';
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo info = await DeviceInfoPlugin().windowsInfo;
        return 'windows_${info.deviceId}';
      } else if (Platform.isLinux) {
        final info = await DeviceInfoPlugin().linuxInfo;
        return 'linux_${info.id}';
      } else {
        debugPrint('sth else');
        return 'unknown_device';
      }
    }
  }
}

class DeviceHardwareInfo<T extends BaseDeviceInfo> {
  final HardwareInfo info;
  final T deviceInfo;

  /// get BaseDeviceInfo and then instantiate DeviceInfo to get Device pb object
  static Future<BaseDeviceInfo> getBaseDeviceInfo() async {
    if (kIsWeb) {
      throw ('web out of scope');
      //  // The web doesnt have a device UID, so use a combination fingerprint as an example
      //  WebBrowserInfo webInfo = await DeviceInfoPlugin().webBrowserInfo;
      //  return (webInfo.vendor ?? '') +
      //      (webInfo.userAgent ?? '') +
      //      webInfo.hardwareConcurrency.toString();
    } else if (Platform.isAndroid) {
      return await DeviceInfoPlugin().androidInfo;
    } else if (Platform.isIOS) {
      return await DeviceInfoPlugin().iosInfo;
    } else if (Platform.isMacOS) {
      return await DeviceInfoPlugin().macOsInfo;
    } else if (Platform.isWindows) {
      return await DeviceInfoPlugin().windowsInfo;
    } else if (Platform.isLinux) {
      return await DeviceInfoPlugin().linuxInfo;
    } else {
      throw ('sth else');
    }
  }

  DeviceHardwareInfo(this.deviceInfo)
      : info = deviceInfo is AndroidDeviceInfo
            ? HardwareInfo(
                Platform.operatingSystem,
                deviceInfo.device,
                deviceInfo.brand,
                deviceInfo.id,
              )
            : deviceInfo is IosDeviceInfo
                ? HardwareInfo(
                    Platform.operatingSystem,
                    deviceInfo.name,
                    'Apple',
                    deviceInfo.identifierForVendor ?? '',
                  )
                : deviceInfo is MacOsDeviceInfo
                    ? HardwareInfo(
                        Platform.operatingSystem,
                        deviceInfo.computerName,
                        'Apple',
                        deviceInfo.systemGUID ?? '',
                      )
                    : deviceInfo is WindowsDeviceInfo
                        ? HardwareInfo(
                            Platform.operatingSystem,
                            deviceInfo.computerName,
                            deviceInfo.productName,
                            deviceInfo.deviceId,
                          )
                        : deviceInfo is LinuxDeviceInfo
                            ? HardwareInfo(
                                Platform.operatingSystem,
                                deviceInfo.name,
                                deviceInfo.prettyName,
                                deviceInfo.id,
                              )
                            : HardwareInfo.empty;
}

class HardwareInfo {
  final String baseOS;
  final String name;
  final String brand;
  final String serialNumber;
  const HardwareInfo(
    this.baseOS,
    this.name,
    this.brand,
    this.serialNumber,
  );

  static const empty = HardwareInfo('', '', '', '');

  HardwareInfo copyWith({
    String? baseOS,
    String? name,
    String? brand,
    String? serialNumber,
  }) {
    return HardwareInfo(
      baseOS ?? this.baseOS,
      name ?? this.name,
      brand ?? this.brand,
      serialNumber ?? this.serialNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseOS': baseOS,
      'name': name,
      'brand': brand,
      'serialNumber': serialNumber,
    };
  }

  factory HardwareInfo.fromMap(Map<String, dynamic> map) {
    return HardwareInfo(
      map['baseOS'] ?? '',
      map['name'] ?? '',
      map['brand'] ?? '',
      map['serialNumber'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HardwareInfo.fromJson(String source) =>
      HardwareInfo.fromMap(json.decode(source));

  @override
  String toString() => '$baseOS-$name-$brand-$serialNumber';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HardwareInfo &&
        other.baseOS == baseOS &&
        other.name == name &&
        other.brand == brand &&
        other.serialNumber == serialNumber;
  }

  @override
  int get hashCode {
    return baseOS.hashCode ^
        name.hashCode ^
        brand.hashCode ^
        serialNumber.hashCode;
  }
}
