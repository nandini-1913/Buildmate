import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/recently_viewed_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../catalog/data/mock/catalog_mock_data.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../widgets/construction_tools_section.dart';
import '../widgets/current_offers_section.dart';
import '../widgets/featured_products_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_category_card.dart';
import '../widgets/home_location_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/popular_brands_section.dart';
import '../widgets/popular_products_section.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recently_viewed_section.dart';
import '../../domain/models/home_models.dart' as legacy;

/// Home tab content for [MainShell].
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  void _open(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  void _openProduct(CatalogProduct product) {
    _open(
      AppRoutes.productDetail,
      arguments: ProductDetailArgs(productId: product.id),
    );
  }

  void _openVariant(ProductVariant variant) {
    _open(
      AppRoutes.productDetail,
      arguments: ProductDetailArgs(
        productId: variant.productId,
        variantId: variant.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    final recentlyViewed = context.watch<RecentlyViewedController>().items;

    final quickActions = CatalogMockData.quickActions
        .map(
          (a) => legacy.QuickAction(
            id: a.id,
            title: a.title,
            icon: a.icon,
            routeName: a.routeName,
            iconColor: a.iconColor,
            iconBackground: a.iconBackground,
          ),
        )
        .toList();

    final categories = CatalogMockData.categories
        .map(
          (c) => legacy.HomeCategory(
            id: c.id,
            name: c.name,
            itemCount: c.itemCount,
            icon: c.icon,
            iconColor: c.iconColor,
            iconBackground: c.iconBackground,
            imageAsset: c.imageAsset,
          ),
        )
        .toList();

    final brands = CatalogMockData.brands
        .map(
          (b) => legacy.HomeBrand(
            id: b.id,
            name: b.name,
            productCount: b.productCount,
            abbreviation: b.abbreviation,
            color: b.color,
            logoAsset: b.logoAsset,
          ),
        )
        .toList();

    final offers = CatalogMockData.offers
        .map(
          (o) => legacy.HomeOffer(
            id: o.id,
            discountLabel: o.discountText,
            title: o.title,
            subtitle: o.minimumOrder.isNotEmpty ? o.minimumOrder : o.description,
            endsOn: o.validUntil,
            ctaLabel: 'Explore',
            routeName: AppRoutes.offerDetail,
          ),
        )
        .toList();

    final tools = CatalogMockData.tools
        .map(
          (t) => legacy.ConstructionTool(
            id: t.id,
            title: t.title,
            subtitle: t.subtitle,
            icon: t.icon,
            routeName: t.routeName,
          ),
        )
        .toList();

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeAppBar(
            user: user,
            onRewards: () => _open(AppRoutes.myRewards),
            onNotifications: () => _open(AppRoutes.notifications),
            onProfile: () => _open(AppRoutes.profile),
            onCart: () => _open(AppRoutes.cart),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space3,
                      AppSpacing.space4,
                      0,
                    ),
                    child: HomeLocationBar(
                      label: 'Home',
                      address: 'B-14/15, Navprena CHS, Sector 8, Chembur',
                      onTap: () => _open(
                        AppRoutes.chooseLocation,
                        arguments: SignupFlowArgs(
                          mobileNumber: user.phone ?? '',
                          fullName: user.name,
                          isLocationUpdate: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space3,
                      AppSpacing.space4,
                      0,
                    ),
                    child: HomeSearchBar(
                      onTap: () => _open(AppRoutes.search),
                      onVoice: () => _open(AppRoutes.search),
                      onScan: () => _open(AppRoutes.search),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: QuickActionsRow(
                      actions: quickActions,
                      onTap: (action) => _open(action.routeName),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: CategoriesSection(
                      categories: categories,
                      onViewAll: () => _open(AppRoutes.categories),
                      onCategoryTap: (category) {
                        _open(
                          AppRoutes.categoryBrowse,
                          arguments:
                              CategoryBrowseArgs(categoryId: category.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  FeaturedProductsSection(
                    products: CatalogMockData.featuredProducts,
                    onViewAll: () => _open(
                      AppRoutes.productList,
                      arguments:
                          const ProductListArgs(title: 'Featured Products'),
                    ),
                    onProductTap: _openProduct,
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  PopularBrandsSection(
                    brands: brands,
                    onViewAll: () => _open(AppRoutes.brands),
                    onBrandTap: (brand) {
                      _open(
                        AppRoutes.brandProducts,
                        arguments: BrandProductsArgs(brandId: brand.id),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: PopularProductsSection(
                      products: CatalogMockData.popularProducts,
                      onViewAll: () => _open(
                        AppRoutes.productList,
                        arguments:
                            const ProductListArgs(title: 'Popular Products'),
                      ),
                      onProductTap: _openProduct,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  RecentlyViewedSection(
                    products: recentlyViewed,
                    onViewAll: recentlyViewed.isEmpty
                        ? null
                        : () => _open(
                              AppRoutes.productList,
                              arguments: const ProductListArgs(
                                title: 'Recently Viewed',
                              ),
                            ),
                    onTap: _openVariant,
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  CurrentOffersSection(
                    offers: offers,
                    onViewAll: () => _open(AppRoutes.offers),
                    onExplore: (offer) {
                      _open(
                        AppRoutes.offerDetail,
                        arguments: OfferDetailArgs(offerId: offer.id),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: ConstructionToolsSection(
                      tools: tools,
                      onViewAll: () => _open(AppRoutes.materialCalculator),
                      onToolTap: (tool) => _open(tool.routeName),
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.space16 + AppSpacing.space12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space4,
        0,
        AppSpacing.space4,
        AppSpacing.space5,
      ),
      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
    );
  }
}
