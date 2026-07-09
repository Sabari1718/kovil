import 'package:flutter/material.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class SamugamSaathiContent extends StatefulWidget {
  const SamugamSaathiContent({super.key});

  @override
  State<SamugamSaathiContent> createState() => _SamugamSaathiContentState();
}

class _SamugamSaathiContentState extends State<SamugamSaathiContent> {
  final ScrollController _scrollController = ScrollController();
  // Toggle Add Mapping form
  bool _showForm = false;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Form dropdowns
  String? _selectedUser;
  String? _selectedSectorTitle;
  String? _selectedSector;
  String? _selectedSubSector;

  final List<String> _userList = [
    'lohit - lovelyloiht003@gmail.com - 9003853603',
    'Ravi - ravi123@gmail.com - 9876543210',
    'Priya - priya456@gmail.com - 9123456789',
  ];

  final List<String> _sectorTitleList = [
    'Devotees',
    'Trustees',
    'Volunteers',
    'Priests',
  ];

  final List<String> _sectorList = ['Hindu'];

  final List<String> _subSectorList = [
    'Saivam',
    'Vaishnavam',
    'Shaktham',
    'Kaumaram',
  ];

  // Mock mapped records
  final List<Map<String, dynamic>> _records = [
    {
      'id': '1',
      'name': 'lohit',
      'email': 'lovelyloiht003@gmail.com',
      'phone': '9003853603',
      'sectorTitle': 'Devotees',
      'sector': 'Hindu',
      'subSector': 'Saivam',
      'primaryCategories': ['Murugan', 'Shivan'],
      'subCategories': ['Bhairavar', 'Nataraja'],
    },
  ];

  void _clearForm() {
    setState(() {
      _selectedUser = null;
      _selectedSectorTitle = null;
      _selectedSector = null;
      _selectedSubSector = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          _buildAddSection(),
          const SizedBox(height: 24),
          _buildListCard(),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Colors.indigo,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'சமூகம் மற்றும் சாதி (Community & Caste)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'பயனர்களின் மதம், சமூகம் மற்றும் உட்பிரிவு விவரங்களை இங்கே இணைக்கலாம்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  // ─── Add Mapping Section ─────────────────────────────────────────────────────
  Widget _buildAddSection() {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        children: [
          // Header row — always visible
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'புதிய விவரம் சேர்க்க (Add New Mapping)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _showForm
                    ? OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _showForm = false;
                          _clearForm();
                        }),
                        icon: const Icon(Icons.close, size: 15),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => setState(() => _showForm = true),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Mapping'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EE1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
              ],
            ),
          ),

          // Expandable Mapping Form
          if (_showForm) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Select Existing User (full width)
                  _dropdownField(
                    label: 'பயனரைத் தேர்ந்தெடுக்கவும் (Select Existing User) *',
                    hint: '-- பயனரைத் தேர்ந்தெடுக்கவும் (Select User) --',
                    icon: Icons.person_outline,
                    value: _selectedUser,
                    items: _userList,
                    onChanged: (v) => setState(() => _selectedUser = v),
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Sector Title | Sector
                  _twoRow(
                    _dropdownField(
                      label: 'துறைத் தலைப்பு (Sector Title) *',
                      hint: 'Select Sector Title',
                      icon: Icons.category_outlined,
                      value: _selectedSectorTitle,
                      items: _sectorTitleList,
                      onChanged: (v) =>
                          setState(() => _selectedSectorTitle = v),
                    ),
                    _dropdownField(
                      label: 'துறை (Sector) *',
                      hint: 'Select Sector',
                      icon: Icons.layers_outlined,
                      value: _selectedSector,
                      items: _sectorList,
                      onChanged: (v) => setState(() => _selectedSector = v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Sub Sector (full width)
                  _dropdownField(
                    label: 'துணைத் துறை (Sub Sector) *',
                    hint: 'Select Sub Sector',
                    icon: Icons.account_tree_outlined,
                    value: _selectedSubSector,
                    items: _subSectorList,
                    onChanged: (v) => setState(() => _selectedSubSector = v),
                  ),
                  const SizedBox(height: 28),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_selectedUser == null ||
                              _selectedSectorTitle == null ||
                              _selectedSector == null ||
                              _selectedSubSector == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'அனைத்து புலங்களையும் நிரப்பவும்!',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
                          setState(() => _showForm = false);
                          _clearForm();
                        },
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Save Mapping'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EE1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Mapped Details List ─────────────────────────────────────────────────────
  Widget _buildListCard() {
    final q = _searchController.text.toLowerCase();
    final filtered = _records.where((r) {
      return q.isEmpty ||
          (r['name'] as String).toLowerCase().contains(q) ||
          (r['sector'] as String).toLowerCase().contains(q) ||
          (r['sectorTitle'] as String).toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'பதிவான விவரங்கள் (Mapped Details)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'பெயர் அல்லது துறை தேடல்...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
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
                      borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.grey.shade200),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'பயனர் விவரம் (USER DETAILS)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'துறைத் தலைப்பு\n(SECTOR TITLE)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'துறை\n(SECTOR)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'துணைத் துறை\n(SUB SECTOR)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'பிரிவுகள்\n(CATEGORIES)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ACTIONS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                ],
                rows: filtered.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final r = entry.value;
                  return DataRow(
                    cells: [
                      // # id
                      DataCell(
                        Text(
                          r['id']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // User Details
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.indigo.shade400,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  r['name']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  r['email']!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  r['phone']!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Sector Title
                      DataCell(
                        Text(
                          r['sectorTitle']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                      // Sector badge
                      DataCell(_sectorBadge(r['sector']!, idx)),

                      // Sub Sector
                      DataCell(
                        Text(
                          r['subSector']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                      // Categories
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Primary: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          (r['primaryCategories']
                                                  as List<String>)
                                              .join(', '),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Sub: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: (r['subCategories'] as List<String>)
                                          .join(', '),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Actions
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 15,
                            ),
                            onPressed: () {
                              setState(() {
                                _records.removeAt(idx);
                              });
                            },
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'பதிவுகள் இல்லை',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectorBadge(String sector, int idx) {
    final colors = [
      [Colors.green.shade100, Colors.green.shade700],
      [Colors.purple.shade100, Colors.purple.shade700],
      [Colors.blue.shade100, Colors.blue.shade700],
      [Colors.orange.shade100, Colors.orange.shade700],
    ];
    final c = colors[idx % colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c[0],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        sector,
        style: TextStyle(
          color: c[1],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _twoRow(Widget a, Widget b) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 600) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [a, const SizedBox(height: 14), b],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 14),
          Expanded(child: b),
        ],
      );
    },
  );

  Widget _dropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  hint: Text(
                    hint,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
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
      ),
    ],
  );
}
