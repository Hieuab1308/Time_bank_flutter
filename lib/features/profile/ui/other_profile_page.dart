import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import '../domain/profile.dart';
import 'widgets/profile_header.dart';
import 'widgets/other_profile_detile.dart';
import 'widgets/reviews_list.dart';
import 'report_page.dart';

class OtherProfilePage extends ConsumerStatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialAvatarUrl;
  final String? initialDescription;
  final Profile? initialProfile;

  const OtherProfilePage({
    Key? key,
    required this.userId,
    this.initialName,
    this.initialAvatarUrl,
    this.initialDescription,
    this.initialProfile,
  }) : super(key: key);

  @override
  ConsumerState<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends ConsumerState<OtherProfilePage> {
  bool _isLoadingFollow = false;
  bool? _localIsFollowing;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onFollowPressed(bool isFollowing) async {
    if (isFollowing) {
      final didConfirm = await _showUnfollowDialog();
      if (didConfirm != true) return;

      setState(() {
        _isLoadingFollow = true;
        _localIsFollowing = false;
      });

      try {
        ref.invalidate(unfollowUserProvider(widget.userId));
        await ref.read(unfollowUserProvider(widget.userId).future);

        ref.invalidate(profileByIdProvider(widget.userId));
        ref.invalidate(followersCountProvider(widget.userId));
        final refreshed =
            await ref.read(profileByIdProvider(widget.userId).future);
        await ref.read(followersCountProvider(widget.userId).future);

        if (mounted) {
          if (refreshed.isFollowing == false) {
            setState(() => _localIsFollowing = null);
          } else {
            setState(() => _localIsFollowing = refreshed.isFollowing);
          }
        }

        try {
          ref.invalidate(myProfileProvider);
          await ref.read(myProfileProvider.future);
          ref.invalidate(myFollowingCountProvider);
          await ref.read(myFollowingCountProvider.future);
        } catch (_) {}
      } catch (e) {
        if (mounted) {
          setState(() {
            _localIsFollowing = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Lỗi khi hủy theo dõi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoadingFollow = false);
      }
    } else {
      setState(() {
        _isLoadingFollow = true;
        _localIsFollowing = true;
      });

      try {
        ref.invalidate(followUserProvider(widget.userId));
        await ref.read(followUserProvider(widget.userId).future);

        ref.invalidate(profileByIdProvider(widget.userId));
        ref.invalidate(followersCountProvider(widget.userId));
        final refreshed =
            await ref.read(profileByIdProvider(widget.userId).future);
        await ref.read(followersCountProvider(widget.userId).future);

        if (mounted) {
          if (refreshed.isFollowing == true) {
            setState(() => _localIsFollowing = null);
          } else {
            setState(() => _localIsFollowing = refreshed.isFollowing);
          }
        }

        try {
          ref.invalidate(myProfileProvider);
          await ref.read(myProfileProvider.future);
          ref.invalidate(myFollowingCountProvider);
          await ref.read(myFollowingCountProvider.future);
        } catch (_) {}
      } catch (e) {
        if (mounted) {
          setState(() {
            _localIsFollowing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Lỗi khi theo dõi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoadingFollow = false);
      }
    }
  }

  Future<bool?> _showUnfollowDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Hủy theo dõi?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003E77),
                  fontSize: 20)),
          content: const Text('Bạn có chắc chắn muốn hủy theo dõi người này?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              child: const Text('Hủy',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  )),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Xác nhận',
                  style: TextStyle(
                    color: Color(0xFF003E77),
                    fontSize: 18,
                  )),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  // ✅ ĐÃ SỬA: Thêm SingleChildScrollView để tránh lỗi overflow
  void _showReportSheet(String reportedUserName) {
    final reportReasons = [
      'Spam',
      'Nội dung không phù hợp',
      'Lừa đảo hoặc gian lận',
      'Giả mạo tài khoản',
      'Quấy rối hoặc bắt nạt',
      'Vi phạm quyền riêng tư',
      'Khác...',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Cho phép bottom sheet co giãn theo nội dung
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return SafeArea(
          // Wrap bằng SingleChildScrollView để cuộn được nếu nội dung quá dài
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Báo cáo người dùng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF003E77),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Danh sách lý do
                  ...reportReasons.map((reason) {
                    return ListTile(
                      title: Text(reason, style: const TextStyle(fontSize: 16)),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.pop(context); // Đóng bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportPage(
                              reportedUserName: reportedUserName,
                              reportReason: reason,
                              targetId: widget.userId,
                              targetType: 'user',
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileByIdProvider(widget.userId));
    final followersAsync = ref.watch(followersCountProvider(widget.userId));
    final followingAsync = ref.watch(followingCountProvider(widget.userId));

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003E77),
          elevation: 0,
          toolbarHeight: 48,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey[300]?.withOpacity(0.5),
              height: 1.0,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.refresh(profileByIdProvider(widget.userId).future),
              ref.refresh(followersCountProvider(widget.userId).future),
              ref.refresh(followingCountProvider(widget.userId).future),
            ]);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: profileAsync.when(
              data: (profile) {
                final bool idMismatch = profile.id != widget.userId;
                Profile displayProfile;
                final bool isFollowing;

                if (idMismatch) {
                  final previewBase = widget.initialProfile ??
                      Profile(
                        id: widget.userId,
                        name: widget.initialName ?? profile.name,
                        phone: '',
                        email: profile.email,
                        avatarUrl: widget.initialAvatarUrl ?? profile.avatarUrl,
                        birthDate: profile.birthDate,
                        gender: profile.gender,
                        description:
                            widget.initialDescription ?? profile.description,
                        regionId: profile.regionId,
                        regionName: profile.regionName,
                        fullRegionAddress: profile.fullRegionAddress,
                        street: profile.street,
                        workAddress: profile.workAddress,
                        studyAddress: profile.studyAddress,
                        socialNetwork: profile.socialNetwork,
                        updatedAt: profile.updatedAt,
                        points: profile.points,
                        isFollowing: false,
                      );

                  displayProfile = previewBase.copyWith(
                    phone: previewBase.phone.isNotEmpty
                        ? previewBase.phone
                        : profile.phone,
                    email: previewBase.email ?? profile.email,
                    birthDate: previewBase.birthDate ?? profile.birthDate,
                    gender: previewBase.gender == Gender.unknown
                        ? profile.gender
                        : previewBase.gender,
                    description: previewBase.description ?? profile.description,
                    regionId: previewBase.regionId ?? profile.regionId,
                    regionName: previewBase.regionName ?? profile.regionName,
                    fullRegionAddress: previewBase.fullRegionAddress ??
                        profile.fullRegionAddress,
                    street: previewBase.street ?? profile.street,
                    workAddress: previewBase.workAddress ?? profile.workAddress,
                    studyAddress:
                        previewBase.studyAddress ?? profile.studyAddress,
                    socialNetwork:
                        previewBase.socialNetwork ?? profile.socialNetwork,
                    points: previewBase.points > 0
                        ? previewBase.points
                        : profile.points,
                    isFollowing: false,
                  );

                  isFollowing = false;
                } else {
                  displayProfile = profile;
                  isFollowing = displayProfile.isFollowing;
                }

                final effectiveFollowing = _localIsFollowing ?? isFollowing;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeader(
                        name: displayProfile.name,
                        subtitle: displayProfile.description ?? '',
                        avatarUrl: displayProfile.avatarUrl,
                        isSelf: false,
                        followers: followersAsync.value ?? 0,
                        following: followingAsync.value ?? 0,
                        points: displayProfile.points,
                      ),
                      if (idMismatch) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: const Text(
                            'Lưu ý: API trả thông tin khác với người trong bài đăng — hiển thị thông tin tóm tắt từ bài đăng.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),

                            // ------ ROW ĐÃ SỬA LỖI OVERFLOW ------
                            Row(
                              children: [
                                // 1. Nút Theo dõi (Dùng Expanded)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoadingFollow
                                        ? null
                                        : () => _onFollowPressed(
                                            effectiveFollowing),
                                    icon: _isLoadingFollow
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF0D4C7B),
                                            ),
                                          )
                                        : Icon(
                                            effectiveFollowing
                                                ? Icons.how_to_reg_rounded
                                                : Icons.person_add,
                                            size: 20,
                                          ),
                                    label: Text(
                                      effectiveFollowing
                                          ? 'Đang theo dõi'
                                          : 'Theo dõi',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      backgroundColor: const Color(0xFFF0F6F9),
                                      foregroundColor: const Color(0xFF0D4C7B),
                                      minimumSize: const Size(0, 44),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 2. Nút Nhắn tin (Dùng Expanded)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.message, size: 20),
                                    label: const Text(
                                      'Nhắn tin',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      side: const BorderSide(
                                          color: Color(0xFF0D4C7B)),
                                      foregroundColor: const Color(0xFF0D4C7B),
                                      minimumSize: const Size(0, 44),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 3. Nút Báo cáo (Fixed size)
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF0D4C7B)),
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        _showReportSheet(displayProfile.name),
                                    icon: const Icon(Icons.report_outlined,
                                        color: Color(0xFF0D4C7B), size: 22),
                                    tooltip: 'Báo cáo người dùng',
                                    padding: EdgeInsets.zero,
                                  ),
                                )
                              ],
                            ),
                            // ----------------------------------------

                            const SizedBox(height: 12),
                            OtherProfileDetile(
                              profile: displayProfile,
                              followersCount: followersAsync.value ?? 0,
                            ),
                            const SizedBox(height: 12),
                            ReviewsList(userId: widget.userId),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              loading: () => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(
                      name: widget.initialName ?? 'Người dùng',
                      subtitle: widget.initialDescription ?? '',
                      avatarUrl: widget.initialAvatarUrl,
                      isSelf: false,
                      followers: followersAsync.value ?? 0,
                      following: followingAsync.value ?? 0,
                      points: 0,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
              error: (e, st) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('Lỗi khi tải hồ sơ: $e')),
                ),
              ),
            ),
          ),
        ));
  }
}