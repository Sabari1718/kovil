import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nertthi_kadan_content.dart';
import 'kulam_makkal_content.dart';
import 'samugam_saathi_content.dart';
import 'kattali_tharar_content.dart';

class DevoteesTabsContent extends ConsumerStatefulWidget {
  const DevoteesTabsContent({super.key});

  @override
  ConsumerState<DevoteesTabsContent> createState() => _DevoteesTabsContentState();
}

class _DevoteesTabsContentState extends ConsumerState<DevoteesTabsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                  child: Text('நேர்த்தி கடன்'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('குலம் மக்கள்'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('சமூகம் மற்றும் சாதி'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('கட்டளை தாரர்கள்'),
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
              NertthiKadanContent(),
              KulamMakkalContent(),
              SamugamSaathiContent(),
              KattaliTharalContent(),
            ],
          ),
        ),
      ],
    );
  }
}
