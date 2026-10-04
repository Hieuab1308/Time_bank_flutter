import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/domain/user_profile.dart';

class MyQrCodePage extends ConsumerStatefulWidget {
  const MyQrCodePage({super.key});

  @override
  ConsumerState<MyQrCodePage> createState() => _MyQrCodePageState();
}

class _MyQrCodePageState extends ConsumerState<MyQrCodePage> {
  bool _isSaving = false;

  Future<void> _saveQrCode(String qrUrl) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 1. Download image to temporary directory
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      
      await Dio().download(qrUrl, path);

      // 2. Save to gallery using gal
      await Gal.putImage(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu mã QR vào thư viện ảnh!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().toLowerCase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorStr.contains('accessdenied') || errorStr.contains('permission')
                ? 'Không có quyền truy cập thư viện ảnh.'
                : 'Lỗi khi lưu ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR của tôi'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D1B4C),
                Color(0xFF0F58A1)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: userProfileState.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Đã xảy ra lỗi: $err'),
          data: (user) {
            return _buildQrCodeView(user);
          },
        ),
      ),
    );
  }

  Widget _buildQrCodeView(UserProfile user) {
    if (user.qrCode == null || user.qrCode!.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tạo mã QR...'),
          Text('Vui lòng thử lại sau giây lát.'),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D1B4C),
            Color(0xFF0F58A1)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            user.qrCode!,
            width: 250,
            height: 250,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, size: 100, color: Colors.yellow);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Đưa mã này cho người khác để nhận Time',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tài khoản: ${user.phone}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _saveQrCode(user.qrCode!),
            icon: _isSaving 
                ? const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Icon(Icons.download, color: Color(0xFF0D1B4C)),
            label: Text(
              _isSaving ? 'Đang lưu...' : 'Lưu mã QR',
              style: const TextStyle(
                color: Color(0xFF0D1B4C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}