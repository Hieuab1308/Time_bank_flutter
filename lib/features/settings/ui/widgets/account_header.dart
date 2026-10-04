import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../profile/providers/providers.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../auth/providers/auth_providers.dart';


class AccountHeader extends ConsumerStatefulWidget {
  final UserProfile user;
  const AccountHeader({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<AccountHeader> createState() => _AccountHeaderState();
}

class _AccountHeaderState extends ConsumerState<AccountHeader> {
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildAvatar() {
    final url = widget.user.avatarUrl;
    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(url),
      );
    } else {
      return CircleAvatar(
        radius: 48,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.person_outline,
          size: 60,
          color: Colors.grey[600],
        ),
      );
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Bạn chưa đăng nhập!');
      }

      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      File file = File(pickedFile.path);
      String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String storagePath = 'avatars/$userId/$fileName';
      Reference storageRef = _storage.ref().child(storagePath);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadURL = await snapshot.ref.getDownloadURL();


      await ref.read(profileRepositoryProvider).updateMyProfile(
        {
          'avatar_url': downloadURL,
        },
      );

      ref.refresh(userProfileProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật avatar thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
      ),
      child: Column(
        children: [
          Text('Tài Khoản',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildAvatar(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                  if (_isUploading)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.user.fullName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(widget.user.email,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 18),
          Container(height: 8, color: Colors.grey[100]),
        ],
      ),
    );
  }
}