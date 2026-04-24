import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/category_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/shop_model.dart';
import '../../widgets/product_card_widget.dart';
import '../../widgets/category_chip_widget.dart';
import '../../widgets/bottom_nav_widget.dart';
import '../../services/route_transitions.dart';
import '../settings/settings_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'cart_screen.dart';
import 'all_categories_screen.dart';
import 'all_products_screen.dart';
import 'shops_screen.dart';
import 'shop_detail_screen.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({Key? key}) : super(key: key);

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int _selectedCategory = 0;
  int _navIndex = 0;

  String get _username {
    final u = FirebaseAuth.instance.currentUser;
    return u?.displayName ?? u?.email?.split('@').first ?? 'User';
  }

  // Filter products by selected category (index 0 = "new_in" = show all)
  List<ProductModel> get _visibleProducts {
    if (_selectedCategory == 0) return allProducts;
    final catId = appCategories[_selectedCategory].id;
    return allProducts.where((p) => p.category == catId).toList();
  }

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
    switch (i) {
      case 1:
        Navigator.push(context, SlidePageRoute(page: const SearchScreen()))
            .then((_) => setState(() => _navIndex = 0));
        break;
      case 2:
        Navigator.push(context, SlidePageRoute(page: const FavoritesScreen()))
            .then((_) => setState(() => _navIndex = 0));
        break;
      case 3:
        Navigator.push(
                context, SlidePageRoute(page: const NotificationsScreen()))
            .then((_) => setState(() => _navIndex = 0));
        break;
      case 4:
        Navigator.push(context, SlidePageRoute(page: const CartScreen()))
            .then((_) => setState(() => _navIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(username: _username),
                ),
                SliverToBoxAdapter(child: _SearchSection()),
                SliverToBoxAdapter(
                  child: _CategoryRow(
                    selectedIndex: _selectedCategory,
                    onSelect: (i) => setState(() => _selectedCategory = i),
                    onSeeAll: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const AllCategoriesScreen()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ShopsRow(
                    onSeeAll: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const ShopsScreen()),
                    ),
                    onShopTap: (shop) => Navigator.push(
                      context,
                      SlidePageRoute(page: ShopDetailScreen(shop: shop)),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => ProductCardWidget(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ExploreMoreButton(
                    onTap: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const AllProductsScreen()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 90.h)),
              ],
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavWidget(
                currentIndex: _navIndex,
                onTap: _onNavTap,
                cartCount: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Header  (no cart icon)
// ────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String username;
  const _Header({required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              SlidePageRoute(page: const SettingsScreen()),
            ),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primary,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_back'.tr(),
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textSecondary),
                ),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconBtn(
            icon: Icons.notifications_none_rounded,
            hasBadge: true,
            onTap: () => Navigator.push(
              context,
              SlidePageRoute(page: const NotificationsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool hasBadge;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: Colors.white, size: 19.r)),
            if (hasBadge)
              Positioned(
                top: 7.r,
                right: 7.r,
                child: Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Search section
// ────────────────────────────────────────────────────────────────────────────

class _SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'discover'.tr(),
            style: TextStyle(
              fontSize: 34.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'find_products'.tr(),
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 14.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: 14.w),
                Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const SearchScreen()),
                    ),
                    decoration: InputDecoration(
                      hintText: 'search_placeholder'.tr(),
                      hintStyle: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(6.r),
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.tune_rounded,
                      color: Colors.white, size: 16.r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Category row  — with left/right arrow buttons
// ────────────────────────────────────────────────────────────────────────────

class _CategoryRow extends StatefulWidget {
  final int selectedIndex;
  final void Function(int) onSelect;
  final VoidCallback onSeeAll;

  const _CategoryRow({
    required this.selectedIndex,
    required this.onSelect,
    required this.onSeeAll,
  });

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  late final ScrollController _sc;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    final target = (_sc.offset + delta).clamp(0.0, _sc.position.maxScrollExtent);
    _sc.animateTo(target,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'categories'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: Text(
                  'see_all'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            // Left arrow
            GestureDetector(
              onTap: () => _scrollBy(-160),
              child: Container(
                margin: EdgeInsets.only(left: 8.w, right: 4.w),
                width: 30.r,
                height: 30.r,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_left_rounded,
                    size: 18.r, color: AppColors.textPrimary),
              ),
            ),

            // Scrollable chips
            Expanded(
              child: SingleChildScrollView(
                controller: _sc,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    appCategories.length,
                    (i) => CategoryChipWidget(
                      category: appCategories[i],
                      isSelected: widget.selectedIndex == i,
                      onTap: () => widget.onSelect(i),
                    ),
                  ),
                ),
              ),
            ),

            // Right arrow
            GestureDetector(
              onTap: () => _scrollBy(160),
              child: Container(
                margin: EdgeInsets.only(left: 4.w, right: 8.w),
                width: 30.r,
                height: 30.r,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18.r, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Boutiques row
// ────────────────────────────────────────────────────────────────────────────

class _ShopsRow extends StatefulWidget {
  final VoidCallback onSeeAll;
  final void Function(ShopModel) onShopTap;

  const _ShopsRow({required this.onSeeAll, required this.onShopTap});

  @override
  State<_ShopsRow> createState() => _ShopsRowState();
}

class _ShopsRowState extends State<_ShopsRow> {
  late final ScrollController _sc;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    final target = (_sc.offset + delta)
        .clamp(0.0, _sc.position.maxScrollExtent);
    _sc.animateTo(target,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'boutiques'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: Text(
                  'see_all_shops'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Flèche gauche
            GestureDetector(
              onTap: () => _scrollBy(-180),
              child: Container(
                margin: EdgeInsets.only(left: 8.w, right: 4.w),
                width: 30.r,
                height: 30.r,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_left_rounded,
                    size: 18.r, color: AppColors.textPrimary),
              ),
            ),

            // Liste scrollable
            Expanded(
              child: SizedBox(
                height: 100.h,
                child: ListView.builder(
                  controller: _sc,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(right: 4.w),
                  itemCount: allShops.length,
                  itemBuilder: (ctx, i) => _ShopChip(
                    shop: allShops[i],
                    onTap: () => widget.onShopTap(allShops[i]),
                  ),
                ),
              ),
            ),

            // Flèche droite
            GestureDetector(
              onTap: () => _scrollBy(180),
              child: Container(
                margin: EdgeInsets.only(left: 4.w, right: 8.w),
                width: 30.r,
                height: 30.r,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18.r, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _ShopChip extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;
  const _ShopChip({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            // Logo circulaire
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: ClipOval(
                child: _shopImage(shop),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              shop.name,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _shopImage(ShopModel shop) {
  if (shop.imageAsset != null) {
    return Image.asset(shop.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ShopAvatar(name: shop.name));
  }
  if (shop.imageUrl != null) {
    return Image.network(shop.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ShopAvatar(name: shop.name));
  }
  return _ShopAvatar(name: shop.name);
}

class _ShopAvatar extends StatelessWidget {
  final String name;
  const _ShopAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'S',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Explore More banner
// ────────────────────────────────────────────────────────────────────────────

class _ExploreMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ExploreMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'explore_more'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textPrimary, size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}
