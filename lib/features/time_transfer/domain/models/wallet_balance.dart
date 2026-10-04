class WalletBalance {
  final int secs;
  final String pretty; // ví dụ: "10:45:00"
  final String status;

  WalletBalance({required this.secs, required this.pretty, required this.status});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      secs: json['balance']['secs'],
      pretty: json['balance']['pretty'],
      status: json['status'],
    );
  }
}