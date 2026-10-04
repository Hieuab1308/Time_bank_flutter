import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:time_bank_flutter/features/service/domain/models/offer.dart';
import 'package:time_bank_flutter/features/service/providers/service_providers.dart';

class ApplicantDetailFullPage extends ConsumerStatefulWidget {
  final Offer offer;

  const ApplicantDetailFullPage({super.key, required this.offer});

  @override
  ConsumerState<ApplicantDetailFullPage> createState() =>
      _ApplicantDetailFullPageState();
}

class _ApplicantDetailFullPageState
    extends ConsumerState<ApplicantDetailFullPage> {
  bool _isLoading = false;
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final refLocal = ref;
    final offer = widget.offer;

    final bool isWithdrawRequest = offer.status == 'withdrawn';

    final appBarTitle = isWithdrawRequest
        ? 'Yêu cầu hủy dịch vụ'
        : 'Yêu cầu nhận dịch vụ';

    final greenButtonText = isWithdrawRequest ? 'Duyệt hủy' : 'Duyệt yêu cầu';
    final redButtonText = isWithdrawRequest ? 'Từ chối hủy' : 'Từ chối';

    final serviceName = offer.jobTitle;
    final duration = _formatDuration(offer.time);
    final detailLocation =
    offer.place.trim().isNotEmpty ? offer.place : offer.regionCode;
    final jobCreatedTime = _formatDateTime(offer.preferredStart);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: const Color(0xFF003E77),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF003E77),
                    backgroundImage: offer.offerUserAvatar != null
                        ? NetworkImage(offer.offerUserAvatar!)
                        : null,
                    child: offer.offerUserAvatar == null
                        ? const Icon(Icons.person,
                        color: Colors.white, size: 35)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.offerUserName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003E77))),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mở chat...')));
                    },
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF003E77), size: 28),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                          label: 'Thời gian:',
                          value: jobCreatedTime,
                          valueStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      _InfoRow(
                          label: 'Tên dịch vụ:',
                          value: serviceName,
                          valueStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF003E77),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      _InfoRow(
                          label: 'Thời lượng dịch vụ:',
                          value: duration,
                          valueStyle: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFFCC0404),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      if (detailLocation.isNotEmpty) ...[
                        _InfoRow(label: 'Địa điểm:', value: detailLocation),
                        const SizedBox(height: 14),
                      ],
                      const Text('Ghi chú:',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF003E77))),
                      const SizedBox(height: 8),
                      TextField(
                          controller: TextEditingController(text: offer.note),
                          readOnly: true,
                          maxLines: 4,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                  BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                  BorderSide(color: Colors.grey[300]!)),
                              contentPadding: const EdgeInsets.all(12))),
                    ]),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          setState(() => _isLoading = true);
                          try {
                            final statusToUpdate = isWithdrawRequest
                                ? 'cancelled'
                                : 'accepted';

                            await refLocal.read(
                                updateOfferStatusAcceptedProvider((
                                offerId: offer.id,
                                jobId: offer.jobId,
                                status: statusToUpdate
                                )).future);
                            Navigator.pop(context);
                            refLocal.invalidate(allMyPendingOffersProvider);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Lỗi duyệt yêu cầu: ${e.toString()}')));
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        icon: _isLoading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const SizedBox.shrink(),
                        label: Text(greenButtonText,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )))),
              ]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                            setState(() => _isLoading = true);
                            try {
                              final statusToUpdate = isWithdrawRequest
                                  ? 'accepted'
                                  : 'rejected';

                              await refLocal.read(
                                  updateOfferStatusRejectedProvider((
                                  offerId: offer.id,
                                  jobId: offer.jobId,
                                  status: statusToUpdate
                                  )).future);
                              Navigator.pop(context);
                              refLocal.invalidate(allMyPendingOffersProvider);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lỗi từ chối yêu cầu: ${e.toString()}')));
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: _isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            redButtonText,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 145,
          child: Text(label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF003E77)))),
      Expanded(
          child: Text(value,
              style: valueStyle ??
                  const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.bold),
              softWrap: false,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}