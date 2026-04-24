import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartService.instance.items,
          builder: (context, items, _) {
            final total = CartService.instance.totalPrice;
            return Column(
              children: [
                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16.r, color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Mon Panier',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${items.length} articles',
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // ── Liste ────────────────────────────────────────────
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 60.r, color: AppColors.textLight),
                              SizedBox(height: 16.h),
                              Text(
                                'Votre panier est vide',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 8.h),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (ctx, i) => _CartTile(item: items[i]),
                        ),
                ),

                // ── Total + Commander ─────────────────────────────────
                if (items.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x10000000), blurRadius: 16)
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$total MRU',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Commande passée avec succès !'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Commander',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 60.r,
              height: 60.r,
              child: item.product.imageAsset != null
                  ? Image.asset(item.product.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imgFallback())
                  : item.product.imageUrl != null
                      ? Image.network(item.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imgFallback())
                      : _imgFallback(),
            ),
          ),
          SizedBox(width: 12.w),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.size != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Taille : ${item.size}',
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary),
                  ),
                ],
                SizedBox(height: 3.h),
                Text(
                  item.product.price,
                  style: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          // Quantité + supprimer
          Column(
            children: [
              Row(
                children: [
                  _QtyBtn(
                      icon: Icons.remove_rounded,
                      onTap: () => cart.decrement(item)),
                  SizedBox(width: 8.w),
                  Text('${item.quantity}',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8.w),
                  _QtyBtn(
                      icon: Icons.add_rounded,
                      onTap: () => cart.increment(item)),
                ],
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () => cart.remove(item),
                child: Icon(Icons.delete_outline_rounded,
                    size: 18.r, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: AppColors.background,
        child: Icon(Icons.shopping_bag_outlined,
            size: 24, color: AppColors.textLight),
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26.r,
        height: 26.r,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Icon(icon, size: 13.r, color: AppColors.textPrimary),
      ),
    );
  }
}
