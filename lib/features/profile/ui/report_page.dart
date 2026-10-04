import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_bank_flutter/features/service/providers/report_provider.dart';

class ReportPage extends ConsumerStatefulWidget {
  final String reportedUserName; // Tên hiển thị (người hoặc dịch vụ)
  final String reportReason;     // Lý do chọn từ menu

  final String targetId;         
  final String targetType;       

  const ReportPage({
    super.key,
    required this.reportedUserName,
    required this.reportReason,
    required this.targetId,      // <<
    required this.targetType,    // <<
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
                PermissionStatus status = PermissionStatus.denied;
                if (Platform.isAndroid) {
                  status = await Permission.storage.request();
                  if (!status.isGranted) {
                    status = await Permission.photos.request();
                  }
                } else if (Platform.isIOS) {
                  status = await Permission.photos.request();
                } else {
                  status = await Permission.storage.request();
                }
                
                final allowed = status.isGranted || status.isLimited;
                if (!allowed) {
                  if (mounted) {
                     final open = await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Quyền bị từ chối'),
                        content: const Text(
                            'Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh. Bạn có muốn mở Cài đặt để cấp quyền?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(dctx).pop(false),
                              child: const Text('Hủy')),
                          TextButton(
                              onPressed: () => Navigator.of(dctx).pop(true),
                              child: const Text('Mở Cài đặt')),
                        ],
                      ),
                    );
                    if (open == true) openAppSettings();
                  }
                  return;
                }

                try {
                  final XFile? picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (picked != null) {
                    setState(() => _selectedImages.add(picked.path));
                  }
                } catch (e) {
                  debugPrint('Gallery pick error: $e');
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
    
    // Lọc ra những ảnh local (chưa có http)
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
    
    // Giữ lại các ảnh đã là URL (nếu có)
    downloadUrls.addAll(localPaths.where((p) => p.startsWith('http')));
    return downloadUrls;
  }

  // ✅ HÀM GỌI API ĐÃ ĐƯỢC CẬP NHẬT
  void _submitReport() async {
    setState(() => _isLoading = true);
    try {
      // 1. Upload ảnh trước (nếu có)
      final List<String> imageUrls = await _uploadImages(_selectedImages);

      // 2. Gọi Provider để tạo Report
      // Truyền đúng targetId và targetType từ widget
      await ref.read(createReportProvider({
        "targetType": widget.targetType, // 'user' hoặc 'job'/'service'
        "targetId": widget.targetId,     // ID đối tượng
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
        Navigator.pop(context); // Quay lại màn hình trước
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

  // Widget hiển thị ảnh với nút X
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // List ảnh đã chọn
            ..._selectedImages.map((path) {
              return SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 110, 
                        height: 110,
                        color: Colors.grey[200],
                        child: Image.file(
                          File(path),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Nút X
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
                            color: Colors.black54,
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
                child: const Center(child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tự động xác định tiêu đề dựa trên targetType
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
      // Thêm gesture detector để ẩn bàn phím khi chạm ra ngoài
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white, // Đảm bảo nền trắng cho gesture detector hoạt động tốt
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  '$titleLabel:',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                
                // Tên đối tượng bị báo cáo
                Text(
                  widget.reportedUserName,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003E77)),
                ),
                const SizedBox(height: 24),

                // Lý do
                const Text(
                  'Lý do báo cáo:',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
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
                const Divider(height: 32),

                // Mô tả
                const Text(
                  'Mô tả chi tiết:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Cung cấp thêm thông tin về hành vi vi phạm...',
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

                // Ảnh minh họa
                const Text(
                  'Thêm ảnh minh họa:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildImagePicker(),
                
                const SizedBox(height: 40),
                
                // Nút gửi
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003E77), // Đổi màu cho đồng bộ app bar
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
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Gửi báo cáo',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}