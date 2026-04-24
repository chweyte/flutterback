import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/category_model.dart';
import '../../widgets/product_card_widget.dart';
import '../../widgets/category_chip_widget.dart';
import '../../widgets/bottom_nav_widget.dart';
import '../../services/route_transitions.dart';
import '../settings/settings_screen.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({Key? key}) : super(key: key);

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int _selectedCategory = 0;
  int _navIndex = 0;
  int _cartCount = 0;

  // Sample products – replace with Firestore data in production.
  static const _products = [
    {'name': 'Parfum Oud Rose',    'price': '1 200 MRU', 'dark': false},
    {'name': 'Melhfa Élégante',    'price': '800 MRU',   'dark': true},
    {'name': 'Daraa Premium',      'price': '950 MRU',   'dark': false},
    {'name': 'Sac Cuir Artisanal', 'price': '2 500 MRU', 'dark': false},
  ];

  String get _username {
    final u = FirebaseAuth.instance.currentUser;
    return u?.displayName ?? u?.email?.split('@').first ?? 'User';
  }

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
    // Profile tab → Settings screen
    if (i == 4) {
      Navigator.push(context, SlidePageRoute(page: const SettingsScreen()))
          .then((_) => setState(() => _navIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable content ─────────────────────────────────────
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(username: _username, cartCount: _cartCount),
                ),
                SliverToBoxAdapter(child: _SearchSection()),
                SliverToBoxAdapter(
                  child: _CategoryRow(
                    selectedIndex: _selectedCategory,
                    onSelect: (i) => setState(() => _selectedCategory = i),
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
                      (ctx, i) => ProductCardWidget(
                        name: _products[i]['name'] as String,
                        price: _products[i]['price'] as String,
                        isDark: _products[i]['dark'] as bool,
                        onAddToCart: () => setState(() => _cartCount++),
                      ),
                      childCount: _products.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _ExploreMoreButton()),
                // Extra space so content is not hidden behind the floating nav
                SliverToBoxAdapter(child: SizedBox(height: 90.h)),
              ],
            ),

            // ── Floating bottom navigation bar ─────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavWidget(
                currentIndex: _navIndex,
                onTap: _onNavTap,
                cartCount: _cartCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Header
// ────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String username;
  final int cartCount;

  const _Header({required this.username, required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        children: [
          // Avatar – initials
          CircleAvatar(
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
            onTap: () {},
          ),
          SizedBox(width: 8.w),
          _HeaderIconBtn(
            icon: Icons.shopping_bag_outlined,
            hasBadge: cartCount > 0,
            badgeCount: cartCount,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Circular icon button with optional red dot badge.
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool hasBadge;
  final int badgeCount;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    this.hasBadge = false,
    this.badgeCount = 0,
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
                  child: badgeCount > 0
                      ? Center(
                          child: Text(
                            '$badgeCount',
                            style:
                                TextStyle(color: Colors.white, fontSize: 4.sp),
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Search & title section
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
            style: TextStyle(
                fontSize: 15.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 14.h),
          // Search bar
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0A000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                // Filter toggle button
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
// Horizontal category chips
// ────────────────────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const _CategoryRow({required this.selectedIndex, required this.onSelect});

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
              Text(
                'see_all'.tr(),
                style: TextStyle(
                    fontSize: 13.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: appCategories.length,
            itemBuilder: (ctx, i) => CategoryChipWidget(
              category: appCategories[i],
              isSelected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Explore More banner
// ────────────────────────────────────────────────────────────────────────────

class _ExploreMoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
    );
  }
}
