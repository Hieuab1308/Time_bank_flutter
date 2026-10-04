import 'package:time_bank_flutter/features/service/domain/repositories/service_repository.dart';
import '../domain/models/offer.dart';
import '../domain/models/pagination.dart';
import '../domain/models/service.dart';
import 'package:flutter/material.dart';

class MockServiceRepository implements ServiceRepository {
  // Trạng thái ứng tuyển cho job (để sync giữa community và my service)
  static final Map<String, String> _applicationStatus = {
    // serviceId -> status: 'none', 'pending', 'approved', 'cancelled'
    // Pre-seed some approved statuses so the "Đã nhận" tab can show
    // services where the current user was approved by other providers.
    '1': 'approved',
    '3': 'approved',
  };

  // Lưu trạng thái trước khi cancel để restore khi reject cancel request
  static final Map<String, String> _previousStatus = {};

  // Current user ID (người dùng hiện tại)
  static const String currentUserId = '11';
  // Current user display name used by mock applicants
  static const String currentUserName = 'Trần Văn Minh';

  // Mock friends list (user IDs that are friends with current user)
  // In a real app this would come from the social graph / API
  static final List<String> mockFriendUserIds = ['10', '14'];

  static bool isFriend(String userId) => mockFriendUserIds.contains(userId);

  // Simple skill name lookup for mock data / UI display.
  // In the real app this would come from a Skill repository or API.
  static final Map<String, String> skillNames = {
    '1': 'Guitar',
    '2': 'Sửa laptop',
    '3': 'Yoga',
    '4': 'Dịch thuật',
    '5': 'Nấu ăn chay',
    '6': 'Hỗ trợ CV',
    '7': 'Photoshop',
  };

  static String? getSkillName(String? skillId) {
    if (skillId == null) return null;
    return skillNames[skillId];
  }

