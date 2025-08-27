// lib/features/admin/widgets/account_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AccountTabBar extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onTabChanged;

  const AccountTabBar({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: TabBar(
          controller: tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey600,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          onTap: (index) => onTabChanged(),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'BĐH'),
            Tab(text: 'PDT'),
            Tab(text: 'GLV'),
          ],
        ),
      ),
    );
  }
}
