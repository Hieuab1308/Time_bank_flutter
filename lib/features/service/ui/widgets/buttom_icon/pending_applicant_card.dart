import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_bank_flutter/features/service/domain/models/offer.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/applicantdetailfullpage.dart';

class PendingApplicantCard extends StatelessWidget {
  final Offer offer;

  const PendingApplicantCard({super.key, required this.offer});

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
    final bool isWithdrawRequest = offer.status == 'withdrawn';

    final String requestTypeText;
    final Color requestColor;

    if (isWithdrawRequest) {
      requestTypeText = 'Yêu cầu chờ xét duyệt hủy dịch vụ';
      requestColor = Colors.red[800] ?? const Color(0xFFD32F2F);
    } else {
      requestTypeText = 'Yêu cầu chờ xét duyệt nhận dịch vụ';
      requestColor = const Color.fromARGB(255, 25, 154, 29);
    }

    final requestTime = _formatDateTime(offer.createdAt);

    final jobTitle = offer.jobTitle;
    final jobTime = _formatDateTime(offer.preferredStart);
    final duration = _formatDuration(offer.time);
    final location =
        offer.place.trim().isNotEmpty ? offer.place : offer.regionCode;

    final jobSkills =
        offer.skills.map((skill) => skill['name'] ?? '').join(', ');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ApplicantDetailFullPage(offer: offer)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(requestTypeText,
                        style: TextStyle(fontSize: 13, color: requestColor))),
                Text(requestTime,
                    style: TextStyle(fontSize: 12, color: requestColor)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: offer.offerUserAvatar != null
                      ? NetworkImage(offer.offerUserAvatar!)
                      : null,
                  child: offer.offerUserAvatar == null
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.offerUserName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003E77))),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(jobTitle,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003E77))),
                        const SizedBox(height: 8),
                        _CardLabelValue(
                            label: 'Thời gian',
                            value: jobTime,
                            valueStyle: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        _CardLabelValue(
                            label: 'Thời lượng',
                            value: duration,
                            valueStyle: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFCC0404),
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        if (location.isNotEmpty)
                          _CardLabelValue(label: 'Địa điểm', value: location),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: LayoutBuilder(builder: (context, constraints) {
                        final double maxChipWidth = 72;
                        final double chipWidth =
                            (constraints.maxWidth).clamp(40, maxChipWidth);

                        final specializations = jobSkills
                            .split(',')
                            .map((e) => e.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: specializations
                              .map((spec) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: chipWidth),
                                      child: SizedBox(
                                        height: 20,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0DC06),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            spec.trim(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF000000),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
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

class _CardLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _CardLabelValue(
      {required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 80,
          child: Text('$label:',
              style: const TextStyle(fontSize: 12, color: Color(0xFF003E77)))),
      const SizedBox(width: 8),
      Expanded(
          child: Text(value,
              style: valueStyle ??
                  const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.w600),
              softWrap: false,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}

class _SpecializationTagsInline extends StatelessWidget {
  final String? specializations;
  const _SpecializationTagsInline({this.specializations});

  @override
  Widget build(BuildContext context) {
    if (specializations == null || specializations!.isEmpty) {
      return const Text('Chưa có thông tin',
          style: TextStyle(color: Colors.grey));
    }
    final tags = specializations!.split(',').map((e) => e.trim()).toList();
    return Wrap(
        spacing: 6,
        runSpacing: 4,
        children: tags
            .map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE0DC06),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(t,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF000000)))))
            .toList());
  }
}
