import 'package:bingo_app/features/player/widgets/camera_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CameraErrorView', () {
    testWidgets('permissão negada: explica e oferece Abrir configurações', (
      tester,
    ) async {
      await pumpApp(
        tester,
        CameraErrorView(
          error: const MobileScannerException(
            errorCode: MobileScannerErrorCode.permissionDenied,
          ),
          onRetry: () {},
        ),
        textScale: 1.3,
      );

      expect(find.text('Sem acesso à câmera'), findsOneWidget);
      expect(find.byKey(const Key('scan_open_settings')), findsOneWidget);
      expect(find.byKey(const Key('scan_retry_camera')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('erro genérico: mensagem neutra e Tentar de novo', (
      tester,
    ) async {
      var retries = 0;
      await pumpApp(
        tester,
        CameraErrorView(
          error: const MobileScannerException(
            errorCode: MobileScannerErrorCode.genericError,
          ),
          onRetry: () => retries++,
        ),
      );

      expect(find.byKey(const Key('scan_open_settings')), findsNothing);
      await tester.tap(find.byKey(const Key('scan_retry_camera')));
      await tester.pump();
      expect(retries, 1);
    });
  });
}
