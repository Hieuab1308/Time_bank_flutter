import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/data/model/service_filter.dart';
import 'package:time_bank_flutter/features/service/ui/page/search_page.dart';
import '../widgets/service_list_container.dart';
import '../widgets/service_header.dart';
import '../widgets/create_page/service_create_page.dart';
import '../widgets/service_list_container_community.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key, this.initialListTypeFilter});
  
  final String? initialListTypeFilter;

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String _query = '';
  String? _socialFilter;
  ServiceFilter? _detailedFilter;
  
  String _listTypeFilter = 'Tất cả mọi người'; 

  @override
  void initState() {
    super.initState();
    if (widget.initialListTypeFilter != null) {
      setState(() {
        _listTypeFilter = widget.initialListTypeFilter!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        title: const Text(
          'Dịch vụ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceCreatePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF003E77),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: ServiceHeader(
              onFilterChanged: (filterValue) {
                if (filterValue == null) return;
                
                if (filterValue == 'Tất cả mọi người' ||
                    filterValue == 'Dịch vụ của tôi') {
                  setState(() {
                    _listTypeFilter = filterValue;
                  });
                } else if (filterValue == 'Mọi người' ||
                           filterValue == 'Bạn bè') {
                  setState(() {
                    _socialFilter = filterValue;
                  });
                }
              },
              onSearchChanged: (searchText) {
                setState(() {
                  _query = searchText;
                });
              },
            ),
          ),
        ],
        body: _buildConditionalList(),
      ),
    );
  }

  Widget _buildConditionalList() {
    if (_listTypeFilter == 'Dịch vụ của tôi') {
      return ServiceListContainer(
        query: _query,
        filter: null, 
        socialFilter: _socialFilter,
      );
    } else {
      return ServiceListContainerCommunity(
        query: _query,
        filter: null,
        socialFilter: _socialFilter,
      );
    }
  }
}