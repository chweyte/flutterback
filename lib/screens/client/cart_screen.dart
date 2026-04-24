import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';

class CartItem {
  final String name;
  final String price;
  final int priceValue;
  int quantity;
  CartItem({
    required this.name,
    required this.price,
    required this.priceValue,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // In production: use a cart provider/Firestore
  final List<CartItem> _items = [
    CartItem(name: 'Parfum Oud Rose',    price: '1 200 MRU', priceValue: 1200),
    CartItem(name: 'Melhfa Élégante',    price: '800 MRU',   priceValue: 800),
    CartItem(name: 'Daraa Premium',      price: '950 MRU',   priceValue: 950),
  ];

  int get _total => _items.fold(0, (s, e) => s + e.priceValue * e.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    '${_items.length} articles',
                    style: TextStyle(
                        fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: _items.isEmpty
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
                      physics: const ClampingScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (ctx, i) => _CartItemTile(
                        item: _items[i],
                        onRemove: () =>
                            setState(() => _items.removeAt(i)),
                        onIncrement: () =>
                            setState(() => _items[i].quantity++),
                        onDecrement: () => setState(() {
                          if (_items[i].quantity > 1) {
                            _items[i].quantity--;
                          } else {
                            _items.removeAt(i);
                          }
                        }),
                      ),
                    ),
            ),

            // Total + checkout
            if (_items.isNotEmpty)
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          '$_total MRU',
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
                              content: Text('Commande passée avec succès !'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Commander',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w700),
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

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                size: 28.r, color: AppColors.textLight),
          ),
          SizedBox(width: 12.w),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.price,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Quantity control
          Row(
            children: [
              _QtyBtn(icon: Icons.remove_rounded, onTap: onDecrement),
              SizedBox(width: 8.w),
              Text(
                '${item.quantity}',
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8.w),
              _QtyBtn(icon: Icons.add_rounded, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
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
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 14.r, color: AppColors.textPrimary),
      ),
    );
  }
}
