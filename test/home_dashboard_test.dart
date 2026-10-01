import 'package:customerapp/core/routes/app_routes.dart';
import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/state/profile_controller.dart';
import 'package:customerapp/core/state/quotation_controller.dart';
import 'package:customerapp/core/state/recently_viewed_controller.dart';
import 'package:customerapp/core/state/reward_controller.dart';
import 'package:customerapp/core/state/session_controller.dart';
import 'package:customerapp/core/state/wishlist_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedController()),
        ChangeNotifierProvider(create: (_) => QuotationController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(
          create: (context) => RewardController(
            quotationController: context.read<QuotationController>(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: child,
      ),
    );
  }

  testWidgets('Home dashboard shows session user and sections', (tester) async {
    final exceptions = <Object>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      exceptions.add(details.exceptionAsString());
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(wrap(const MainShell()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Rajesh Kumar'), findsOneWidget);
    expect(find.text('What are you looking for today?'), findsOneWidget);
    expect(find.text('Reward Points'), findsOneWidget);
    expect(find.text('Featured Products'), findsOneWidget);
    expect(find.text('Popular Brands'), findsOneWidget);
    expect(find.text('Construction Tools'), findsOneWidget);
    expect(exceptions, isEmpty, reason: exceptions.join('\n---\n'));
  });

  testWidgets('Auth still targets home placeholder route', (tester) async {
    expect(AppRoutes.homePlaceholder, '/home-placeholder');
  });
}