  @override
  Future<List<Offer>> fetchMyPendingOffers() async {
    // Trả về một danh sách rỗng để mô phỏng
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  @override
  Future<Map<String, dynamic>> cancelJob({
    required String jobId,
  }) async {
    try {

      return {};
    } catch (e, st) {
      debugPrint("cancelJob error: $e\n$st");
      rethrow;
    }
  }

    @override
  Future<bool> deleteMyJob({required String jobId}) async {
    try {
      return true;
    } catch (e, st) {
      debugPrint("deleteMyJob error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<void> updateOfferStatusAccepted(
      {required String offerId,
      required String jobId,
      required String status}) async {
    final path = 'offers/$offerId/me-job/$jobId/accept-offer';
  }

  @override
  Future<Map<String, dynamic>> findJobCommunity({
    required PaginationRequestDto pagingInfo,
  }) async {
    final path = 'jobs?$pagingInfo';
    // For mock, filter the mock data to only include community-available services
    final communityServices = _mockData
        .where((s) => s.visibility == 'public' && s.status == 'open')
        .toList();
    // Simulate pagination
    final startIndex = (pagingInfo.page - 1) * pagingInfo.pageSize;
    final pagedServices =
        communityServices.skip(startIndex).take(pagingInfo.pageSize).toList();
    return {
      'data': pagedServices,
      'total': communityServices.length,
    };
  }

  @override
  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String regionCode,
    required String place,
    required int time,
    required int slot,
    required String visibility,
    required List<String> skills,
    required String preferredStartTime,
    List<String>? imageUrls,
  }) async {
    const path = '/jobs';
    return {};
  }

  @override
  Future<Map<String, dynamic>> checkUpdateJob({
    required String jobId,
    required Map<String, dynamic> dto,
  }) async {
    final id = jobId.toString();
    final path = '/jobs/$id';
    return {};
  }

  @override
  Future<Service?> getdetaillJobCommunityById(Object jobId) async {
    final id = jobId.toString();
    final path = '/jobs/$id';
    try {} catch (e, st) {
      debugPrint('getdetaillJobCommunityById: error fetching $path -> $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateOfferStatusRejected(
      {required String offerId,
      required String jobId,
      required String status}) async {
    final path = 'offers/$offerId/me-job/$jobId/accept-offer';
  }

  // Map a list of skill IDs to display names. Returns empty list when ids is null.
  static List<String> getSkillNamesFromIds(List<String>? ids) {
    if (ids == null) return [];
    return ids.map((id) => skillNames[id] ?? id).toList();
  }

  // Helper: get comma-joined display string for a list of skill IDs.
  static String skillNamesAsString(List<String>? ids) {
    final names = getSkillNamesFromIds(ids);
    return names.join(', ');
  }

  // Listeners để notify khi có thay đổi
  static final List<VoidCallback> _changeListeners = [];

  // Mock data cho applicants
  static final List<Map<String, dynamic>> mockApplicants = [
    {
      'id': '1',
      'name': 'Nguyễn Văn An',
      'specialization': 'Âm nhạc, Guitar, Sáng tác',
      'rating': 4.8,
      'requestType': 'receive', // receive hoặc cancel
      'requestTime': '09:15 15/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar':
          'https://anhavatardep.com/wp-content/uploads/2025/05/avatar-don-gian-1.jpg',
      'serviceId': '2', // link tới service
    },
    {
      'id': '2',
      'name': 'Trần Thị Bình',
      'specialization': 'Công nghệ, Thiết kế, Marketing',
      'rating': 4.2,
      'requestType': 'receive',
      'requestTime': '14:30 14/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar':
          'https://anhavatardep.com/wp-content/uploads/2025/05/avatar-don-gian-3.jpg',
      'serviceId': '8', // link tới job test (Photoshop)
    },
    {
      'id': '3',
      'name': 'Lê Hoàng Cường',
      'specialization': 'Sức khỏe, Yoga, Thiền định',
      'rating': 4.5,
      'requestType': 'receive',
      'requestTime': '11:45 13/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.green,
      'avatar': 'https://betapto.edu.vn/upload/2025/08/avatar-con-tho-03.webp',
      'serviceId': '6', // link tới service
    },
    {
      'id': '4',
      'name': 'Phạm Thị Dung',
      'specialization': 'Ngôn ngữ, Dịch thuật',
      'rating': 4.9,
      'requestType': 'receive',
      'requestTime': '16:20 12/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.green,
      'avatar':
          'https://anhavatardep.com/wp-content/uploads/2025/05/avatar-don-gian-2.jpg',
      'serviceId': '7', // link tới service
    },
    {
      'id': '5',
      'name': 'Võ Minh Hiếu',
      'specialization': 'Ẩm thực, Nấu ăn',
      'rating': 4.3,
      'requestType': 'cancel',
      'requestTime': '08:30 11/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar':
          'https://cdn-media.sforum.vn/storage/app/media/thanhhuyen/h%C3%ACnh%20n%E1%BB%81n%20th%E1%BB%8F%20b%E1%BA%A3y%20m%C3%A0u/1.2/hinh-nen-tho-bay-mau-19.jpg',
      'serviceId': '6', // link tới service
    },
    // Mock approved applicants for the current user (mình được phê duyệt)
    {
      'id': '100',
      'name': currentUserName,
      'specialization': 'Dạy guitar / Hỗ trợ kỹ thuật',
      'rating': 4.7,
      'requestType': 'receive',
      'requestTime': '10:00 20/10/2025',
      'status': 'approved',
      'statusText': 'Đã duyệt',
      'statusColor': Colors.green,
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'serviceId': '1', // approved on service id 1 (owner != current user)
    },
    {
      'id': '101',
      'name': currentUserName,
      'specialization': 'Hướng dẫn Yoga',
      'rating': 4.8,
      'requestType': 'receive',
      'requestTime': '09:00 18/10/2025',
      'status': 'approved',
      'statusText': 'Đã duyệt',
      'statusColor': Colors.green,
      'avatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      'serviceId': '3', // approved on service id 3 (owner != current user)
    },
  ];

  final List<Service> _mockData = [
    Service(
      id: '1',
      userId: '10',
      skillId: '1',
      skillIds: ['1', '2', '3'],
      title: 'Dạy guitar cơ bản',
      description: 'Học các hợp âm và kỹ thuật đệm hát trong 4 buổi.',
      regionCode: 'HNI',
      place: '',
      preferredStart: null,
      time: 240,
      slot: 6,
      visibility: 'public',
      status: 'open',
      ratingAvg: 4.8,
      ratingCount: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      providerName: 'Nguyễn Hữu An',
      providerAvatar:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
      bookedSlots: 2,
      serviceImages: [
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
        'https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=500',
        'https://hokaguitar.com/wp-content/uploads/2022/07/thu-tu-day-dan-guitar-1.jpg',
        'https://vietthuong.vn/upload/content/images/tuvan/guitar/not-danh-dan-guitar-co-ban-cho-nguoi-moi-04.jpg',
      ],
    ),
    Service(
      id: '2',
      userId: '11',
      skillId: '2',
      skillIds: ['2', '3'],
      title: 'Sửa laptop cơ bản',
      description:
          'Dịch vụ sửa laptop cơ bản bao gồm các công việc như vệ sinh, làm sạch bụi bẩn trong máy, thay keo tản nhiệt giúp cải thiện hiệu suất làm mát, và kiểm tra tổng thể hệ thống phần cứng. '
          'Ngoài ra, tôi sẽ hỗ trợ cài đặt, tối ưu và khắc phục các lỗi phần mềm thường gặp như máy chạy chậm, lỗi driver, hoặc xung đột ứng dụng. '
          'Dịch vụ phù hợp cho sinh viên, nhân viên văn phòng, hoặc bất kỳ ai muốn bảo dưỡng định kỳ để laptop hoạt động mượt mà và ổn định hơn.',
      regionCode: 'HCM',
      place: '',
      preferredStart: null,
      time: 180,
      slot: 3,
      visibility: 'public',
      status: 'open',
      ratingAvg: 4.6,
      ratingCount: 21,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      bookedSlots: 1,
      serviceImages: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
        'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      ],
    ),
    Service(
      id: '3',
      userId: '12',
      skillId: '3',
      skillIds: ['3'],
      title: 'Hướng dẫn Yoga',
      description:
          'Dịch vụ hướng dẫn Yoga cơ bản dành cho người mới bắt đầu muốn rèn luyện sức khỏe, cải thiện sự dẻo dai và cân bằng tinh thần. '
          'Buổi học tập trung vào các tư thế nền tảng như hít thở đúng cách, giữ thăng bằng, và giãn cơ nhẹ nhàng, giúp cơ thể làm quen dần với nhịp tập. '
          'Ngoài ra, tôi sẽ hướng dẫn cách điều chỉnh tư thế phù hợp với từng thể trạng, kết hợp thư giãn và thiền ngắn để giảm căng thẳng sau giờ học hoặc làm việc. '
          'Bạn chỉ cần chuẩn bị thảm tập và tinh thần thoải mái – tôi sẽ đồng hành, giúp bạn xây dựng thói quen luyện tập an toàn, hiệu quả và bền vững.',
      regionCode: 'DN',
      place: '',
      preferredStart: null,
      time: 45,
      slot: 6,
      visibility: 'public',
      status: 'open',
      ratingAvg: 4.9,
      ratingCount: 58,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      providerName: 'Lê Thị Hồng',
      providerAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      bookedSlots: 4,
      serviceImages: [
        'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2022/9/28/tu-the-chien-binh-3-2-1664351573296410151956.jpg',
      ],
    ),
    Service(
      id: '4',
      userId: '13',
      skillId: '4',
      skillIds: ['4', '2'],
      title: 'Dịch thuật tiếng Anh',
      description: 'Dịch tài liệu kỹ thuật và văn bản chuyên ngành.',
      regionCode: 'HN',
      place: '',
      preferredStart: null,
      time: 120,
      slot: 1,
      visibility: 'public',
      status: 'open',
      ratingAvg: 4.7,
      ratingCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      providerName: 'Pham Quang',
      providerAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      bookedSlots: 1,
    ),
    // Community-only mock
    Service(
      id: '5',
      userId: '14',
      skillId: '5',
      skillIds: ['5'],
      title: 'Lớp nấu ăn chay',
      description: 'Học các món chay cơ bản trong 3 buổi thực hành.',
      regionCode: 'HCM',
      place: '',
      preferredStart: null,
      time: 270,
      slot: 6,
      visibility: 'public',
      status: 'open',
      ratingAvg: 4.5,
      ratingCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      providerName: 'Ngô Thị Mai',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      bookedSlots: 3,
      serviceImages: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500',
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      ],
    ),
    // My-service mock (belongs to userId 11)
    Service(
      id: '6',
      userId: '11',
      skillId: '6',
      skillIds: ['6', '5'],
      title: 'Hỗ trợ CV tiếng Anh',
      description: 'Chỉnh sửa CV và luyện phỏng vấn tiếng Anh, 1:1.',
      regionCode: 'Hai Duong',
      place: '',
      preferredStart: null,
      time: 60,
      slot: 5,
      visibility: 'hidden',
      status: 'open',
      ratingAvg: 4.4,
      ratingCount: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      bookedSlots: 4,
      serviceImages: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500',
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      ],
    ),
    Service(
      id: '7',
      userId: '11',
      skillId: '5',
      skillIds: ['5'],
      title: 'Hỗ trợ CV tiếng Anh',
      description: 'Chỉnh sửa CV và luyện phỏng vấn tiếng Anh, 1:1.',
      regionCode: 'Hai Duong',
      place: '',
      preferredStart: null,
      time: 60,
      slot: 3,
      visibility: 'hidden',
      status: 'open',
      ratingAvg: 4.4,
      ratingCount: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      bookedSlots: 2,
    ),
    // Job test để sync giữa Community và My Service
    Service(
      id: '8',
      userId: '11', // Current user - sẽ hiện ở cả Community và My Service
      skillId: '7',
      skillIds: ['7', '1'],
      title: 'Dạy Photoshop cơ bản',
      description:
          'Hướng dẫn sử dụng Photoshop từ cơ bản đến nâng cao cho người mới bắt đầu.',
      regionCode: 'HCM',
      place: '',
      preferredStart: null,
      time: 120,
      slot: 4,
      visibility: 'public', // Hiện ở Community
      status: 'open',
      ratingAvg: 4.6,
      ratingCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      bookedSlots: 2,
      serviceImages: [
        'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?w=800',
      ],
    ),
    // Services currently in progress
    Service(
      id: '9',
      userId: '11', // belongs to current user
      skillId: '6',
      skillIds: ['6'],
      title: '1:1 Coaching ',
      description: 'Buổi coaching đang được triển khai theo lịch.',
      regionCode: 'HCM',
      place: '',
      preferredStart: null,
      time: 90,
      slot: 2,
      visibility: 'hidden',
      status: 'in_progress',
      ratingAvg: 4.9,
      ratingCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      bookedSlots: 2,
      serviceImages: [
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
      ],
    ),
    Service(
      id: '10',
      userId: '11',
      skillId: '3',
      skillIds: ['3'],
      title: 'Khóa Yoga ',
      description: 'Lớp yoga đang diễn ra hàng tuần.',
      regionCode: 'DN',
      place: '',
      preferredStart: null,
      time: 60,
      slot: 8,
      visibility: 'public',
      status: 'in_progress',
      ratingAvg: 4.8,
      ratingCount: 20,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      providerName: 'Lê Thị Hồng',
      providerAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      bookedSlots: 6,
      serviceImages: [
        'https://images.unsplash.com/photo-1505765052052-6c7b6b4f0b0d?w=800',
      ],
    ),
    // Cancelled demo services
    Service(
      id: '13',
      userId: '11',
      skillId: '2',
      skillIds: ['2'],
      title: 'Sửa laptop ',
      description: 'Khách hàng yêu cầu hủy trước khi bắt đầu.',
      regionCode: 'HCM',
      place: '',
      preferredStart: null,
      time: 90,
      slot: 2,
      visibility: 'hidden',
      status: 'cancelled',
      ratingAvg: 4.2,
      ratingCount: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      bookedSlots: 0,
      serviceImages: [],
    ),
    Service(
      id: '14',
      userId: '11',
      skillId: '4',
      skillIds: ['4'],
      title: 'Dịch thuật',
      description: 'Yêu cầu bị hủy bởi chủ nhiệm.',
      regionCode: 'HN',
      place: '',
      preferredStart: null,
      time: 60,
      slot: 1,
      visibility: 'public',
      status: 'cancelled',
      ratingAvg: 4.0,
      ratingCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      providerName: 'Pham Quang',
      providerAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      bookedSlots: 0,
      serviceImages: [],
    ),
    // Completed services for demo / "Hoàn thành" tab
    Service(
      id: '11',
      userId: '11',
      skillId: '1',
      skillIds: ['1'],
      title: 'Buổi Dạy Guitar',
      description: 'Buổi học guitar đã hoàn thành và feedback được thu thập.',
      regionCode: 'HNI',
      place: '',
      preferredStart: null,
      time: 120,
      slot: 4,
      visibility: 'hidden',
      status: 'completed',
      ratingAvg: 4.9,
      ratingCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      bookedSlots: 4,
      serviceImages: [
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
      ],
    ),
    Service(
      id: '12',
      userId: '11',
      skillId: '5',
      skillIds: ['5'],
      title: 'Lớp nấu ăn chay',
      description: 'Khóa nấu ăn chay đã hoàn tất với nhiều món ngon.',
      regionCode: 'HCM',
      place: '',
      preferredStart: null,
      time: 180,
      slot: 6,
      visibility: 'public',
      status: 'completed',
      ratingAvg: 4.7,
      ratingCount: 9,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      providerName: 'Pham Quang',
      providerAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      bookedSlots: 6,
      serviceImages: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500',
      ],
    ),
  ];

