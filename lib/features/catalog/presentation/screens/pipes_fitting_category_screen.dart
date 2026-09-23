import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/cart_controller.dart';
import '../../../../core/state/catalog_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../data/repositories/pipes_fitting_repository.dart';
import '../../domain/models/catalog_models.dart';
import '../../domain/models/pipes_fitting_catalog_models.dart';
import '../widgets/pipes_filter_panel.dart';

/// Category-level entry screen for Plumbing Pipes & Fittings.
///
/// Single-page Category -> Type -> Sub-category drilldown: the left sidebar
/// lets the shopper pick a pipe Type (UPVC/PVC/CPVC) and a Sub-category
/// (Pipe/Fitting/Tubing), and the product grid on the right updates in
/// place — no new page is opened. Brand filtering is available from the
/// dedicated button in the header. Driven by the same UPVC/PVC/CPVC mock
/// catalog as before (assets/data/pipes_fitting_mock_data.json).
class PipesFittingCategoryScreen extends StatefulWidget {
  const PipesFittingCategoryScreen({super.key});

  @override
  State<PipesFittingCategoryScreen> createState() =>
      _PipesFittingCategoryScreenState();
}

enum _CatSection { all, upvc, pvc, cpvc }

abstract final class _CatSidebarImages {
  static const all = CatalogMockData.pipeAllThumbnailAsset;
  static const upvc = 'assets/images/categories/fittings.png';
  static const pvc = 'assets/images/pipes/single_pipe.png';
  static const cpvc = 'assets/images/categories/sanitary_wares.png';
}

class _CatSectionMeta {
  const _CatSectionMeta({
    required this.section,
    required this.label,
    required this.imageAsset,
  });

  final _CatSection section;
  final String label;
  final String imageAsset;
}

class _CategoryProductGroup {
  const _CategoryProductGroup({
    required this.title,
    required this.subCategory,
    required this.products,
    required this.imageAsset,
  });

  final String title;
  final String subCategory;
  final List<PipesFittingProduct> products;
  final String imageAsset;

  double get minMrp => products
      .map((p) => p.displayPrice)
      .reduce((a, b) => a < b ? a : b);

