import '../models/wallet_balance.dart';

abstract class WalletRepository {
  Future<WalletBalance> getMyWallet();
}