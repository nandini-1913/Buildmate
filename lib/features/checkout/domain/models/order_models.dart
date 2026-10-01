import 'dart:math';

import '../../../../core/state/cart_controller.dart';
import 'address_models.dart';
import 'payment_models.dart';

/// One line of a placed order, copied out of the cart.
class OrderLine {
  const OrderLine({
    required this.name,
    required this.quantity,
    required this.total,
  });

  final String name;
  final int quantity;
  final double total;
}

/// Snapshot of an order taken when "Place Order" succeeds, so the
/// confirmation screen still has the details after the cart is cleared.
class PlacedOrder {
  const PlacedOrder({
    required this.orderId,
    required this.lines,
    required this.total,
    required this.address,
    required this.delivery,
    required this.method,
  });

  /// Builds the order from the current cart. [random] is injectable for tests.
  factory PlacedOrder.fromCart(
    CartController cart, {
    required DeliveryAddress address,
    required DeliveryOption delivery,
    required PaymentMethod method,
    Random? random,
  }) {
    final number = 100000 + (random ?? Random()).nextInt(900000);
    return PlacedOrder(
      orderId: '#SC-$number',
      lines: [
        for (final item in cart.items)
          OrderLine(
            name: item.variant.productName,
            quantity: item.quantity,
            total: item.totalPrice,
          ),
      ],
      total: cart.grandTotal + delivery.fee,
      address: address,
      delivery: delivery,
      method: method,
    );
  }

  final String orderId;
  final List<OrderLine> lines;
  final double total;
  final DeliveryAddress address;
  final DeliveryOption delivery;
  final PaymentMethod method;

  /// Distinct products, matching the cart's "N items" wording.
  int get itemCount => lines.length;

  /// Cash on delivery is collected later; every other method is prepaid.
  bool get isPaid => method != PaymentMethod.cod;

  String get paymentStatus => switch (method) {
    PaymentMethod.upi => 'Paid via UPI',
    PaymentMethod.card => 'Paid via Card',
    PaymentMethod.netBanking => 'Paid via Net Banking',
    PaymentMethod.cod => 'Pay on Delivery',
  };

  String get customerFirstName {
    final name = address.fullName.trim();
    return name.isEmpty ? 'there' : name.split(RegExp(r'\s+')).first;
  }
}
