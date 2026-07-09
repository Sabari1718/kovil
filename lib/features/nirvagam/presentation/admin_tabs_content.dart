import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tharma_kartta_content.dart';
import 'nan_kodaiyalar_content.dart';
import 'ara_nilayat_thurai_content.dart';
import 'porul_athara_content.dart';
import 'anna_thanam_content.dart';
import 'paktharkal_kuzhu_content.dart';

class AdminTabsContent extends ConsumerStatefulWidget {
  const AdminTabsContent({super.key});

  @override
  ConsumerState<AdminTabsContent> createState() => _AdminTabsContentState();
}

class _AdminTabsContentState extends ConsumerState<AdminTabsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
            tabs: const [
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('தர்மகர்த்தா'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('நன்கொடையாளர் / தொண்டர்'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('அறநிலையத்துறை'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('பொருளாதாரம்'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('அன்ன தானம்'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('பக்தர்கள் குழு'),
                ),
              ),
            ],
          ),
        ),

        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              TharmaKartthaContent(),
              NanKodaiyalarContent(),
              AraNilayatThuraiContent(),
              PorulAtharaContent(),
              AnnaThanamContent(),
              PaktharkalKuzhuContent(),
            ],
          ),
        ),
      ],
    );
  }
}
