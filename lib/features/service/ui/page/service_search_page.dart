import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/service_list_container_community.dart';
import '../widgets/service_list_container.dart';

class ServiceSearchPage extends StatefulWidget {
  final String initialQuery;
  const ServiceSearchPage({super.key, this.initialQuery = ''});

  @override
  State<ServiceSearchPage> createState() => _ServiceSearchPageState();
}

class _ServiceSearchPageState extends State<ServiceSearchPage> {
  late TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: _query);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF003E77),
          elevation: 0,
          title: const Text('Tìm kiếm',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.12),
                  color: Colors.white,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm dịch vụ...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: (v) {
                      Navigator.of(context).pop(v);
                    },
                  ),
                ),
              ),
            ),
            Expanded(child: ServiceListContainerCommunity(query: _query)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
