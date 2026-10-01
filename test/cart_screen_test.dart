import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/state/quotation_controller.dart';
import 'package:customerapp/core/state/session_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/catalog/domain/models/catalog_models.dart';
import 'package:customerapp/features/catalog/presentation/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

ProductVariant _variant(String id, String name, double price, String unit) {
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
    unit: unit,
    icon: 'inventory_2',
    rating: 4.5,
    reviewCount: 10,
    stockStatus: StockStatus.values.first,
    specifications: const {},
  );
}

/// Screenshot cart: 2 × ₹600 + 10 × ₹350 + 5 × ₹1,500 = ₹12,200.
CartController _seededCart() {
  return CartController()
    ..addVariant(_variant('1', 'Cement 50kg', 600, 'bag'), quantity: 2)
    ..addVariant(_variant('2', 'Red Bricks', 350, 'piece'), quantity: 10)
    ..addVariant(_variant('3', 'TMT Steel Bars', 1500, 'piece'), quantity: 5);
}

void main() {
  group('CartController pricing', () {
    test('matches the reference totals', () {
      final cart = _seededCart();
      expect(cart.subtotal, 12200);
      expect(cart.shipping, 0); // over the free-shipping threshold
      expect(cart.gst, 2196);
      expect(cart.grandTotal, 14396);
    });

    test('BUILD10 takes 10% off before GST', () {
      final cart = _seededCart();
      expect(cart.applyCoupon(' build10 '), CartCoupon.build10);
      expect(cart.discount, 1220);
      expect(cart.gst, 1976);
      expect(cart.grandTotal, 12200 - 1220 + 1976);
    });

    test('FREESHIP waives shipping below the threshold', () {
      final cart = CartController()
        ..addVariant(_variant('1', 'Cement', 600, 'bag'), quantity: 2);
      expect(cart.shipping, CartController.shippingFee);
      cart.applyCoupon('FREESHIP');
      expect(cart.shipping, 0);
    });

    test(
      'unknown coupon is rejected and emptying the cart drops the coupon',
      () {
        final cart = _seededCart();
        expect(cart.applyCoupon('NOPE'), isNull);
        cart.applyCoupon('BUILD10');
        cart.clear();
        expect(cart.coupon, isNull);
      },
    );

    test('quantity is capped at 99', () {
      final cart = _seededCart();
      cart.setQuantity('1', 150);
      expect(cart.quantityOf('1'), CartController.maxQuantity);
    });
  });

  group('CartScreen', () {
    setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

    Widget wrap(CartController cart) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SessionController()),
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider(create: (_) => QuotationController()),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const CartScreen()),
      );
    }

    FilledButton proceedButton(WidgetTester tester) => tester.widget(
      find.ancestor(
        of: find.text('Proceed to Address'),
        matching: find.byType(FilledButton),
      ),
    );

    testWidgets('empty cart hides the checkout bar and stepper', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(wrap(CartController()));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Proceed to Address'), findsNothing);
      expect(find.textContaining('Total Amount'), findsNothing);
      expect(find.text('1. Cart'), findsNothing);
      expect(find.text('Step 1 of 4'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('renders items, steps quantity and removes an item', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = _seededCart();
      await tester.pumpWidget(wrap(cart));
      await tester.pumpAndSettle();

      expect(find.text('Review Items (3)'), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Price Details'), findsOneWidget);
      expect(proceedButton(tester).onPressed, isNotNull);

      await tester.tap(find.byTooltip('Increase quantity').first);
      await tester.pumpAndSettle();
      expect(cart.quantityOf('1'), 3);

      await tester.tap(find.byTooltip('Remove').first);
      await tester.pumpAndSettle();
      expect(find.text('Review Items (2)'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });
  });
}
