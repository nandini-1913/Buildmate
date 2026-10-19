import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

<<<<<<< Updated upstream
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/state/catalog_controller.dart';
=======
import 'core/firebase/firebase_bootstrap.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/state/catalog_controller.dart';
import 'core/state/location_controller.dart';
import 'core/state/order_history_controller.dart';
>>>>>>> Stashed changes
import 'core/state/cart_controller.dart';
import 'core/state/profile_controller.dart';
import 'core/state/quotation_controller.dart';
import 'core/state/recently_viewed_controller.dart';
import 'core/state/reward_controller.dart';
import 'core/state/session_controller.dart';
import 'core/state/wishlist_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/rewards/data/in_memory_reward_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final sessionController = SessionController();
<<<<<<< Updated upstream
  await sessionController.restore();

  runApp(BuildMateApp(sessionController: sessionController));
=======
  runApp(ShivaniConstructionsApp(sessionController: sessionController));
  unawaited(_initializeServices(sessionController));
}

Future<void> _initializeServices(SessionController sessionController) async {
  final firebaseInitialization = FirebaseBootstrap.initialize();
  await sessionController.restore();
  await firebaseInitialization;
  await sessionController.syncFromFirebase();
>>>>>>> Stashed changes
}

class BuildMateApp extends StatelessWidget {
  const BuildMateApp({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionController),
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
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OrderHistoryController()),
        ChangeNotifierProvider(
          create: (context) => RewardController(
            quotationController: context.read<QuotationController>(),
            repository: InMemoryRewardRepository.withDemoSeed(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
