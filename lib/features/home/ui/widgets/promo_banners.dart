import 'dart:async';
import 'package:flutter/material.dart';

class PromoBanners extends StatefulWidget {
  const PromoBanners({super.key});

  @override
  State<PromoBanners> createState() => _PromoBannersState();
}

class _PromoBannersState extends State<PromoBanners> {
  final PageController _controller = PageController(viewportFraction: 0.96);
  late final Timer _timer;
  int _page = 0;

  final List<Map<String, String>> _banners = [
    {
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200',
      'title': 'Lớp nấu ăn cho gia đình',
    },
    {
      'image': 'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=1200',
      'title': 'Lập trình cùng chuyên gia',
    },
    {
      'image': 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=1200',
      'title': 'Học máy tính từ cơ bản đến nâng cao',
    },
    {
      'image': 'https://capcuuthucung.com/wp-content/uploads/2023/12/pet247-tham-kham-cham-soc-thu-cung-nhu-ban-than2.png',
      'title': 'Chăm sóc thú cưng tại nhà',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _page = (_page + 1) % _banners.length;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        b['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Text(
                          b['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 22 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF003E77) : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
