import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/category_image.dart';

/// Category entry screen for Electricals — layout mirrors
/// [PipesFittingCategoryScreen]; catalog data is wired separately.
class ElectricalsCategoryScreen extends StatefulWidget {
  const ElectricalsCategoryScreen({super.key});

  @override
  State<ElectricalsCategoryScreen> createState() =>
      _ElectricalsCategoryScreenState();
}

enum _ElectricalsModuleSort {
  all,
  discount,
  priceLowHigh,
  whatsNew,
  priceHighLow,
  ratings,
}

class _CatSectionMeta {
  const _CatSectionMeta({
    required this.typeName,
    required this.label,
    this.imageUrl,
  });

  final String? typeName;
  final String label;
  final String? imageUrl;
}

class _SubCatMeta {
  const _SubCatMeta({
    required this.name,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
}

class _ElectricalsCategoryScreenState extends State<ElectricalsCategoryScreen> {
  static const _allSection = _CatSectionMeta(
    typeName: null,
    label: 'All',
  );

  static const int _placeholderGridCount = 6;

  String? _selectedType;
  String? _subCategory;
  _ElectricalsModuleSort _sort = _ElectricalsModuleSort.all;
  String? _selectedBrand;
  String? _size;
  String? _class;

  final GlobalKey _sortButtonKey = GlobalKey();
  final GlobalKey _sizeButtonKey = GlobalKey();
  final GlobalKey _brandButtonKey = GlobalKey();
  final GlobalKey _classButtonKey = GlobalKey();
  OverlayEntry? _sortOverlay;
  OverlayEntry? _sizeOverlay;
  OverlayEntry? _brandOverlay;
  OverlayEntry? _classOverlay;

  @override
  void dispose() {
    _closeSortMenu();
    _closeSizeMenu();
    _closeBrandMenu();
    _closeClassMenu();
    super.dispose();
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

  void _closeClassMenu() {
    _classOverlay?.remove();
    _classOverlay = null;
  }

  void _closeAllMenus() {
    _closeSortMenu();
    _closeSizeMenu();
    _closeBrandMenu();
    _closeClassMenu();
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
        final maxLeft = screenWidth - menuWidth - edgeMargin;
        final left = (offset.dx + size.width - menuWidth).clamp(
          edgeMargin,
          maxLeft < edgeMargin ? edgeMargin : maxLeft,
        );

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
        sizes: const <String>[],
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
        brands: const <String>[],
        selectedBrand: _selectedBrand,
        onSelected: (brand) {
          setState(() => _selectedBrand = brand);
          _closeBrandMenu();
        },
      ),
    );
  }

  void _toggleClassMenu() {
    if (_classOverlay != null) {
      _closeClassMenu();
      return;
    }
    _closeAllMenus();
    _showDropdown(
      buttonKey: _classButtonKey,
      setOverlay: (entry) => _classOverlay = entry,
      closeThis: _closeClassMenu,
      menuWidth: 200,
      buildMenu: () => _ClassDropdownMenu(
        classes: const <String>[],
        selectedClass: _class,
        onSelected: (className) {
          setState(() => _class = className);
          _closeClassMenu();
        },
      ),
    );
  }

  String _titleFor() {
    final typeLabel = _selectedType;
    if (typeLabel == null && _subCategory == null) return 'Electricals';
    if (typeLabel != null && _subCategory != null) {
      return '$typeLabel $_subCategory';
    }
    if (typeLabel != null) return '$typeLabel Products';
    return _subCategory!;
  }

  String _subtitleFor() {
    final typeLabel = _selectedType;
    if (_selectedBrand != null) {
      final scope = typeLabel ?? 'Electricals';
      return '$_selectedBrand brand $scope products';
    }
    if (typeLabel != null && _subCategory != null) {
      return 'High quality $typeLabel ${_subCategory!.toLowerCase()} for various applications';
    }
    if (typeLabel != null) {
      return 'Browse $typeLabel electrical products and accessories';
    }
    return 'Wide range of wires, switches, lights and accessories';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const minBodyHeight = 480.0;
          if (constraints.maxHeight >= minBodyHeight) {
            return _buildBody(context);
          }
          return SingleChildScrollView(
            child: SizedBox(height: minBodyHeight, child: _buildBody(context)),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    const sections = [_allSection];
    const subCategoryItems = <_SubCatMeta>[];

    return Column(
      children: [
        _CategoryHeader(
          sort: _sort,
          selectedSize: _size,
          selectedBrand: _selectedBrand,
          selectedClass: _class,
          sortButtonKey: _sortButtonKey,
          sizeButtonKey: _sizeButtonKey,
          brandButtonKey: _brandButtonKey,
          classButtonKey: _classButtonKey,
          onBack: () => Navigator.of(context).maybePop(),
          onSearch: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.search, arguments: const SearchArgs()),
          onSortTap: _toggleSortMenu,
          onSizeTap: _toggleSizeMenu,
          onBrandTap: _toggleBrandMenu,
          onClassTap: _toggleClassMenu,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CategorySidebar(
                sections: sections,
                selectedType: _selectedType,
                subCategories: subCategoryItems,
                selectedSubCategory: _subCategory,
                onSectionSelected: (typeName) => setState(() {
                  _selectedType = typeName;
                  _subCategory = null;
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
                        title: _titleFor(),
                        subtitle: _subtitleFor(),
                      ),
                      Expanded(
                        child: GridView.builder(
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
                                childAspectRatio: 0.52,
                              ),
                          itemCount: _placeholderGridCount,
                          itemBuilder: (context, index) =>
                              const _ElectricalsProductCardShell(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.sort,
    required this.selectedSize,
    required this.selectedBrand,
    required this.selectedClass,
    required this.sortButtonKey,
    required this.sizeButtonKey,
    required this.brandButtonKey,
    required this.classButtonKey,
    required this.onBack,
    required this.onSearch,
    required this.onSortTap,
    required this.onSizeTap,
    required this.onBrandTap,
    required this.onClassTap,
  });

  final _ElectricalsModuleSort sort;
  final String? selectedSize;
  final String? selectedBrand;
  final String? selectedClass;
  final Key sortButtonKey;
  final Key sizeButtonKey;
  final Key brandButtonKey;
  final Key classButtonKey;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onSortTap;
  final VoidCallback onSizeTap;
  final VoidCallback onBrandTap;
  final VoidCallback onClassTap;

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
                      'Electricals',
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
                      label: sort == _ElectricalsModuleSort.all
                          ? 'Sort By'
                          : _SortDropdownMenu._options
                                .firstWhere((option) => option.$1 == sort)
                                .$2,
                      active: sort != _ElectricalsModuleSort.all,
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
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: _FilterDropdownButton(
                      key: classButtonKey,
                      label: selectedClass ?? 'Class',
                      active: selectedClass != null,
                      onTap: onClassTap,
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
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
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
    (_ElectricalsModuleSort.all, 'All'),
    (_ElectricalsModuleSort.discount, 'Discount'),
    (_ElectricalsModuleSort.priceLowHigh, 'Price (lowest first)'),
    (_ElectricalsModuleSort.whatsNew, 'What’s New'),
    (_ElectricalsModuleSort.priceHighLow, 'Price (highest first)'),
    (_ElectricalsModuleSort.ratings, 'Ratings'),
  ];

  final _ElectricalsModuleSort selectedSort;
  final ValueChanged<_ElectricalsModuleSort> onSelected;

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
    required this.sizes,
    required this.selectedSize,
    required this.onSelected,
  });

  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String?> onSelected;

  @override
  State<_SizeDropdownMenu> createState() => _SizeDropdownMenuState();
}

class _SizeDropdownMenuState extends State<_SizeDropdownMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final sizes = widget.sizes.where(
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
    required this.brands,
    required this.selectedBrand,
    required this.onSelected,
  });

  final List<String> brands;
  final String? selectedBrand;
  final ValueChanged<String?> onSelected;

  @override
  State<_BrandDropdownMenu> createState() => _BrandDropdownMenuState();
}

class _BrandDropdownMenuState extends State<_BrandDropdownMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.brands.where(
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
        if (widget.brands.isEmpty && _query.isEmpty)
          _DropdownTile(
            label: 'No brands in catalog',
            selected: false,
            onTap: () {},
          ),
        for (final brand in filtered)
          _DropdownTile(
            label: brand,
            selected:
                widget.selectedBrand != null &&
                widget.selectedBrand!.toLowerCase() == brand.toLowerCase(),
            onTap: () => widget.onSelected(brand),
          ),
      ],
    );
  }
}

