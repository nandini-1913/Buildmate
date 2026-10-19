import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ElectricalsCategoryScreen extends StatefulWidget {
  const ElectricalsCategoryScreen({super.key});

  @override
  State<ElectricalsCategoryScreen> createState() =>
      _ElectricalsCategoryScreenState();
}

class _ElectricalsCategoryScreenState extends State<ElectricalsCategoryScreen> {
  static const int _emptyTileCount = 6;
  bool _allSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ElectricalsHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onSearch: () => Navigator.of(context).pushNamed(AppRoutes.search),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 112,
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.space3),
                          _SidebarItem(
                            label: 'All',
                            selected: _allSelected,
                            onTap: () => setState(() => _allSelected = true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: AppColors.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            child: Text(
                              'Electricals',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.space3,
                                0,
                                AppSpacing.space3,
                                AppSpacing.space3,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: AppSpacing.space3,
                                    crossAxisSpacing: AppSpacing.space3,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: _emptyTileCount,
                              itemBuilder: (context, index) =>
                                  const _EmptyProductTile(),
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
        ),
      ),
    );
  }
}

class _ElectricalsHeader extends StatelessWidget {
  const _ElectricalsHeader({required this.onBack, required this.onSearch});

  final VoidCallback onBack;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
            const Expanded(
              child: Text(
                'Electricals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      child: Material(
        color: selected ? AppColors.primarySidebarSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyProductTile extends StatelessWidget {
  const _EmptyProductTile();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
    );
  }
}
