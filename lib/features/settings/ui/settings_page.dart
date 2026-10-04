import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/account_header.dart';
import 'change_password_page.dart';
import 'change_pin_page.dart';
import '../../auth/providers/auth_providers.dart';
import '../../profile/ui/profile_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        icon: const Icon(Icons.logout_rounded, color: kLogoutButtonColor, size: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: kDarkTextColor, fontWeight: FontWeight.bold, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
          style: TextStyle(color: kGreyTextColor, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGreyTextColor,
                    side: BorderSide(color: kGreyTextColor.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Huỷ bỏ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kLogoutButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Đăng xuất'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.loading;

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF003E77),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: profileAsync.when(
            data: (user) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountHeader(user: user),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  context,
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Hồ sơ cá nhân',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none,
                      title: 'Thông báo',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.vpn_key_outlined,
                      title: 'Đổi mã PIN',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePinPage()));
                      },
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: isLoggingOut ? null : () => _handleLogout(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLogoutButtonColor,
                      disabledBackgroundColor: kLogoutButtonColor.withOpacity(0.6),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: kLogoutButtonColor.withOpacity(0.3),
                    ),
                    child: isLoggingOut
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
            error: (e, st) => Center(child: Text('Lỗi khi tải thông tin: $e', style: const TextStyle(color: kDarkTextColor))),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: kPrimaryColor),
          title: Text(title, style: const TextStyle(color: kDarkTextColor, fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, color: kGreyTextColor, size: 18),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: kLightBackgroundColor,
          ),
      ],
    );
  }
}