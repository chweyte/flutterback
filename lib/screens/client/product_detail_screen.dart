import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/models/product_model.dart';
import '../../core/models/shop_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/cart_service.dart';
import '../../services/favorites_service.dart';
import '../../services/route_transitions.dart';
import 'cart_screen.dart';
import '../../widgets/product_card_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  int _qty = 1;

  // Tailles selon catégorie
  List<String>? get _sizes {
    switch (widget.product.category) {
      case 'shoes':
        return ['36', '37', '38', '39', '40', '41', '42', '43', '44'];
      case 'melhfa':
        return ['1m', '2m'];
      case 'clothing':
        return ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '4XL'];
      case 'daraa':
        return ['3m','4m','5m','6m','7m','8m','9m','10m','11m','12m'];
      default:
        return null;
    }
  }

  ShopModel? get _shop => allShops.cast<ShopModel?>().firstWhere(
        (s) => s!.id == widget.product.shopId,
        orElse: () => null,
      );

  List<ProductModel> get _similar => allProducts
      .where((p) =>
          p.category == widget.product.category && p.id != widget.product.id)
      .take(6)
      .toList();

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            _FullscreenImage(product: widget.product),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _addToCart() {
    final sizes = _sizes;
    if (sizes != null && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez choisir une taille'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    for (var i = 0; i < _qty; i++) {
      CartService.instance.add(widget.product, size: _selectedSize);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ajouté au panier'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _sizes;
    final shop = _shop;
    final similar = _similar;
    final isDark = widget.product.isDark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable content ────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── Image ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _openFullscreen(context),
                      child: SizedBox(
                        height: 340.h,
                        width: double.infinity,
                        child: _ProductImage(product: widget.product),
                      ),
                    ),
                    // Dégradé bas
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100.h,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFFF2F2F7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Boutons overlay
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleBtn(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                            ValueListenableBuilder<List<ProductModel>>(
                              valueListenable:
                                  FavoritesService.instance.favorites,
                              builder: (_, __, ___) {
                                final isFav = FavoritesService.instance
                                    .isFavorite(widget.product.id);
                                return _CircleBtn(
                                  icon: isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  iconColor: isFav
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                  onTap: () => FavoritesService.instance
                                      .toggle(widget.product),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Infos produit ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Boutique
                      if (shop != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.store_outlined,
                                  size: 12.r,
                                  color: AppColors.textSecondary),
                              SizedBox(width: 4.w),
                              Text(
                                shop.name,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 10.h),
                      // Nom + prix
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            widget.product.price,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Stock badge
                      Row(
                        children: [
                          Container(
                            width: 7.r,
                            height: 7.r,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'En stock',
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // ── Sélecteur de taille ──────────────────────
                      if (sizes != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Taille',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedSize ?? 'Choisir',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: _selectedSize != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: sizes.map((s) {
                            final selected = _selectedSize == s;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSize = s),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 150),
                                width: 50.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ── Quantité ─────────────────────────────────
                      Row(
                        children: [
                          Text(
                            'Quantité',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          _QtyControl(
                            qty: _qty,
                            onDecrement: () {
                              if (_qty > 1)
                                setState(() => _qty--);
                            },
                            onIncrement: () => setState(() => _qty++),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),

                      // ── Produits similaires ───────────────────────
                      if (similar.isNotEmpty) ...[
                        Text(
                          'Produits similaires',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: similar.length,
                          itemBuilder: (ctx, i) =>
                              ProductCardWidget(product: similar[i]),
                        ),
                        SizedBox(height: 100.h),
                      ] else
                        SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Barre fixe en bas ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Bouton Ajouter au panier (prend la majorité)
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Ajouter au panier',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Icône panier — ouvre CartScreen
                  ValueListenableBuilder<List<CartItem>>(
                    valueListenable: CartService.instance.items,
                    builder: (_, items, __) {
                      final count = CartService.instance.totalCount;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          SlidePageRoute(page: const CartScreen()),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 52.r,
                              height: 52.r,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(16.r),
                                border: Border.all(
                                    color: AppColors.border),
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 22.r,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
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

// ── Image produit (asset ou réseau) ────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final ProductModel product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.imageAsset != null) {
      return Image.asset(product.imageAsset!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imgFallback());
    }
    if (product.imageUrl != null) {
      return Image.network(product.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imgFallback());
    }
    return _imgFallback();
  }

  Widget _imgFallback() => Container(
        color: AppColors.primary,
        child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: Colors.white54, size: 50)),
      );
}

// ── Bouton circulaire overlay ───────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _CircleBtn(
      {required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x14000000), blurRadius: 8)
          ],
        ),
        child: Icon(icon,
            size: 18.r,
            color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}

// ── Contrôle quantité ──────────────────────────────────────────────────────
class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QtyControl(
      {required this.qty,
      required this.onDecrement,
      required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.remove_rounded,
                  size: 16.r, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            '$qty',
            style: TextStyle(
                fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.add_rounded,
                  size: 16.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vue fullscreen photo ────────────────────────────────────────────────────
class _FullscreenImage extends StatelessWidget {
  final ProductModel product;
  const _FullscreenImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: product.imageAsset != null
                ? Image.asset(product.imageAsset!, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white54, size: 60))
                : product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white54, size: 60))
                    : const Icon(Icons.image_not_supported_outlined,
                        color: Colors.white54, size: 60),
          ),
        ),
      ),
    );
  }
}
