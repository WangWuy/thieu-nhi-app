// lib/features/main/screens/main_layout_screen.dart - UPDATED WITH MANUAL ATTENDANCE
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'package:thieu_nhi_app/features/attendance/screens/qr_scanner_screen.dart';
import 'package:thieu_nhi_app/features/attendance/screens/manual_attendance_screen.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
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

        return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;

                  // Provide AttendanceBloc for attendance-related screens
                  if (tab.requiresAttendanceBloc) {
                    return _currentIndex == index
                        ? BlocProvider(
                            create: (context) => AttendanceBloc(
                              attendanceService: AttendanceService(),
                            ),
                            child: tab.screen,
                          )
                        : Container();
                  }

                  return _currentIndex == index ? tab.screen : Container();
                }).toList(),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(tabs, user),
            ));
      },
    );
  }

  List<TabItem> _getTabsForUser(UserModel user) {
    return [
      // Dashboard
      TabItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Trang chủ',
        screen: const DashboardScreen(),
        requiresAttendanceBloc: false,
      ),

      // QR Scanner
      TabItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Quét QR',
        screen: const QRScannerScreen(),
        requiresAttendanceBloc: true,
      ),

      // Manual Attendance ✅ NEW TAB
      TabItem(
        icon: Icons.edit_outlined,
        activeIcon: Icons.edit,
        label: 'Thủ công',
        screen: const ManualAttendanceScreen(),
        requiresAttendanceBloc: true,
      ),

      // Profile
      TabItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Cá nhân',
        screen: const ProfileScreen(),
        requiresAttendanceBloc: false,
      ),
    ];
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = index == _currentIndex;

              // Special styling for QR tab (middle)
              final isQRTab = index == 1;
              final isManualTab = index == 2; // Manual attendance tab

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isQRTab || isManualTab
                              ? AppColors.secondary.withOpacity(0.1)
                              : _getRoleColor(user.role).withOpacity(0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(
                            isQRTab || isManualTab ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isQRTab || isManualTab
                                    ? AppColors.secondary
                                    : _getRoleColor(user.role))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              isQRTab || isManualTab ? 14 : 12,
                            ),
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            color: isActive ? Colors.white : AppColors.grey600,
                            size: isQRTab || isManualTab ? 22 : 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? (isQRTab || isManualTab
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
  final bool requiresAttendanceBloc;

  TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
    this.requiresAttendanceBloc = false,
  });
}