  String? get imageUrl {
    for (final product in products) {
      final url = product.imageUrl;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String get unit => 'pcs';

  String get discountLabel {
    final cheapest = products.reduce(
      (a, b) => a.displayPrice <= b.displayPrice ? a : b,
    );
    final discount = cheapest.discountPercent;
    if (discount == null || discount <= 0) return '';
    final percent = discount > 1 ? discount : discount * 100;
    return 'discount ${percent.round()}%';
  }
}

/// Maps a mock [PipesFittingProduct] into a [ProductVariant] so it can be
/// added to the shared [CartController] like any other catalog product.
ProductVariant _variantFor(
  PipesFittingProduct product,
  _CategoryProductGroup group,
) {
  final idParts = [
    product.brand,
    product.productName,
    product.size ?? '',
    product.productCode ?? '',
  ].join('|').toLowerCase();

  return ProductVariant(
    id: 'pipe-${idParts.hashCode}',
    productId: 'pipe-product-${idParts.hashCode}',
    productName: product.productName,
    sku: product.productCode ?? '',
    brandId: product.brand.toLowerCase(),
    brandName: product.brand,
    categoryId: CatalogMockData.pipesTubingCategoryId,
    categoryName: 'Pipes & Tubing',
    subCategoryId: group.subCategory.toLowerCase(),
    subCategoryName: group.subCategory,
    description: group.title,
    price: product.displayPrice,
    unit: group.unit,
    icon: 'plumbing',
    rating: 0,
    reviewCount: 0,
    stockStatus: (product.stock != null && product.stock! <= 0)
        ? StockStatus.outOfStock
        : StockStatus.inStock,
    specifications: {
      if (product.size != null) 'Size': product.size!,
      if (product.length != null) 'Length': product.length!,
      if (product.stdPkg != null) 'Std. Packaging': product.stdPkg!,
    },
    imageAsset: group.imageAsset,
    mrp: product.mrp,
    discountRate: product.discountPercent == null
        ? null
        : (product.discountPercent! > 1
            ? product.discountPercent! / 100
            : product.discountPercent),
    imageUrl: product.imageUrl,
  );
}

class _PipesFittingCategoryScreenState
    extends State<PipesFittingCategoryScreen> {
  static const _sections = [
    _CatSectionMeta(
      section: _CatSection.all,
      label: 'All',
      imageAsset: _CatSidebarImages.all,
    ),
    _CatSectionMeta(
      section: _CatSection.pvc,
      label: 'PVC',
      imageAsset: _CatSidebarImages.pvc,
    ),
    _CatSectionMeta(
      section: _CatSection.cpvc,
      label: 'CPVC',
      imageAsset: _CatSidebarImages.cpvc,
    ),
    _CatSectionMeta(
      section: _CatSection.upvc,
      label: 'UPVC',
      imageAsset: _CatSidebarImages.upvc,
    ),
  ];

  late final Future<PipesFittingCatalog> _catalogFuture;

  _CatSection _section = _CatSection.all;
  String? _subCategory;
  PipeModuleSort _sort = PipeModuleSort.all;
  String? _selectedBrand;
  String? _size;
  final GlobalKey _sortButtonKey = GlobalKey();
  final GlobalKey _sizeButtonKey = GlobalKey();
  final GlobalKey _brandButtonKey = GlobalKey();
  OverlayEntry? _sortOverlay;
  OverlayEntry? _sizeOverlay;
  OverlayEntry? _brandOverlay;

  @override
  void initState() {
    super.initState();
    _catalogFuture = PipesFittingRepository.load();
  }

  @override
  void dispose() {
    _closeSortMenu();
    _closeSizeMenu();
    _closeBrandMenu();
    super.dispose();
  }

  String? _typeNameForSection(_CatSection section) {
    switch (section) {
      case _CatSection.all:
        return null;
      case _CatSection.upvc:
        return 'UPVC';
      case _CatSection.pvc:
        return 'PVC';
      case _CatSection.cpvc:
        return 'CPVC';
    }
  }

  String _imageForType(String typeName) {
    switch (typeName) {
      case 'PVC':
        return _CatSidebarImages.pvc;
      case 'UPVC':
        return _CatSidebarImages.upvc;
      case 'CPVC':
        return _CatSidebarImages.cpvc;
      default:
        return _CatSidebarImages.all;
    }
  }

  List<String> _subCategoryNames(PipesFittingCatalog catalog) {
    final names = <String>[];
    for (final type in catalog.types) {
      for (final sub in type.subCategories) {
        if (!names.any((n) => n.toLowerCase() == sub.subCategory.toLowerCase())) {
          names.add(sub.subCategory);
        }
      }
    }
    return names;
  }

  List<_CategoryProductGroup> _groupsForSection(
    PipesFittingCatalog catalog,
    _CatSection section,
    String? subCategory,
  ) {
    final typeName = _typeNameForSection(section);
    final types = typeName == null
        ? catalog.types
        : catalog.types.where((t) => t.type == typeName);

    final groups = <_CategoryProductGroup>[];
    for (final type in types) {
      for (final sub in type.subCategories) {
        if (subCategory != null &&
            sub.subCategory.toLowerCase() != subCategory.toLowerCase()) {
          continue;
        }
        for (final cls in sub.classes) {
          if (cls.products.isEmpty) continue;
          groups.add(
            _CategoryProductGroup(
              title: '${type.type} ${sub.subCategory} (${cls.className})',
              subCategory: sub.subCategory,
              products: cls.products,
              imageAsset: _imageForType(type.type),
            ),
          );
        }
      }
    }
    return groups;
  }

  bool _matchesBrand(_CategoryProductGroup group, String brand) {
    return group.products.any(
      (p) => p.brand.toLowerCase() == brand.toLowerCase(),
    );
  }

  bool _matchesSize(_CategoryProductGroup group, String sizeLabel) {
    final targetMm = pipeSizeMmValue(sizeLabel);
    if (targetMm == null) return false;
    return group.products.any((p) {
      final raw = p.size ?? '';
      final mm = pipeSizeMmValue(raw);
      if (mm != null && mm == targetMm) return true;
      return raw.toLowerCase().contains('${targetMm.toInt()}');
    });
  }

  List<_CategoryProductGroup> _filteredGroups(PipesFittingCatalog catalog) {
    var groups = _groupsForSection(catalog, _section, _subCategory);

    if (_selectedBrand != null) {
      groups = groups.where((g) => _matchesBrand(g, _selectedBrand!)).toList();
    }
    if (_size != null && _size!.isNotEmpty) {
      groups = groups.where((g) => _matchesSize(g, _size!)).toList();
    }

    switch (_sort) {
      case PipeModuleSort.all:
        break;
      case PipeModuleSort.discount:
        break;
      case PipeModuleSort.priceLowHigh:
        groups.sort((a, b) => a.minMrp.compareTo(b.minMrp));
      case PipeModuleSort.whatsNew:
        groups = groups.reversed.toList();
      case PipeModuleSort.priceHighLow:
        groups.sort((a, b) => b.minMrp.compareTo(a.minMrp));
      case PipeModuleSort.ratings:
        break;
    }
    return groups;
  }

  String _pluralize(String value) =>
      value.toLowerCase().endsWith('s') ? value : '${value}s';

  String _titleFor(PipesFittingCatalog catalog) {
    final typeLabel = _typeNameForSection(_section);
    if (typeLabel == null && _subCategory == null) return catalog.category;
    if (typeLabel != null && _subCategory != null) {
      return '$typeLabel ${_pluralize(_subCategory!)}';
    }
    if (typeLabel != null) return '$typeLabel Products';
    return _pluralize(_subCategory!);
  }

  String _subtitleFor(PipesFittingCatalog catalog) {
    final typeLabel = _typeNameForSection(_section);
    if (_selectedBrand != null) {
      final scope = typeLabel ?? catalog.category;
      return '$_selectedBrand brand $scope products';
    }
    if (typeLabel != null && _subCategory != null) {
      return 'High quality $typeLabel ${_subCategory!.toLowerCase()}s for various applications';
    }
    if (typeLabel != null) {
      return 'Browse $typeLabel pipes, fittings and accessories';
    }
    return 'Wide range of pipes, fittings and accessories';
  }

  void _closeSortMenu() {
    _sortOverlay?.remove();
    _sortOverlay = null;
  }

  void _closeSizeMenu() {
    _sizeOverlay?.remove();
    _sizeOverlay = null;
  }

  void _closeBrandMenu() {
    _brandOverlay?.remove();
    _brandOverlay = null;
  }

  void _closeAllMenus() {
    _closeSortMenu();
    _closeSizeMenu();
    _closeBrandMenu();
  }

  void _showDropdown({
    required GlobalKey buttonKey,
    required ValueChanged<OverlayEntry?> setOverlay,
    required VoidCallback closeThis,
    required double menuWidth,
    required Widget Function() buildMenu,
  }) {
    final renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final entry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        const edgeMargin = AppSpacing.space3;
        // Anchor to the button's right edge, but clamp so the menu never
        // spills off either side of the screen.
        final maxLeft = screenWidth - menuWidth - edgeMargin;
        final left = (offset.dx + size.width - menuWidth)
            .clamp(edgeMargin, maxLeft < edgeMargin ? edgeMargin : maxLeft);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: closeThis,
              ),
            ),
            Positioned(
              top: offset.dy + size.height + AppSpacing.space1,
              left: left,
              width: menuWidth,
              child: buildMenu(),
            ),
          ],
        );
      },
    );
    setOverlay(entry);
    Overlay.of(context).insert(entry);
  }

  void _toggleSortMenu() {
    if (_sortOverlay != null) {
      _closeSortMenu();
      return;
    }
    _closeAllMenus();
    _showDropdown(
      buttonKey: _sortButtonKey,
      setOverlay: (entry) => _sortOverlay = entry,
      closeThis: _closeSortMenu,
      menuWidth: 240,
      buildMenu: () => _SortDropdownMenu(
        selectedSort: _sort,
        onSelected: (sort) {
          setState(() => _sort = sort);
          _closeSortMenu();
        },
      ),
    );
  }

  void _toggleSizeMenu() {
    if (_sizeOverlay != null) {
      _closeSizeMenu();
      return;
    }
    _closeAllMenus();
    _showDropdown(
      buttonKey: _sizeButtonKey,
      setOverlay: (entry) => _sizeOverlay = entry,
      closeThis: _closeSizeMenu,
      menuWidth: 200,
      buildMenu: () => _SizeDropdownMenu(
        selectedSize: _size,
        onSelected: (size) {
          setState(() => _size = size);
          _closeSizeMenu();
        },
      ),
    );
  }

  void _toggleBrandMenu() {
    if (_brandOverlay != null) {
      _closeBrandMenu();
      return;
    }
    _closeAllMenus();
    _showDropdown(
      buttonKey: _brandButtonKey,
      setOverlay: (entry) => _brandOverlay = entry,
      closeThis: _closeBrandMenu,
      menuWidth: 220,
      buildMenu: () => _BrandDropdownMenu(
        selectedBrand: _selectedBrand,
        onSelected: (brand) {
          setState(() => _selectedBrand = brand);
          _closeBrandMenu();
        },
      ),
    );
  }

  Widget _catalogBody(PipesFittingCatalog catalog) {
    final groups = _filteredGroups(catalog);
    final subCategoryNames = _subCategoryNames(catalog);

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CategorySidebar(
              sections: _sections,
              selected: _section,
              subCategoryNames: subCategoryNames,
              selectedSubCategory: _subCategory,
              onSectionSelected: (section) => setState(() {
                _section = section;
                if (section == _CatSection.all) {
                  _subCategory = null;
                }
              }),
              onSubCategorySelected: (name) =>
                  setState(() => _subCategory = name),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ContentHeading(
                      title: _titleFor(catalog),
                      subtitle: _subtitleFor(catalog),
                    ),
                    Expanded(
                      child: groups.isEmpty
                          ? const _CatalogStateMessage(
                              icon: Icons.inventory_2_outlined,
                              title: 'No products here yet',
                              subtitle:
                                  'Try another category or adjust your filters.',
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.space3,
                                0,
                                AppSpacing.space3,
                                AppSpacing.space2,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSpacing.space3,
                                crossAxisSpacing: AppSpacing.space3,
                                childAspectRatio: 0.56,
                              ),
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return _CategoryProductCard(
                                  group: group,
                                  siblingGroups: groups,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogController = context.watch<CatalogController>();
    final liveCatalog = catalogController.pipesFittingCatalog;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CategoryHeader(
            sort: _sort,
            selectedSize: _size,
            selectedBrand: _selectedBrand,
            sortButtonKey: _sortButtonKey,
            sizeButtonKey: _sizeButtonKey,
            brandButtonKey: _brandButtonKey,
            onBack: () => Navigator.of(context).maybePop(),
            onSearch: () => Navigator.of(context).pushNamed(AppRoutes.search),
            onSortTap: _toggleSortMenu,
            onSizeTap: _toggleSizeMenu,
            onBrandTap: _toggleBrandMenu,
          ),
          Expanded(
            child: liveCatalog != null
                ? _catalogBody(liveCatalog)
                : catalogController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : FutureBuilder<PipesFittingCatalog>(
                        future: _catalogFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }
                          final catalog = snapshot.data;
                          if (catalog == null) {
                            return const _CatalogStateMessage(
                              icon: Icons.error_outline_rounded,
                              title: 'Unable to load catalog',
                              subtitle:
                                  'Please check your connection and try again.',
                            );
                          }
                          return _catalogBody(catalog);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.sort,
    required this.selectedSize,
    required this.selectedBrand,
    required this.sortButtonKey,
    required this.sizeButtonKey,
    required this.brandButtonKey,
    required this.onBack,
    required this.onSearch,
    required this.onSortTap,
    required this.onSizeTap,
    required this.onBrandTap,
  });

  final PipeModuleSort sort;
  final String? selectedSize;
  final String? selectedBrand;
  final Key sortButtonKey;
  final Key sizeButtonKey;
  final Key brandButtonKey;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onSortTap;
  final VoidCallback onSizeTap;
  final VoidCallback onBrandTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space3,
            AppSpacing.space2,
            AppSpacing.space3,
            AppSpacing.space2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBack,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text(
                      'Plumbing Pipes & Fittings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    onPressed: onSearch,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: _FilterDropdownButton(
                      key: sortButtonKey,
                      label: 'Sort By',
                      active: sort != PipeModuleSort.all,
                      onTap: onSortTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: _FilterDropdownButton(
                      key: sizeButtonKey,
                      label: selectedSize ?? 'Size',
                      active: selectedSize != null,
                      onTap: onSizeTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: _FilterDropdownButton(
                      key: brandButtonKey,
                      label: selectedBrand ?? 'Brand',
                      active: selectedBrand != null,
                      onTap: onBrandTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdownButton extends StatelessWidget {
  const _FilterDropdownButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space1),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortDropdownMenu extends StatefulWidget {
  const _SortDropdownMenu({
    required this.selectedSort,
    required this.onSelected,
  });

  static const _options = [
    (PipeModuleSort.all, 'All'),
    (PipeModuleSort.discount, 'Discount'),
    (PipeModuleSort.priceLowHigh, 'Price (lowest first)'),
    (PipeModuleSort.whatsNew, 'What’s New'),
    (PipeModuleSort.priceHighLow, 'Price (highest first)'),
    (PipeModuleSort.ratings, 'Ratings'),
  ];

  final PipeModuleSort selectedSort;
  final ValueChanged<PipeModuleSort> onSelected;

  @override
  State<_SortDropdownMenu> createState() => _SortDropdownMenuState();
}

class _SortDropdownMenuState extends State<_SortDropdownMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final options = _SortDropdownMenu._options.where(
      (option) => option.$2.toLowerCase().contains(_query.toLowerCase()),
    );

    return _DropdownMenuChrome(
      searchHint: 'Search sort options...',
      onQueryChanged: (value) => setState(() => _query = value),
      children: [
        for (final option in options)
          _DropdownTile(
            label: option.$2,
            selected: widget.selectedSort == option.$1,
            onTap: () => widget.onSelected(option.$1),
          ),
      ],
    );
  }
}

class _SizeDropdownMenu extends StatefulWidget {
  const _SizeDropdownMenu({
    required this.selectedSize,
    required this.onSelected,
  });

  final String? selectedSize;
  final ValueChanged<String?> onSelected;

  @override
  State<_SizeDropdownMenu> createState() => _SizeDropdownMenuState();
}

class _SizeDropdownMenuState extends State<_SizeDropdownMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final sizes = PipeFilterSizes.all.where(
      (size) => size.toLowerCase().contains(_query.toLowerCase()),
    );

    return _DropdownMenuChrome(
      searchHint: 'Search size...',
      onQueryChanged: (value) => setState(() => _query = value),
      children: [
        if (_query.isEmpty)
          _DropdownTile(
            label: 'All Sizes',
            selected: widget.selectedSize == null,
            onTap: () => widget.onSelected(null),
          ),
        for (final size in sizes)
          _DropdownTile(
            label: size,
            selected: widget.selectedSize == size,
            onTap: () => widget.onSelected(size),
          ),
      ],
    );
  }
}

class _BrandDropdownMenu extends StatefulWidget {
  const _BrandDropdownMenu({
    required this.selectedBrand,
    required this.onSelected,
  });

  final String? selectedBrand;
  final ValueChanged<String?> onSelected;

  @override
  State<_BrandDropdownMenu> createState() => _BrandDropdownMenuState();
}

class _BrandDropdownMenuState extends State<_BrandDropdownMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final brands = PipeFilterBrands.names.where(
      (brand) => brand.toLowerCase().contains(_query.toLowerCase()),
    );

    return _DropdownMenuChrome(
      searchHint: 'Search brand...',
      onQueryChanged: (value) => setState(() => _query = value),
      children: [
        if (_query.isEmpty)
          _DropdownTile(
            label: 'All Brands',
            selected: widget.selectedBrand == null,
            onTap: () => widget.onSelected(null),
          ),
        for (final brand in brands)
          _DropdownTile(
            label: brand,
            selected: widget.selectedBrand == brand,
            onTap: () => widget.onSelected(brand),
          ),
      ],
    );
  }
}

