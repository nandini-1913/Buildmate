import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:customerapp/core/state/session_controller.dart';
import 'package:customerapp/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App launches splash screen', (WidgetTester tester) async {
    final sessionController = SessionController();
    await sessionController.restore();
    await tester.pumpWidget(
      BuildMateApp(sessionController: sessionController),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);

    // Complete splash delay so no pending timers remain.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
  });
}
