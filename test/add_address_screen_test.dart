import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/checkout/domain/models/address_models.dart';
import 'package:customerapp/features/checkout/presentation/screens/add_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  /// Hosts the screen behind a button so the popped result can be read.
  Future<List<DeliveryAddress?>> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final results = <DeliveryAddress?>[];
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartController(),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                results.add(
                  await Navigator.of(context).push<DeliveryAddress>(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddAddressScreen(showMapPreview: false),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('shows validation errors when saving an empty form',
      (tester) async {
    final results = await pumpScreen(tester);
    await tester.tap(find.text('Save & Deliver Here'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Mobile number is required'), findsOneWidget);
    expect(find.text('Pincode is required'), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('pincode auto-fills city and state', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(field('Pincode'), '560076');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Bangalore'), findsOneWidget);
    expect(find.text('Karnataka'), findsOneWidget);
  });

  testWidgets('saves a filled form and pops with the address', (tester) async {
    final results = await pumpScreen(tester);

    await tester.enterText(field('Full Name'), 'Nandini Sharma');
    await tester.enterText(field('Mobile Number'), '9876543210');
    await tester.enterText(field('Pincode'), '560001');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(field('House / Flat / Building No.'), 'Plot 45');
    await tester.enterText(field('Area / Street / Landmark'), 'Tech Park Road');
    await tester.tap(find.text('Office'));
    await tester.tap(find.text('Make this my default address'));
    await tester.pump();

    await tester.tap(find.text('Save & Deliver Here'));
    await tester.pumpAndSettle();

    expect(results, hasLength(1));
    final address = results.single!;
    expect(address.fullName, 'Nandini Sharma');
    expect(address.mobile, '9876543210');
    expect(address.city, 'Bangalore');
    expect(address.state, 'Karnataka');
    expect(address.type, AddressType.office);
    expect(address.isDefault, isTrue);
  });
}
