import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/transaction_history/providers/transaction_history_providers.dart';
import 'widgets/balance_box.dart';
import 'widgets/date_range_filter.dart';
import 'widgets/day_group_section.dart';
import 'widgets/transaction_detail_sheet.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';

class TransactionHistoryPage extends ConsumerWidget {
  const TransactionHistoryPage({super.key});
  Future<void> _handleRefresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(currentBalanceProvider.future),
      ref.refresh(transactionsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(currentBalanceProvider);
    final txAsync = ref.watch(transactionsProvider);
    final range = ref.watch(transactionRangeProvider);

    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF003E77),
        foregroundColor: Colors.white,
        leading: canPop
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        )
            : null,
        title: const Text('Lịch sử giao dịch'),
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _handleRefresh(ref),
          color: const Color(0xFF003E77),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('SỐ DƯ TÀI KHOẢN HIỆN TẠI:', style: _secLabelStyle),
                const SizedBox(height: 6),
                balanceAsync.when(
                  data: (s) => BalanceBox(balanceText: _formatHms(s)),
                  error: (e, st) => _errorBox('Balance error'),
                  loading: () => const SizedBox(height: 72, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                ),
                const SizedBox(height: 24),
                Text('Truy vấn lịch sử giao dịch', style: _secLabelStyle),
                const SizedBox(height: 10),
                DateRangeFilter(
                  from: range.from,
                  to: range.to,
                  onPickFrom: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: range.from,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: range.to,
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor: Colors.white,
                          colorScheme: ColorScheme.light(
                            primary: const Color(0xFF003E77),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            surfaceVariant: Colors.white,
                            background: Colors.white,
                            onSurface: Colors.black,
                            onBackground: Colors.black,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      ref.read(transactionRangeProvider.notifier).state = (from: picked, to: range.to);
                    }
                  },
                  onPickTo: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: range.to,
                      firstDate: range.from,
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor: Colors.white,
                          colorScheme: ColorScheme.light(
                            primary: const Color(0xFF003E77),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            surfaceVariant: Colors.white,
                            background: Colors.white,
                            onSurface: Colors.black,
                            onBackground: Colors.black,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      ref.read(transactionRangeProvider.notifier).state = (from: range.from, to: picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hệ thống cho phép truy vấn giao dịch trong vòng thời gian 1 năm kể từ ngày hiện tại',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF546170), height: 1.3),
                ),
                const SizedBox(height: 20),
                Consumer(
                  builder: (context, ref, _) {
                    final dir = ref.watch(transactionDirectionFilterProvider);
                    Widget _button(String label, TransactionDirection? value) => Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: dir == value ? const Color(0xFF0A3D66) : Colors.transparent,
                          foregroundColor: dir == value ? Colors.white : const Color(0xFF0A3D66),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 39),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: () => ref.read(transactionDirectionFilterProvider.notifier).state = value,
                        child: Text(label),
                      ),
                    );

                    return Container(
                      height: 42,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE4E6EB)),
                        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0,2))],
                      ),
                      child: Row(children: [
                        _button('Tất cả', null),
                        const SizedBox(width: 6),
                        _button('Vào', TransactionDirection.incoming),
                        const SizedBox(width: 6),
                        _button('Ra', TransactionDirection.out),
                      ]),
                    );
                  },
                ),
                const SizedBox(height: 12),
                txAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return _empty();
                    }
                    final groupedFiltered = _groupByDate(list);
                    return Column(
                      children: [
                        for (final g in groupedFiltered.entries)
                          DayGroupSection(
                            dateLabel: g.key,
                            entries: g.value,
                            onTapEntry: (e) => _showDetail(context, e),
                          ),
                      ],
                    );
                  },
                  error: (e, st) => _errorBox('Load error'),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static final _secLabelStyle = const TextStyle(fontSize: 12, letterSpacing: 0.4, fontWeight: FontWeight.w700, color: Color(0xFF0A3D66));

  Map<String, List<TransactionEntry>> _groupByDate(List<TransactionEntry> list) {
    final Map<String, List<TransactionEntry>> map = {};
    for (final e in list) {
      final key = e.formattedDate;
      map.putIfAbsent(key, () => []).add(e);
    }
    // Reverse chronological (newest date first)
    final entries = map.entries.toList()
      ..sort((a,b) => b.value.first.occurredAt.compareTo(a.value.first.occurredAt));
    return { for (final e in entries) e.key : e.value };
  }

  void _showDetail(BuildContext context, TransactionEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionDetailSheet(entry: entry),
    );
  }

  Widget _empty() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Text('Không có giao dịch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A5A6A))),
  );

  Widget _errorBox(String msg) => Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE5E5),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD64545)),
    ),
    child: Text(msg, style: const TextStyle(color: Color(0xFFD64545), fontWeight: FontWeight.w600)),
  );

  static String _formatHms(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(h)}:${pad(m)}:${pad(s)}';
  }
}