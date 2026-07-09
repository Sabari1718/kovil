import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/nirvagam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class AraNilayatThuraiContent extends StatefulWidget {
  const AraNilayatThuraiContent({super.key});

  @override
  State<AraNilayatThuraiContent> createState() =>
      _AraNilayatThuraiContentState();
}

class _AraNilayatThuraiContentState extends State<AraNilayatThuraiContent> {
  final ScrollController _scrollController = ScrollController();
  final _memberNameCtrl = TextEditingController();
  final _yagasalaiCtrl = TextEditingController();
  final _pookaiPeyarCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _selectedKilamai;
  String? _selectedNilai;

  final List<String> _kilamaiList = [
    'திங்கள்',
    'செவ்வாய்',
    'புதன்',
    'வியாழன்',
    'வெள்ளி',
    'சனி',
    'ஞாயிறு',
  ];
  final List<String> _nilaiList = ['Open', 'Closed', 'Pending'];

  bool _isLoading = false;
  File? _selectedImage;
  int? _editingId;
  late final NirvagamApiRepository _apiRepository;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _apiRepository = NirvagamApiRepository(ApiClient());
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getAranilaiyatturai();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveData() async {
    if (_memberNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('உறுப்பினர் பெயர் உள்ளிடவும்!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'temple_id': '1',
      'general_member': _memberNameCtrl.text.trim(),
      'yagasalai_pooja': _yagasalaiCtrl.text.trim(),
      'pooja_name': _pookaiPeyarCtrl.text.trim(),
      'day': _selectedKilamai ?? '',
      'date': _dateCtrl.text.trim(),
      'time': _timeCtrl.text.trim(),
      'status': _selectedNilai?.toLowerCase() ?? 'open',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateAranilaiyatturai(
        _editingId!,
        data,
        imageFile: _selectedImage,
      );
    } else {
      success = await _apiRepository.addAranilaiyatturai(
        data,
        imageFile: _selectedImage,
      );
    }

    if (success) {
      _clearForm();
      await _fetchData();
      CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteData(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (!confirm) return;

    setState(() => _isLoading = true);
    final success = await _apiRepository.deleteAranilaiyatturai(id);
    if (success) {
      await _fetchData();
      if (mounted) {
        await CustomDeleteDialog.showDeleted(context);
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editData(Map<String, dynamic> r) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    setState(() {
      _editingId = int.tryParse(r['id']?.toString() ?? '');
      _memberNameCtrl.text = r['general_member']?.toString() ?? '';
      _yagasalaiCtrl.text = r['yagasalai_pooja']?.toString() ?? '';
      _pookaiPeyarCtrl.text = r['pooja_name']?.toString() ?? '';

      final dt = r['date']?.toString();
      if (dt != null && dt.isNotEmpty) {
        _dateCtrl.text = dt.split('T')[0];
      } else {
        _dateCtrl.text = '';
      }

      _timeCtrl.text = r['time']?.toString() ?? '';

      final kilamai = r['day']?.toString();
      _selectedKilamai = _kilamaiList.contains(kilamai) ? kilamai : null;

      final stat = r['status']?.toString().toLowerCase();
      _selectedNilai = stat == 'closed'
          ? 'Closed'
          : (stat == 'pending' ? 'Pending' : 'Open');

      _selectedImage = null;
    });
  }

  void _clearForm() => setState(() {
    _memberNameCtrl.clear();
    _yagasalaiCtrl.clear();
    _pookaiPeyarCtrl.clear();
    _dateCtrl.clear();
    _timeCtrl.clear();
    _selectedKilamai = null;
    _selectedNilai = null;
    _selectedImage = null;
    _editingId = null;
  });

  @override
  void dispose() {
    _memberNameCtrl.dispose();
    _yagasalaiCtrl.dispose();
    _pookaiPeyarCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _searchCtrl.dispose();
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
          _header(),
          const SizedBox(height: 24),
          _formCard(),
          const SizedBox(height: 24),
          _listCard(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _header() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.account_balance_outlined,
          color: Colors.indigo.shade600,
          size: 22,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'அறநிலையத்துறை (Religious Endowments)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              'வாரிய உறுப்பினர்கள் மற்றும் யாகசாலை பூஜை விவரங்களை நிர்வகிக்கவும்.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );

  // ── Form Card ─────────────────────────────────────────────────────────────────
  Widget _formCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecor(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1 – குழு விவரங்கள்
        _sectionLabel('குழு விவரங்கள்', Colors.indigo.shade600),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (ctx, bc) {
            final isWide = bc.maxWidth > 560;
            final nameField = _textField(
              'உறுப்பினர் பெயர்',
              '',
              _memberNameCtrl,
              Icons.person_outline,
            );
            final docField = _uploadField('ஆவணம் / புகைப்படம்');
            return isWide
                ? Row(
                    children: [
                      Expanded(child: nameField),
                      const SizedBox(width: 16),
                      Expanded(child: docField),
                    ],
                  )
                : Column(
                    children: [nameField, const SizedBox(height: 14), docField],
                  );
          },
        ),
        const SizedBox(height: 20),

        // Section 2 – பூஜை விவரங்கள்
        _sectionLabel('பூஜை விவரங்கள்', Colors.indigo.shade600),
        const SizedBox(height: 12),
        // Row 1
        _threeCol(
          _textField(
            'யாகசாலை பூஜை',
            '',
            _yagasalaiCtrl,
            Icons.article_outlined,
          ),
          _textField(
            'பூஜை பெயர்',
            '',
            _pookaiPeyarCtrl,
            Icons.auto_awesome_outlined,
          ),
          _dropdown(
            'கிழமை',
            'தேர்வு செய்க...',
            Icons.calendar_today_outlined,
            _selectedKilamai,
            _kilamaiList,
            (v) => setState(() => _selectedKilamai = v),
          ),
        ),
        const SizedBox(height: 14),
        // Row 2
        _threeCol(
          _dateField('தேதி', _dateCtrl),
          _timeField('நேரம்', _timeCtrl),
          _dropdown(
            'நிலை',
            'Open',
            Icons.toggle_on_outlined,
            _selectedNilai,
            _nilaiList,
            (v) => setState(() => _selectedNilai = v),
          ),
        ),
        const SizedBox(height: 24),
        // Buttons
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 10,
          children: [
            _clearBtn(_clearForm),
            _saveBtn(
              _isLoading
                  ? 'Saving...'
                  : (_editingId != null ? 'Update' : 'Save'),
              _isLoading ? () {} : _saveData,
            ),
          ],
        ),
      ],
    ),
  );

  // ── List Card ─────────────────────────────────────────────────────────────────
  Widget _listCard() {
    final q = _searchCtrl.text.toLowerCase();
    final filtered = _records
        .where(
          (r) =>
              q.isEmpty ||
              (r['general_member']?.toString() ?? '').toLowerCase().contains(
                q,
              ) ||
              (r['yagasalai_pooja']?.toString() ?? '').toLowerCase().contains(
                q,
              ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _listHeader('பதிவுகள் (Records)', _searchCtrl),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.grey.shade200),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columnSpacing: 16,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80,
                columns: const [
                  DataColumn(label: Text('#', style: _hStyle)),
                  DataColumn(
                    label: Text('குழு உறுப்பினர் &\nஆவணம்', style: _hStyle),
                  ),
                  DataColumn(label: Text('யாகசாலை &\nபூஜை', style: _hStyle)),
                  DataColumn(label: Text('கிழமை &\nதேதி', style: _hStyle)),
                  DataColumn(label: Text('நேரம்', style: _hStyle)),
                  DataColumn(label: Text('நிலை', style: _hStyle)),
                  DataColumn(label: Text('ACTIONS', style: _hStyle)),
                ],
                rows: filtered.asMap().entries.map((e) {
                  final idx = e.key;
                  final r = e.value;
                  final isOpen =
                      r['status']?.toString().toLowerCase() == 'open';
                  return DataRow(
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 13,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r['general_member']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (r['executive_member_file'] != null &&
                                r['executive_member_file']
                                    .toString()
                                    .isNotEmpty)
                              Text(
                                'ஆவணம் காண்க (View File)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  size: 13,
                                  color: Colors.orange.shade400,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    r['yagasalai_pooja']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              r['pooja_name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r['day']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              r['date']?.toString().split('T')[0] ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          r['time']?.toString() ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        _nilaiChip(r['status']?.toString() ?? '', isOpen),
                      ),
                      DataCell(_actionBtns(r)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          if (filtered.isEmpty) _emptyState(),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  static const _hStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: Color(0xFF1E1B4B),
  );

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

  Widget _sectionLabel(String label, Color color) => Text(
    label,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
  );

  Widget _threeCol(Widget a, Widget b, Widget c) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 700) {
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

  Widget _textField(
    String label,
    String hint,
    TextEditingController ctrl,
    IconData icon,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      TextField(controller: ctrl, decoration: _inputDeco(hint, icon)),
    ],
  );

  Widget _uploadField(String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    _selectedImage!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              const SizedBox(width: 8),
              Text(
                _selectedImage != null ? 'Image Selected' : 'பதிவேற்றவும்',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _dateField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        readOnly: true,
        decoration: _inputDeco(
          'dd-mm-yyyy',
          Icons.calendar_month_outlined,
          suffix: Icons.edit_calendar_outlined,
        ),
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (d != null) {
            ctrl.text =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    ],
  );

  Widget _timeField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        readOnly: true,
        decoration: _inputDeco(
          '--:--',
          Icons.access_time_outlined,
          suffix: Icons.schedule,
        ),
        onTap: () async {
          final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (t != null) {
            ctrl.text =
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
          }
        },
      ),
    ],
  );

  Widget _dropdown(
    String label,
    String hint,
    IconData icon,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
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
            Icon(icon, size: 14, color: Colors.grey.shade400),
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
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
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

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF374151),
    ),
  );

  InputDecoration _inputDeco(String hint, IconData icon, {IconData? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        prefixIcon: Icon(icon, size: 14, color: Colors.grey.shade400),
        suffixIcon: suffix != null
            ? Icon(suffix, size: 14, color: Colors.grey.shade400)
            : null,
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
      );

  Widget _listHeader(String title, TextEditingController ctrl) => Wrap(
    spacing: 12,
    runSpacing: 8,
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_list_bulleted,
            color: Colors.grey.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
      SizedBox(
        width: 180,
        child: TextField(
          controller: ctrl,
          onChanged: (_) => setState(() {}),
          decoration: _inputDeco('தேடல்...', Icons.search),
        ),
      ),
    ],
  );

  Widget _nilaiChip(String nilai, bool isOpen) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      nilai,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
      ),
    ),
  );

