import 'dart:async'; // Dùng cho Timer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_bank_flutter/features/profile/ui/other_profile_page.dart';
import 'package:time_bank_flutter/features/profile/ui/profile_page.dart';
import 'package:time_bank_flutter/features/profile/providers/providers.dart';
import 'package:time_bank_flutter/features/profile/domain/profile.dart';
import 'package:time_bank_flutter/features/service/providers/booking_providers.dart';
import '../../../../chat/providers/chat_providers.dart';
import '../../../../chat/ui/chat_conversation_page.dart';
import '../../../domain/models/service.dart';
import '../../../providers/offer_provider.dart';
import '../../../providers/service_providers.dart';

import 'service_detail_header.dart';

class CommunityServiceDetailPage extends ConsumerStatefulWidget {
  final String serviceId;

  const CommunityServiceDetailPage({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<CommunityServiceDetailPage> createState() =>
      _CommunityServiceDetailPageState();
}

class _CommunityServiceDetailPageState
    extends ConsumerState<CommunityServiceDetailPage>
    with WidgetsBindingObserver {
  bool _isFavorited = false;
  int _currentImageIndex = 0;
  PageController? _pageController;
  bool _isCheckedIn = false;
  Timer? _checkInTimer;
  Timer? _cancellationTimer;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(viewportFraction: 1.0);
    _loadSavedStates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController?.dispose();
    _noteController.dispose();
    _checkInTimer?.cancel(); // Hủy timer khi widget bị hủy
    _cancellationTimer?.cancel(); // << THÊM MỚI: Hủy timer thứ 2
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(offerStatusProvider(widget.serviceId));
    }
  }

  Future<void> _loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();
    final isFavorited = prefs.getBool('favorite_${widget.serviceId}') ?? false;

