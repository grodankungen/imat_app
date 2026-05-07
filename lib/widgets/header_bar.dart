import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/ui_state.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/pages/login_page.dart';
import 'package:imat_app/widgets/account_modal.dart';
import 'package:imat_app/widgets/order_history_modal.dart';
import 'package:provider/provider.dart';

/// Top header: logo, search bar, favorites toggle, cart button.
class HeaderBar extends StatelessWidget {
  final GlobalKey cartButtonKey;
  final GlobalKey favoritesButtonKey;

  const HeaderBar({
    super.key,
    required this.cartButtonKey,
    required this.favoritesButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final ui = context.watch<UiState>();

    final isLoggedIn = AccountData.isLoggedIn(iMat);
    final favoritesCount = iMat.favorites.length;
    final cartCount = iMat
        .getShoppingCart()
        .items
        .fold<double>(0, (sum, i) => sum + i.amount)
        .toInt();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingHuge,
        vertical: AppTheme.paddingMedium,
      ),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/imat_logo.png',
            height: 64,
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 64,
              child: Center(
                child: Text(
                  'iMat',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize5xl,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.paddingLarge),
          // Search bar
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: _SearchField(
                onChanged: (v) => context.read<UiState>().setSearch(v),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.paddingLarge),
          // Account menu (logged in) or login button (logged out)
          if (isLoggedIn)
            _AccountMenu(email: iMat.getCustomer().email)
          else
            _LoginButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
            ),
          const SizedBox(width: AppTheme.paddingMediumSmall),
          // Favorites toggle
          _FavoritesButton(
            key: favoritesButtonKey,
            count: favoritesCount,
            active: ui.showFavorites,
            onPressed: () => context.read<UiState>().toggleFavoritesFilter(),
          ),
          const SizedBox(width: AppTheme.paddingMediumSmall),
          // Cart button
          _CartButton(
            key: cartButtonKey,
            count: cartCount,
            onPressed: () => context.read<UiState>().toggleCart(),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: AppTheme.fontSizeLg),
      decoration: InputDecoration(
        hintText: 'Sök varor...',
        hintStyle: const TextStyle(color: AppTheme.hint, fontSize: AppTheme.fontSizeLg),
        prefixIcon: const Icon(Icons.search, color: AppTheme.hint, size: 20),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 24,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.person_outline, size: 22, color: AppTheme.black),
              SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Logga in',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesButton extends StatelessWidget {
  final int count;
  final bool active;
  final VoidCallback onPressed;

  const _FavoritesButton({
    super.key,
    required this.count,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.favorite : Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: active
                ? null
                : Border.all(color: AppTheme.border, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: active ? Colors.white : AppTheme.textPrimary,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Favoriter ($count)',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header account button with custom dropdown:
/// "Inloggad som [email]" header, then "Kontouppgifter", "Historik",
/// divider, "Logga ut".
class _AccountMenu extends StatefulWidget {
  final String email;
  const _AccountMenu({required this.email});

  @override
  State<_AccountMenu> createState() => _AccountMenuState();
}

class _AccountMenuState extends State<_AccountMenu> {
  final LayerLink _link = LayerLink();
  final GlobalKey _btnKey = GlobalKey();
  OverlayEntry? _entry;

  bool get _open => _entry != null;

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _show();
    }
  }

  void _show() {
    final overlay = Overlay.of(context);
    final box = _btnKey.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: Offset(size.width - 280, size.height + 8),
            child: _AccountMenuPopup(
              email: widget.email.isEmpty
                  ? 'anna.andersson@email.se'
                  : widget.email,
              onItem: (id) {
                _close();
                switch (id) {
                  case 'account':
                    showAccountModal(context);
                    break;
                  case 'history':
                    showOrderHistoryModal(context);
                    break;
                  case 'logout':
                    _logout();
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
    setState(() {});
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void _logout() {
    AccountData.setLoggedIn(context.read<ImatDataHandler>(), false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utloggad')),
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Material(
        key: _btnKey,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 22,
                  color: AppTheme.black,
                ),
                const SizedBox(width: AppTheme.paddingSmall),
                const Text(
                  'Konto',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppTheme.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountMenuPopup extends StatelessWidget {
  final String email;
  final void Function(String) onItem;
  const _AccountMenuPopup({required this.email, required this.onItem});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      color: Colors.white,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email header
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inloggad som',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXs,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Kontouppgifter',
              onTap: () => onItem('account'),
            ),
            _MenuItem(
              icon: Icons.history,
              label: 'Historik',
              onTap: () => onItem('history'),
            ),
            const Divider(height: 1, color: AppTheme.border),
            _MenuItem(
              icon: Icons.logout,
              label: 'Logga ut',
              destructive: true,
              onTap: () => onItem('logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppTheme.favorite : AppTheme.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppTheme.paddingMedium),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _CartButton({super.key, required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart,
                size: 22,
                color: Colors.white,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Kundvagn ($count)',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