  Widget _actionBtns(Map<String, dynamic> r) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _iconBtn(
        Icons.edit_outlined,
        Colors.grey.shade300,
        Colors.grey.shade600,
        () => _editData(r),
      ),
      const SizedBox(width: 6),
      _iconBtn(
        Icons.delete_outline,
        Colors.red.shade200,
        Colors.red.shade400,
        () => _deleteData(int.tryParse(r['id']?.toString() ?? '0') ?? 0),
        bg: Colors.red.shade50,
      ),
    ],
  );

  Widget _iconBtn(
    IconData icon,
    Color border,
    Color iconColor,
    VoidCallback cb, {
    Color? bg,
  }) => Container(
    decoration: BoxDecoration(
      color: bg ?? Colors.white,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: IconButton(
      icon: Icon(icon, color: iconColor, size: 15),
      onPressed: cb,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    ),
  );

  Widget _clearBtn(VoidCallback cb) => OutlinedButton.icon(
    onPressed: cb,
    icon: Icon(Icons.clear_all, size: 15, color: Colors.grey.shade700),
    label: Text('Clear', style: TextStyle(color: Colors.grey.shade700)),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _saveBtn(String label, VoidCallback cb) => ElevatedButton.icon(
    onPressed: cb,
    icon: const Icon(Icons.save_outlined, size: 15),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6B4EE1),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'பதிவுகள் இல்லை',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