    if (mounted) {
      setState(() {
        _isFavorited = isFavorited;
      });
    }
  }

  Future<void> _saveFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite_${widget.serviceId}', _isFavorited);
  }

  Future<void> _handleRefresh() async {
    ref.refresh(detailJobCommunityByIdProvider(widget.serviceId));
    ref.invalidate(offerStatusProvider(widget.serviceId));
    await ref.read(detailJobCommunityByIdProvider(widget.serviceId).future);
  }

  // << CẬP NHẬT: Đổi tên thành _scheduleTimers và thêm logic
  void _scheduleTimers(Service service) {
    _checkInTimer?.cancel();
    _cancellationTimer?.cancel();

    final startTime = service.preferredStart;
    final now = DateTime.now();

    // Không lên lịch nếu không có thời gian hoặc đã check-in
    if (startTime == null || _isCheckedIn) {
      return;
    }

    // --- Lên lịch cho timer MỞ CỬA SỔ check-in ---
    // (5 phút trước thời gian bắt đầu)
    final checkInStartTime = startTime.subtract(const Duration(minutes: 5));
    if (checkInStartTime.isAfter(now)) {
      final duration = checkInStartTime.difference(now);
      _checkInTimer = Timer(duration, () {
        if (mounted) {
          setState(() {
            debugPrint('Check-in window OPENED! Rebuilding UI.');
          });
        }
      });
    }

    // --- Lên lịch cho timer ĐÓNG CỬA SỔ check-in (Hủy) ---
    // (10 phút sau thời gian bắt đầu)
    final checkInEndTime = startTime.add(const Duration(minutes: 10));
    if (checkInEndTime.isAfter(now)) {
      final duration = checkInEndTime.difference(now);
      _cancellationTimer = Timer(duration, () {
        if (mounted) {
          setState(() {
            debugPrint('Check-in window CLOSED! Rebuilding UI.');
          });
        }
      });
    }
  }

  void _handleCheckIn() async {
    _checkInTimer?.cancel();
    _cancellationTimer?.cancel(); // << THÊM MỚI: Hủy cả timer thứ 2

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.checkInBooking(jobId: widget.serviceId);

      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Thành công',
              style: TextStyle(
                color: Color(0xFF003E77),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Đã check in thành công!',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF003E77),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      setState(() {
        _isCheckedIn = true;
      });
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check in thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync =
        ref.watch(detailJobCommunityByIdProvider(widget.serviceId));
    final offerStatusAsync = ref.watch(offerStatusProvider(widget.serviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chi tiết dịch vụ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: serviceAsync.when(
        data: (service) => service != null
            ? _buildContent(service, offerStatusAsync)
            : const Center(child: Text('Không tìm thấy dịch vụ.')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Đã xảy ra lỗi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(detailJobCommunityByIdProvider(widget.serviceId));
                },
                child: const Text('Thử lại'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Service service, AsyncValue<dynamic> offerStatusAsync) {
    // << CẬP NHẬT: Gọi hàm _scheduleTimers (thay vì _scheduleCheckInTimer)
    _scheduleTimers(service);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF003E77),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ServiceDetailHeader(
                service: service,
                isMyService: false,
                isFavorited: _isFavorited,
                onFavoritePressed: _toggleFavorite,
                showAllSpecializations: true,
              ),
            ),
            const SizedBox(height: 20),
            _buildServiceBox(service),
            const SizedBox(height: 30),
            _buildActionRow(service, offerStatusAsync),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _goToProfile(BuildContext context, String serviceUserId,
      {String? providerName, String? providerAvatar, String? description}) {
    final myProfileId = ref.read(myProfileProvider).value?.id;
    debugPrint(
        'Profile navigation: serviceUserId=$serviceUserId, myProfileId=$myProfileId');

    if (myProfileId != null && serviceUserId == myProfileId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        ),
      );
    } else {
      debugPrint('Navigating to OtherProfilePage: userId=$serviceUserId, '
          'providerName=${providerName ?? '<null>'}, '
          'providerAvatar=${providerAvatar ?? '<null>'}');

      final previewProfile = Profile(
        id: serviceUserId,
        name: providerName ?? 'Người dùng',
        phone: '',
        avatarUrl: providerAvatar,
        description: description ?? '',
        points: 0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherProfilePage(
            userId: serviceUserId,
            initialName: providerName,
            initialAvatarUrl: providerAvatar,
            initialDescription: description,
            initialProfile: previewProfile,
          ),
        ),
      );
    }
  }

  Widget _buildServiceBox(Service service) {
    final followersAsync = ref.watch(followersCountProvider(service.userId));
    final followingAsync = ref.watch(followingCountProvider(service.userId));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF003E77).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _goToProfile(context, service.userId,
                    providerName: service.providerName,
                    providerAvatar: service.providerAvatar,
                    description:
                        service.providerSpecialization ?? service.description),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: service.providerAvatar != null &&
                          service.providerAvatar!.isNotEmpty
                      ? NetworkImage(service.providerAvatar!)
                      : null,
                  child: (service.providerAvatar == null ||
                          service.providerAvatar!.isEmpty)
                      ? Text(
                          service.providerName?.substring(0, 1).toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _goToProfile(context, service.userId,
                      providerName: service.providerName,
                      providerAvatar: service.providerAvatar,
                      description: service.providerSpecialization ??
                          service.description),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.providerName ??
                            'Người cung cấp #${service.userId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF003E77),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeAgo(service.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    _navigateToChat(service);
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF003E77),
                    size: 25,
                  ),
                  splashRadius: 20,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.grey.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    'Đã follow', followingAsync.value?.toString() ?? '...'),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildStatItem(
                    'Follower', followersAsync.value?.toString() ?? '...'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Mô tả:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003E77),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.description ?? 'Không có mô tả',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (service.serviceImages != null &&
              service.serviceImages!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Hình ảnh minh họa:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF003E77),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: service.serviceImages!.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF003E77).withOpacity(0.1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        service.serviceImages![index],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF003E77),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Lỗi tải ảnh',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            if (service.serviceImages!.length > 1) ...[
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    service.serviceImages!.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? const Color(0xFF003E77)
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003E77),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // << CẬP NHẬT: Toàn bộ logic `case 'accepted'`
  Widget _buildActionRow(
      Service service, AsyncValue<dynamic> offerStatusAsync) {
    return offerStatusAsync.when(
      data: (statusData) {
        debugPrint('--- [DEBUG] API Offer Status Data: $statusData ---');

        String? status;
        if (statusData is Map<String, dynamic>) {
          final offerValue = statusData['offer'];
          if (offerValue is String) {
            status = offerValue;
          } else {
            status = null;
          }
        } else if (statusData == false) {
          status = null;
        } else {
          status = null;
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: switch (status) {
            'pending' => Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.withOpacity(0.7),
                        disabledForegroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Đã gửi yêu cầu',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _showCancelConfirmationDialog();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                ],
              ),
            'accepted' => () {
                // 1. Ưu tiên hàng đầu: Nếu đã check-in
                if (_isCheckedIn) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.teal.withOpacity(0.7),
                        disabledForegroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Đã check in',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  );
                }

                final startTime = service.preferredStart;
                final now = DateTime.now();

                // 2. Nếu không có thời gian, quay về "Đã được duyệt"
                if (startTime == null) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.green.withOpacity(0.7),
                            disabledForegroundColor:
                                Colors.white.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Đã được duyệt (thiếu thời gian)',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // 3. Xác định cửa sổ check-in
                final checkInStartTime =
                    startTime.subtract(const Duration(minutes: 5));
                final checkInEndTime =
                    startTime.add(const Duration(minutes: 10));

                // 4. KIỂM TRA: Đã lỡ hẹn (quá 10 phút sau)
                if (now.isAfter(checkInEndTime)) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.withOpacity(0.7),
                        disabledForegroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Đã hủy do không check in',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  );
                }

                // 5. KIỂM TRA: Đang trong cửa sổ check-in
                // (Từ 5 phút trước ĐẾN 10 phút sau)
                if (now.isAfter(checkInStartTime) &&
                    now.isBefore(checkInEndTime)) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleCheckIn, // GỌI HÀM CHECK IN
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Check in',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          _showCancelConfirmationDialog();
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                    ],
                  );
                }

                // 6. Mặc định: Chưa đến cửa sổ check-in
                // (now.isBefore(checkInStartTime))
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null, // Chưa tới giờ
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.green.withOpacity(0.7),
                          disabledForegroundColor:
                              Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Đã được duyệt',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _showCancelConfirmationDialog();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                  ],
                );
              }(),
            'withdrawn' => Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null, // Đang chờ, vô hiệu hóa
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.orange.withOpacity(0.7),
                        disabledForegroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Đang chờ xét duyệt hủy',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _showCancelConfirmationDialog();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                ],
              ),
            'rejected' => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null, // Bị từ chối, không action
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.red.withOpacity(0.7),
                    disabledForegroundColor: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Đã bị từ chối',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            'cancelled' => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null, // Đã hủy, không action
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.red.withOpacity(0.7),
                    disabledForegroundColor: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Đã hủy',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            null || _ => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showConfirmationDialog(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Chấp nhận công việc',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
              ),
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
            child: CircularProgressIndicator(
          color: Color(0xFF003E77),
        )),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            'Lỗi tải trạng thái: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận hủy yêu cầu',
            style: TextStyle(
              color: Color(0xFF003E77),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Bạn có chắc muốn hủy yêu cầu ứng tuyển chứ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelRequest();
              },
              child: const Text(
                'Đồng ý',
                style: TextStyle(
                  color: Color(0xFF003E77),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showConfirmationDialog(Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Xác nhận ứng tuyển',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003E77),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/images/image 2.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style:
                      const TextStyle(fontSize: 16, color: Color(0xFF003E77)),
                      children: [
                        const TextSpan(
                            text: 'Bạn đồng ý ứng tuyển vào yêu cầu: '),
                        TextSpan(
                          text: service.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                            text:
                            ', yêu cầu ứng tuyển sẽ được gửi tới người đăng và yêu cầu của bạn sẽ được xem xét, phê duyệt.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bạn có thể gửi lời nhắn cho người đăng bài:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF003E77),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập ghi chú...',
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _requestService();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Đồng ý',
                        style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    _saveFavoriteState();
  }

  void _requestService() async {
    try {
      final note = _noteController.text;
      final repo = ref.read(offerRepositoryProvider);

      await repo.createOffer(
        jobId: widget.serviceId,
        note: note,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi yêu cầu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      ref.invalidate(offerStatusProvider(widget.serviceId));
      _noteController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi yêu cầu thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelRequest() async {
    try {
      final repo = ref.read(offerRepositoryProvider);
      await repo.cancelMyOffer(widget.serviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy yêu cầu thành công.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      ref.invalidate(offerStatusProvider(widget.serviceId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hủy yêu cầu thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToChat(Service service) async {
    final peerUid = service.userId;
    final peerName =
        service.providerName ?? 'Người cung cấp #${service.userId}';

    final myUid = ref.read(currentUidProvider);

    if (peerUid == myUid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bạn không thể tự chat với chính mình.')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final peerAvatar = service.providerAvatar ?? '';
      final threadId = await ref.read(ensureDmThreadProvider(
        (peerUid: peerUid, peerName: peerName, peerAvatar: peerAvatar),
      ).future);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatConversationPage(
              threadId: threadId,
              fallbackName: peerName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tạo phòng chat: $e')),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 30) {
      return '${diff.inDays} ngày trước';
    } else {
      final months = (diff.inDays / 30).round();
      if (months <= 0) return '${diff.inDays} ngày trước';
      return '$months tháng trước';
    }
  }
}
