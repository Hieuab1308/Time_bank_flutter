import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'my_qr_page.dart';

class QrScannerPage extends StatefulWidget {
  final void Function(String scannedValue) onScanSuccess;

  const QrScannerPage({
    super.key,
    required this.onScanSuccess,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final ImagePicker _picker = ImagePicker();
  bool _isHandlingScan = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Xử lý khi quét được mã
  void _handleScannedValue(String scannedValue) {
    if (_isHandlingScan) return;
    setState(() { _isHandlingScan = true; });

    controller.stop();
    final isPhoneNumber = RegExp(r'^[0-9\+]{9,12}$').hasMatch(scannedValue);

    if (isPhoneNumber) {
      widget.onScanSuccess(scannedValue);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mã QR không hợp lệ. Đây không phải SĐT TimeBank.')),
      );
      setState(() { _isHandlingScan = false; });
      controller.start();
    }
  }

  /// Xử lý nút "Tải ảnh lên"
  void _scanFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // User hủy

      final bool success = await controller.analyzeImage(image.path);

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy mã QR trong ảnh.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đọc ảnh: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã'),
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
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.on:
                    return const Icon(Icons.flash_off, color: Colors.yellow);
                  case TorchState.off:
                    return const Icon(Icons.flash_on);
                  default: // unavailable
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Lớp Camera
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? scannedValue = barcodes.first.rawValue;
                if (scannedValue != null && scannedValue.isNotEmpty) {
                  _handleScannedValue(scannedValue);
                }
              }
            },
          ),
          _buildScannerOverlay(),
        ],
      ),
    );
  }


  /// Widget này vẽ UI đè lên camera
  Widget _buildScannerOverlay() {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Di chuyển Camera đến vùng chứa mã QR, tiến trình quét mã sẽ diễn ra tự động',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverlayButton(
                icon: Icons.qr_code_scanner,
                label: 'QR của tôi',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyQrCodePage()),
                  );
                },
              ),
              _buildOverlayButton(
                icon: Icons.image,
                label: 'Tải ảnh lên',
                onPressed: _scanFromGallery,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.black.withOpacity(0.5),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}