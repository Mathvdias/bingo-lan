import 'package:flutter/widgets.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:bingo_app/core/config/env.dart';

/// Service for Microsoft Clarity session recording and heatmaps
class ClarityService {
  static const String projectId = Env.clarityProjectId;

  /// Get Clarity configuration
  static ClarityConfig get config => ClarityConfig(
    projectId: projectId,
    logLevel: LogLevel.Verbose, // Changed to Verbose for debugging
  );

  /// Get ClarityWidget to wrap the app
  /// Usage: ClarityWidget(app: MyApp(), clarityConfig: ClarityService.config)
  static Widget wrapApp(Widget app) {
    return ClarityWidget(app: app, clarityConfig: config);
  }
}
