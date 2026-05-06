import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/ui_state.dart';
import 'package:imat_app/util/categories.dart';
import 'package:provider/provider.dart';

class CategorySidebar extends StatelessWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.watch<UiState>();

    return Container(
      width: AppTheme.sidebarWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.gray200)),
      ),
      padding: const EdgeInsets.all(AppTheme.paddingMediumLarge),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
              child: Text(
                'Kategorier',
                style: TextStyle(fontSize: AppTheme.fontSizeXl, fontWeight: FontWeight.w600),
              ),
            ),
            for (final group in categoryGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: _CategoryButton(
                  group: group,
                  selected:
                      !ui.showFavorites && ui.selectedCategory == group,
                  onTap: () => context.read<UiState>().selectCategory(group),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final CategoryGroup group;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppTheme.green600 : AppTheme.gray100;
    final fg = selected ? Colors.white : AppTheme.gray900;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        hoverColor: selected ? null : AppTheme.gray200,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(group.icon, size: 20, color: fg),
              const SizedBox(width: AppTheme.paddingMediumSmall),
              Expanded(
                child: Text(
                  group.label,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.w500,
                    color: fg,
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
