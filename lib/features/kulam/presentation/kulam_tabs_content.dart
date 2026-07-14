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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown Selection
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _currentIndex,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.white),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
              selectedItemBuilder: (BuildContext context) {
                return [
                  'குலதெய்வம் வழிபாடு',
                  'சமூகம்',
                  'உட்பிரிவு',
                  'குலம்',
                  'குல தெய்வம்',
                  'வகைரா',
                  'குலம் மக்கள்',
                  'முன்னோர்களைச் சேர்க்க',
                ].map<Widget>((String text) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList();
              },
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('குலதெய்வம் வழிபாடு'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('சமூகம்'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('உட்பிரிவு'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('குலம்'),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text('குல தெய்வம்'),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text('வகைரா'),
                ),
                DropdownMenuItem(
                  value: 6,
                  child: Text('குலம் மக்கள்'),
                ),
                DropdownMenuItem(
                  value: 7,
                  child: Text('முன்னோர்களைச் சேர்க்க'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentIndex = value;
                  });
                }
              },
            ),
          ),
        ),

        // Content View
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
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
}
