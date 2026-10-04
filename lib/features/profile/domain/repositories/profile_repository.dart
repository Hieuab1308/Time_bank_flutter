import '../profile.dart';
import '../review.dart';

abstract class ProfileRepository {
  Future<Profile> fetchMyProfile();
  Future<Profile> fetchProfileById(String userId);
  Future<void> updateMyProfile(Map<String, dynamic> updates);
  Future<List<Review>> fetchReviews(String userId);

  Future<int> getFollowersCount(String userId);
  Future<int> getFollowingCount(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
}