import 'package:customerapp/core/routes/app_routes.dart';
import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/checkout/domain/models/address_models.dart';
import 'package:customerapp/features/checkout/presentation/screens/select_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const newAddress = DeliveryAddress(
    fullName: 'Ravi Kumar',
    mobile: '9123456780',
    pincode: '411001',
    city: 'Pune',
    state: 'Maharashtra',
    house: 'Site 7',
    area: 'FC Road',
    type: AddressType.other,
    customLabel: 'Warehouse',
    isDefault: false,
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartController(),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SelectAddressScreen(),
          onGenerateRoute: (settings) => settings.name == AppRoutes.addAddress
              ? MaterialPageRoute<DeliveryAddress>(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () => Navigator.of(context).pop(newAddress),
                      child: const Text('fake save'),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows mock addresses and delivery options', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    expect(find.text('Standard Delivery'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('Express Delivery'), findsOneWidget);
    expect(find.text('Proceed to Payment'), findsOneWidget);
  });

  testWidgets('express delivery adds its fee to the total', (tester) async {
    await pumpScreen(tester);
    expect(find.text('₹0'), findsOneWidget);

    await tester.tap(find.text('Express Delivery'));
    await tester.pump();
    expect(find.text('₹99'), findsNWidgets(2));
  });

  testWidgets('Add New opens the form and selects the saved address',
      (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Add New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('fake save'));
    await tester.pumpAndSettle();

    expect(find.text('Warehouse'), findsOneWidget);
    final card = find.ancestor(
      of: find.text('Warehouse'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.selected ?? false),
      ),
    );
    expect(card, findsOneWidget);
  });
}
