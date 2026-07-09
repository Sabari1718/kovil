import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/piraarthanai_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class KuraiNivarthiContent extends StatefulWidget {
  const KuraiNivarthiContent({super.key});

  @override
  State<KuraiNivarthiContent> createState() => _KuraiNivarthiContentState();
}

class _KuraiNivarthiContentState extends State<KuraiNivarthiContent> {
  final ScrollController _scrollController = ScrollController();
  // Active tab: 0=வழிபாட்டு முறைகள், 1=விரதங்கள், 2=நிவர்த்திகள்
  int _activeTab = 0;

  // Dropdowns
  String _selectedPoojaiVagai = 'தேர்வு செய்க';
  String _selectedDeity = 'தேர்வு செய்க';
  String _nithiyaMarrum = 'இல்லை';

  final PiraarthanaiApiRepository _apiRepository = PiraarthanaiApiRepository(
    ApiClient(),
  );
  bool _isLoading = false;
  int? _editingId;
  File? _selectedImage;
  String? _existingImageUrl;

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _vazhibaattuController = TextEditingController();
  final TextEditingController _virathamController = TextEditingController();
  final TextEditingController _nivarthiMuraiController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Search
  final TextEditingController _searchController = TextEditingController();

  final List<String> _poojaiVagaiList = [
    'தேர்வு செய்க',
    'வார சிறப்பு நாட்கள்',
    'வார சிறப்பு நிகழ்மைகள்',
    'யாதும் யாதும்',
  ];

  final List<String> _deityList = [
    'தேர்வு செய்க',
    'உடனூறை/ அம்பாள்',
    'தக்ஷிணாமூர்த்தி',
    'சண்டிகேஸ்வரர்',
    'கால பைரவர்',
    'நவ நாயகர்கள்',
    'மூலவர் மட்டும்',
  ];

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getKuraiNivarthi();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedImage = null;
      _existingImageUrl = null;
      _selectedPoojaiVagai = 'தேர்வு செய்க';
      _selectedDeity = 'தேர்வு செய்க';
      _nithiyaMarrum = 'இல்லை';
      _titleController.clear();
      _vazhibaattuController.clear();
      _virathamController.clear();
      _nivarthiMuraiController.clear();
      _notesController.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vazhibaattuController.dispose();
    _virathamController.dispose();
    _nivarthiMuraiController.dispose();
    _notesController.dispose();
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
          _buildFormCard(),
          const SizedBox(height: 28),
          _buildListCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.radio_button_checked,
                color: Colors.blue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'குறை நிவர்த்தி (Remedies)',
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
          'பக்தர்களின் குறைகளை போக்கும் வழிபாட்டு முறைகள் மற்றும் நிவர்த்திகளை நிர்வகிக்கலாம்.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab buttons
          _buildTabRow(),
          const SizedBox(height: 24),

          // Row 1: Poojai Vagai | Deity | Nithiya Marrum
          _threeRow(
            _dropdown(
              'பூஜை வகை',
              _selectedPoojaiVagai,
              _poojaiVagaiList,
              Icons.auto_fix_high_outlined,
              (v) => setState(() => _selectedPoojaiVagai = v!),
            ),
            _dropdown(
              'தெய்வங்கள்',
              _selectedDeity,
              _deityList,
              Icons.person_outline,
              (v) => setState(() => _selectedDeity = v!),
            ),
            _radioGroup(),
          ),
          const SizedBox(height: 16),

          // Row 2: Full-width title
          _fullWidthField(),
          const SizedBox(height: 16),

          // Row 3: Vazhibaattu | Viratham | Niverthi Murai
          _threeRow(
            _textField(
              'வழிபாட்டு முறை',
              '',
              _vazhibaattuController,
              Icons.auto_fix_high_outlined,
            ),
            _textField(
              'விரதம்',
              '',
              _virathamController,
              Icons.favorite_border,
            ),
            _textField(
              'நிவர்த்தி முறை',
              '',
              _nivarthiMuraiController,
              Icons.radio_button_off,
            ),
          ),
          const SizedBox(height: 16),

