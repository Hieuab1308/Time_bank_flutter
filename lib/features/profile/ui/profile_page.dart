import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_details.dart';
import 'widgets/reviews_list.dart';
import 'widgets/profile_action_tabs.dart';
import 'edit_profile_page.dart';
import '../../home/ui/widgets/activity_card.dart';

const Color kPrimaryColor = Color(0xFF003E77);
const Color kAccentColor = Color(0xFF007BFF);
const Color kLightBackgroundColor = Color(0xFFF0F2F5);
const Color kDarkTextColor = Color(0xFF333333);
const Color kGreyTextColor = Color(0xFF757575);
const Color kLogoutButtonColor = Color(0xFFD81B3A);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();
  int _tabIndex = 0;
  Map<String, bool> _visibility = {};

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshProfileCounts());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshProfileCounts());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshProfileCounts();
    }
  }

  Future<void> _refreshProfileCounts() async {
    try {
      ref.invalidate(myProfileProvider);
      final profile = await ref.read(myProfileProvider.future);
      ref.invalidate(followersCountProvider(profile.id));
      ref.invalidate(followingCountProvider(profile.id));
      ref.invalidate(myFollowersCountProvider);
      ref.invalidate(myFollowingCountProvider);
      await ref.read(followersCountProvider(profile.id).future);
      await ref.read(followingCountProvider(profile.id).future);
      await ref.read(myFollowersCountProvider.future);
      await ref.read(myFollowingCountProvider.future);
    } catch (_) {}
  }

  void _scrollToDetails() {
    setState(() => _tabIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trang cá nhân',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myProfileProvider);
          ref.invalidate(myFollowersCountProvider);
          ref.invalidate(myFollowingCountProvider);
          await ref.read(myProfileProvider.future);
        },
        child: profileAsync.when(
          data: (profile) {
            final followersAsync = ref.watch(myFollowersCountProvider);
            final followingAsync = ref.watch(myFollowingCountProvider);

            return Transform.translate(
              offset: const Offset(0, -60),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: EdgeInsets.only(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(
                      name: profile.name,
                      subtitle: profile.description ?? '',
                      avatarUrl: profile.avatarUrl,
                      isSelf: true,
                      followers: followersAsync.value ?? 0,
                      following: followingAsync.value ?? 0,
                      points: profile.points,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          ProfileActionTabs(
                            key: ValueKey(_tabIndex),
                            initialIndex: _tabIndex,
                            leftLabel: 'Chi tiết\n& Đánh giá',
                            rightLabel: 'Dịch vụ',
                            onLeftTap: _scrollToDetails,
                            onRightTap: () {
                              setState(() => _tabIndex = 1);
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_tabIndex == 0) ...[
                            ProfileDetails(
                              key: _detailsKey,
                              profile: profile,
                              visibility:
                                  _visibility.isEmpty ? null : _visibility,
                              onEdit: () async {
                                final result = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfilePage(profile: profile),
                                ));
                                if (result != null) {
                                  if (result is Map &&
                                      result.containsKey('visibility')) {
                                    final vis = result['visibility'];
                                    if (vis is Map) {
                                      setState(() {
                                        _visibility =
                                            Map<String, bool>.fromEntries(
                                          vis.entries.map((e) => MapEntry(
                                              e.key.toString(),
                                              e.value == true)),
                                        );
                                      });
                                    }
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            ReviewsList(userId: profile.id),
                          ] else ...[
                            Consumer(
                              builder: (context, ref2, _) {
                                final activitiesAsync =
                                    ref2.watch(activitiesProvider(profile.id));
                                return activitiesAsync.when(
                                  data: (activities) => Column(
                                    children: activities
                                        .map((a) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12.0),
                                              child: ActivityCard(
                                                activity: a,
                                                onTap: () {},
                                                onMoreTap: () {},
                                                compact: true,
                                                horizontalPadding: 0,
                                                verticalPadding: 6,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  loading: () => const Center(
                                      child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: CircularProgressIndicator(),
                                  )),
                                  error: (e, st) => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                        child: Text('Lỗi khi tải dịch vụ')),
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(child: CircularProgressIndicator()),
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
    );
  }
}
