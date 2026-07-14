import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'poojai_content.dart';
import 'nithiya_poojai_content.dart';
import 'kizhama_poojai_content.dart';
import 'sirappu_poojai_content.dart';

class PoojasTabsContent extends ConsumerStatefulWidget {
  final Function(String, {Map<String, dynamic>? arguments}) onScreenSelected;
  final Map<String, dynamic>? screenArguments;

  const PoojasTabsContent({
    super.key,
    required this.onScreenSelected,
    this.screenArguments,
  });

  @override
  ConsumerState<PoojasTabsContent> createState() => _PoojasTabsContentState();
}

class _PoojasTabsContentState extends ConsumerState<PoojasTabsContent> {
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
                  'பூஜைகள்',
                  'நித்திய பூஜை',
                  'கிழமை பூஜை',
                  'சிறப்பு பூஜை',
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
                  child: Text('பூஜைகள்'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('நித்திய பூஜை'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('கிழமை பூஜை'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('சிறப்பு பூஜை'),
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
            children: [
              PookaiContent(
                onScreenSelected: (screen, {arguments}) {
                  widget.onScreenSelected(screen, arguments: arguments);
                },
              ),
              NithiyaPookaiContent(
                editPoojai: widget.screenArguments?['editPoojai'],
              ),
              KizhamaPookaiContent(
                editPoojai: widget.screenArguments?['editPoojai'],
              ),
              SirappuPookaiContent(
                editPoojai: widget.screenArguments?['editPoojai'],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
