import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_bank_flutter/features/service/providers/report_provider.dart';

class ReportPage extends ConsumerStatefulWidget {
  final String reportedUserName;
  final String reportReason;
  final String targetId;
  final String targetType;

  const ReportPage({
    super.key,
    required this.reportedUserName,
    required this.reportReason,
    required this.targetId,
    required this.targetType,
  });

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  List<String> _selectedImages = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final status = await Permission.camera.request();
                if (!status.isGranted) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Quyền camera bị từ chối'),
                    ));
                  }
                  return;
                }
                try {
                  final XFile? picked = await ImagePicker()
                      .pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (picked != null) {
                    setState(() => _selectedImages.add(picked.path));
                  }
                } catch (e) {
                  debugPrint('Camera pick error: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () async {
                Navigator.of(ctx).pop();
                // Kiểm tra quyền (đơn giản hóa cho Android/iOS)
                PermissionStatus status;
                if (Platform.isAndroid) {
                  status = await Permission.photos.status;
                  if (status.isDenied)
                    status = await Permission.storage.request();
                } else {
                  status = await Permission.photos.request();
                }

                if (status.isGranted ||
                    status.isLimited ||
                    await Permission.photos.request().isGranted) {
                  try {
                    final XFile? picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) {
                      setState(() => _selectedImages.add(picked.path));
                    }
                  } catch (e) {
                    debugPrint('Gallery pick error: $e');
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Cần quyền truy cập thư viện ảnh'),
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _uploadImages(List<String> localPaths) async {
    final List<String> downloadUrls = [];

    if (localPaths.isEmpty) {
      return downloadUrls;
    }

    final storageRef = FirebaseStorage.instance.ref();

    // Chỉ upload những đường dẫn là file local (không bắt đầu bằng http)
    final pathsToUpload =
        localPaths.where((p) => !p.startsWith('http')).toList();

    await Future.wait(
      pathsToUpload.map((localPath) async {
        try {
          final file = File(localPath);
          final fileName =
              'report_images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
          final uploadRef = storageRef.child(fileName);
          final uploadTask = uploadRef.putFile(file);
          final snapshot = await uploadTask.whenComplete(() {});
          final downloadUrl = await snapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        } catch (e) {
          debugPrint('Lỗi upload file: $localPath - Lỗi: $e');
        }
      }),
    );
    downloadUrls.addAll(localPaths.where((p) => p.startsWith('http')));
    return downloadUrls;
  }

  void _submitReport() async {
    setState(() => _isLoading = true);
    try {
      final List<String> imageUrls = await _uploadImages(_selectedImages);

      await ref.read(createReportProvider({
        "targetType": widget.targetType,
        "targetId": widget.targetId,
        "reason": widget.reportReason,
        "description": _descriptionController.text,
        "imageUrls": imageUrls,
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi báo cáo thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Submit report error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi báo cáo thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._selectedImages.map((path) {
              return SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ảnh nền
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 110,
                        height: 110,
                        color: Colors.grey[200],
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.remove(path);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54, // Màu nền bán trong suốt
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Nút thêm ảnh
            GestureDetector(
              onTap: () => _showImageSourceOptions(context),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                    SizedBox(height: 4),
                    Text("Thêm ảnh",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Xác định tiêu đề hiển thị
    final titleLabel =
        widget.targetType == 'user' ? 'Báo cáo người dùng' : 'Báo cáo dịch vụ';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleLabel,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF003E77),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$titleLabel:',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              widget.reportedUserName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003E77)),
            ),
            const SizedBox(height: 24),

            const Text(
              'Lý do báo cáo:',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200)),
              child: Text(
                widget.reportReason,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Mô tả chi tiết:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Cung cấp thêm thông tin về hành vi vi phạm (nếu có)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF003E77)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Thêm ảnh minh họa:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildImagePicker(), // Widget chọn ảnh đã cập nhật

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF003E77), // Đổi màu nút cho hợp tông
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Gửi báo cáo',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
