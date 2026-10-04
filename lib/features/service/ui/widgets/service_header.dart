import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';
import 'package:time_bank_flutter/features/service/ui/page/four_service_applicants_page.dart';
import 'package:time_bank_flutter/features/service/ui/page/rating_page.dart';
import 'create_page/service_create_page.dart';
import 'package:time_bank_flutter/features/auth/domain/user_profile.dart';

// << Import provider pagination (đã có) >>
import 'package:time_bank_flutter/features/service/providers/service_pagination_provider.dart';
// << THÊM MỚI: Import provider cho "Chờ xác nhận" >>
import 'package:time_bank_flutter/features/service/providers/service_providers.dart';

class ServiceHeader extends ConsumerStatefulWidget {
  final bool isMyTab;
  final Function(String?)? onFilterChanged;
  final Function(String)? onSearchChanged;

  const ServiceHeader({
    super.key,
    this.isMyTab = false,
    this.onFilterChanged,
    this.onSearchChanged,
  });

  @override
  ConsumerState<ServiceHeader> createState() => _ServiceHeaderState();
}

class _ServiceHeaderState extends ConsumerState<ServiceHeader> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.isMyTab ? 'Yêu cầu của tôi' : 'Tất cả mọi người';
  }

  Widget _buildAvatar(AsyncValue<UserProfile> profileAsync) {
    final profile = profileAsync.valueOrNull;
    final url = profile?.avatarUrl;

    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey[200],
      );
    } else {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[200],
        child: const Icon(
          Icons.person,
          color: Color(0xFF003E77),
          size: 22,
        ),
      );
    }
  }

  Widget _buildGreeting(AsyncValue<UserProfile> profileAsync) {

    final String name = profileAsync.when(
      data: (user) => user.fullName.split(' ').first,
      loading: () => 'bạn',
      error: (e, s) => 'bạn',
    );

    return Flexible(
      fit: FlexFit.loose,
      child: Text(
        'Hãy tạo điều bạn muốn?',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 15,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    // --- Đếm "Đã mở" và "Đang thực hiện" ---
    final paginationState = ref.watch(servicePaginationProvider(null));
    final openServicesCount = paginationState.services
        .where((s) => s.status.toString().toLowerCase() == 'open')
        .length;
    final inProgressServicesCount = paginationState.services
        .where((s) => s.status.toString().toLowerCase() == 'matched')
        .length;

    // << THÊM MỚI: Lắng nghe và đếm "Chờ xác nhận" >>
    final pendingOffersAsync = ref.watch(allMyPendingOffersProvider);
    final pendingCount = pendingOffersAsync.when(
      data: (offers) {
        // Sử dụng logic lọc giống hệt như trong PendingApplicantsNoSearchWidget
        return offers
            .where((o) => o.status == 'pending' || o.status == 'withdrawn')
            .length;
      },
      loading: () => 0,
      error: (e, s) => 0,
    );
    // << KẾT THÚC PHẦN THÊM MỚI >>

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServiceCreatePage(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _buildAvatar(userProfileAsync),
                        const SizedBox(width: 10),

                        _buildGreeting(userProfileAsync),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              // << CẬP NHẬT: Thêm count cho "Chờ xác nhận" >>
              _buildStatusIcon(
                'assets/icons/File_Check.png',
                'Chờ xác nhận',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FourServiceApplicantsPage(
                        serviceTitle: 'Chờ xác nhận',
                        initialTabIndex: 0, // tab 1
                      ),
                    ),
                  );
                },
                count: pendingCount, // << TRUYỀN COUNT VÀO ĐÂY
              ),

              _buildStatusIcon(
                'assets/icons/Folder_Open.png',
                'Đã mở',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FourServiceApplicantsPage(
                        serviceId: '3',
                        serviceTitle: 'Đã mở',
                        initialTabIndex: 2, // tab 2
                      ),
                    ),
                  );
                },
                count: openServicesCount, // Đếm "Đã mở"
              ),

              _buildStatusIcon(
                'assets/icons/pending.png',
                'Đang thực hiện',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FourServiceApplicantsPage(
                        serviceId: '4',
                        serviceTitle: 'Đang thực hiện',
                        initialTabIndex: 3, // tab 3
                      ),
                    ),
                  );
                },
                count: inProgressServicesCount, // Đếm "Đang thực hiện"
              ),

              _buildStatusIcon('assets/icons/Wavy_Check.png', 'Đánh giá', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ServiceRatingPage()),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _iconForFilter(_selectedFilter),
                    color: Color(0xFF003E77),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _displayLabelForFilter(_selectedFilter),
                    style: TextStyle(
                      color: Color(0xFF003E77),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Color(0xFF003E77),
                ),
                onPressed: () {
                  _showFilter(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: widget.onSearchChanged,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm dịch vụ, người dùng...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  // Thêm tham số {int count = 0}
  Widget _buildStatusIcon(String imagePath, String label, VoidCallback onTap,
      {int count = 0}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              // Dùng Stack để thêm Badge
              child: Stack(
                clipBehavior: Clip.none, // Cho phép badge hiển thị bên ngoài
                children: [
                  Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      IconData fallbackIcon;
                      switch (imagePath) {
                        case 'assets/icons/pending.png':
                          fallbackIcon = Icons.hourglass_empty;
                          break;
                        case 'assets/icons/Folder_Open.png':
                          fallbackIcon = Icons.check_circle_outline;
                          break;
                        case 'assets/icons/File_Check.png':
                          fallbackIcon = Icons.play_circle_outline;
                          break;
                        case 'assets/icons/Wavy_Check.png':
                          fallbackIcon = Icons.star_outline;
                          break;
                        default:
                          fallbackIcon = Icons.help_outline;
                      }
                      return Icon(
                        fallbackIcon,
                        color: const Color(0xFF003E77),
                        size: 20,
                      );
                    },
                  ),
                  // Widget Badge
                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Bộ lọc chi tiết'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(Icons.public, 'Mọi người'),
              _buildFilterOption(Icons.group, 'Bạn bè'),
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

  void _showFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Bộ lọc dịch vụ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(Icons.public, 'Tất cả mọi người'),
              _buildFilterOption(Icons.assignment_ind, 'Dịch vụ của tôi'),
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

  Widget _buildFilterOption(IconData icon, String label,
      [String? filterValue]) {
    return Builder(builder: (BuildContext context) {
      return ListTile(
        leading: Icon(icon, color: Color(0xFF003E77)),
        title: Text(label),
        onTap: () {
          Navigator.of(context).pop();
          final value = filterValue ?? label;
          setState(() {
            _selectedFilter = value;
          });
          if (widget.onFilterChanged != null) {
            widget.onFilterChanged!(value);
          }
        },
      );
    });
  }

  IconData _iconForFilter(String filter) {
    switch (filter) {
      case 'Bạn bè':
        return Icons.group;
      case 'Yêu cầu của tôi':
        return Icons.assignment_ind;
      case 'Mọi người':
      case 'Tất cả mọi người':
      default:
        return Icons.public;
    }
  }

  String _displayLabelForFilter(String filter) {
    if (filter == 'Mọi người') return 'Mọi người';
    return filter;
  }
}
