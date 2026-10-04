import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/offer.dart';
import '../../../providers/service_providers.dart';
// Đã XÓA: Import MockServiceRepository

class ApprovedApplicantsWidget extends ConsumerStatefulWidget {
  // <-- Đã đổi
  final String serviceId;

  const ApprovedApplicantsWidget({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<ApprovedApplicantsWidget> createState() => // <-- Đã đổi
      _ApprovedApplicantsWidgetState();
}

class _ApprovedApplicantsWidgetState
    extends ConsumerState<ApprovedApplicantsWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      'rating': 4.0,
      'requestTime': requestTimeString,
      'originalOffer': offer,
    };
  }

  @override
  Widget build(BuildContext context) {
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
                    'Không thể tải danh sách đã duyệt:\n$error\nKéo xuống để thử lại',
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

        final serviceApprovedApplicants = allApplicantsMap
            .where((a) =>
                a['status'] == 'accepted' &&
                a['serviceId'].toString() == widget.serviceId)
            .toList();

        // Lọc theo tìm kiếm
        final filteredApplicants = serviceApprovedApplicants.where((applicant) {
          final name = applicant['name'].toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            // Thanh tìm kiếm và icon lọc
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
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            // Danh sách ứng viên
            Expanded(
              child: RefreshIndicator(
                // <-- Thêm RefreshIndicator
                onRefresh: _handleRefresh,
                child: Builder(
                  builder: (context) {
                    if (filteredApplicants.isEmpty) {
                      // Bọc trạng thái rỗng để cho phép cuộn
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
                                        : Icons.check_circle_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Không tìm thấy ứng viên nào'
                                        : 'Chưa có ứng viên nào được duyệt',
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
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredApplicants.length,
                        itemBuilder: (context, index) {
                          try {
                            return _buildApplicantCard(
                                context, filteredApplicants[index]);
                          } catch (e) {
                            return Container(
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text('Error loading applicant: $e',
                                    style: const TextStyle(color: Colors.red)),
                              ),
                            );
                          }
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

  Widget _buildApplicantCard(
      BuildContext context, Map<String, dynamic> applicant) {
    // Cập nhật text, có thể đổi màu nếu muốn
    final String requestTypeText = 'Yêu cầu đã được phê duyệt nhận dịch vụ';
    const Color requestTypeColor =
        Color.fromARGB(255, 1, 151, 6); // Màu xanh lá

    return GestureDetector(
      onTap: () => _showApplicantDetailsModal(context, applicant),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    requestTypeText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: requestTypeColor, // <-- Dùng màu xanh
                    ),
                  ),
                ),
                Text(
                  applicant['requestTime']?.toString() ?? 'Không có thời gian',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF003E77),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Thông tin ứng viên
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: (applicant['avatar'] != null &&
                          applicant['avatar'].toString().isNotEmpty)
                      ? NetworkImage(applicant['avatar'].toString())
                      : null,
                  child: (applicant['avatar'] == null ||
                          applicant['avatar'].toString().isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 35)
                      : null,
                ),

                const SizedBox(width: 16),

                // Thông tin bên phải
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên
                      Text(
                        applicant['name']?.toString() ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003E77),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Chuyên môn
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

                      // Đánh giá
                      Row(
                        children: [
                          ...List.generate(5, (starIndex) {
                            final rating = applicant['rating'] ?? 0;
                            return Icon(
                              starIndex < (rating is num ? rating.toInt() : 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFE6E609),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${applicant['rating'] ?? 0}',
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
      ),
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

  void _showApplicantDetailsModal(
      BuildContext context, Map<String, dynamic> applicant) {
    final Offer? offer = applicant['originalOffer'] as Offer?;

    final serviceName = offer?.jobTitle ?? 'N/A';
    final jobCreatedTime = offer?.jobCreatedAt != null
        ? _formatDateTime(offer!.jobCreatedAt)
        : 'N/A';
    final duration = offer != null ? _formatDuration(offer.time) : '00:00:00';
    final description = offer?.jobDescription ?? 'Không có mô tả';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Chi tiết ứng viên đã duyệt',
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
                            backgroundImage: (applicant['avatar'] != null &&
                                    applicant['avatar'].toString().isNotEmpty)
                                ? NetworkImage(applicant['avatar'].toString())
                                : null,
                            child: (applicant['avatar'] == null ||
                                    applicant['avatar'].toString().isEmpty)
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
                                  applicant['name']?.toString() ??
                                      'Unknown User',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF003E77),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text(
                                      'Liên hệ:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF003E77),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Icon điện thoại
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Đang gọi điện thoại...')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Icon chat
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Mở chat...')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                      final rating = applicant['rating'] ?? 0;
                                      return Icon(
                                        starIndex <
                                                (rating is num
                                                    ? rating.toInt()
                                                    : 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: const Color(0xFFE6E609),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${applicant['rating'] ?? 0}',
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

                      const SizedBox(height: 14),

                      // Thông tin chi tiết công việc
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DÙNG DỮ LIỆU TỪ OFFER
                            _buildInfoSectionBold(
                                'Tên công việc:', serviceName),
                            const SizedBox(height: 12),
                            _buildInfoSectionBold('Thời gian:', jobCreatedTime),
                            const SizedBox(height: 12),
                            _buildInfoSectionBold('Thời lượng:', duration),
                            const SizedBox(height: 12),

                            // DÙNG DỮ LIỆU TỪ APPLICANT (MAP)
                            _buildInfoSection(
                                'Ngày tạo yêu cầu:',
                                applicant['requestTime']?.toString() ??
                                    'Không có thông tin'),
                            const SizedBox(height: 12),

                            _buildInfoSectionBold(
                                'Trạng thái:', 'Đã được duyệt'),
                            const SizedBox(height: 12),

                            // DÙNG DỮ LIỆU TỪ OFFER
                            _buildInfoSection('Mô tả công việc:', description),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF003E77),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF003E77),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSectionBold(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF003E77),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // In đậm nội dung
                color: Color(0xFF003E77),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    return '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
  }

  String _formatDuration(int totalMinutes) {
    final duration = Duration(minutes: totalMinutes);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
