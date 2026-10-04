import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_providers.dart';
import '../domain/models/models.dart';


final selectedProvinceIdProvider = StateProvider<String?>((_) => null);

final selectedDistrictIdProvider = StateProvider<String?>((_) => null);

final selectedWardIdProvider = StateProvider<String?>((_) => null);

final provincesProvider = FutureProvider<List<Region>>((ref) async {
  final repo = ref.read(onboardingRepoProvider);
  final items = await repo.getProvinces();
  items.sort((a, b) => a.name.compareTo(b.name));
  ref.keepAlive();
  return items;
});

final districtsProvider = FutureProvider.autoDispose<List<Region>>((ref) async {
  final provinceId = ref.watch(selectedProvinceIdProvider);
  if (provinceId == null) return <Region>[];
  final repo = ref.read(onboardingRepoProvider);
  final items = await repo.getDistricts(provinceId);
  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
});

final wardsProvider = FutureProvider.autoDispose<List<Region>>((ref) async {
  final districtId = ref.watch(selectedDistrictIdProvider);
  if (districtId == null) return <Region>[];
  final repo = ref.read(onboardingRepoProvider);
  final items = await repo.getWards(districtId);
  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
});

final selectedProvinceProvider = Provider<Region?>((ref) {
  final id = ref.watch(selectedProvinceIdProvider);
  final listAsync = ref.watch(provincesProvider);
  return listAsync.maybeWhen(
    data: (items) => items.firstWhere(
          (e) => e.id == id,
      orElse: () => null as Region,
    ),
    orElse: () => null,
  );
});

final selectedDistrictProvider = Provider<Region?>((ref) {
  final id = ref.watch(selectedDistrictIdProvider);
  final listAsync = ref.watch(districtsProvider);
  return listAsync.maybeWhen(
    data: (items) => items.firstWhere(
          (e) => e.id == id,
      orElse: () => null as Region,
    ),
    orElse: () => null,
  );
});

final selectedWardProvider = Provider<Region?>((ref) {
  final id = ref.watch(selectedWardIdProvider);
  final listAsync = ref.watch(wardsProvider);
  return listAsync.maybeWhen(
    data: (items) => items.firstWhere(
          (e) => e.id == id,
      orElse: () => null as Region,
    ),
    orElse: () => null,
  );
});

final fullAddressTextProvider = FutureProvider<String?>((ref) async {
  final wardId = ref.watch(selectedWardIdProvider);
  if (wardId == null) return null;

  final repo = ref.read(onboardingRepoProvider);

  final ward = await repo.getRegionDetail(wardId);
  if (ward.parentId == null) return ward.name;

  final district = await repo.getRegionDetail(ward.parentId!);

  Region? province;
  if (district.parentId != null) {
    province = await repo.getRegionDetail(district.parentId!);
  }

  final parts = <String>[
    ward.name,
    district.name,
    if (province != null) province.name,
  ];
  return parts.join(', ');
});


void selectProvince(WidgetRef ref, String? provinceId) {
  ref.read(selectedProvinceIdProvider.notifier).state = provinceId;
  ref.read(selectedDistrictIdProvider.notifier).state = null;
  ref.read(selectedWardIdProvider.notifier).state = null;
}

void selectDistrict(WidgetRef ref, String? districtId) {
  ref.read(selectedDistrictIdProvider.notifier).state = districtId;
  ref.read(selectedWardIdProvider.notifier).state = null;
}

void selectWard(WidgetRef ref, String? wardId) {
  ref.read(selectedWardIdProvider.notifier).state = wardId;
}