          // Row 4: Notes (left 50%) | Photo (right 50%)
          _twoRow(
            _textField(
              'விளக்கம் / குறிப்புகள்',
              '',
              _notesController,
              Icons.description_outlined,
            ),
            _uploadField('நிவர்த்தி புகைப்படம்'),
          ),
          const SizedBox(height: 32),

          // Buttons
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 14,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _clearForm,
                icon: Icon(
                  Icons.radio_button_off,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                label: Text(
                  'Clear',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('தலைப்பை உள்ளிடவும்!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        setState(() => _isLoading = true);

                        final data = {
                          'temple_id': 1,
                          'pooja_type': _selectedPoojaiVagai == 'தேர்வு செய்க'
                              ? ''
                              : _selectedPoojaiVagai,
                          'ritual_change': _nithiyaMarrum == 'உண்டு'
                              ? 'change'
                              : 'இல்லை',
                          'deity_selection': 'all',
                          'deity_name': _selectedDeity == 'தேர்வு செய்க'
                              ? ''
                              : _selectedDeity,
                          'title': _titleController.text.trim(),
                          'worship_method': _vazhibaattuController.text.trim(),
                          'vratham': _virathamController.text.trim(),
                          'nivarthi': _nivarthiMuraiController.text.trim(),
                          'description': _notesController.text.trim(),
                          'sub_category': 'worship',
                          'status': 'active',
                        };

                        bool success;
                        if (_editingId != null) {
                          success = await _apiRepository.updateKuraiNivarthi(
                            _editingId!,
                            data,
                            imageFile: _selectedImage,
                          );
                        } else {
                          success = await _apiRepository.addKuraiNivarthi(
                            data,
                            imageFile: _selectedImage,
                          );
                        }

                        setState(() => _isLoading = false);

                        if (success) {
                          _clearForm();
                          _loadRecords();
                          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(
                  _isLoading
                      ? 'Saving...'
                      : (_editingId != null ? 'Update' : 'Save'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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
    );
  }

  Widget _buildListCard() {
    final q = _searchController.text.toLowerCase();
    final filtered = _records.where((r) {
      return q.isEmpty ||
          (r['title']?.toString().toLowerCase().contains(q) ?? false) ||
          (r['worship_method']?.toString().toLowerCase().contains(q) ?? false);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.grey.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'நிவர்த்தி முறைகள் பட்டியல்',
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
                width: 180,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'தேடு...',
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
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.grey.shade200),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columnSpacing: 24,
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
                      'வகையீடு & தலைப்பு',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'வழிபாட்டு முறை',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'நிலை',
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
                rows: filtered
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              r['id']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 250,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child:
                                        r['image_path'] != null &&
                                            r['image_path']
                                                .toString()
                                                .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: Image.network(
                                              'https://temple.jobes24x7.com/storage/${r['image_path']}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Icon(
                                                Icons.image_outlined,
                                                size: 16,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.image_outlined,
                                            size: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          r['title']?.toString() ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          r['pooja_type']?.toString() ?? '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              r['worship_method']?.toString() ?? '',
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
                                r['status']?.toString() ?? 'active',
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
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.grey.shade600,
                                      size: 15,
                                    ),
                                    onPressed: () {
                                      _scrollController.jumpTo(0);
                                      setState(() {
                                        _editingId = r['id'];
                                        _titleController.text =
                                            r['title']?.toString() ?? '';
                                        _vazhibaattuController.text =
                                            r['worship_method']?.toString() ??
                                            '';
                                        _virathamController.text =
                                            r['vratham']?.toString() ?? '';
                                        _nivarthiMuraiController.text =
                                            r['nivarthi']?.toString() ?? '';
                                        _notesController.text =
                                            r['description']?.toString() ?? '';

                                        String pType =
                                            r['pooja_type']?.toString() ?? '';
                                        _selectedPoojaiVagai =
                                            _poojaiVagaiList.contains(pType)
                                            ? pType
                                            : 'தேர்வு செய்க';

                                        String deity =
                                            r['deity_name']?.toString() ?? '';
                                        _selectedDeity =
                                            _deityList.contains(deity)
                                            ? deity
                                            : 'தேர்வு செய்க';

                                        String ritChange =
                                            r['ritual_change']?.toString() ??
                                            '';
                                        _nithiyaMarrum =
                                            ritChange == 'change' ||
                                                ritChange == 'உண்டு'
                                            ? 'உண்டு'
                                            : 'இல்லை';

                                        _selectedImage = null;
                                        _existingImageUrl = r['image_path']
                                            ?.toString();
                                      });
                                    },
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 15,
                                    ),
                                    onPressed: () async {
                                      final confirm =
                                          await CustomDeleteDialog.showConfirmation(
                                            context,
                                          );
                                      if (confirm == true) {
                                        setState(() => _isLoading = true);
                                        bool success = await _apiRepository
                                            .deleteKuraiNivarthi(r['id']);
                                        if (success) {
                                          _loadRecords();
                                          CustomDeleteDialog.showSuccess(
                                            context,
                                          );
                                        } else {
                                          setState(() => _isLoading = false);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to delete record',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab row ────────────────────────────────────────────────────────────
  Widget _buildTabRow() {
    final tabs = [
      (Icons.bolt, 'வழிபாட்டு முறைகள்'),
      (Icons.favorite_border, 'விரதங்கள்'),
      (Icons.check_circle_outline, 'நிவர்த்திகள்'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tabs.asMap().entries.map((e) {
        final idx = e.key;
        final tab = e.value;
        final isActive = _activeTab == idx;
        return InkWell(
          onTap: () => setState(() => _activeTab = idx),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF3B82F6)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.$1,
                  size: 15,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  tab.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Radio group for நித்திய பூஜை மாற்றும் ────────────────────────────
  Widget _radioGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'நித்திய பூஜை மாற்றும்',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<String>(
              value: 'உண்டு',
              groupValue: _nithiyaMarrum,
              onChanged: (v) => setState(() => _nithiyaMarrum = v!),
              activeColor: const Color(0xFF3B82F6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Text(
              'உண்டு',
              style: TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
            const SizedBox(width: 12),
            Radio<String>(
              value: 'இல்லை',
              groupValue: _nithiyaMarrum,
              onChanged: (v) => setState(() => _nithiyaMarrum = v!),
              activeColor: const Color(0xFF3B82F6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Text(
              'இல்லை',
              style: TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Full-width title field ──────────────────────────────────────────────
  Widget _fullWidthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'நிவர்த்தி தலைப்பு *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.radio_button_off,
              size: 15,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
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
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────
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

  Widget _threeRow(Widget a, Widget b, Widget c) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 750)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            a,
            const SizedBox(height: 14),
            b,
            const SizedBox(height: 14),
            c,
          ],
        );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 14),
          Expanded(child: b),
          const SizedBox(width: 14),
          Expanded(child: c),
        ],
      );
    },
  );

  Widget _twoRow(Widget a, Widget b) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 600)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [a, const SizedBox(height: 14), b],
        );
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

  Widget _textField(
    String label,
    String hint,
    TextEditingController ctrl,
    IconData icon,
  ) => Column(
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
      TextField(controller: ctrl, decoration: _inputDecoration(hint, icon)),
    ],
  );

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) => Column(
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

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        prefixIcon: Icon(icon, size: 15, color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        filled: true,
        fillColor: Colors.white,
      );

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _existingImageUrl = null;
      });
    }
  }

  Widget _uploadField(String label) => Column(
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
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://temple.jobes24x7.com/storage/$_existingImageUrl',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Image Error / Change',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'பதிவேற்றவும்',
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
  );
}
