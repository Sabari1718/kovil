import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../poojai/data/poojai_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class ThiruvizhaContent extends StatefulWidget {
  const ThiruvizhaContent({super.key});

  @override
  State<ThiruvizhaContent> createState() => _ThiruvizhaContentState();
}

class _ThiruvizhaContentState extends State<ThiruvizhaContent> {
  final ScrollController _scrollController = ScrollController();
  // Controllers
  final TextEditingController _pookaiPeyarController = TextEditingController();
  final TextEditingController _englishDateController = TextEditingController();
  final TextEditingController _tamilDateController = TextEditingController();
  final TextEditingController _thalapuController = TextEditingController();
  final TextEditingController _pookaiNeramController = TextEditingController();
  final TextEditingController _theebaNeramController = TextEditingController();
  final TextEditingController _vilakamController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Dropdowns
  String? _selectedKilamai;
  String? _selectedPookaiPorutkal;
  String? _selectedSirappu;

  final PoojaiApiRepository _apiRepository = PoojaiApiRepository(ApiClient());
  bool _isLoading = false;
  int? _editingId;
  File? _selectedImage;
  String? _existingImageUrl;

  final List<String> _kilamaiList = [
    'திங்கள்',
    'செவ்வாய்',
    'புதன்',
    'வியாழன்',
    'வெள்ளி',
    'சனி',
    'ஞாயிறு',
  ];

  final List<String> _pookaiPorutkalList = [
    'பூ',
    'தூபம்',
    'தீபம்',
    'நைவேத்தியம்',
    'கற்பூரம்',
  ];

  final List<String> _sirappuList = [
    'சாதாரண பூஜை',
    'சிறப்பு அபிஷேகம்',
    'விழா பூஜை',
  ];

