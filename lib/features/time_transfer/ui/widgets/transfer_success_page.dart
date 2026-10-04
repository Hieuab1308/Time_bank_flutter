import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/transfer_result.dart';
import '../../providers/transaction_providers.dart';

class TransferSuccessPage extends ConsumerStatefulWidget {
  final TransferResult result;
  final String recipientName;
  final String senderName;
  final String recipientPhone;

  const TransferSuccessPage({
    super.key,
    required this.result,
    required this.recipientName,
    required this.senderName,
    required this.recipientPhone,
  });

  @override
  ConsumerState<TransferSuccessPage> createState() =>
      _TransferSuccessPageState();
}

class _TransferSuccessPageState extends ConsumerState<TransferSuccessPage> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _saveImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
      if (boundary == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lưu thất bại: không tìm thấy vùng ảnh')));
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lưu thất bại: không thể chuyển đổi ảnh')));
        return;
      }

      final bytes = byteData.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/transfer_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đã lưu ảnh: ${file.path}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
    }
  }


  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final d = Duration(seconds: totalSeconds);
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }


  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);
    const colorSuccess = Color(0xFF2ECC71);

    return WillPopScope(
      onWillPop: () async {
        ref.read(transactionFormProvider.notifier).reset();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: colorPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              ref.read(transactionFormProvider.notifier).reset();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: 250,
              color: colorPrimary,
            ),

            SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: Container(
                        margin:
                        const EdgeInsets.only(top: 60, left: 16, right: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              backgroundColor: colorSuccess,
                              child: Icon(Icons.check,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              "Chuyển thời gian thành công",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              _formatDuration(widget.result.secs),
                              style: const TextStyle(
                                fontSize: 34,
                                color: colorPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('HH:mm - dd/MM/yyyy')
                                  .format(widget.result.completedAt?.toLocal() ?? DateTime.now()),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.recipientName.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: colorPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.recipientPhone,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    '${widget.senderName.toUpperCase()} chuyển khoản',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Text(
                              "Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi",
                              style:
                              TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            const SizedBox(height: 36),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ActionButton(
                                    icon: Icons.share_outlined,
                                    label: "Chia sẻ",
                                    onTap: () {}),
                                _ActionButton(
                                    icon: Icons.home_outlined,
                                    label: "Trang chủ",
                                    onTap: () {
                                      ref
                                          .read(transactionFormProvider.notifier)
                                          .reset();
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    }),
                                _ActionButton(
                                    icon: Icons.download_outlined,
                                    label: "Lưu ảnh",
                                    onTap: _saveImage),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0, // Bỏ elevation theo UI gốc
                        ),
                        onPressed: () {
                          ref.read(transactionFormProvider.notifier).reset();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Thực hiện giao dịch khác",
                          style: TextStyle(fontSize: 17.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFBDBDBD);
    const iconColor = Color(0xFF666666);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: const Color(0x22003E77),
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}