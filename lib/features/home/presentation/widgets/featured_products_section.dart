import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/cart_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import 'home_section_header.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({
    super.key,
    required this.variants,
    this.onViewAll,
    this.onVariantTap,
    this.isLoading = false,
  });

  final List<ProductVariant> variants;
  final VoidCallback? onViewAll;
  final void Function(ProductVariant variant)? onVariantTap;
  final bool isLoading;

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
        if (isLoading && variants.isEmpty)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (variants.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Text(
              'No featured products from server yet.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          )
        else
          SizedBox(
            height: 228,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
              itemCount: variants.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.space3),
              itemBuilder: (context, index) {
                final variant = variants[index];
                return FeaturedProductCard(
                  variant: variant,
                  onTap: () => onVariantTap?.call(variant),
                );
              },
            ),
          ),
      ],
    );
  }
}

class FeaturedProductCard extends StatelessWidget {
<<<<<<< Updated upstream
  const FeaturedProductCard({super.key, required this.product, this.onTap});
=======
  const FeaturedProductCard({
    super.key,
    required this.variant,
    this.onTap,
  });
>>>>>>> Stashed changes

  final ProductVariant variant;
  final VoidCallback? onTap;

  void _addToCart(BuildContext context) {
    if (!variant.inStock) return;
    context.read<CartController>().addVariant(variant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${variant.displayName} added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 132,
      height: 228,
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
                imageAsset: '',
                imageUrl: variant.imageUrl,
                fallbackIcon: variant.icon,
                fallbackIconColor: AppColors.primary,
                fallbackBackground: AppColors.surfaceContainer,
                width: double.infinity,
                height: 72,
                fit: BoxFit.cover,
                iconSize: AppSpacing.space6,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space2,
                    AppSpacing.space2,
                    AppSpacing.space2,
                    AppSpacing.space2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
<<<<<<< Updated upstream
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
=======
                      Text(
                        variant.brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        variant.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${variant.priceLabel} / ${variant.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      StockStatusChip(inStock: variant.inStock),
                      const SizedBox(height: AppSpacing.space1),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: FilledButton(
                          onPressed:
                              variant.inStock ? () => _addToCart(context) : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            textStyle: theme.textTheme.labelSmall,
                          ),
                          child: const Text('Add'),
                        ),
                      ),
>>>>>>> Stashed changes
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
