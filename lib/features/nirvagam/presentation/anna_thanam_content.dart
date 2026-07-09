import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/nirvagam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class AnnaThanamContent extends StatefulWidget {
  const AnnaThanamContent({super.key});

  @override
  State<AnnaThanamContent> createState() => _AnnaThanamContentState();
}

class _AnnaThanamContentState extends State<AnnaThanamContent> {
  final ScrollController _scrollController = ScrollController();
  final _viseshamCtrl = TextEditingController();
  final _kuzhuvCtrl = TextEditingController();
  final _kattaliCtrl = TextEditingController();
  final _ennCtrl = TextEditingController();
  final _thogaiCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _balaCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  bool _isLoading = false;
  int? _editingId;
  late final NirvagamApiRepository _apiRepository;
  List<Map<String, dynamic>> _records = [];
  File? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _apiRepository = NirvagamApiRepository(ApiClient());
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getAnnatanam();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (_viseshamCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('விசேஷம் உள்ளிடவும்!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'temple_id': 1,
      'special_event': _viseshamCtrl.text.trim(),
      'annadhanam_group': _kuzhuvCtrl.text.trim(),
      'sponsor_name': _kattaliCtrl.text.trim(),
      'count': _ennCtrl.text.trim().isEmpty ? '0' : _ennCtrl.text.trim(),
      'amount': _thogaiCtrl.text.trim().isEmpty ? '0' : _thogaiCtrl.text.trim(),
      'date': _dateCtrl.text.trim(),
      'start_time': _startTimeCtrl.text.trim(),
      'end_time': _endTimeCtrl.text.trim(),
      'benefits': _balaCtrl.text.trim(),
      'status': 'active',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateAnnatanam(
        _editingId!,
        data,
        imageFile: _selectedImage,
      );
    } else {
      success = await _apiRepository.addAnnatanam(
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
    final success = await _apiRepository.deleteAnnatanam(id);
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
      _viseshamCtrl.text = r['special_event']?.toString() ?? '';
      _kuzhuvCtrl.text = r['annadhanam_group']?.toString() ?? '';
      _kattaliCtrl.text = r['sponsor_name']?.toString() ?? '';
      _ennCtrl.text = r['count']?.toString() ?? '';
      _thogaiCtrl.text = r['amount']?.toString() ?? '';
      _balaCtrl.text = r['benefits']?.toString() ?? '';

      final dt = r['date']?.toString();
      if (dt != null && dt.isNotEmpty) {
        _dateCtrl.text = dt.split('T')[0];
      } else {
        _dateCtrl.text = '';
      }

      _startTimeCtrl.text = r['start_time']?.toString() ?? '';
      _endTimeCtrl.text = r['end_time']?.toString() ?? '';

      if (r['image_path'] != null && r['image_path'].toString().isNotEmpty) {
        _existingImageUrl =
            'https://temple.jobes24x7.com/uploads/${r['image_path']}';
      } else {
        _existingImageUrl = null;
      }
      _selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _clearForm() => setState(() {
    _viseshamCtrl.clear();
    _kuzhuvCtrl.clear();
    _kattaliCtrl.clear();
    _ennCtrl.clear();
    _thogaiCtrl.clear();
    _dateCtrl.clear();
    _startTimeCtrl.clear();
    _endTimeCtrl.clear();
    _balaCtrl.clear();
    _selectedImage = null;
    _existingImageUrl = null;
    _editingId = null;
  });

  @override
  void dispose() {
    _viseshamCtrl.dispose();
    _kuzhuvCtrl.dispose();
    _kattaliCtrl.dispose();
    _ennCtrl.dispose();
    _thogaiCtrl.dispose();
    _dateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _balaCtrl.dispose();
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
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.restaurant_outlined,
          color: Colors.amber.shade700,
          size: 22,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'அன்ன தானம் (Annadhanam Service)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              'கோவிலின் உணவு சேவை மற்றும் கட்டளைதாரர்கள் விவரங்களை நிர்வகிக்கவும்.',
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
        // Row 1: விசேஷம் | அன்னதான குழு | கட்டலை தாரர்கள்
        _threeCol(
          _textField(
            'விசேஷம் *',
            '',
            _viseshamCtrl,
            Icons.celebration_outlined,
          ),
          _textField('அன்னதான குழு', '', _kuzhuvCtrl, Icons.people_outline),
          _textField(
            'கட்டலை தாரர்கள்',
            '',
            _kattaliCtrl,
            Icons.favorite_outline,
          ),
        ),
        const SizedBox(height: 14),

        // Row 2: எண்ணிக்கை | தொகை | தேதி
        _threeCol(
          _textField('எண்ணிக்கை', '', _ennCtrl, Icons.person_outline),
          _textField(
            'தொகை (₹)',
            '',
            _thogaiCtrl,
            Icons.currency_rupee_outlined,
          ),
          _dateField('தேதி *', _dateCtrl),
        ),
        const SizedBox(height: 14),

        // Row 3: ஆரம்ப நேரம் | இளுகி நேரம் | புகைப்படம்
        _threeCol(
          _timeField('ஆரம்ப நேரம்', _startTimeCtrl),
          _timeField('இளுகி நேரம்', _endTimeCtrl),
          _uploadField('புகைப்படம்'),
        ),
        const SizedBox(height: 14),

        // Row 4: பலன்கள் full width
        _label('பலன்கள் (Benefits)'),
        const SizedBox(height: 6),
        TextField(
          controller: _balaCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'பலன்கள்...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Icon(
                Icons.description_outlined,
                size: 14,
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
        const SizedBox(height: 20),

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
                  : (_editingId != null ? 'Update Service' : 'Save Service'),
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
              (r['special_event']?.toString() ?? '').toLowerCase().contains(
                q,
              ) ||
              (r['annadhanam_group']?.toString() ?? '').toLowerCase().contains(
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
          _listHeader('அன்னதான விவரங்கள் (Records)', _searchCtrl),
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
                  DataColumn(label: Text('விசேஷம் &\nகுழு', style: _hStyle)),
                  DataColumn(label: Text('கட்டலை\nதாரர்கள்', style: _hStyle)),
                  DataColumn(label: Text('எண்ணிக்கை', style: _hStyle)),
                  DataColumn(label: Text('மதிப்பு (₹)', style: _hStyle)),
                  DataColumn(label: Text('தேதி &\nநேரம்', style: _hStyle)),
                  DataColumn(label: Text('ACTIONS', style: _hStyle)),
                ],
                rows: filtered.asMap().entries.map((e) {
                  final idx = e.key;
                  final r = e.value;
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
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child:
                                      (r['image_path'] != null &&
                                          r['image_path'].toString().isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.network(
                                            'https://temple.jobes24x7.com/uploads/${r['image_path']}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Icon(
                                              Icons.image_outlined,
                                              size: 13,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.image_outlined,
                                          size: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    r['special_event']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if ((r['annadhanam_group']?.toString() ?? '')
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Text(
                                  r['annadhanam_group']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          r['sponsor_name']?.toString() ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['count']?.toString() ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          '₹${r['amount']?.toString() ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r['date']?.toString().split('T')[0] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              r['start_time']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
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
                              () => _deleteData(
                                int.tryParse(r['id']?.toString() ?? '0') ?? 0,
                              ),
                              bg: Colors.red.shade50,
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
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _existingImageUrl!,
                    width: double.infinity,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'பதிவேற்றவும்',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
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
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'பதிவேற்றவும்',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ],
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
              fontSize: 13,
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
