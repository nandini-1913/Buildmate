import 'package:customerapp/core/routes/app_router.dart';
import 'package:customerapp/core/routes/app_routes.dart';
import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/checkout/domain/models/address_models.dart';
import 'package:customerapp/features/checkout/domain/models/payment_models.dart';
import 'package:customerapp/features/checkout/presentation/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpScreen(
    WidgetTester tester, {
    DeliveryOption delivery = DeliveryOption.standard,
  }) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartController(),
        child: MaterialApp(
          theme: AppTheme.light(),
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: PaymentScreen(
            args: PaymentArgs(
              address: MockAddresses.saved.first,
              delivery: delivery,
            ),
            processingDelay: const Duration(milliseconds: 10),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows all methods with UPI selected and expanded',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('Step 3 of 4'), findsOneWidget);
    for (final method in PaymentMethod.values) {
      expect(find.text(method.label), findsOneWidget);
    }
    expect(find.text('Enter UPI ID (e.g. 9876543210@paytm)'), findsOneWidget);
    expect(
      find.text('Guaranteed 256-bit SSL encrypted safe checkout'),
      findsOneWidget,
    );
  });

  testWidgets('place order total includes the delivery fee', (tester) async {
    await pumpScreen(tester, delivery: DeliveryOption.express);
    expect(find.text('Place Order (₹99)'), findsOneWidget);
  });

  testWidgets('invalid UPI ID blocks the order', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField), 'not-a-upi');
    await tester.tap(find.text('Place Order (₹0)'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid UPI ID (e.g. name@okaxis)'), findsOneWidget);
  });

  testWidgets('valid UPI ID places the order and opens confirmation',
      (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField), '9876543210@paytm');
    await tester.tap(find.text('Place Order (₹0)'));
    await tester.pumpAndSettle();

    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Thank You, Nandini!'), findsOneWidget);
    expect(find.text('Paid via UPI'), findsOneWidget);
  });

  testWidgets('selecting card swaps UPI field for card fields', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Credit / Debit Card'));
    await tester.pumpAndSettle();

    expect(find.text('Enter UPI ID (e.g. 9876543210@paytm)'), findsNothing);
    expect(find.text('Card number'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Card number'),
      '4111111111111111',
    );
    expect(find.text('4111 1111 1111 1111'), findsOneWidget);
  });

  testWidgets('cash on delivery needs no extra input', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Cash on Delivery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Order (₹0)'));
    await tester.pumpAndSettle();

    expect(find.text('Pay on Delivery'), findsOneWidget);
    expect(find.text('Amount Payable'), findsOneWidget);
  });

  group('PaymentValidators', () {
    test('card number uses Luhn', () {
      expect(PaymentValidators.cardNumber('4111 1111 1111 1111'), isNull);
      expect(PaymentValidators.cardNumber('4111 1111 1111 1112'), isNotNull);
    });

    test('expiry rejects past months', () {
      final now = DateTime(2026, 9, 29);
      expect(PaymentValidators.expiry('09/26', now: now), isNull);
      expect(PaymentValidators.expiry('08/26', now: now), 'Card expired');
      expect(PaymentValidators.expiry('13/27', now: now), 'Invalid month');
    });
  });
}
