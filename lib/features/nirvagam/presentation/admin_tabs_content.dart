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

class _AdminTabsContentState extends ConsumerState<AdminTabsContent> {
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
                  'தர்மகர்த்தா',
                  'நன்கொடையாளர் / தொண்டர்',
                  'அறநிலையத்துறை',
                  'பொருளாதாரம்',
                  'அன்ன தானம்',
                  'பக்தர்கள் குழு',
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
                  child: Text('தர்மகர்த்தா'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('நன்கொடையாளர் / தொண்டர்'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('அறநிலையத்துறை'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('பொருளாதாரம்'),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text('அன்ன தானம்'),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text('பக்தர்கள் குழு'),
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
