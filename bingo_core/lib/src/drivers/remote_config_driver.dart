import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'i_config_driver.dart';

class RemoteConfigDriver implements IConfigDriver {
  FirebaseRemoteConfig? _remoteConfig;

  RemoteConfigDriver({FirebaseRemoteConfig? remoteConfig}) {
    if (remoteConfig != null) {
      _remoteConfig = remoteConfig;
    } else {
      try {
        _remoteConfig = FirebaseRemoteConfig.instance;
      } catch (e) {
        // Firebase likely not initialized.
        // We will fallback to default values.
        if (kDebugMode) {
          log(
            'RemoteConfigDriver: Firebase não inicializado; usando defaults. $e',
          );
        }
        _remoteConfig = null;
      }
    }
  }

  @override
  Future<void> fetchAndActivate() async {
    if (_remoteConfig == null) return;

    try {
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // In debug mode, we can reduce the minimumFetchInterval to 0 to fetch instantly
      if (kDebugMode) {
        await _remoteConfig!.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 1),
            minimumFetchInterval: const Duration(seconds: 0),
          ),
        );
      }

      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      if (kDebugMode) {
        log('RemoteConfigDriver: fetch falhou: $e');
      }
    }
  }

  @override
  bool getBool(String key) {
    if (_remoteConfig == null) return false; // Default safe value
    return _remoteConfig!.getBool(key);
  }

  @override
  int getInt(String key) {
    if (_remoteConfig == null) return 0; // Default safe value
    return _remoteConfig!.getInt(key);
  }

  @override
  String getString(String key) {
    if (_remoteConfig == null) return ''; // Default safe value
    return _remoteConfig!.getString(key);
  }
}
