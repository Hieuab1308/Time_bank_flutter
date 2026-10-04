import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/my_service/my_service_detail_page.dart';

import '../widgets/community/community_service_detail_page.dart';


class ServiceDetailPage extends StatelessWidget {
  final String serviceId;
  final bool isMyService;

  const ServiceDetailPage({
    super.key,
    required this.serviceId,
    this.isMyService = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMyService) {
      return MyServiceDetailPage(serviceId: serviceId);
    } else {
      return CommunityServiceDetailPage(serviceId: serviceId);
    }
  }
}