class _ClassDropdownMenu extends StatefulWidget {
  const _ClassDropdownMenu({
    required this.classes,
    required this.selectedClass,
    required this.onSelected,
  });

  final List<String> classes;
  final String? selectedClass;
  final ValueChanged<String?> onSelected;

  @override
  State<_ClassDropdownMenu> createState() => _ClassDropdownMenuState();
}

class _ClassDropdownMenuState extends State<_ClassDropdownMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final classes = widget.classes.where(
      (name) => name.toLowerCase().contains(_query.toLowerCase()),
    );

    return _DropdownMenuChrome(
      searchHint: 'Search class...',
      onQueryChanged: (value) => setState(() => _query = value),
      children: [
        if (_query.isEmpty)
          _DropdownTile(
            label: 'All Classes',
            selected: widget.selectedClass == null,
            onTap: () => widget.onSelected(null),
          ),
        for (final name in classes)
          _DropdownTile(
            label: name,
            selected: widget.selectedClass != null &&
                widget.selectedClass!.toLowerCase() == name.toLowerCase(),
            onTap: () => widget.onSelected(name),
          ),
      ],
    );
  }
}

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
            _DropdownSearchField(
              hintText: searchHint,
              onChanged: onQueryChanged,
            ),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space1,
                      ),
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
  const _DropdownSearchField({required this.hintText, required this.onChanged});

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
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
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
        color: selected
            ? AppColors.primaryContainer.withValues(alpha: 0.35)
            : null,
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
                  color: selected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
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
                  color: selected
                      ? AppColors.onBackground
                      : AppColors.onSurface,
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
  const _HeaderIconButton({required this.icon, required this.onPressed});

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
  const _ContentHeading({required this.title, required this.subtitle});

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

