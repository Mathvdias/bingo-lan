import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fast startup test', (WidgetTester tester) async {
    // Teste extremamente rápido - apenas cria um MaterialApp simples
    print('🚀 Starting fast test...');
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Fast Test')),
          body: const Center(
            child: Text('Test Running'),
          ),
        ),
      ),
    );

    // Pump rápido sem esperar
    await tester.pump();
    
    // Verificação imediata
    expect(find.text('Fast Test'), findsOneWidget);
    expect(find.text('Test Running'), findsOneWidget);
    
    print('✅ Fast test completed!');
  });
}