  // Records
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchPoojais();
  }

  Future<void> _fetchPoojais() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getThodarPoojais();
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
      _pookaiPeyarController.clear();
      _englishDateController.clear();
      _tamilDateController.clear();
      _thalapuController.clear();
      _pookaiNeramController.clear();
      _theebaNeramController.clear();
      _vilakamController.clear();
      _selectedKilamai = null;
      _selectedPookaiPorutkal = null;
      _selectedSirappu = null;
    });
  }

  @override
  void dispose() {
    _pookaiPeyarController.dispose();
    _englishDateController.dispose();
    _tamilDateController.dispose();
    _thalapuController.dispose();
    _pookaiNeramController.dispose();
    _theebaNeramController.dispose();
    _vilakamController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildListCard(),
            ],
          ),
        ),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.celebration_outlined,
              color: Colors.purple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'தொடர் பூஜை (திருவிழாக்கள்)',
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
        'கோவிலின் விசேஷ திருவிழாக்கள் மற்றும் தொடர் பூஜைகளை நிர்வகிக்கவும்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  // ─── Form Card ───────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: பூஜை பெயர் | ஆங்கில தேதி | தமிழ் தேதி
          _threeRow(
            _textField(
              'பூஜை பெயர் *',
              '',
              _pookaiPeyarController,
              Icons.auto_awesome_outlined,
            ),
            _dateField('ஆங்கில தேதி *', _englishDateController),
            _dateField('தமிழ் தேதி', _tamilDateController),
          ),
          const SizedBox(height: 16),

          // Row 2: கிழமை | தலைப்பு | பூஜை நேரம்
          _threeRow(
            _dropdownField(
              label: 'கிழமை *',
              hint: 'கேர்வ செய்க...',
              icon: Icons.calendar_today_outlined,
              value: _selectedKilamai,
              items: _kilamaiList,
              onChanged: (v) => setState(() => _selectedKilamai = v),
            ),
            _textField('தலைப்பு', '', _thalapuController, Icons.title_outlined),
            _timeField('பூஜை நேரம்', _pookaiNeramController),
          ),
          const SizedBox(height: 16),

          // Row 3: திபாராதனை நேரம் | பூஜை பொருட்கள் | சிறப்பு பூஜை
          _threeRow(
            _timeField('திபாராதனை நேரம்', _theebaNeramController),
            _dropdownField(
              label: 'பூஜை பொருட்கள்',
              hint: 'கேர்வ செய்க...',
              icon: Icons.format_list_bulleted,
              value: _selectedPookaiPorutkal,
              items: _pookaiPorutkalList,
              onChanged: (v) => setState(() => _selectedPookaiPorutkal = v),
            ),
            _dropdownField(
              label: 'சிறப்பு பூஜை',
              hint: 'கேர்வ செய்க...',
              icon: Icons.auto_awesome,
              value: _selectedSirappu,
              items: _sirappuList,
              onChanged: (v) => setState(() => _selectedSirappu = v),
            ),
          ),
          const SizedBox(height: 16),

          // Row 4: விளக்கம் | புகைப்படம்
          _twoRow(
            _multilineField(
              'விளக்கம் / குறிப்புகள்',
              'கூடுதல் தகவல்கள்...',
              _vilakamController,
            ),
            _uploadField('புகைப்படம்'),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _clearForm,
                icon: Icon(
                  Icons.clear_all,
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
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_pookaiPeyarController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('பூஜை பெயர் உள்ளிடவும்!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        final data = {
                          'pooja_name': _pookaiPeyarController.text.trim(),
                          'end_date': _englishDateController.text,
                          'tamil_date': _tamilDateController.text,
                          'day': _selectedKilamai ?? '',
                          'title': _thalapuController.text.trim(),
                          'description': _vilakamController.text,
                          'pooja_time': _pookaiNeramController.text,
                          'deeparathanai_time': _theebaNeramController.text,
                          'items': _selectedPookaiPorutkal ?? '',
                          'special_name': _selectedSirappu ?? '',
                          'special_description': '',
                          'status': 'செயல்பாட்டில்',
                          'temple_id': 1,
                        };

                        bool success;
                        if (_editingId != null) {
                          success = await _apiRepository.updateThodarPoojai(
                            _editingId!,
                            data,
                            imageFile: _selectedImage,
                          );
                        } else {
                          success = await _apiRepository.addThodarPoojai(
                            data,
                            imageFile: _selectedImage,
                          );
                        }

                        setState(() => _isLoading = false);

                        if (success) {
                          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
                          _clearForm();
                          _fetchPoojais();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save record'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(_editingId == null ? 'Save' : 'Update'),
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
    );
  }

  // ─── List Card ───────────────────────────────────────────────────────────────
  Widget _buildListCard() {
    final q = _searchController.text.toLowerCase();
    final filtered = _records.where((r) {
      final name = r['pooja_name']?.toString().toLowerCase() ?? '';
      final kilamai = r['day']?.toString().toLowerCase() ?? '';
      return q.isEmpty || name.contains(q) || kilamai.contains(q);
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
                    Icon(
                      Icons.format_list_bulleted,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'திருவிழாக்கள் பட்டியல்',
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
                    hintText: 'தேடல்...',
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
                      'திருவிழா & தலைப்பு',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'தேதி & நேரம்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'கிழமை',
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
                      DataCell(
                        Text(
                          r['id']?.toString() ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  r['pooja_name']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B4EE1),
                                  ),
                                ),
                                if (r['title'] != null &&
                                    r['title'].toString().isNotEmpty)
                                  Text(
                                    r['title'].toString(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              r['end_date']?.toString().split('T').first ?? '-',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              r['pooja_time']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          r['day']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B4EE1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
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
                                    _editingId = int.tryParse(
                                      r['id']?.toString() ?? '',
                                    );
                                    _pookaiPeyarController.text =
                                        r['pooja_name']?.toString() ?? '';
                                    _thalapuController.text =
                                        r['title']?.toString() ?? '';
                                    _vilakamController.text =
                                        r['description']?.toString() ?? '';
                                    _pookaiNeramController.text =
                                        r['pooja_time']?.toString() ?? '';
                                    _theebaNeramController.text =
                                        r['deeparathanai_time']?.toString() ??
                                        '';
                                    _englishDateController.text =
                                        r['end_date']
                                            ?.toString()
                                            .split('T')
                                            .first ??
                                        '';
                                    _tamilDateController.text =
                                        r['tamil_date']
                                            ?.toString()
                                            .split('T')
                                            .first ??
                                        '';
                                    String kilamai = r['day']?.toString() ?? '';
                                    _selectedKilamai =
                                        _kilamaiList.contains(kilamai)
                                        ? kilamai
                                        : null;
                                    String items = r['items']?.toString() ?? '';
                                    _selectedPookaiPorutkal =
                                        _pookaiPorutkalList.contains(items)
                                        ? items
                                        : null;
                                    String special =
                                        r['special_name']?.toString() ?? '';
                                    _selectedSirappu =
                                        _sirappuList.contains(special)
                                        ? special
                                        : null;
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
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                  size: 15,
                                ),
                                onPressed: () async {
                                  final id = int.tryParse(
                                    r['id']?.toString() ?? '',
                                  );
                                  if (id != null) {
                                    final confirm =
                                        await CustomDeleteDialog.showConfirmation(
                                          context,
                                        );
                                    if (confirm) {
                                      setState(() => _isLoading = true);
                                      final success = await _apiRepository
                                          .deleteThodarPoojai(id);
                                      setState(() => _isLoading = false);
                                      if (success) {
                                        await CustomDeleteDialog.showSuccess(
                                          context,
                                        );
                                        _fetchPoojais();
                                      } else {
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
      if (bc.maxWidth < 750) {
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
      }
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
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
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
            borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ],
  );

  Widget _dateField(String label, TextEditingController ctrl) => Column(
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
      TextField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'dd-mm-yyyy',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            size: 15,
            color: Colors.grey.shade400,
          ),
          suffixIcon: Icon(
            Icons.edit_calendar_outlined,
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
            borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            ctrl.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    ],
  );

  Widget _timeField(String label, TextEditingController ctrl) => Column(
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
      TextField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          hintText: '--:--',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Icon(
            Icons.access_time_outlined,
            size: 15,
            color: Colors.grey.shade400,
          ),
          suffixIcon: Icon(
            Icons.schedule,
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
            borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            ctrl.text =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
          }
        },
      ),
    ],
  );

  Widget _multilineField(
    String label,
    String hint,
    TextEditingController ctrl,
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
      TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Icon(
              Icons.description_outlined,
              size: 15,
              color: Colors.grey.shade400,
            ),
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
            borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ],
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
