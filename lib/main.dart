import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/state/catalog_controller.dart';
import 'core/state/cart_controller.dart';
import 'core/state/quotation_controller.dart';
import 'core/state/recently_viewed_controller.dart';
import 'core/state/reward_controller.dart';
import 'core/state/session_controller.dart';
import 'core/state/wishlist_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/firebase_phone_auth_service.dart';
import 'features/rewards/data/in_memory_reward_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp();

  final sessionController = SessionController();
  await sessionController.restore();

  runApp(ShivaniConstructionsApp(sessionController: sessionController));
}

class ShivaniConstructionsApp extends StatelessWidget {
  const ShivaniConstructionsApp({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionController),
        Provider<AuthService>(create: (_) => FirebasePhoneAuthService()),
        ChangeNotifierProvider(
          create: (_) {
            final controller = CatalogController();
            controller.startPipeCatalogSync();
            return controller;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedController()),
        ChangeNotifierProvider(create: (_) => QuotationController()),
        ChangeNotifierProvider(
          create: (context) => RewardController(
            quotationController: context.read<QuotationController>(),
            repository: InMemoryRewardRepository.withDemoSeed(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Buildmate 24x7',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