  @override
  Future<Map<String, dynamic>> getMyJobs({
    required PaginationRequestDto pagingInfo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final myServices =
        _mockData.where((s) => s.userId == currentUserId).toList();

    // Simple pagination logic
    final start = (pagingInfo.page - 1) * pagingInfo.pageSize;
    final end = start + pagingInfo.pageSize;
    final pagedServices = myServices.sublist(
      start,
      end > myServices.length ? myServices.length : end,
    );

    return {
      'items': pagedServices,
      'total': myServices.length,
    };
  }

  @override
  Future<List<Offer>> getOffersForMyJob(Object jobId) async {
    final sid = jobId.toString();
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, offers would be fetched from an API or database.
    // Here we filter mockApplicants for those linked to the given serviceId.
    final offers = mockApplicants
        .where((applicant) => applicant['serviceId'] == sid)
        .map((applicant) => Offer(
              id: applicant['id'],
              status: applicant['status'],
              note: '',
              createdAt: DateTime.now(),
              jobId: '',
              jobTitle: '',
              jobDescription: '',
              regionCode: '',
              place: '',
              preferredStart: DateTime.now(),
              time: 111,
              slot: 1,
              visibility: '',
              jobStatus: '',
              jobCreatedAt: DateTime.now(),
              jobOwnerId: '',
              jobOwnerName: '',
              jobOwnerAvatar: '',
              skills: [],
              offers: [],
              offerUserId: '',
              offerUserName: '',
              offerUserAvatar: '',
            ))
        .toList();
    return offers;
  }

  @override
  Future<List<Service>> fetchPublicServices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.where((s) => s.visibility == 'public').toList();
  }

