import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../data/nirvagam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class PorulAtharaContent extends StatefulWidget {
  const PorulAtharaContent({super.key});

  @override
  State<PorulAtharaContent> createState() => _PorulAtharaContentState();
}

class _PorulAtharaContentState extends State<PorulAtharaContent> {
  final ScrollController _scrollController = ScrollController();
  final _paktharCtrl = TextEditingController();
  final _porulCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  // Items chips list
  final List<String> _currentItems = [];

  bool _isLoading = false;
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
    final data = await _apiRepository.getPorulatar();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (_paktharCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('பக்தர் பெயர் உள்ளிடவும்!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'temple_id': 1,
      'devotee_name': _paktharCtrl.text.trim(),
      'items': _currentItems,
      'amount': _valueCtrl.text.trim().isEmpty ? '0' : _valueCtrl.text.trim(),
      'date': _dateCtrl.text.trim(),
      'status': 'active',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updatePorulatar(_editingId!, data);
    } else {
      success = await _apiRepository.addPorulatar(data);
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
    final success = await _apiRepository.deletePorulatar(id);
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
      _paktharCtrl.text = r['devotee_name']?.toString() ?? '';
      _valueCtrl.text = r['amount']?.toString() ?? '';

      final dt = r['date']?.toString();
      if (dt != null && dt.isNotEmpty) {
        _dateCtrl.text = dt.split('T')[0];
      } else {
        _dateCtrl.text = '';
      }

      _currentItems.clear();
      if (r['items'] is List) {
        for (var i in (r['items'] as List)) {
          if (i != null && i.toString().isNotEmpty) {
            _currentItems.add(i.toString());
          }
        }
      } else if (r['item_name'] != null &&
          r['item_name'].toString().isNotEmpty) {
        _currentItems.addAll(
          r['item_name'].toString().split(',').map((e) => e.trim()),
        );
      }
    });
  }

  void _clearForm() => setState(() {
    _paktharCtrl.clear();
    _porulCtrl.clear();
    _valueCtrl.clear();
    _dateCtrl.clear();
    _currentItems.clear();
    _editingId = null;
  });

  void _addItem() {
    final val = _porulCtrl.text.trim();
    if (val.isNotEmpty && !_currentItems.contains(val)) {
      setState(() {
        _currentItems.add(val);
        _porulCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    _paktharCtrl.dispose();
    _porulCtrl.dispose();
    _valueCtrl.dispose();
    _dateCtrl.dispose();
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
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.link, color: Colors.teal.shade600, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'பொருளாதார் பங்களிப்பு (Economy)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              'பொருள்கள், நிதி பங்களிப்புகள் மற்றும் மற்ற உபயங்களை நிர்வகிக்கவும்.',
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
        // Single responsive row: Pakthar | Porul+btn | Value | Date
        LayoutBuilder(
          builder: (ctx, bc) {
            final isWide = bc.maxWidth > 700;
            final fields = [
              _textField(
                'பக்தர் பெயர் *',
                '',
                _paktharCtrl,
                Icons.person_outline,
              ),
              _porulField(),
              _textField(
                'மதிப்பு (₹)',
                '',
                _valueCtrl,
                Icons.currency_rupee_outlined,
              ),
              _dateField('தேதி', _dateCtrl),
            ];
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 12),
                      Expanded(child: fields[1]),
                      const SizedBox(width: 12),
                      Expanded(child: fields[2]),
                      const SizedBox(width: 12),
                      Expanded(child: fields[3]),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fields[0],
                      const SizedBox(height: 14),
                      fields[1],
                      const SizedBox(height: 14),
                      fields[2],
                      const SizedBox(height: 14),
                      fields[3],
                    ],
                  );
          },
        ),

        // Chips for added items
        if (_currentItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ..._currentItems.map(
                (item) => Chip(
                  label: Text(item, style: const TextStyle(fontSize: 11)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _currentItems.remove(item)),
                  backgroundColor: Colors.teal.shade50,
                  side: BorderSide(color: Colors.teal.shade200),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
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

  // Porul field with + button
  Widget _porulField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('பொருள் / வகை *'),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _porulCtrl,
              decoration: _inputDeco('எ.கா. தேங்கா', Icons.redeem_outlined),
              onSubmitted: (_) => _addItem(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addItem,
            child: Container(
              width: 40,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EE1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    ],
  );

  // ── List Card ─────────────────────────────────────────────────────────────────
  Widget _listCard() {
    final q = _searchCtrl.text.toLowerCase();
    final filtered = _records
        .where(
          (r) =>
              q.isEmpty ||
              (r['devotee_name']?.toString() ?? '').toLowerCase().contains(q),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _listHeader('பங்களிப்பு விவரங்கள் (Records)', _searchCtrl),
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
                dataRowMinHeight: 56,
                dataRowMaxHeight: 76,
                columns: const [
                  DataColumn(label: Text('#', style: _hStyle)),
                  DataColumn(label: Text('பக்தர்\nபெயர்', style: _hStyle)),
                  DataColumn(label: Text('பொருள் / வகை', style: _hStyle)),
                  DataColumn(label: Text('மதிப்பு (₹)', style: _hStyle)),
                  DataColumn(label: Text('தேதி', style: _hStyle)),
                  DataColumn(label: Text('ACTIONS', style: _hStyle)),
                ],
                rows: filtered.asMap().entries.map((e) {
                  final idx = e.key;
                  final r = e.value;
                  final items =
                      (r['items'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [];
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
                              r['devotee_name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: items
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.teal.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.redeem_outlined,
                                        size: 11,
                                        color: Colors.teal.shade600,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      DataCell(
                        Text(
                          '₹${r['amount']?.toString() ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['date']?.toString().split('T')[0] ?? '',
                          style: const TextStyle(fontSize: 12),
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

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF374151),
    ),
  );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
    prefixIcon: Icon(icon, size: 14, color: Colors.grey.shade400),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        decoration: InputDecoration(
          hintText: 'dd-mm-yyyy',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            size: 14,
            color: Colors.grey.shade400,
          ),
          suffixIcon: Icon(
            Icons.edit_calendar_outlined,
            size: 14,
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
