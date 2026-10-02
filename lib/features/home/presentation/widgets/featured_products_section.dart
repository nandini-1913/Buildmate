import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../../catalog/data/mock/catalog_mock_data.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import 'home_section_header.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({
    super.key,
    required this.products,
    this.onViewAll,
    this.onProductTap,
  });

  final List<CatalogProduct> products;
  final VoidCallback? onViewAll;
  final void Function(CatalogProduct product)? onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: HomeSectionHeader(
            title: 'Featured Products',
            onViewAll: onViewAll,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        SizedBox(
          height: 348,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            itemCount: products.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.space3),
            itemBuilder: (context, index) {
              final product = products[index];
              return FeaturedProductCard(
                product: product,
                onTap: () => onProductTap?.call(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeaturedProductCard extends StatelessWidget {
  const FeaturedProductCard({super.key, required this.product, this.onTap});

  final CatalogProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final from = CatalogMockData.cheapestVariantFor(product.id);
    final brandName = from?.brandName ?? product.categoryName;
    final rating = from?.rating;
    final inStock = from?.inStock ?? true;

    return SizedBox(
      width: 176,
      height: 348,
      child: Material(
        color: AppColors.surface,
        elevation: AppElevation.level1,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: const BorderSide(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryImage(
                imageAsset: product.imageAsset,
                fallbackIcon: product.icon,
                fallbackIconColor: AppColors.primary,
                fallbackBackground: AppColors.surfaceContainer,
                width: double.infinity,
                height: 112,
                fit: BoxFit.cover,
                iconSize: AppSpacing.space8,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  brandName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  product.specSummary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption(
                                    color: AppColors.outline,
                                  ),
                                ),
                                if (rating != null) ...[
                                  const SizedBox(height: AppSpacing.space1),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: AppTypography.caption(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.space1),
                                Text(
                                  from == null
                                      ? product.priceWithUnit
                                      : '${from.priceLabel} / ${product.unit}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space1),
                                StockStatusChip(inStock: inStock),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ProductActionBar(product: product, compact: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
