import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/paktharkal_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class NertthiKadanContent extends StatefulWidget {
  const NertthiKadanContent({super.key});

  @override
  State<NertthiKadanContent> createState() => _NertthiKadanContentState();
}

class _NertthiKadanContentState extends State<NertthiKadanContent> {
  final ScrollController _scrollController = ScrollController();
  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nertthiController = TextEditingController();
  final TextEditingController _kanikaiController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final PaktharkalApiRepository _apiRepository = PaktharkalApiRepository(
    ApiClient(),
  );
  bool _isLoading = false;
  int? _editingId;
  File? _selectedImage;
  String? _existingImageUrl;

  // Dropdowns — all poojai dropdowns: ஆம்/இல்லை
  String _thiruvilakku = 'இல்லை';
  String _poojaiKanakku = 'இல்லை';
  String _vaganaPoojai = 'இல்லை';
  String _chakkaraVaganam = 'இல்லை';
  String _nilai = 'Active';

  final List<String> _poojaOptions = ['தேர்வு செய்க...', 'ஆம்', 'இல்லை'];
  final List<String> _nilaiOptions = ['தேர்வு செய்க.', 'Active', 'Inactive'];

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getNerttiKatan();
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
      _nameController.clear();
      _nertthiController.clear();
      _kanikaiController.clear();
      _valueController.clear();
      final now = DateTime.now();
      _dateController.text =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      _thiruvilakku = 'இல்லை';
      _poojaiKanakku = 'இல்லை';
      _vaganaPoojai = 'இல்லை';
      _chakkaraVaganam = 'இல்லை';
      _nilai = 'Active';
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(
        () => _dateController.text =
            '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nertthiController.dispose();
    _kanikaiController.dispose();
    _valueController.dispose();
    _dateController.dispose();
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

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Colors.pink,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'நேர்த்தி கடன் (Vows & Offerings)',
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
        'பக்தர்களின் நேர்த்தி கடன் மற்றும் காணிக்கை விவரங்களை நிர்வகிக்கலாம்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name | Nerthi | Kanikkai
          _threeRow(
            _textField(
              'பக்தர் பெயர் *',
              '',
              _nameController,
              Icons.person_outline,
            ),
            _textField(
              'நேர்த்தி கடன்',
              '',
              _nertthiController,
              Icons.favorite_border,
            ),
            _textField(
              'காணிக்கை',
              '',
              _kanikaiController,
              Icons.redeem_outlined,
            ),
          ),
          const SizedBox(height: 16),

          // Row 2: Value | Date | Photo
          _threeRow(
            _textField(
              'மதிப்பு (₹)',
              '',
              _valueController,
              Icons.attach_money_outlined,
              TextInputType.number,
            ),
            _dateField(),
            _uploadField('புகைப்படம்'),
          ),
          const SizedBox(height: 16),

          // Row 3: Thiruvilakku | Poojai Kanakku | Vagana Poojai
          _threeRow(
            _poojaDropdown(
              'திருவிளக்கு பூஜை',
              _thiruvilakku,
              Icons.local_fire_department_outlined,
              (v) => setState(() => _thiruvilakku = v!),
            ),
            _poojaDropdown(
              'பூஜ கணக்கு பூஜை',
              _poojaiKanakku,
              Icons.description_outlined,
              (v) => setState(() => _poojaiKanakku = v!),
            ),
            _poojaDropdown(
              'வாகன பூஜை',
              _vaganaPoojai,
              Icons.directions_car_outlined,
              (v) => setState(() => _vaganaPoojai = v!),
            ),
          ),
          const SizedBox(height: 16),

          // Row 4: Chakkara Vaganam (left) | Nilai (right)
          _twoRow(
            _poojaDropdown(
              'சக்கர வாகனம் பூஜை',
              _chakkaraVaganam,
              Icons.rotate_right_outlined,
              (v) => setState(() => _chakkaraVaganam = v!),
            ),
            _nilaiDropdown(),
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
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('பக்தர் பெயரை உள்ளிடவும்!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        final amountText = _valueController.text.trim();
                        if (amountText.isNotEmpty &&
                            double.tryParse(amountText) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'மதிப்பு (₹) சரியாக உள்ளிடவும்! (Amount must be a number)',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        String apiDate = '';
                        if (_dateController.text.isNotEmpty) {
                          final parts = _dateController.text.split('-');
                          if (parts.length == 3)
                            apiDate = '${parts[2]}-${parts[1]}-${parts[0]}';
                        }

                        final data = {
                          'temple_id': 1,
                          'devotee_name': _nameController.text.trim(),
                          'nerthi': _nertthiController.text.trim(),
                          'offering': _kanikaiController.text.trim(),
                          'amount': amountText,
                          'date': apiDate,
                          'thiruvilakku_pooja': _thiruvilakku == 'ஆம்'
                              ? 'yes'
                              : 'no',
                          'new_account_pooja': _poojaiKanakku == 'ஆம்'
                              ? 'yes'
                              : 'no',
                          'vehicle_pooja': _vaganaPoojai == 'ஆம்'
                              ? 'yes'
                              : 'no',
                          'chakra_vehicle_pooja': _chakkaraVaganam == 'ஆம்'
                              ? 'yes'
                              : 'no',
                          'status': _nilai == 'Active' ? 'active' : 'inactive',
                        };

                        bool success;
                        if (_editingId != null) {
                          success = await _apiRepository.updateNerttiKatan(
                            _editingId!,
                            data,
                            imageFile: _selectedImage,
                          );
                        } else {
                          success = await _apiRepository.addNerttiKatan(
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
    final filtered = _records
        .where(
          (r) =>
              q.isEmpty ||
              (r['devotee_name']?.toString().toLowerCase().contains(q) ??
                  false) ||
              (r['nerthi']?.toString().toLowerCase().contains(q) ?? false),
        )
        .toList();

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
                        'நேர்த்தி கடன் பதிவுகள் (Records)',
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
                      'பக்தர் & நேர்த்தி',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'காணிக்கை',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'மதிப்பு (₹)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'தேதி',
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:
                                      r['image_path'] != null &&
                                          r['image_path'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.network(
                                            'https://temple.jobes24x7.com/storage/${r['image_path']}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Icon(
                                              Icons.person_outline,
                                              size: 16,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      r['devotee_name']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      r['nerthi']?.toString() ?? '',
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
                          DataCell(
                            Text(
                              r['offering']?.toString() ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text(
                              r['amount']?.toString() != null &&
                                      r['amount'].toString().isNotEmpty
                                  ? '₹${r['amount']}'
                                  : '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(() {
                              if (r['date'] == null ||
                                  r['date'].toString().isEmpty)
                                return '';
                              try {
                                final dt = DateTime.parse(r['date'].toString());
                                return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
                              } catch (_) {
                                return r['date'].toString();
                              }
                            }(), style: const TextStyle(fontSize: 12)),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (r['status']?.toString().toLowerCase() ==
                                        'active'
                                    ? Colors.green.shade50
                                    : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                r['status']?.toString() ?? 'active',
                                style: TextStyle(
                                  color:
                                      (r['status']?.toString().toLowerCase() ==
                                          'active'
                                      ? Colors.green
                                      : Colors.red),
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
                                        _nameController.text =
                                            r['devotee_name']?.toString() ?? '';
                                        _nertthiController.text =
                                            r['nerthi']?.toString() ?? '';
                                        _kanikaiController.text =
                                            r['offering']?.toString() ?? '';
                                        _valueController.text =
                                            r['amount']?.toString() ?? '';

                                        String dateVal =
                                            r['date']?.toString() ?? '';
                                        if (dateVal.isNotEmpty) {
                                          try {
                                            final dt = DateTime.parse(dateVal);
                                            _dateController.text =
                                                '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
                                          } catch (_) {}
                                        }

                                        _thiruvilakku =
                                            r['thiruvilakku_pooja']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'yes'
                                            ? 'ஆம்'
                                            : 'இல்லை';
                                        _poojaiKanakku =
                                            r['new_account_pooja']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'yes'
                                            ? 'ஆம்'
                                            : 'இல்லை';
                                        _vaganaPoojai =
                                            r['vehicle_pooja']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'yes'
                                            ? 'ஆம்'
                                            : 'இல்லை';
                                        _chakkaraVaganam =
                                            r['chakra_vehicle_pooja']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'yes'
                                            ? 'ஆம்'
                                            : 'இல்லை';
                                        _nilai =
                                            r['status']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'inactive'
                                            ? 'Inactive'
                                            : 'Active';

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
                                            .deleteNerttiKatan(r['id']);
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

  // ─── Helpers ─────────────────────────────────────────────────────────────

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
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) => Column(
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
        keyboardType: keyboardType,
        decoration: _inputDecoration(hint, icon),
      ),
    ],
  );

  Widget _dateField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'தேதி',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: _dateController,
        readOnly: true,
        onTap: _pickDate,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
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
            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ],
  );

  /// Shared dropdown for all 4 poojai fields (ஆம்/இல்லை)
  Widget _poojaDropdown(
    String label,
    String value,
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
                  items: _poojaOptions
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

  /// நிலை dropdown — Active / Inactive only
  Widget _nilaiDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'நிலை',
        style: TextStyle(
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
            Icon(
              Icons.check_circle_outline,
              size: 15,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _nilai,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  items: _nilaiOptions
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _nilai = v!),
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
                          size: 15,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Image Error',
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
                      size: 15,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'புகைப்படம்...',
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
}