class _CategorySidebar extends StatefulWidget {
  const _CategorySidebar({
    required this.sections,
    required this.selectedType,
    required this.subCategories,
    required this.selectedSubCategory,
    required this.onSectionSelected,
    required this.onSubCategorySelected,
  });

  final List<_CatSectionMeta> sections;
  final String? selectedType;
  final List<_SubCatMeta> subCategories;
  final String? selectedSubCategory;
  final ValueChanged<String?> onSectionSelected;
  final ValueChanged<String?> onSubCategorySelected;

  @override
  State<_CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<_CategorySidebar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMeta = widget.sections.first;
    final typeMetas = widget.sections.skip(1).toList();

    return ColoredBox(
      color: AppColors.surfaceContainer,
      child: SizedBox(
        width: 96,
        child: Scrollbar(
          controller: _scrollController,
          thickness: 3,
          radius: const Radius.circular(3),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
            children: [
              _SidebarSectionLabel(
                label: allMeta.label,
                selected: widget.selectedType == null,
                onTap: () => widget.onSectionSelected(null),
              ),
              const SizedBox(height: AppSpacing.space3),
              const _SidebarSectionLabel(label: 'Type'),
              for (final meta in typeMetas)
                _SidebarImageTile(
                  label: meta.label,
                  selected: widget.selectedType?.toLowerCase() ==
                      meta.typeName?.toLowerCase(),
                  onTap: () => widget.onSectionSelected(meta.typeName),
                  imageUrl: meta.imageUrl,
                ),
              if (widget.selectedType != null) ...[
                const SizedBox(height: AppSpacing.space3),
                const _SidebarSectionLabel(label: 'Sub-category'),
                _SidebarAllRow(
                  meta: allMeta,
                  selected: widget.selectedSubCategory == null,
                  onTap: () => widget.onSubCategorySelected(null),
                ),
                for (final sub in widget.subCategories)
                  _SidebarImageTile(
                    label: sub.name,
                    selected: widget.selectedSubCategory?.toLowerCase() ==
                        sub.name.toLowerCase(),
                    onTap: () => widget.onSubCategorySelected(sub.name),
                    imageUrl: sub.imageUrl,
                  ),
              ],
              const SizedBox(height: AppSpacing.space2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = onTap != null;
    final fill = selected && interactive
        ? AppColors.primaryContainer.withValues(alpha: 0.55)
        : AppColors.primaryContainer.withValues(alpha: 0.35);

    final labelChild = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: selected && interactive
              ? AppColors.onBackground
              : AppColors.primary,
          fontWeight: selected && interactive ? FontWeight.w800 : FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space2,
        AppSpacing.space2,
        AppSpacing.space2,
        AppSpacing.space1,
      ),
      child: interactive
          ? Material(
              color: fill,
              borderRadius: AppRadius.smAll,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.smAll,
                child: labelChild,
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: AppRadius.smAll,
              ),
              child: labelChild,
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
        color: selected
            ? AppColors.primaryContainer.withValues(alpha: 0.55)
            : Colors.transparent,
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

class _SidebarImageTile extends StatelessWidget {
  const _SidebarImageTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.imageAsset = '',
    this.imageUrl,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String imageAsset;
  final String? imageUrl;

  static const double _circleSize = 52;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: 2,
      ),
      child: Material(
        color: selected
            ? AppColors.primarySidebarSelected
            : Colors.transparent,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space1,
              vertical: AppSpacing.space2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _circleSize,
                  height: _circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  clipBehavior: Clip.antiAlias,
                  child: CategoryImage(
                    imageAsset: imageAsset,
                    imageUrl: imageUrl,
                    fallbackIcon: 'electrical_services',
                    fallbackIconColor: AppColors.outline,
                    fallbackBackground: AppColors.surface,
                    fit: BoxFit.contain,
                    iconSize: 26,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    height: 1.15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? AppColors.onSurface
                        : AppColors.onBackground,
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

/// Visual shell matching pipes product cards — content is filled when catalog
/// is connected.
class _ElectricalsProductCardShell extends StatelessWidget {
  const _ElectricalsProductCardShell();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
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
                      imageAsset: '',
                      imageUrl: null,
                      fallbackIcon: 'electrical_services',
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
                            '— options',
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
                      const TextSpan(text: '—'),
                      TextSpan(
                        text: ' /—',
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
                  '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
