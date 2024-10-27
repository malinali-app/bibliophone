// set the container used in azure blob and the user folder
import 'package:bibliophone/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:bibliophone/src/app_launch/c_device.dart';

import 'package:bibliophone/src/flutter/future_builder2.dart';

class PackageInfoWidget extends StatelessWidget {
  const PackageInfoWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<PackageInfo>(
        future: PackageInfo.fromPlatform(),
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
            GlobalConfig.setAppName(snap.data!.appName);
            GlobalConfig.setAppVersion(snap.data!.version);
            GlobalConfig.setAppBuildVersionInt(
                int.tryParse(snap.data!.buildNumber) ?? 0);
            return const DeviceInfoWidget();
          }
        });
  }
}
