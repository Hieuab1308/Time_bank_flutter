import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/offer.dart';
import '../../../providers/service_providers.dart';

class PendingApplicantsWidget extends ConsumerStatefulWidget {
  final String serviceId;
  final ValueChanged<Map<String, dynamic>>? onApplicantTap;
  final bool showSearchAndFilter;
  final bool showAllJobs;

  const PendingApplicantsWidget({
    super.key,
    required this.serviceId,
    this.onApplicantTap,
    this.showSearchAndFilter = true,
    this.showAllJobs = false,
  });

  @override
  ConsumerState<PendingApplicantsWidget> createState() =>
      _PendingApplicantsWidgetState();
}

class _PendingApplicantsWidgetState
    extends ConsumerState<PendingApplicantsWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(offerListProvider(widget.serviceId));
  }

  Map<String, dynamic> _mapOfferToApplicantMap(Offer offer) {
    final specializationString = offer.skills
        .map((skill) => skill['name']?.toString() ?? 'N/A')
        .join(', ');

    final requestTimeString =
        DateFormat('HH:mm dd/MM/yyyy').format(offer.createdAt.toLocal());

    return {
      'id': offer.id,
      'status': offer.status,
      'serviceId': offer.jobId,
      'name': offer.offerUserName,
      'avatar': offer.offerUserAvatar,
      'specialization': specializationString.isEmpty
          ? 'Chưa có thông tin'
          : specializationString,
      'rating': 0.0,
      'requestTime': requestTimeString,
      'originalOffer': offer,
    };
  }

  String _formatDuration(int totalMinutes) {
    final duration = Duration(minutes: totalMinutes);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Widget _buildNoteInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF003E77),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Không có' : value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF003E77),
            fontWeight: FontWeight.w500,
          ),
          softWrap: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAllJobs) {
      return const Center(
        child: Text(
            'Chức năng "Show All Jobs" chưa được kết nối với API (cần API khác)'),
      );
    }

    final offersAsyncValue = ref.watch(offerListProvider(widget.serviceId));

    return offersAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Không thể tải danh sách ứng viên:\n$error\nKéo xuống để thử lại',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      data: (List<Offer> offers) {
        final allApplicantsMap = offers.map(_mapOfferToApplicantMap).toList();

        final servicePendingApplicants = allApplicantsMap
            .where((a) =>
                (a['status'] == 'pending' || a['status'] == 'withdrawn') &&
                a['serviceId'].toString() == widget.serviceId)
            .toList();

        final filteredApplicants = widget.showSearchAndFilter
            ? servicePendingApplicants.where((applicant) {
                final name = applicant['name'].toString().toLowerCase();
                final specialization =
                    applicant['specialization'].toString().toLowerCase();
                return name.contains(_searchQuery.toLowerCase()) ||
                    specialization.contains(_searchQuery.toLowerCase());
              }).toList()
            : servicePendingApplicants.toList();

        debugPrint('🔍 Filtered applicants: ${filteredApplicants.length}');

        return Column(
          children: [
            if (widget.showSearchAndFilter)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm ứng viên đã duyệt...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: Builder(
                  builder: (context) {
                    debugPrint(
                        '🎯 UI Decision: filteredApplicants.isEmpty = ${filteredApplicants.isEmpty}');
                    debugPrint('🎯 Search query: "$_searchQuery"');

                    if (filteredApplicants.isEmpty) {
                      debugPrint('📺 Showing empty state');
                      return LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.hourglass_empty,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Không tìm thấy ứng viên nào'
                                        : 'Không có ứng viên nào đang chờ phê duyệt',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    } else {
                      debugPrint(
                          'Showing ListView with ${filteredApplicants.length} items');
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredApplicants.length,
                        itemBuilder: (context, index) {
                          debugPrint(
                              'Building card for applicant ${index}: ${filteredApplicants[index]['name']}');
                          return _buildApplicantCard(
                              context, filteredApplicants[index]);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecializationTags(
      BuildContext context, String? specializations) {
    if (specializations == null ||
        specializations.isEmpty ||
        specializations == 'Chưa có thông tin') {
      return const Text('Chưa có thông tin',
          style: TextStyle(color: Colors.grey, fontSize: 12));
    }

    final List<String> tags =
        specializations.split(',').map((e) => e.trim()).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: tags
            .map((tag) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0DC06),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 9,
                      color: (Color(0xFF000000)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildApplicantCard(
      BuildContext context, Map<String, dynamic> applicant) {
    final String status = applicant['status'] ?? '';
    final String requestTypeText;
    final Color requestTypeColor;

    if (status == 'withdrawn') {
      requestTypeText = 'Yêu cầu chờ xét duyệt hủy dịch vụ';
      requestTypeColor = Colors.red;
    } else {
      requestTypeText = 'Yêu cầu chờ xét duyệt nhận dịch vụ';
      requestTypeColor = const Color.fromARGB(255, 1, 151, 6);
    }

    final double rating = applicant['rating'] as double;

    return GestureDetector(
        onTap: () {
          if (widget.onApplicantTap != null) {
            widget.onApplicantTap!(applicant);
            return;
          }

          _showApplicantDetailsModal(context, applicant);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 1),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      requestTypeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: requestTypeColor,
                      ),
                    ),
                  ),
                  Text(
                    applicant['requestTime'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF003E77),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF003E77),
                    backgroundImage: applicant['avatar'] != null
                        ? NetworkImage(applicant['avatar'])
                        : null,
                    child: applicant['avatar'] == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 35)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF003E77),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Chuyên môn:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF003E77),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildSpecializationTags(
                                  context, applicant['specialization']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < applicant['rating'].floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: Color(0xFFE6E609),
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${applicant['rating']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003E77),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Bộ lọc ứng viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sắp xếp theo:'),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Tên A-Z'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Đánh giá cao nhất'),
                leading: const Icon(Icons.star),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Thời gian nộp mới nhất'),
                leading: const Icon(Icons.access_time),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showApplicantDetailsModal(
      BuildContext context, Map<String, dynamic> applicant) {
    final Offer? offer = applicant['originalOffer'] as Offer?;

    final serviceName = offer?.jobTitle ?? 'Chưa có thông tin';

    final duration = offer != null ? _formatDuration(offer.time) : '00:00:00';

    String jobCreatedTime = 'Chưa có thông tin';
    if (offer?.jobCreatedAt != null) {
      final createdAt = offer!.jobCreatedAt.toLocal();
      jobCreatedTime =
          '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
    }

    final double rating = applicant['rating'] as double;

    final String applicantNote = offer?.note ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Chi tiết ứng viên',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003E77),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFF003E77),
                            backgroundImage: applicant['avatar'] != null
                                ? NetworkImage(applicant['avatar'])
                                : null,
                            child: applicant['avatar'] == null
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 35)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  applicant['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF003E77),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Chuyên môn:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF003E77),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildSpecializationTags(
                                          context, applicant['specialization']),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < rating.floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Color(0xFFE6E609),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$rating',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF003E77),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mở chat...')),
                              );
                            },
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFF003E77),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Thời gian:', jobCreatedTime),
                            const SizedBox(height: 12),
                            _buildInfoRow('Tên dịch vụ:', serviceName),
                            const SizedBox(height: 12),
                            _buildInfoRow('Thời lượng dịch vụ:', duration),
                            const SizedBox(height: 12),
                            _buildNoteInfoRow(
                                'Ghi chú của ứng viên:', applicantNote),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _showApproveConfirmDialog(
                                          context, applicant);
                                    },
                              icon: const Icon(Icons.person_add_alt_outlined,
                                  size: 20, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              label: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Duyệt yêu cầu',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _showRejectConfirmDialog(
                                          context, applicant);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Từ chối',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF003E77),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF003E77),
              fontWeight: FontWeight.bold,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showApproveConfirmDialog(
      BuildContext context, Map<String, dynamic> applicant) {
    final String currentStatus = applicant['status'] ?? 'pending';
    final bool isReceiveRequest = currentStatus == 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Xác nhận duyệt',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isReceiveRequest
              ? 'Bạn có chắc muốn duyệt ứng viên ${applicant['name']}?'
              : 'Bạn có chắc muốn duyệt yêu cầu hủy của ${applicant['name']}?',
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFFCC0404),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final Offer? offer = applicant['originalOffer'] as Offer?;
              if (offer == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lỗi: Không tìm thấy dữ liệu offer.')),
                );
                Navigator.pop(context);
                return;
              }

              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              final String newApiStatus =
                  isReceiveRequest ? 'accepted' : 'cancelled';
              try {
                await ref.read(updateOfferStatusAcceptedProvider(
                  (
                    offerId: offer.id,
                    jobId: offer.jobId,
                    status: newApiStatus,
                  ),
                ).future);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isReceiveRequest
                        ? 'Đã duyệt ứng viên ${applicant['name']}'
                        : 'Đã duyệt yêu cầu hủy của ${applicant['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(offerListProvider(widget.serviceId));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Duyệt thất bại: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('Đồng ý',
                style: TextStyle(
                  color: Color(0xFF003E77),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmDialog(
      BuildContext context, Map<String, dynamic> applicant) {
    final String currentStatus = applicant['status'] ?? 'pending';
    final bool isReceiveRequest = currentStatus == 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Xác nhận từ chối',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isReceiveRequest
              ? 'Bạn có chắc muốn từ chối ứng viên ${applicant['name']}?'
              : 'Bạn có chắc muốn từ chối yêu cầu hủy của ${applicant['name']}?',
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFFCC0404),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final Offer? offer = applicant['originalOffer'] as Offer?;
              if (offer == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lỗi: Không tìm thấy dữ liệu offer.')),
                );
                Navigator.pop(context);
                return;
              }

              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              final String newApiStatus =
                  isReceiveRequest ? 'rejected' : 'accepted';
              try {
                await ref.read(updateOfferStatusRejectedProvider(
                  (
                    offerId: offer.id,
                    jobId: offer.jobId,
                    status: newApiStatus,
                  ),
                ).future);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isReceiveRequest
                        ? 'Đã từ chối ứng viên ${applicant['name']}'
                        : 'Đã từ chối yêu cầu hủy của ${applicant['name']}'),
                    backgroundColor: Colors.orange,
                  ),
                );
                ref.invalidate(offerListProvider(widget.serviceId));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Từ chối thất bại: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text(
              'Từ chối',
              style: TextStyle(
                color: Color(0xFF003E77),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