/// Shared card chrome + search field wrapper for the header filter dropdowns.
class _DropdownMenuChrome extends StatelessWidget {
  const _DropdownMenuChrome({
    required this.searchHint,
    required this.onQueryChanged,
    required this.children,
  });

  final String searchHint;
  final ValueChanged<String> onQueryChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: AppElevation.level3,
      shadowColor: AppColors.shadow,
      borderRadius: AppRadius.smAll,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 360),
        decoration: BoxDecoration(
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DropdownSearchField(hintText: searchHint, onChanged: onQueryChanged),
            Flexible(
              child: children.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space4,
                        vertical: AppSpacing.space4,
                      ),
                      child: Text(
                        'No matches found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
                      children: children,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownSearchField extends StatelessWidget {
  const _DropdownSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space3,
        AppSpacing.space3,
        AppSpacing.space3,
        AppSpacing.space2,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.primaryContainer.withValues(alpha: 0.35) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.onBackground : AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.mdAll,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.onBackground),
        ),
      ),
    );
  }
}

class _ContentHeading extends StatelessWidget {
  const _ContentHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space3,
        AppSpacing.space3,
        AppSpacing.space3,
        AppSpacing.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogStateMessage extends StatelessWidget {
  const _CatalogStateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.space1),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  const _CategorySidebar({
    required this.sections,
    required this.selected,
    required this.subCategoryNames,
    required this.selectedSubCategory,
    required this.onSectionSelected,
    required this.onSubCategorySelected,
  });