  @override
  Future<Service?> fetchServiceById(Object id) async {
    final sid = id.toString();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockData.firstWhere((s) => s.id == sid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Service>> fetchServicesByUser(Object userId) async {
    final uid = userId.toString();
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.where((s) => s.userId == uid).toList();
  }

  // Method để lấy service theo ID
  static Service? getServiceById(Object serviceId) {
    final repository = MockServiceRepository();
    final sid = serviceId.toString();
    try {
      return repository._mockData.firstWhere((s) => s.id == sid);
    } catch (_) {
      return null;
    }
  }

  // Method to get services by status. Optional ownerId filters to services
  // belonging to a specific user (useful for "my services" views).
  static List<Service> getServicesByStatus(String status, {String? ownerId}) {
    final repo = MockServiceRepository();
    return repo._mockData.where((s) {
      final matchesStatus =
          s.status.toString().toLowerCase() == status.toString().toLowerCase();
      if (!matchesStatus) return false;
      if (ownerId != null) return s.userId == ownerId;
      return true;
    }).toList();
  }

  // Set a service's status (used by UI to mark cancelled/completed states in mocks)
  static void setServiceStatus(Object serviceId, String status) {
    final sid = serviceId.toString();
    final repo = MockServiceRepository();
    try {
      final idx = repo._mockData.indexWhere((s) => s.id == sid);
      if (idx != -1) {
        final s = repo._mockData[idx];
        // Recreate the Service with updated status since Service is immutable
        final updated = Service(
          id: s.id,
          userId: s.userId,
          skillId: s.skillId,
          skillIds: s.skillIds,
          title: s.title,
          description: s.description,
          regionCode: s.regionCode,
          place: s.place,
          preferredStart: s.preferredStart,
          time: s.time,
          slot: s.slot,
          visibility: s.visibility,
          status: status,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          ratingAvg: s.ratingAvg,
          ratingCount: s.ratingCount,
          providerName: s.providerName,
          providerAvatar: s.providerAvatar,
          providerSpecialization: s.providerSpecialization,
          serviceImages: s.serviceImages,
          bookedSlots: s.bookedSlots,
        );
        repo._mockData[idx] = updated;
        _notifyListeners();
      }
    } catch (_) {
      // ignore
    }
  }

  // Update certain fields of an existing service in the mock dataset.
  // This does an immutable replace (Service is immutable), preserving fields
  // that are not supplied in the parameters.
  static void updateServiceFields(Object serviceId,
      {String? title,
      String? description,
      String? place,
      int? time,
      int? slot,
      String? visibility,
      List<String>? skills,
      DateTime? preferredStart,
      List<String>? serviceImages}) {
    final sid = serviceId.toString();
    final repo = MockServiceRepository();
    try {
      final idx = repo._mockData.indexWhere((s) => s.id == sid);
      if (idx == -1) return;
      final s = repo._mockData[idx];

      final updated = Service(
        id: s.id,
        userId: s.userId,
        skillId:
            (skills != null && skills.isNotEmpty) ? skills.first : s.skillId,
        skillIds: skills ?? s.skillIds,
        title: title ?? s.title,
        description: description ?? s.description,
        regionCode: s.regionCode,
        place: place ?? s.place,
        preferredStart: preferredStart ?? s.preferredStart,
        time: time ?? s.time,
        slot: slot ?? s.slot,
        visibility: visibility ?? s.visibility,
        status: s.status,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        ratingAvg: s.ratingAvg,
        ratingCount: s.ratingCount,
        providerName: s.providerName,
        providerAvatar: s.providerAvatar,
        providerSpecialization: s.providerSpecialization,
        serviceImages: serviceImages ?? s.serviceImages,
        bookedSlots: s.bookedSlots,
      );

      repo._mockData[idx] = updated;
      _notifyListeners();
    } catch (e) {
      debugPrint('updateServiceFields failed: $e');
    }
  }

  // Method chuyển đổi minSlotMinutes thành format HH:MM:SS
  static String formatDuration(int minSlotMinutes) {
    final int hours = minSlotMinutes ~/ 60;
    final int minutes = minSlotMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
  }

  // Methods để quản lý trạng thái ứng tuyển
  static String getApplicationStatus(Object serviceId) {
    final sid = serviceId.toString();
    return _applicationStatus[sid] ?? 'none';
  }

  static void setApplicationStatus(Object serviceId, String status) {
    final sid = serviceId.toString();
    _applicationStatus[sid] = status;
  }

  // Apply cho job (từ Community)
  static void applyForJob(Object serviceId) {
    final sid = serviceId.toString();
    _applicationStatus[sid] = 'pending';

    // Thêm applicant mới vào mockApplicants
    final newApplicant = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': currentUserName, // Current user name
      'specialization': 'Công nghệ, Thiết kế, Marketing',
      'rating': 4.5,
      'requestType': 'receive',
      'requestTime':
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'serviceId': sid,
    };

    mockApplicants.add(newApplicant);

    // Notify all listeners
    _notifyListeners();
  }

  @override
  Future<Map<String, dynamic>> confirmUpdateJob({
    required Map<String, dynamic> body,
  }) async {
    try {
      return {
        'message': 'Cập nhật công việc thành công (mock)',
      };
    } catch (e, st) {
      debugPrint("confirmUpdateJob error: $e\n$st");
      rethrow;
    }
  }

  // Approve applicant (từ My Service)
  static void approveApplicant(
      Object serviceId, Map<String, dynamic> applicant) {
    final sid = serviceId.toString();
    debugPrint('🎯 Approving applicant for serviceId: $serviceId'); // Debug
    debugPrint('📝 Applicant before update: ${applicant.toString()}');

    // Update applicant status
    applicant['status'] = 'approved';
    applicant['statusText'] = 'Đã duyệt';
    applicant['statusColor'] = Colors.green;

    debugPrint('📝 Applicant after update: ${applicant.toString()}');

    // Update application status
    _applicationStatus[sid] = 'approved';
    debugPrint(
        '✅ Set application status to approved for serviceId: $serviceId'); // Debug
    debugPrint('📊 Current _applicationStatus: $_applicationStatus'); // Debug

    // Debug: Check if applicant is still in mockApplicants list
    final foundApplicant = mockApplicants.firstWhere(
        (a) =>
            a['serviceId'].toString() == sid && a['name'] == applicant['name'],
        orElse: () => {});
    debugPrint('🔍 Found applicant in list: ${foundApplicant.isNotEmpty}');
    if (foundApplicant.isNotEmpty) {
      debugPrint('📋 Applicant in list status: ${foundApplicant['status']}');
    }

    // Notify all listeners
    _notifyListeners();
  }

  // Approve cancel request (từ My Service) - reset về trạng thái ban đầu
  static void approveCancelRequest(Object serviceId) {
    final sid = serviceId.toString();
    debugPrint('✅ Approving cancel request for serviceId: $serviceId');

    // Reset application status về none (như chưa từng apply)

    _applicationStatus[sid] = 'none';

    // Remove applicant from list
    mockApplicants.removeWhere((applicant) =>
        applicant['serviceId'].toString() == sid &&
        applicant['name'] == 'Trần Văn Minh');

    debugPrint('🔄 Reset application status to none and removed applicant');

    // Clear previous status
    _previousStatus.remove(serviceId);

    // Notify all listeners
    _notifyListeners();
  }

  // Reject cancel request (từ My Service) - giữ nguyên trạng thái trước đó
  static void rejectCancelRequest(Object serviceId) {
    final sid = serviceId.toString();
    debugPrint('❌ Rejecting cancel request for serviceId: $serviceId');

    // Tìm applicant với requestType 'cancel'
    final applicantIndex = mockApplicants.indexWhere((applicant) =>
        applicant['serviceId'].toString() == sid &&
        applicant['name'] == 'Trần Văn Minh' &&
        applicant['requestType'] == 'cancel');

    if (applicantIndex != -1) {
      final applicant = mockApplicants[applicantIndex];

      // Restore về trạng thái trước khi cancel
      final previousStatus = _previousStatus[sid] ?? 'pending';
      _applicationStatus[sid] = previousStatus;

      // QUAN TRỌNG: Thay vì xóa, chuyển applicant về receive request
      applicant['requestType'] = 'receive';
      applicant['requestTime'] =
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';

      // Set status dựa trên previousStatus
      if (previousStatus == 'pending') {
        applicant['status'] = 'pending';
        applicant['statusText'] = 'Chờ duyệt';
        applicant['statusColor'] = Colors.orange;
      } else if (previousStatus == 'approved') {
        applicant['status'] = 'approved';
        applicant['statusText'] = 'Đã duyệt';
        applicant['statusColor'] = Colors.green;
      }

      debugPrint('🔄 Converted cancel request back to receive request');
      debugPrint(
          '📝 Restored status: $previousStatus, requestType: ${applicant['requestType']}');

      // Clear previous status sau khi restore
      _previousStatus.remove(sid);
    } else {
      debugPrint('❌ No cancel request found to reject');
    }

    // Notify all listeners
    _notifyListeners();
  } // Cancel application (từ Community)

  static void cancelApplication(Object serviceId) {
    final sid = serviceId.toString();
    debugPrint(
        '🗑️ MockServiceRepository.cancelApplication called for serviceId: $serviceId');

    // Lưu trạng thái hiện tại trước khi cancel
    final currentStatus = _applicationStatus[sid] ?? 'none';
    _previousStatus[sid] = currentStatus;
    debugPrint('💾 Saved previous status: $currentStatus');

    _applicationStatus[sid] = 'cancelled';

    // Thay vì xóa, chuyển applicant thành cancel request
    final applicantIndex = mockApplicants.indexWhere((applicant) =>
        applicant['serviceId'].toString() == sid &&
        applicant['name'] == 'Trần Văn Minh');

    if (applicantIndex != -1) {
      final applicant = mockApplicants[applicantIndex];

      // Chuyển đổi thành cancel request
      applicant['requestType'] = 'cancel';
      applicant['requestTime'] =
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
      applicant['status'] = 'pending'; // Vẫn pending để admin xử lý
      applicant['statusText'] = 'Chờ duyệt';
      applicant['statusColor'] = Colors.orange;

      debugPrint('🔄 Converted applicant to cancel request');
      debugPrint('📝 Updated requestType: ${applicant['requestType']}');
    } else {
      debugPrint('❌ No applicant found to convert to cancel request');
    }

    // Notify all listeners
    _notifyListeners();
  }

  // Methods để quản lý listeners
  static void addListener(VoidCallback listener) {
    _changeListeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _changeListeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _changeListeners) {
      listener();
    }
  }

  // Reset application (từ My Service khi reject)
  static void resetApplication(Object serviceId) {
    final sid = serviceId.toString();
    _applicationStatus[sid] = 'none';

    // Remove applicant from list
    mockApplicants.removeWhere((applicant) =>
        applicant['serviceId'].toString() == sid &&
        applicant['name'] == 'Trần Văn Minh');

    // Notify all listeners
    _notifyListeners();
  }

  // Add a new service to mock data and notify listeners so UI can refresh
  static void addService(Service service) {
    final repo = MockServiceRepository();
    repo._mockData.insert(0, service);
    _notifyListeners();
  }
}
