import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kula_deivam_worship_content.dart';
import 'samugam_manage_content.dart';
import 'subcommunity_manage_content.dart';
import 'kulam_manage_content.dart';
import 'kula_deivam_mapping_content.dart';
import 'vagaiyara_manage_content.dart';
import 'ancestors_manage_content.dart';
import '../../paktharkal/presentation/kulam_makkal_content.dart';

class KulamTabsContent extends ConsumerStatefulWidget {
  const KulamTabsContent({super.key});

  @override
  ConsumerState<KulamTabsContent> createState() => _KulamTabsContentState();
}

class _KulamTabsContentState extends ConsumerState<KulamTabsContent> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Builder(
        builder: (context) {
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
                        child: Text('குலதெய்வம் வழிபாடு'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('சமூகம்'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('உட்பிரிவு'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('குலம்'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('குல தெய்வம்'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('வகைரா'),
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
                        child: Text('முன்னோர்களைச் சேர்க்க'),
                      ),
                    ),
                  ],
                ),
              ),
          
              // Tab Bar View
              Expanded(
                child: TabBarView(
                  children: const [
                    KulaDeivamWorshipContent(),
                    SamugamManageContent(),
                    SubCommunityManageContent(),
                    KulamManageContent(),
                    KulaDeivamMappingContent(),
                    VagaiyaraManageContent(),
                    KulamMakkalContent(),
                    AncestorsManageContent(),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
