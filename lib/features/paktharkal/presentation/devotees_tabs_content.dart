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

class _DevoteesTabsContentState extends ConsumerState<DevoteesTabsContent> {
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
                  'நேர்த்தி கடன்',
                  'குலம் மக்கள்',
                  'சமூகம் மற்றும் சாதி',
                  'கட்டளை தாரர்கள்',
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
                  child: Text('நேர்த்தி கடன்'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('குலம் மக்கள்'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('சமூகம் மற்றும் சாதி'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('கட்டளை தாரர்கள்'),
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
