import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/nirvagam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class PaktharkalKuzhuContent extends StatefulWidget {
  const PaktharkalKuzhuContent({super.key});

  @override
  State<PaktharkalKuzhuContent> createState() => _PaktharkalKuzhuContentState();
}

class _PaktharkalKuzhuContentState extends State<PaktharkalKuzhuContent> {
  final ScrollController _scrollController = ScrollController();
  final _nameCtrl = TextEditingController();
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
    final data = await _apiRepository.getVisucam();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (_nameCtrl.text.trim().isEmpty) {
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
      'temple_id': 1,
      'general_member': _nameCtrl.text.trim(),
      'status': 'active',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateVisucam(
        _editingId!,
        data,
        imageFile: _selectedImage,
      );
    } else {
      success = await _apiRepository.addVisucam(
        data,
        imageFile: _selectedImage,
      );
    }

    if (success) {
      _clearForm();
      await _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('உறுப்பினர் சேமிக்கப்பட்டார்!'),
          backgroundColor: Colors.green,
        ),
      );
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
    final success = await _apiRepository.deleteVisucam(id);
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
      _nameCtrl.text = r['general_member']?.toString() ?? '';

      if (r['executive_member_file'] != null &&
          r['executive_member_file'].toString().isNotEmpty) {
        _existingImageUrl =
            'https://temple.jobes24x7.com/uploads/${r['executive_member_file']}';
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
    _nameCtrl.clear();
    _selectedImage = null;
    _existingImageUrl = null;
    _editingId = null;
  });

  @override
  void dispose() {
    _nameCtrl.dispose();
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
          Icons.shield_outlined,
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
              'பக்தர்கள் குழு (Committee)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              'கோவிலின் உறுப்பினர்களின் விவரங்களை இங்கே நிர்வகிக்கலாம்.',
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
        // 2-col layout: name field | upload field
        LayoutBuilder(
          builder: (ctx, bc) {
            final isWide = bc.maxWidth > 560;
            final nameField = _textField(
              'உறுப்பினர் பெயர் *',
              '',
              _nameCtrl,
              Icons.person_outline,
            );
            final uploadField = _uploadField('ஆவணம் / புகைப்படம்');
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: nameField),
                      const SizedBox(width: 16),
                      Expanded(child: uploadField),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nameField,
                      const SizedBox(height: 14),
                      uploadField,
                    ],
                  );
          },
        ),
        const SizedBox(height: 20),

        // Buttons
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _clearForm,
              icon: Icon(
                Icons.clear_all,
                size: 15,
                color: Colors.grey.shade700,
              ),
              label: Text(
                'Clear',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? () {} : _saveData,
              icon: const Icon(Icons.save_outlined, size: 15),
              label: Text(
                _isLoading
                    ? 'Saving...'
                    : (_editingId != null ? 'Update Member' : 'Save Member'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EE1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
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

  // ── List Card ─────────────────────────────────────────────────────────────────
  Widget _listCard() {
    final q = _searchCtrl.text.toLowerCase();
    final filtered = _records
        .where(
          (r) =>
              q.isEmpty ||
              (r['general_member']?.toString() ?? '').toLowerCase().contains(q),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + search
          Wrap(
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
                  const Text(
                    'உறுப்பினர் பட்டியல் (Directory)',
                    style: TextStyle(
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
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDeco('தேடல்...', Icons.search),
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
                dataRowMinHeight: 52,
                dataRowMaxHeight: 64,
                columns: const [
                  DataColumn(label: Text('#', style: _hStyle)),
                  DataColumn(label: Text('உறுப்பினர் பெயர்', style: _hStyle)),
                  DataColumn(label: Text('ஆவணம்', style: _hStyle)),
                  DataColumn(label: Text('நிலை', style: _hStyle)),
                  DataColumn(label: Text('ACTIONS', style: _hStyle)),
                ],
                rows: filtered.asMap().entries.map((e) {
                  final idx = e.key;
                  final r = e.value;
                  final isActive = r['status'] == 'active';
                  return DataRow(
                    cells: [
                      // #
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

                      // Name with person icon
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r['general_member']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ஆவணம் – View link
                      DataCell(
                        r['executive_member_file'] != null &&
                                r['executive_member_file'].toString().isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 15,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          content: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Image.network(
                                                'https://temple.jobes24x7.com/uploads/${r['executive_member_file']}',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '--',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                      ),

                      // நிலை chip
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      // Actions
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
}
