import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/themes/beer_colors.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authStateProvider);
    if (authState is Authenticated) {
      _nameController.text = authState.user.name;
      _emailController.text = authState.user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隱私設定'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('變更 Profile Information', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            _buildProfileForm(),
            SizedBox(height: 24.h),
            Divider(height: 1.h),
            SizedBox(height: 24.h),
            Text('變更密碼', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            _buildPasswordForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _profileFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '姓名'),
            validator: (v) => (v == null || v.isEmpty) ? '請輸入姓名' : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty) ? '請輸入 Email' : null,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savingProfile ? null : _submitProfile,
              style: ElevatedButton.styleFrom(backgroundColor: BeerColors.primaryAmber600),
              child: _savingProfile
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('儲存資料'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    try {
      final service = AuthService();
      final user = await service.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      final token = await service.getAuthToken() ?? '';
      ref.read(authStateProvider.notifier).state = Authenticated(
        User.fromUserData(user),
        token,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('個人資料已更新')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新失敗：$e')));
      }
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _currentPwdController,
            decoration: const InputDecoration(labelText: '目前密碼'),
            obscureText: true,
            validator: (v) => (v == null || v.isEmpty) ? '請輸入目前密碼' : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _newPwdController,
            decoration: const InputDecoration(labelText: '新密碼'),
            obscureText: true,
            validator: (v) => (v == null || v.length < 8) ? '至少 8 碼' : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _confirmPwdController,
            decoration: const InputDecoration(labelText: '確認新密碼'),
            obscureText: true,
            validator: (v) => (v != _newPwdController.text) ? '與新密碼不一致' : null,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savingPassword ? null : _submitPassword,
              style: ElevatedButton.styleFrom(backgroundColor: BeerColors.error700),
              child: _savingPassword
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('變更密碼'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    try {
      final service = AuthService();
      await service.changePassword(
        currentPassword: _currentPwdController.text,
        newPassword: _newPwdController.text,
        newPasswordConfirmation: _confirmPwdController.text,
      );
      if (mounted) {
        _currentPwdController.clear();
        _newPwdController.clear();
        _confirmPwdController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密碼已更新')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('變更失敗：$e')));
      }
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }
}