  final List<_CatSectionMeta> sections;
  final _CatSection selected;
  final List<String> subCategoryNames;
  final String? selectedSubCategory;
  final ValueChanged<_CatSection> onSectionSelected;
  final ValueChanged<String?> onSubCategorySelected;

  @override
  Widget build(BuildContext context) {
    final allMeta = sections.first;
    final typeMetas = sections.skip(1).toList();

    return ColoredBox(
      color: AppColors.surfaceContainer,
      child: SizedBox(
        width: 108,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
          children: [
            _SidebarAllRow(
              meta: allMeta,
              selected: selected == _CatSection.all,
              onTap: () => onSectionSelected(_CatSection.all),
            ),
            const SizedBox(height: AppSpacing.space3),
            const _SidebarSectionLabel(label: 'Type'),
            for (final meta in typeMetas)
              _SidebarTypeRow(
                meta: meta,
                selected: selected == meta.section,
                onTap: () => onSectionSelected(meta.section),
              ),
            if (selected != _CatSection.all) ...[
              const SizedBox(height: AppSpacing.space3),
              const _SidebarSectionLabel(label: 'Sub-category'),
              _SidebarSubCategoryRow(
                label: 'All',
                selected: selectedSubCategory == null,
                onTap: () => onSubCategorySelected(null),
              ),
              for (final name in subCategoryNames)
                _SidebarSubCategoryRow(
                  label: name,
                  selected: selectedSubCategory?.toLowerCase() ==
                      name.toLowerCase(),
                  onTap: () => onSubCategorySelected(name),
                ),
            ],
            const SizedBox(height: AppSpacing.space2),
          ],
        ),
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space3,
        AppSpacing.space2,
        AppSpacing.space3,
        AppSpacing.space1,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _SidebarAllRow extends StatelessWidget {
  const _SidebarAllRow({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final _CatSectionMeta meta;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Material(
        color: selected ? AppColors.primaryContainer.withValues(alpha: 0.55) : Colors.transparent,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space2,
              vertical: AppSpacing.space2,
            ),
            child: Text(
              meta.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarTypeRow extends StatelessWidget {
  const _SidebarTypeRow({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final _CatSectionMeta meta;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: 2,
      ),
      child: Material(
        color: selected ? AppColors.primarySidebarSelected : Colors.transparent,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space2,
              vertical: AppSpacing.space1,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.smAll,
                    border: selected
                        ? null
                        : Border.all(color: AppColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(4),
                  child: CategoryImage(
                    imageAsset: meta.imageAsset,
                    fallbackIcon: 'plumbing',
                    fallbackIconColor: AppColors.outline,
                    fallbackBackground: AppColors.surface,
                    fit: BoxFit.contain,
                    width: 22,
                    height: 22,
                    iconSize: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    meta.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.onSurface : AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarSubCategoryRow extends StatelessWidget {
  const _SidebarSubCategoryRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: 2,
      ),
      child: Material(
        color: selected ? AppColors.primarySidebarSelected : Colors.transparent,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space2,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  const _CategoryProductCard({
    required this.group,
    required this.siblingGroups,
  });

  final _CategoryProductGroup group;
  final List<_CategoryProductGroup> siblingGroups;

  void _openConfigurator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PipeConfiguratorScreen(
          groups: siblingGroups,
          initialGroup: group,
          initialProduct: group.products.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = group.minMrp;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openConfigurator(context),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
              aspectRatio: 1.02,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CategoryImage(
                        imageAsset: group.imageAsset,
                        imageUrl: group.imageUrl,
                        fallbackIcon: 'plumbing',
                        fallbackIconColor: AppColors.outline,
                        fallbackBackground: AppColors.surfaceContainer,
                        fit: BoxFit.contain,
                        borderRadius: AppRadius.mdAll,
                        iconSize: AppSpacing.space8,
                      ),
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.space2,
                    bottom: AppSpacing.space2,
                    child: Material(
                      color: AppColors.accentGreenContainer,
                      borderRadius: BorderRadius.circular(10),
                      elevation: AppElevation.level1,
                      shadowColor: AppColors.shadow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space2,
                          vertical: AppSpacing.space1,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ADD',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.onAccentGreenContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${group.products.length} Products',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onAccentGreenContainer,
                                fontSize: 10,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space1,
                AppSpacing.space2,
                AppSpacing.space1,
                AppSpacing.space1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBackground,
                      ),
                      children: [
                        const TextSpan(
                          text: '₹',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: price.toStringAsFixed(0)),
                        TextSpan(
                          text: ' /${group.unit}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.discountLabel,
                    maxLines: 1,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product configurator screen opened when a shopper taps a product card in
/// [PipesFittingCategoryScreen] — shows the tapped product with a size and
/// type picker plus an "Add to Cart" action. The Add to Cart button reverts
/// to the previous (direct add-to-cart with a snackbar) flow, scoped to this
/// screen only; the rest of the module's navigation is unchanged.
class _PipeConfiguratorScreen extends StatefulWidget {
  const _PipeConfiguratorScreen({
    required this.groups,
    required this.initialGroup,
    required this.initialProduct,
  });

  final List<_CategoryProductGroup> groups;
  final _CategoryProductGroup initialGroup;
  final PipesFittingProduct initialProduct;

  @override
  State<_PipeConfiguratorScreen> createState() =>
      _PipeConfiguratorScreenState();
}

class _PipeConfiguratorScreenState extends State<_PipeConfiguratorScreen> {
  late _CategoryProductGroup _group = widget.initialGroup;
  late PipesFittingProduct _product = widget.initialProduct;

  PipesFittingProduct _liveProduct(CatalogController catalog) {
    return catalog.productByCode(_product.productCode) ?? _product;
  }

  static String _typeLabelFor(_CategoryProductGroup group) {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(group.title);
    return match?.group(1) ?? group.title;
  }

  List<_CategoryProductGroup> get _siblingGroups => widget.groups
      .where((g) =>
          g.subCategory.toLowerCase() ==
          widget.initialGroup.subCategory.toLowerCase())
      .toList();

  List<String> get _sizeOptions {
    final sizes = <String>{
      for (final p in _group.products)
        if (p.size != null && p.size!.isNotEmpty) p.size!,
    }.toList();
    sizes.sort();
    return sizes;
  }

  List<String> get _typeOptions {
    final types = <String>{
      for (final g in _siblingGroups) _typeLabelFor(g),
    }.toList();
    types.sort();
    return types;
  }

  void _onSizeChanged(String? size) {
    if (size == null) return;
    final match = _group.products.where((p) => p.size == size);
    if (match.isEmpty) return;
    setState(() => _product = match.first);
  }

  void _onTypeChanged(String? type) {
    if (type == null) return;
    final groupMatches =
        _siblingGroups.where((g) => _typeLabelFor(g) == type);
    if (groupMatches.isEmpty) return;
    final newGroup = groupMatches.first;
    if (newGroup == _group) return;
    final sameSize = newGroup.products.where((p) => p.size == _product.size);
    setState(() {
      _group = newGroup;
      _product = sameSize.isNotEmpty ? sameSize.first : newGroup.products.first;
    });
  }

  void _addToCart() {
    final product = _liveProduct(context.read<CatalogController>());
    context.read<CartController>().addVariant(_variantFor(product, _group));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text('${product.brand} ${product.productName} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String _titleFor(PipesFittingProduct product) {
    final code = product.productCode;
    final namePart = (code != null && code.isNotEmpty)
        ? '${code}_${product.productName}'
        : product.productName;
    final details = <String>[
      _typeLabelFor(_group),
      if (product.size != null && product.size!.isNotEmpty) product.size!,
      if (product.length != null && product.length!.isNotEmpty)
        product.length!,
    ];
    final detailText = details.isEmpty ? '' : ', ${details.join(', ')}';
    return '$namePart$detailText ${product.brand}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _liveProduct(context.watch<CatalogController>());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              child: Row(
                children: [
                  Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: AppRadius.mdAll,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 22,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Material(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                        side: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      child: InkWell(
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.search),
                        borderRadius: AppRadius.mdAll,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space3,
                            vertical: AppSpacing.space2,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: AppColors.outline,
                              ),
                              const SizedBox(width: AppSpacing.space2),
                              Expanded(
                                child: Text(
                                  'Search products',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.outline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space2,
                  AppSpacing.space4,
                  AppSpacing.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CategoryImage(
                        imageAsset: _group.imageAsset,
                        imageUrl: product.imageUrl ?? _group.imageUrl,
                        fallbackIcon: 'plumbing',
                        fallbackIconColor: AppColors.outline,
                        fallbackBackground: AppColors.surfaceContainer,
                        fit: BoxFit.contain,
                        borderRadius: AppRadius.lgAll,
                        iconSize: AppSpacing.space8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      _titleFor(product),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    _ConfiguratorDropdown(
                      value: product.size,
                      options: _sizeOptions,
                      hint: 'Select size',
                      onChanged: _sizeOptions.isEmpty ? null : _onSizeChanged,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    _ConfiguratorDropdown(
                      value: _typeLabelFor(_group),
                      options: _typeOptions,
                      hint: 'Select type',
                      onChanged:
                          _typeOptions.length <= 1 ? null : _onTypeChanged,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    _ConfiguratorAddToCartCard(
                      selectedSizeLabel: product.size ?? '—',
                      price: product.displayPrice,
                      unit: _group.unit,
                      onAddToCart: _addToCart,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfiguratorDropdown extends StatelessWidget {
  const _ConfiguratorDropdown({
    required this.value,
    required this.options,
    required this.hint,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final String hint;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value != null && options.contains(value) ? value : null;
    final enabled = onChanged != null;
    final textStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: enabled ? AppColors.onBackground : AppColors.disabled,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.disabledContainer,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: enabled ? AppColors.outlineVariant : AppColors.divider,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selected,
          hint: Text(hint, style: textStyle),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? AppColors.onSurfaceVariant : AppColors.disabled,
          ),
          style: textStyle,
          items: [
            for (final option in options)
              DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ConfiguratorAddToCartCard extends StatelessWidget {
  const _ConfiguratorAddToCartCard({
    required this.selectedSizeLabel,
    required this.price,
    required this.unit,
    required this.onAddToCart,
  });

  final String selectedSizeLabel;
  final double price;
  final String unit;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Product Size',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackground,
                    ),
                    children: [
                      const TextSpan(text: '₹'),
                      TextSpan(text: price.toStringAsFixed(0)),
                      TextSpan(
                        text: '/ $unit',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  selectedSizeLabel,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Material(
            color: AppColors.accentGreenContainer,
            borderRadius: AppRadius.lgAll,
            child: InkWell(
              onTap: onAddToCart,
              borderRadius: AppRadius.lgAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space3,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 18,
                      color: AppColors.onAccentGreenContainer,
                    ),
                    const SizedBox(width: AppSpacing.space1),
                    Text(
                      'Add to Cart',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onAccentGreenContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
