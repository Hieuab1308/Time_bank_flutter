import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/api_transfer_to_escrow_repository.dart';
import '../domain/repositories/transfer_to_escrow_repository.dart';

/// Repository provider
final transferToEscrowRepositoryProvider =
    Provider<TransferToEscrowRepository>((ref) {
  final authedApi = ref.watch(authedApiClientProvider);
  return TransferToEscrowApiRepository(authedApi);
});

/// Provider gọi API
final transferToEscrowProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  final repo = ref.watch(transferToEscrowRepositoryProvider);

  return repo.transferToEscrow(
    jobId: params['jobId'],
    secs: params['secs'],
    pin: params['pin'],
  );
});
