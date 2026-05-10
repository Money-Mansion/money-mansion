import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/update_exception.dart';

class AndroidApkInstaller {
  static const _channel = MethodChannel('money_mansion/internal_updater');

  Future<void> install(File apkFile) async {
    if (!Platform.isAndroid) {
      throw const UpdateException(
          'APK installation is only supported on Android');
    }
    if (!await apkFile.exists()) {
      throw const UpdateException('APK file no longer exists');
    }

    var permission = await Permission.requestInstallPackages.status;
    if (!permission.isGranted) {
      permission = await Permission.requestInstallPackages.request();
    }
    if (!permission.isGranted) {
      throw const UpdateException(
        'Allow "install unknown apps" for Money Mansion, then retry install',
      );
    }

    try {
      await _channel
          .invokeMethod<bool>('installApk', {'filePath': apkFile.path});
    } on PlatformException catch (error) {
      throw UpdateException(
        error.message ?? 'Android package installer failed',
        cause: error.code,
      );
    }
  }
}
