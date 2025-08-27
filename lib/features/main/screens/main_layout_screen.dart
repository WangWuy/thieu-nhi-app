// lib/features/main/screens/main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/features/attendance/screens/qr_scanner_screen.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:thieu_nhi_app/features/profile/screens/profile_screen.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final tabs = _getTabsForUser(user);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;

              // Rebuild QR Scanner khi switch tab để reset camera
              if (index == 1 && tab.screen is QRScannerScreen) {
                return _currentIndex == index
                    ? tab.screen
                    : Container(); // Empty container khi không active
              }

              return tab.screen;
            }).toList(),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(tabs, user),
        );
      },
    );
  }

  List<TabItem> _getTabsForUser(UserModel user) {
    final baseTabs = [
      TabItem(
        icon: Icons.home,
        activeIcon: Icons.home_rounded,
        label: 'Trang chủ',
        screen: const DashboardScreen(),
      ),
      // ← Thêm tab QR Scanner ở giữa
      TabItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Điểm danh',
        screen: const QRScannerScreen(),
      ),
      TabItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Cá nhân',
        screen: const ProfileScreen(),
      ),
    ];

    return baseTabs;
  }

  Widget _buildBottomNavigationBar(List<TabItem> tabs, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 70,
            maxHeight: 90,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = index == _currentIndex;

              // ← Đặc biệt cho tab QR Scanner (tab giữa)
              final isQRTab = index == 1; // Tab QR là index 1

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isQRTab
                              ? AppColors.secondary.withOpacity(0.1)
                              : _getRoleColor(user.role).withOpacity(0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(
                              isQRTab ? 8 : 6), // QR tab lớn hơn 1 chút
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isQRTab
                                    ? AppColors.secondary
                                    : _getRoleColor(user.role))
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(isQRTab ? 16 : 12),
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            color: isActive ? Colors.white : AppColors.grey600,
                            size: isQRTab ? 26 : 22, // QR icon lớn hơn
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? (isQRTab
                                      ? AppColors.secondary
                                      : _getRoleColor(user.role))
                                  : AppColors.grey600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.department:
        return AppColors.primary;
      case UserRole.teacher:
        return AppColors.success;
    }
  }
}

class TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}
