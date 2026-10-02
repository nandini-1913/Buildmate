import 'package:customerapp/core/state/profile_controller.dart';
import 'package:customerapp/core/state/quotation_controller.dart';
import 'package:customerapp/core/state/reward_controller.dart';
import 'package:customerapp/core/state/session_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/catalog/domain/models/catalog_models.dart';
import 'package:customerapp/features/profile/data/in_memory_profile_repository.dart';
import 'package:customerapp/features/profile/domain/models/profile_models.dart';
import 'package:customerapp/features/profile/presentation/screens/profile_tab_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const testUser = AppUserProfile(
    id: 'user-live-1',
    name: 'Rishi Dev',
    email: 'rishi.dev@example.com',
    phone: '+91 98765 43210',
  );

  Future<ProfileController> pumpScreen(
    WidgetTester tester, {
    AppUserProfile user = testUser,
  }) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final session = SessionController()..setUser(user);
    final profile = ProfileController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: session),
          ChangeNotifierProvider(create: (_) => QuotationController()),
          ChangeNotifierProvider(
            create: (context) => RewardController(
              quotationController: context.read<QuotationController>(),
            ),
          ),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ProfileTabBody(showBackButton: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return profile;
  }

  testWidgets('shows live personal info and KYC sections with clean state',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('PAN Details'), findsOneWidget);
    expect(find.text('GST Details'), findsOneWidget);
    expect(find.text('Bank Details'), findsOneWidget);
    expect(find.text('Rishi Dev'), findsWidgets);
    expect(find.text('rishi.dev@example.com'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
    expect(find.text('Not Editable'), findsOneWidget);
  });

  testWidgets('approved section is locked', (tester) async {
    final profile = await pumpScreen(tester);

    final current = profile.details!;
    final approvedProfile = current.copyWith(
      pan: const PanDetails(
        panNumber: 'ABCDE1234F',
        nameOnDocument: 'Rishi Dev',
        document: null,
        status: VerificationStatus.approved,
      ),
    );
    await profile.savePan(
      panNumber: approvedProfile.pan.panNumber,
      nameOnDocument: approvedProfile.pan.nameOnDocument,
    );
    // Directly save approved profile into repository for the test
    final repo = InMemoryProfileRepository();
    await repo.save(testUser.id, approvedProfile);
    await profile.loadForUser(testUser);
    await tester.pumpAndSettle();

    await tester.tap(find.text('PAN Details'));
    await tester.pumpAndSettle();

    expect(find.text('Edit PAN Details'), findsNothing);
    expect(
      find.text('PAN details are approved and can no longer be changed.'),
      findsOneWidget,
    );
  });

  testWidgets('editing an unsubmitted section validates and submits for approval',
      (tester) async {
    final profile = await pumpScreen(tester);

    await tester.tap(find.text('GST Details'));
    await tester.pumpAndSettle();
    expect(find.text('Edit GST Details'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'GST Number *'), '123');
    await tester.tap(find.text('Submit for Approval'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid 15-character GSTIN'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'GST Number *'),
      '27aapfu0939f1zv',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name on Document *'),
      'Rishi Dev',
    );
    await tester.tap(find.text('Submit for Approval'));
    await tester.pumpAndSettle();

    expect(profile.details!.gst.gstNumber, '27AAPFU0939F1ZV');
    expect(profile.details!.gst.status, VerificationStatus.pending);
    expect(find.text('27AAPFU0939F1ZV'), findsOneWidget);
  });

  testWidgets('editing personal info updates the session name', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Personal Information'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name *'),
      'Pushpendra Pancholi',
    );
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ProfileTabBody));
    expect(context.read<SessionController>().user.name, 'Pushpendra Pancholi');
    expect(find.text('Pushpendra Pancholi'), findsOneWidget);
    expect(find.text('PP'), findsOneWidget);
  });

  test('maskAccountNumber keeps the last 4 digits', () {
    expect(maskAccountNumber('123456781234'), 'XXXXXXXX1234');
  });
}
