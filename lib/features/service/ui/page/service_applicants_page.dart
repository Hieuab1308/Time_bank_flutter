import 'package:flutter/material.dart';
import '../widgets/my_service/pending_applicants_widget.dart';
import '../widgets/my_service/approved_applicants_widget.dart';

class ServiceApplicantsPage extends StatefulWidget {
  final String serviceId;
  final String serviceTitle;

  const ServiceApplicantsPage({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
  });

  @override
  State<ServiceApplicantsPage> createState() => _ServiceApplicantsPageState();
}

class _ServiceApplicantsPageState extends State<ServiceApplicantsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chi tiết các ứng viên đã ứng tuyển',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Dòng tiêu đề "Danh sách ứng viên" + icon 3 gạch
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách ứng viên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003E77),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.menu_rounded, color: Color(0xFF003E77)),
                  onPressed: () {
                    // TODO: xử lý khi bấm icon ba gạch (mở menu, filter, v.v.)
                  },
                ),
              ],
            ),
          ),

          // 🔹 Thanh Tab ngay dưới tiêu đề
          TabBar(
            controller: _tabController,
            labelColor: Color(0xFFE30000),
            dividerColor: Colors.transparent,
            unselectedLabelColor: Color(0xFF003E77),
            indicator: UnderlineTabIndicator(
              borderSide: const BorderSide(
                width: 5, // 🔹 độ dày của gạch
                color: Color(0xFFE30000),
              ),
              borderRadius: BorderRadius.circular(4), // 🔹 bo tròn hai đầu
              insets:
                  const EdgeInsets.only(bottom: 2), // 🔹 kéo gạch lên gần chữ
            ),
            labelStyle: const TextStyle(
              fontSize: 16.5,
              // fontWeight: FontWeight.w700,
            ),
            labelPadding: const EdgeInsets.symmetric(
                vertical: 6), // 🔹 giảm khoảng cách chữ–gạch
            tabs: const [
              Tab(text: 'Đang chờ phê duyệt'),
              Tab(text: 'Đã phê duyệt'),
            ],
          ),

          // 🔹 Nội dung theo từng Tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PendingApplicantsWidget(serviceId: widget.serviceId),
                ApprovedApplicantsWidget(serviceId: widget.serviceId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
