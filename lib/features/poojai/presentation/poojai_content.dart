import 'package:flutter/material.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class PookaiContent extends StatefulWidget {
  final Function(String, {Map<String, dynamic>? arguments}) onScreenSelected;
  const PookaiContent({super.key, required this.onScreenSelected});

  @override
  State<PookaiContent> createState() => _PookaiContentState();
}

class _PookaiContentState extends State<PookaiContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedDeity = 'அனைத்து தெய்வங்கள்';
  String _selectedCategory = 'அனைத்து பூஜைகள்';

  final List<Map<String, String>> _allPoojais = [
    {
      'deity': 'மூலவர்',
      'sub': 'mulavar',
      'category': 'நித்திய பூஜை',
      'kalam': 'இரண்டு கால பூஜை',
      'nilamai': 'திங்கட்கிழமை',
      'time': 'சாயங்காலம்',
      'date': '2026-05-08',
      'status': 'active',
    },
    {
      'deity': 'மூலவர்',
      'sub': 'mulavar',
      'category': 'கிழமை பூஜை',
      'kalam': 'நான்கு கால பூஜை',
      'nilamai': 'வெள்ளி',
      'time': 'காலை',
      'date': '2026-05-08',
      'status': 'active',
    },
    {
      'deity': 'வைதண்ட ஏகாதசி சிறப்பு பூஜை',
      'sub': 't',
      'category': 'சிறப்பு பூஜை',
      'kalam': 'one_time',
      'nilamai': 'திங்கட்கிழமை',
      'time': '05:00:00',
      'date': '2026-12-23',
      'status': 'active',
    },
  ];

  List<Map<String, String>> get _filtered {
    return _allPoojais.where((p) {
      final q = _searchController.text.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          p['deity']!.toLowerCase().contains(q) ||
          p['category']!.toLowerCase().contains(q);
      final matchDeity =
          _selectedDeity == 'அனைத்து தெய்வங்கள்' ||
          p['deity'] == _selectedDeity;
      final matchCat =
          _selectedCategory == 'அனைத்து பூஜைகள்' ||
          p['category'] == _selectedCategory;
      return matchSearch && matchDeity && matchCat;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.spa, color: Colors.indigo, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'தெய்வங்களுக்கான பூஜைகள் (Temple Rituals)',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'நித்திய, கிழமை மற்றும் சிறப்பு பூஜைகளை இங்கே ஒருங்கிணைத்து நிர்வகிக்கவும்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 28),

          // 3 Category Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final cards = [
                _buildCategoryCard(
                  'நித்திய பூஜை',
                  'DAILY RITUALS',
                  Icons.flash_on,
                  const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A47D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  'நிர்வகிக்க >',
                  'நித்திய பூஜை',
                ),
                _buildCategoryCard(
                  'கிழமை பூஜை',
                  'WEEKLY RITUALS',
                  Icons.calendar_view_week,
                  const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  'நிர்வகிக்க >',
                  'கிழமை பூஜை',
                ),
                _buildCategoryCard(
                  'சிறப்பு பூஜை',
                  'SPECIAL OCCASIONS',
                  Icons.star_outline,
                  const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  'நிர்வகிக்க >',
                  'சிறப்பு பூஜை',
                ),
              ];

              if (isMobile) {
                return Column(
                  children: cards
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: c,
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                children: cards
                    .map(
                      (c) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: c,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),

          // All Poojais List Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'அனைத்து பூஜைகள் பட்டியல்',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.indigo, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filters
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;
                    final searchField = TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'பூஜை அல்லது தெய்வம் மூலம் தேடு...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF524EE1),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    );

                    final deityDropdown = _buildFilterDropdown(
                      Icons.person_outline,
                      _selectedDeity,
                      [
                        'அனைத்து தெய்வங்கள்',
                        'மூலவர்',
                        'உடனாய்',
                        'பரிவார தெய்வங்கள்',
                        'பிகரா தெய்வங்கள்',
                        'உப தெய்வங்கள்',
                      ],
                      (val) => setState(() => _selectedDeity = val!),
                    );

                    final categoryDropdown = _buildFilterDropdown(
                      Icons.filter_list,
                      _selectedCategory,
                      [
                        'அனைத்து பூஜைகள்',
                        'நித்திய பூஜை',
                        'கிழமை பூஜை',
                        'சிறப்பு பூஜை',
                      ],
                      (val) => setState(() => _selectedCategory = val!),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 12),
                          deityDropdown,
                          const SizedBox(height: 12),
                          categoryDropdown,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 12),
                        Expanded(child: deityDropdown),
                        const SizedBox(width: 12),
                        Expanded(child: categoryDropdown),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.grey.shade200),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey.shade50,
                      ),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'தெய்வம் & வகை',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'பூஜை வகை',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'காலம் / நிகழ்வு',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'நிலமை',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'நாள் நேரம்',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'தேதி',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'நிலை',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'ACTIONS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      rows: filtered.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p['deity']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    p['sub']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(_buildCategoryBadge(p['category']!)),
                            DataCell(
                              Text(
                                p['kalam']!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Text(
                                p['nilamai']!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p['time']!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                p['date']!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  p['status']!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.grey.shade600,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      final category = p['category'];
                                      if (category == 'நித்திய பூஜை' ||
                                          category == 'கிழமை பூஜை' ||
                                          category == 'சிறப்பு பூஜை') {
                                        widget.onScreenSelected(
                                          category!,
                                          arguments: {'editPoojai': p},
                                        );
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 16,
                                    ),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    String buttonText,
    String targetScreen,
  ) {
    return InkWell(
      onTap: () => widget.onScreenSelected(targetScreen),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background watermark icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color color;
    if (category == 'நித்திய பூஜை') {
      color = Colors.indigo;
    } else if (category == 'கிழமை பூஜை') {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                items: items
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
