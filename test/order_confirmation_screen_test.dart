import 'dart:math';

import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/catalog/domain/models/catalog_models.dart';
import 'package:customerapp/features/checkout/domain/models/address_models.dart';
import 'package:customerapp/features/checkout/domain/models/order_models.dart';
import 'package:customerapp/features/checkout/domain/models/payment_models.dart';
import 'package:customerapp/features/checkout/presentation/screens/order_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

ProductVariant _variant(String id, String name, double price) {
  return ProductVariant(
    id: id,
    productId: 'p-$id',
    productName: name,
    sku: 'SKU-$id',
    brandId: 'b-$id',
    brandName: 'Brand',
    categoryId: 'c-$id',
    categoryName: name,
    subCategoryId: 's-$id',
    subCategoryName: name,
    description: '',
    price: price,
    unit: 'piece',
    icon: 'inventory_2',
    rating: 4.5,
    reviewCount: 10,
    stockStatus: StockStatus.values.first,
    specifications: const {},
  );
}

/// Screenshot order: ₹12,200 of items + 18% GST = ₹14,396.
CartController _seededCart() {
  return CartController()
    ..addVariant(_variant('1', 'Ultratech Cement', 600), quantity: 2)
    ..addVariant(_variant('2', 'Red Bricks', 350), quantity: 10)
    ..addVariant(_variant('3', 'TMT Steel Bars', 1500), quantity: 5);
}

PlacedOrder _order({PaymentMethod method = PaymentMethod.upi}) {
  return PlacedOrder.fromCart(
    _seededCart(),
    address: MockAddresses.saved.first,
    delivery: DeliveryOption.standard,
    method: method,
    random: Random(1),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PlacedOrder', () {
    test('snapshots cart lines and total', () {
      final order = _order();
      expect(order.lines, hasLength(3));
      expect(order.itemCount, 3);
      expect(order.total, 14396);
      expect(order.orderId, matches(RegExp(r'^#SC-\d{6}$')));
      expect(order.customerFirstName, 'Nandini');
    });

    test('adds the express delivery fee', () {
      final order = PlacedOrder.fromCart(
        _seededCart(),
        address: MockAddresses.saved.first,
        delivery: DeliveryOption.express,
        method: PaymentMethod.card,
      );
      expect(order.total, 14396 + 99);
    });
  });

  Future<void> pumpScreen(WidgetTester tester, PlacedOrder order) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartController(),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrderConfirmationScreen(order: order),
                    ),
                  ),
                  child: const Text('Shop home'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Shop home'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the screenshot content', (tester) async {
    final order = _order();
    await pumpScreen(tester, order);

    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.text('ORDER PLACED SUCCESSFULLY'), findsOneWidget);
    expect(find.text('Thank You, Nandini!'), findsOneWidget);
    expect(
      find.text('Order ID: ${order.orderId}', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('3 - 5 Business Days'), findsOneWidget);
    expect(find.text('Paid via UPI'), findsOneWidget);
    expect(find.text('Order Summary (3 items)'), findsOneWidget);
    expect(find.text('2x Ultratech Cement'), findsOneWidget);
    expect(find.text('₹7,500'), findsOneWidget);
    expect(find.text('Total Amount Paid'), findsOneWidget);
    expect(find.text('₹14,396'), findsOneWidget);
  });

  testWidgets('continue shopping returns to the first route', (tester) async {
    await pumpScreen(tester, _order());
    await tester.tap(find.text('Continue Shopping'));
    await tester.pumpAndSettle();

    expect(find.text('Shop home'), findsOneWidget);
    expect(find.byType(OrderConfirmationScreen), findsNothing);
  });

  testWidgets('cash on delivery shows amount payable', (tester) async {
    await pumpScreen(tester, _order(method: PaymentMethod.cod));

    expect(find.text('Pay on Delivery'), findsOneWidget);
    expect(find.text('Amount Payable'), findsOneWidget);
  });
}
