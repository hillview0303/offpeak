import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 알림 설정 상태 관리를 위한 Provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<bool> {
  NotificationNotifier() : super(true); // 기본값 true

  void toggle() {
    state = !state;
  }

  void updateNotification(bool value) {
    state = value;
  }
}

// 사용자 정보 Provider (예시)
final userProfileProvider = Provider<Map<String, String>>((ref) {
  return {
    'name': '김민수',
    'email': 'minsu@example.com',
    'phone': '010-1234-5678',
    'location': '부산, 대한민국',
  };
});

class MyPage extends HookConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final deletePasswordController = useTextEditingController();

    // Providers
    final notificationEnabled = ref.watch(notificationProvider);
    final profile = ref.watch(userProfileProvider);

    // 컨트롤러 dispose는 자동으로 처리됨
    useEffect(() {
      return () {
        // cleanup은 Hook이 자동으로 처리
      };
    }, []);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(profile),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(Map<String, String> profile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile['email']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile['location']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
            'onTap': () => _showPasswordChangeDialog(
              context,
              currentPasswordController,
              newPasswordController,
              confirmPasswordController,
            ),
          },
          {
            'icon': Icons.person_remove,
            'title': '회원탈퇴',
            'onTap': () => _showDeleteAccountDialog(
              context,
              deletePasswordController,
            ),
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
              _showSnackBar(
                context,
                value ? '알림이 켜졌습니다' : '알림이 꺼졌습니다',
              );
            },
          },
        ],
      },
    ];

    return Column(
      children: sections.map((section) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Text(
                  section['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              ...((section['items'] as List).asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value as Map<String, dynamic>;
                final isLast = index == (section['items'] as List).length - 1;

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
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isToggle) ...[
              Switch(
                value: toggleValue,
                onChanged: onToggle,
                activeColor: const Color(0xFF3B82F6),
              ),
            ] else ...[
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red[600],
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red[200]!),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 8),
              Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            '앱 버전 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2025 Your Company. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '현재 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호 확인',
                border: OutlineInputBorder(),
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
            child: const Text('취소'),
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
            child: const Text('변경'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '회원탈퇴',
          style: TextStyle(color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말로 회원탈퇴를 하시겠습니까?'),
            SizedBox(height: 8),
            Text(
              '⚠️ 주의사항:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('• 모든 데이터가 삭제됩니다'),
            Text('• 삭제된 데이터는 복구할 수 없습니다'),
            Text('• 동일한 이메일로 재가입이 가능합니다'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation(context, deletePasswordController);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('탈퇴하기'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '최종 확인',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('회원탈퇴를 위해 비밀번호를 입력해주세요.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
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
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 실제 회원탈퇴 로직
              passwordController.clear();
              Navigator.pop(context);
              _deleteAccount(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('탈퇴 완료'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
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
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
