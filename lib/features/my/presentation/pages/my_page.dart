import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

// 알림 설정 상태 관리를 위한 Provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<bool> {
  NotificationNotifier() : super(true);
  void toggle() => state = !state;
  void updateNotification(bool value) => state = value;
}

// 사용자 정보 Provider (예시)
final userProfileProvider = Provider<Map<String, String>>((ref) {
  return {
    'name': '김민수',
    'email': 'minsu@gmail.com',
    'phone': '010-1234-5678',
    'location': '부산, 대한민국',
  };
});

class MyPage extends HookConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final deletePasswordController = useTextEditingController();
    final notificationEnabled = ref.watch(notificationProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadowLight,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(profile),
            SizedBox(height: AppSizes.gapL),
            _buildMenuSections(
              context,
              ref,
              notificationEnabled,
              currentPasswordController,
              newPasswordController,
              confirmPasswordController,
              deletePasswordController,
            ),
            _buildLogoutButton(context),
            _buildAppInfo(),
            SizedBox(height: AppSizes.gapXL),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(Map<String, String> profile) {
    return Container(
      margin: EdgeInsets.fromLTRB(AppSizes.gapM, AppSizes.gapM, AppSizes.gapM, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.gapL),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Icon(
                Icons.person,
                size: AppSizes.iconXL,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: AppSizes.gapM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile['name']!,
                    style: AppTextStyles.h4,
                  ),
                  SizedBox(height: AppSizes.gapXS),
                  Text(
                    profile['email']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSizes.gapS),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppSizes.iconS,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: AppSizes.gapXS),
                      Text(
                        profile['location']!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSections(
      BuildContext context,
      WidgetRef ref,
      bool notificationEnabled,
      TextEditingController currentPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      TextEditingController deletePasswordController,
      ) {
    final sections = [
      {
        'title': '계정 관리',
        'items': [
          {
            'icon': Icons.security,
            'title': '비밀번호 변경',
            'onTap': () => _showPasswordChangeDialog(context, currentPasswordController, newPasswordController, confirmPasswordController),
          },
          {
            'icon': Icons.person_remove,
            'title': '회원탈퇴',
            'onTap': () => _showDeleteAccountDialog(context, deletePasswordController),
          },
        ],
      },
      {
        'title': '설정',
        'items': [
          {
            'icon': Icons.notifications_outlined,
            'title': '푸시 알림',
            'isToggle': true,
            'toggleValue': notificationEnabled,
            'onToggle': (value) {
              ref.read(notificationProvider.notifier).updateNotification(value);
              _showSnackBar(context, value ? '알림이 켜졌습니다' : '알림이 꺼졌습니다');
            },
          },
        ],
      },
    ];

    return Column(
      children: sections.map((section) {
        return Container(
          margin: EdgeInsets.fromLTRB(AppSizes.gapM, 0, AppSizes.gapM, AppSizes.gapM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(AppSizes.spacingM, AppSizes.gapM, AppSizes.spacingM, AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusL),
                    topRight: Radius.circular(AppSizes.radiusL),
                  ),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Text(
                  section['title'] as String,
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ...((section['items'] as List).asMap().entries.map((entry) {
                final item = entry.value as Map<String, dynamic>;
                final isLast = entry.key == (section['items'] as List).length - 1;
                return _buildMenuItem(
                  icon: item['icon'] as IconData,
                  title: item['title'] as String,
                  onTap: item['onTap'] as VoidCallback?,
                  isToggle: item['isToggle'] as bool? ?? false,
                  toggleValue: item['toggleValue'] as bool? ?? false,
                  onToggle: item['onToggle'] as Function(bool)?,
                  isLast: isLast,
                );
              })),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isToggle = false,
    bool toggleValue = false,
    Function(bool)? onToggle,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: isToggle ? null : onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? Radius.circular(AppSizes.radiusL) : Radius.zero,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.gapM,
        ),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: AppColors.greyLight)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.gapS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                icon,
                size: AppSizes.iconM,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: AppTextStyles.medium,
                ),
              ),
            ),
            if (isToggle)
              Switch(
                value: toggleValue,
                onChanged: onToggle,
                activeColor: AppColors.primary,
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: AppSizes.iconM,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(AppSizes.gapM, AppSizes.gapS, AppSizes.gapM, AppSizes.gapL),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(0.1),
            foregroundColor: AppColors.error,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: AppSizes.gapM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              side: BorderSide(color: AppColors.error.withOpacity(0.3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: AppSizes.iconM),
              SizedBox(width: AppSizes.gapS),
              Text(
                '로그아웃',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        children: [
          Text(
            '앱 버전 1.0.0',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.gapXS),
          Text(
            '© 2025 Offpeak. All rights reserved.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.gapXS),
          Text(
            '데이터 제공: 한국관광공사 TourAPI',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog(
      BuildContext context,
      TextEditingController currentPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        backgroundColor: AppColors.surface,
        title: Text(
          '비밀번호 변경',
          style: AppTextStyles.h4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                labelText: '현재 비밀번호',
                labelStyle: AppTextStyles.inputLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.borderFocus),
                ),
              ),
            ),
            SizedBox(height: AppSizes.gapM),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                labelText: '새 비밀번호',
                labelStyle: AppTextStyles.inputLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.borderFocus),
                ),
              ),
            ),
            SizedBox(height: AppSizes.gapM),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                labelText: '새 비밀번호 확인',
                labelStyle: AppTextStyles.inputLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.borderFocus),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              currentPasswordController.clear();
              newPasswordController.clear();
              confirmPasswordController.clear();
              Navigator.pop(context);
            },
            child: Text(
              '취소',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // 비밀번호 변경 로직
              if (newPasswordController.text != confirmPasswordController.text) {
                _showSnackBar(context, '새 비밀번호가 일치하지 않습니다.');
                return;
              }
              if (newPasswordController.text.length < 6) {
                _showSnackBar(context, '비밀번호는 6자 이상이어야 합니다.');
                return;
              }
              currentPasswordController.clear();
              newPasswordController.clear();
              confirmPasswordController.clear();
              Navigator.pop(context);
              _showSnackBar(context, '비밀번호가 변경되었습니다.');
            },
            child: Text(
              '변경',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context,
      TextEditingController deletePasswordController,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        backgroundColor: AppColors.surface,
        title: Text(
          '회원탈퇴',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 회원탈퇴를 하시겠습니까?',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              '⚠️ 주의사항:',
              style: AppTextStyles.labelBold,
            ),
            SizedBox(height: AppSizes.gapXS),
            Text('• 모든 데이터가 삭제됩니다', style: AppTextStyles.bodyMedium),
            Text('• 삭제된 데이터는 복구할 수 없습니다', style: AppTextStyles.bodyMedium),
            Text('• 동일한 이메일로 재가입이 가능합니다', style: AppTextStyles.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation(context, deletePasswordController);
            },
            child: Text(
              '탈퇴하기',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(
      BuildContext context,
      TextEditingController passwordController,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        backgroundColor: AppColors.surface,
        title: Text(
          '최종 확인',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '회원탈퇴를 위해 비밀번호를 입력해주세요.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSizes.gapM),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                labelText: '비밀번호',
                labelStyle: AppTextStyles.inputLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  borderSide: BorderSide(color: AppColors.borderFocus),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.clear();
              Navigator.pop(context);
            },
            child: Text(
              '취소',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // 실제 회원탈퇴 로직
              passwordController.clear();
              Navigator.pop(context);
              _deleteAccount(context);
            },
            child: Text(
              '탈퇴 완료',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        backgroundColor: AppColors.surface,
        title: Text(
          '로그아웃',
          style: AppTextStyles.h4,
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: Text(
              '로그아웃',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    // 실제 회원탈퇴 로직 구현
    _showSnackBar(context, '회원탈퇴가 완료되었습니다.');
    // 로그인 페이지로 이동
    // context.pushReplacement('/login');
  }

  void _logout(BuildContext context) {
    // 실제 로그아웃 로직 구현
    _showSnackBar(context, '로그아웃되었습니다.');
    // Navigator.pushReplacementNamed(context, '/login');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
    );
  }
}