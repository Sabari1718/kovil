import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kulatheivam/features/kovil/data/kovil_api_repository.dart';
import 'package:kulatheivam/features/kovil/providers/kovil_dropdown_provider.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class TempleHistoryContent extends ConsumerStatefulWidget {
  const TempleHistoryContent({super.key});

  @override
  ConsumerState<TempleHistoryContent> createState() =>
      _TempleHistoryContentState();
}

class _TempleHistoryContentState extends ConsumerState<TempleHistoryContent> {
  final ImagePicker _picker = ImagePicker();
  String _activeTab = 'வரலாறு'; // Tab state: 'வரலாறு' or 'குடமுழுக்கு'

  // ================= TAB 1: HISTORY STATE =================
  final TextEditingController _hMulavarNameController = TextEditingController(
    text: 'ஸ்ரீ கோபாலகிருஷ்ணன்',
  );
  final TextEditingController _hTempleNameController = TextEditingController(
    text: 'ஸ்ரீ கோபாலகிருஷ்ணன் கோவில்',
  );
  final TextEditingController _hDescriptionController = TextEditingController();
  final TextEditingController _hInfoController = TextEditingController();
  final TextEditingController _hTextController = TextEditingController();
  final TextEditingController _hDateController = TextEditingController();
  XFile? _historyPhoto;

  // ================= TAB 2: KUDAMUZHUKKU STATE =================
  final TextEditingController _kTempleNameController = TextEditingController(
    text: 'ஸ்ரீ கோபாலகிருஷ்ணன் கோவில்',
  );
  final TextEditingController _kLeaderNameController = TextEditingController(
    text: 'ஸ்ரீ கோபாலகிருஷ்ணன்',
  );

  final String _defaultKaalam = 'Select காலம்';
  late String _selectedKaalam;

  final String _defaultYagam = 'Select யாகங்கள் காலம்';
  late String _selectedYagam;

  final String _defaultType = 'Select வகைகள்';
  late String _selectedType;

  final String _defaultKundam = 'Select குண்டங்களின் எண்ணிக்கை';
  late String _selectedKundam;

  final String _defaultMandalaPooja = 'Select மண்டல பூஜை';
  late String _selectedMandalaPooja;

  final String _defaultAdditionalDay = 'Select கூடுதல் நாள்';
  late String _selectedAdditionalDay;

  final TextEditingController _kStartDateController = TextEditingController();
  final TextEditingController _kEndDateController = TextEditingController();
  final TextEditingController _kTimeController = TextEditingController();
  final TextEditingController _kDaysCountController = TextEditingController(
    text: '10',
  );
  final TextEditingController _kUpavasamTimeController =
      TextEditingController();
  final TextEditingController _kAnnadhanamTimeController =
      TextEditingController();
  final TextEditingController _kAddInfo1Controller = TextEditingController();
  final TextEditingController _kAddInfo2Controller = TextEditingController();
  final TextEditingController _kAddDateController = TextEditingController();

  bool _isYagasalaiPoojaChecked = false;
  bool _isSavingHistory = false;
  bool _isLoadingHistories = false;
  List<Map<String, dynamic>> _histories = [];
  int? _editingHistoryId;
  final ScrollController _scrollController = ScrollController();

  bool _isSavingKudamuzhukku = false;
  bool _isLoadingKudamuzhukkus = false;
  List<Map<String, dynamic>> _kudamuzhukkus = [];
  int? _editingKudamuzhukkuId;
  final ScrollController _kScrollController = ScrollController();

  Future<void> _saveHistory() async {
    if (_hTempleNameController.text.trim().isEmpty ||
        _hMulavarNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('தல பெயர் மற்றும் மூலவர் பெயரை உள்ளிடவும்'),
        ),
      );
      return;
    }

    setState(() {
      _isSavingHistory = true;
    });

    // Formatting date to 'yyyy-MM-dd' if needed or passing as is
    String formattedDate = _hDateController.text;
    if (formattedDate.isNotEmpty && formattedDate.contains('/')) {
      final parts = formattedDate.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        formattedDate = '$year-$month-$day';
      }
    }

    final data = {
      'temple_name': _hTempleNameController.text.trim(),
      'title': _hMulavarNameController.text.trim(),
      'description': _hDescriptionController.text.trim(),
      'information': _hInfoController.text.trim(),
      'text_part': _hTextController.text.trim(),
      'history_date': formattedDate,
      'active': '1',
    };

    final repository = ref.read(kovilApiRepositoryProvider);
    final success = _editingHistoryId != null
        ? await repository.updateTempleHistory(
            _editingHistoryId!,
            data,
            imageFile: _historyPhoto,
          )
        : await repository.addTempleHistory(data, imageFile: _historyPhoto);

    if (mounted) {
      setState(() {
        _isSavingHistory = false;
      });
      if (success) {
        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        _clearHistoryForm();
        _fetchHistories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('சேமிப்பதில் பிழை ஏற்பட்டது. (Failed to save)'),
          ),
        );
      }
    }
  }

  Future<void> _fetchHistories() async {
    setState(() => _isLoadingHistories = true);
    final repository = ref.read(kovilApiRepositoryProvider);
    final data = await repository.getTempleHistories();
    if (mounted) {
      setState(() {
        _histories = data;
        _isLoadingHistories = false;
      });
    }
  }

  Future<void> _deleteHistory(Map<String, dynamic> history) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (!confirm) return;

    final repository = ref.read(kovilApiRepositoryProvider);
    int? id = history['id'] is int
        ? history['id']
        : int.tryParse(history['id'].toString());
    if (id != null) {
      await repository.deleteTempleHistory(id);
      setState(() {
        _histories.removeWhere((h) => h['id'] == history['id']);
        if (_editingHistoryId == id) _clearHistoryForm();
      });
      if (mounted) {
        await CustomDeleteDialog.showDeleted(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedKaalam = _defaultKaalam;
    _selectedYagam = _defaultYagam;
    _selectedType = _defaultType;
    _selectedKundam = _defaultKundam;
    _selectedMandalaPooja = _defaultMandalaPooja;
    _selectedAdditionalDay = _defaultAdditionalDay;

    // Fetch histories initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistories();
      _fetchKudamuzhukkus();
    });
  }

  void _editHistory(Map<String, dynamic> history) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    setState(() {
      _editingHistoryId =
          int.tryParse(history['id'].toString()) ?? history['id'];
      _hTempleNameController.text = history['temple_name']?.toString() ?? '';
      _hMulavarNameController.text = history['title']?.toString() ?? '';
      _hDescriptionController.text = history['description']?.toString() ?? '';
      _hInfoController.text = history['information']?.toString() ?? '';
      _hTextController.text = history['text_part']?.toString() ?? '';

      String dateStr = (history['history_date'] ?? '')
          .toString()
          .split('T')
          .first;
      if (dateStr.isNotEmpty) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          _hDateController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
        } else {
          _hDateController.text = dateStr;
        }
      }

      _historyPhoto =
          null; // Can't easily load existing photo path into XFile, so user has to re-upload if they want to change it.
    });

    _scrollController.jumpTo(0);
  }

  Future<void> _saveKudamuzhukku() async {
    if (_kTempleNameController.text.trim().isEmpty ||
        _kLeaderNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('தல பெயர் மற்றும் தலைமை பெயரை உள்ளிடவும்'),
        ),
      );
      return;
    }

    setState(() => _isSavingKudamuzhukku = true);

    String formatDate(String dateStr) {
      if (dateStr.isNotEmpty && dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      }
      return dateStr;
    }

    final data = {
      'temple_name': _kTempleNameController.text.trim(),
      'chief_name': _kLeaderNameController.text.trim(),
      'period': _selectedKaalam == _defaultKaalam ? '' : _selectedKaalam,
      'yaga_period': _selectedYagam == _defaultYagam ? '' : _selectedYagam,
      'type': _selectedType == _defaultType ? '' : _selectedType,
      'kundam_count': _selectedKundam == _defaultKundam ? '' : _selectedKundam,
      'mandala_pooja': _selectedMandalaPooja == _defaultMandalaPooja
          ? ''
          : _selectedMandalaPooja,
      'start_date': formatDate(_kStartDateController.text.trim()),
      'end_date': formatDate(_kEndDateController.text.trim()),
      'time': _kTimeController.text.trim().isEmpty
          ? null
          : _kTimeController.text.trim(),
      'days_count': _kDaysCountController.text.trim(),
      'yagasalai_pooja': _isYagasalaiPoojaChecked,
      'yagasalai_name': '', // or add a field if needed
      'yagasalai_time': _kUpavasamTimeController.text.trim().isEmpty
          ? null
          : _kUpavasamTimeController.text.trim(),
      'deeparadhana_time': null, // or add field
      'annadhanam_time': _kAnnadhanamTimeController.text.trim().isEmpty
          ? null
          : _kAnnadhanamTimeController.text.trim(),
      'extra_field1': _kAddInfo1Controller.text.trim(),
      'extra_field2': _kAddInfo2Controller.text.trim(),
      'extra_date': formatDate(_kAddDateController.text.trim()),
      'extra_day': _selectedAdditionalDay == _defaultAdditionalDay
          ? ''
          : _selectedAdditionalDay,
      'active': true,
    };

    final repository = ref.read(kovilApiRepositoryProvider);
    final success = _editingKudamuzhukkuId != null
        ? await repository.updateKudamuzhukku(_editingKudamuzhukkuId!, data)
        : await repository.addKudamuzhukku(data);

    if (mounted) {
      setState(() => _isSavingKudamuzhukku = false);
      if (success) {
        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        _clearKudamuzhukkuForm();
        await Future.delayed(const Duration(milliseconds: 500));
        _fetchKudamuzhukkus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('சேமிப்பதில் பிழை ஏற்பட்டது.')),
        );
      }
    }
  }

  Future<void> _fetchKudamuzhukkus() async {
    setState(() => _isLoadingKudamuzhukkus = true);
    final repository = ref.read(kovilApiRepositoryProvider);
    final data = await repository.getKudamuzhukkus();
    if (mounted) {
      setState(() {
        _kudamuzhukkus = data;
        _isLoadingKudamuzhukkus = false;
      });
    }
  }

  Future<void> _deleteKudamuzhukku(Map<String, dynamic> kudamuzhukku) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (!confirm) return;

    final repository = ref.read(kovilApiRepositoryProvider);
    final id =
        int.tryParse(kudamuzhukku['id'].toString()) ?? kudamuzhukku['id'];
    if (id != null) {
      await repository.deleteKudamuzhukku(id);
      setState(() {
        _kudamuzhukkus.removeWhere((k) => k['id'] == kudamuzhukku['id']);
        if (_editingKudamuzhukkuId == id) _clearKudamuzhukkuForm();
      });
      if (mounted) {
        await CustomDeleteDialog.showDeleted(context);
      }
    }
  }

  void _editKudamuzhukku(Map<String, dynamic> kudamuzhukku) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    setState(() {
      _editingKudamuzhukkuId =
          int.tryParse(kudamuzhukku['id'].toString()) ?? kudamuzhukku['id'];
      _kTempleNameController.text =
          kudamuzhukku['temple_name']?.toString() ?? '';
      _kLeaderNameController.text =
          kudamuzhukku['chief_name']?.toString() ?? '';
      _selectedKaalam = kudamuzhukku['period']?.toString() ?? _defaultKaalam;
      if (_selectedKaalam.isEmpty) _selectedKaalam = _defaultKaalam;
      _selectedYagam = kudamuzhukku['yaga_period']?.toString() ?? _defaultYagam;
      if (_selectedYagam.isEmpty) _selectedYagam = _defaultYagam;
      _selectedType = kudamuzhukku['type']?.toString() ?? _defaultType;
      if (_selectedType.isEmpty) _selectedType = _defaultType;
      _selectedKundam =
          kudamuzhukku['kundam_count']?.toString() ?? _defaultKundam;
      if (_selectedKundam.isEmpty) _selectedKundam = _defaultKundam;
      _selectedMandalaPooja =
          kudamuzhukku['mandala_pooja']?.toString() ?? _defaultMandalaPooja;
      if (_selectedMandalaPooja.isEmpty)
        _selectedMandalaPooja = _defaultMandalaPooja;

      _kStartDateController.text = (kudamuzhukku['start_date'] ?? '')
          .toString()
          .split('T')
          .first;
      _kEndDateController.text = (kudamuzhukku['end_date'] ?? '')
          .toString()
          .split('T')
          .first;
      _kTimeController.text = kudamuzhukku['time']?.toString() ?? '';
      _kDaysCountController.text = kudamuzhukku['days_count']?.toString() ?? '';
      _isYagasalaiPoojaChecked =
          kudamuzhukku['yagasalai_pooja'] == 1 ||
          kudamuzhukku['yagasalai_pooja'] == '1' ||
          kudamuzhukku['yagasalai_pooja'] == true;
      _kUpavasamTimeController.text =
          kudamuzhukku['yagasalai_time']?.toString() ?? '';
      _kAnnadhanamTimeController.text =
          kudamuzhukku['annadhanam_time']?.toString() ?? '';
      _kAddInfo1Controller.text =
          kudamuzhukku['extra_field1']?.toString() ?? '';
      _kAddInfo2Controller.text =
          kudamuzhukku['extra_field2']?.toString() ?? '';
      _kAddDateController.text = (kudamuzhukku['extra_date'] ?? '')
          .toString()
          .split('T')
          .first;
      _selectedAdditionalDay =
          kudamuzhukku['extra_day']?.toString() ?? _defaultAdditionalDay;
      if (_selectedAdditionalDay.isEmpty)
        _selectedAdditionalDay = _defaultAdditionalDay;
    });

    _scrollController.jumpTo(0);
  }

  void _clearKudamuzhukkuForm() {
    setState(() {
      _editingKudamuzhukkuId = null;
      _kTempleNameController.clear();
      _kLeaderNameController.clear();
      _selectedKaalam = _defaultKaalam;
      _selectedYagam = _defaultYagam;
      _selectedType = _defaultType;
      _selectedKundam = _defaultKundam;
      _selectedMandalaPooja = _defaultMandalaPooja;
      _selectedAdditionalDay = _defaultAdditionalDay;
      _kStartDateController.clear();
      _kEndDateController.clear();
      _kTimeController.clear();
      _kDaysCountController.clear();
      _kUpavasamTimeController.clear();
      _kAnnadhanamTimeController.clear();
      _kAddInfo1Controller.clear();
      _kAddInfo2Controller.clear();
      _kAddDateController.clear();
      _isYagasalaiPoojaChecked = false;
    });
  }

  @override
  void dispose() {
    _hMulavarNameController.dispose();
    _hTempleNameController.dispose();
    _hDescriptionController.dispose();
    _hInfoController.dispose();
    _hTextController.dispose();
    _hDateController.dispose();

    _kTempleNameController.dispose();
    _kLeaderNameController.dispose();
    _kStartDateController.dispose();
    _kEndDateController.dispose();
    _kTimeController.dispose();
    _kDaysCountController.dispose();
    _kUpavasamTimeController.dispose();
    _kAnnadhanamTimeController.dispose();
    _kAddInfo1Controller.dispose();
    _kAddInfo2Controller.dispose();
    _kAddDateController.dispose();
    super.dispose();
  }

  void _clearHistoryForm() {
    setState(() {
      _editingHistoryId = null;
      _hMulavarNameController.clear();
      _hTempleNameController.clear();
      _hDescriptionController.clear();
      _hInfoController.clear();
      _hTextController.clear();
      _hDateController.clear();
      _historyPhoto = null;
    });
  }

  Future<void> _pickHistoryPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _historyPhoto = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking history image: $e');
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        controller.text = '$hour:$minute:00';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.indigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'வரலாறு & குடமுழுக்கு (History & Kudamuzhukku)',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'கோவிலின் வரலாற்றுத் தகவல்கள் மற்றும் குடமுழுக்கு நிகழ்வுகளை இங்கே நிர்வகிக்கவும்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Custom Tab Bar Toggles
          Row(
            children: [
              _buildTabButton('வரலாறு', Icons.history),
              const SizedBox(width: 12),
              _buildTabButton('குடமுழுக்கு', Icons.bolt),
            ],
          ),
          const SizedBox(height: 32),

          // Render active tab view
          _activeTab == 'வரலாறு'
              ? _buildHistoryView()
              : _buildKudamuzhukkuView(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName, IconData icon) {
    final isActive = _activeTab == tabName;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabName;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.indigo.shade50 : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF524EE1) : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF524EE1) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              tabName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF524EE1)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 1 VIEW: HISTORY ====================
  Widget _buildHistoryView() {
    return Container(
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
          // Section Title
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'வரலாறு விவரம் சேர்க்க (Add History Detail)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row 1: Mulavar Name, Temple Name, Description
          _buildResponsiveThreeRow(
            _buildTextField(
              'மூலவர் பெயர்',
              'ஸ்ரீ கோபாலகிருஷ்ணன்',
              _hMulavarNameController,
              Icons.person_outline,
            ),
            _buildTextField(
              'தல பெயர்',
              'ஸ்ரீ கோபாலகிருஷ்ணன் கோவில்',
              _hTempleNameController,
              Icons.home_outlined,
            ),
            _buildTextField(
              'விளக்கம் / தொகுப்பு',
              'விளக்கத்தை உள்ளிடவும்',
              _hDescriptionController,
              Icons.description_outlined,
            ),
          ),
          const SizedBox(height: 16),

          // Row 2: Info, Text Area, Date
          _buildResponsiveThreeRow(
            _buildTextField(
              'தகவல்',
              'தகவல்களை உள்ளிடவும்',
              _hInfoController,
              Icons.info_outline,
            ),
            _buildTextField(
              'உரை பகுதி',
              'உரைப் பகுதியை உள்ளிடவும்',
              _hTextController,
              Icons.document_scanner,
            ),
            _buildDateField('வரலாறு தேதி', _hDateController),
          ),
          const SizedBox(height: 24),

          // Photo Upload Area
          const Text(
            'புகைப்படம் (Photo)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickHistoryPhoto,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle
                      .solid, // Note: standard dashed isn't in boxDecoration, custom border can be done, solid is standard clean look.
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _historyPhoto != null
                        ? _historyPhoto!.name
                        : 'புகைப்படத்தை தேர்ந்தெடுக்கவும் அல்லது இங்கே இழுக்கவும்',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max size 5MB (JPG, PNG)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 16,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: _clearHistoryForm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Clear Form'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isSavingHistory ? null : _saveHistory,
                icon: _isSavingHistory
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check, size: 16),
                label: Text(
                  _isSavingHistory
                      ? (_editingHistoryId != null
                            ? 'Updating...'
                            : 'Saving...')
                      : (_editingHistoryId != null
                            ? 'Update History'
                            : 'Save History'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF524EE1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildHistoryListTable(),
        ],
      ),
    );
  }

  Widget _buildHistoryListTable() {
    return Container(
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'வரலாறு பட்டியல் (History Records)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _fetchHistories,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoadingHistories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_histories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'வரலாறு எதுவும் கிடைக்கவில்லை.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('மூலவர் & தல பெயர்')),
                  DataColumn(label: Text('புகைப்படம்')),
                  DataColumn(label: Text('விவரம் / தகவல்')),
                  DataColumn(label: Text('தேதி')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: _histories.map((history) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '#${history['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              history['title']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              history['temple_name']?.toString() ?? '-',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        history['photo_path'] != null &&
                                history['photo_path'].toString().isNotEmpty
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.image,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Photo',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                '-',
                                style: TextStyle(color: Colors.grey),
                              ),
                      ),
                      DataCell(
                        Container(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                history['description']?.toString() ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                history['information']?.toString() ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (history['history_date'] ?? '')
                                  .toString()
                                  .split('T')
                                  .first,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
                                size: 18,
                              ),
                              onPressed: () => _editHistory(history),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade400,
                                size: 18,
                              ),
                              onPressed: () => _deleteHistory(history),
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
        ],
      ),
    );
  }

  // ==================== TAB 2 VIEW: KUDAMUZHUKKU ====================
  Widget _buildKudamuzhukkuView() {
    _scrollController.jumpTo(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Card
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
              // Form Title
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'குடமுழுக்கு விவரம் சேர்க்க (Add Kudamuzhukku Detail)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Row 1: Temple Name, Leader Name, Kaalam Dropdown
              _buildResponsiveThreeRow(
                _buildTextField(
                  'தல பெயர்',
                  'தல பெயர்...',
                  _kTempleNameController,
                  Icons.home_outlined,
                ),
                _buildTextField(
                  'தலைமை பெயர்',
                  'தலைமை பெயர்...',
                  _kLeaderNameController,
                  Icons.person_outline,
                ),
                _buildDropdownField(
                  'காலம்',
                  _selectedKaalam,
                  [
                    _defaultKaalam,
                    'ஒரு கால பூஜை',
                    'இரண்டு கால பூஜை',
                    'நான்கு கால பூஜை',
                  ],
                  (val) => setState(() => _selectedKaalam = val!),
                  Icons.lock_clock,
                ),
              ),
              const SizedBox(height: 16),

              // Row 2: Yagam Dropdown, Type Dropdown, Kundam Dropdown
              _buildResponsiveThreeRow(
                _buildDropdownField(
                  'யாகங்கள் காலம்',
                  _selectedYagam,
                  [_defaultYagam, 'நான்கு கால யாகம்', 'எட்டு கால யாகம்'],
                  (val) => setState(() => _selectedYagam = val!),
                  Icons.fireplace_outlined,
                ),
                _buildDropdownField(
                  'வகைகள்',
                  _selectedType,
                  [
                    _defaultType,
                    'மகா கும்பாபிஷேகம்',
                    'விமான கும்பாபிஷேகம்',
                    'ஆவர்தனம்',
                  ],
                  (val) => setState(() => _selectedType = val!),
                  Icons.category_outlined,
                ),
                _buildDropdownField(
                  'குண்டங்களின் எண்ணிக்கை',
                  _selectedKundam,
                  [_defaultKundam, '3', '5', '9', '108'],
                  (val) => setState(() => _selectedKundam = val!),
                  Icons.numbers,
                ),
              ),
              const SizedBox(height: 16),

              // Row 3: Start Date, End Date, Time
              _buildResponsiveThreeRow(
                _buildDateField('தொடக்க தேதி', _kStartDateController),
                _buildDateField('முடிவு தேதி', _kEndDateController),
                _buildTimeField('நேரம்', _kTimeController),
              ),
              const SizedBox(height: 16),

              // Row 4: Days Count, Upavasam Time, Annadhanam Time
              _buildResponsiveThreeRow(
                _buildTextField(
                  'நாட்களின் எண்ணிக்கை',
                  'எ.கா: 10',
                  _kDaysCountController,
                  Icons.calendar_month_outlined,
                ),
                _buildTimeField('உபாரதனை நேரம்', _kUpavasamTimeController),
                _buildTimeField('அன்னதானம் நேரம்', _kAnnadhanamTimeController),
              ),
              const SizedBox(height: 16),

              // Row 5: Mandala Pooja Dropdown, Yagasalai Checkbox
              _buildResponsiveRow(
                _buildDropdownField(
                  'மண்டல பூஜை',
                  _selectedMandalaPooja,
                  [_defaultMandalaPooja, '48 நாட்கள் மண்டல பூஜை', '1 மண்டலம்'],
                  (val) => setState(() => _selectedMandalaPooja = val!),
                  Icons.list_alt,
                ),
                _buildYagasalaiCheckbox(),
              ),
              const SizedBox(height: 16),

              // Row 6: Additional Info 1, Additional Info 2, Additional Date
              _buildResponsiveThreeRow(
                _buildTextField(
                  'கூடுதல் தகவல் 1',
                  'கூடுதல் விவரங்கள்...',
                  _kAddInfo1Controller,
                  Icons.info_outline,
                ),
                _buildTextField(
                  'கூடுதல் தகவல் 2',
                  'கூடுதல் விவரங்கள்...',
                  _kAddInfo2Controller,
                  Icons.info_outline,
                ),
                _buildDateField('கூடுதல் தேதி', _kAddDateController),
              ),
              const SizedBox(height: 16),

              // Row 7: Additional Day dropdown
              _buildResponsiveRow(
                _buildDropdownField(
                  'கூடுதல் நாள்',
                  _selectedAdditionalDay,
                  [
                    _defaultAdditionalDay,
                    'திங்கள்',
                    'செவ்வாய்',
                    'புதன்',
                    'வியாழன்',
                    'வெள்ளி',
                    'சனி',
                    'ஞாயிறு',
                  ],
                  (val) => setState(() => _selectedAdditionalDay = val!),
                  Icons.today_outlined,
                ),
                const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Form buttons
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 16,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: _clearKudamuzhukkuForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Clear Form'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isSavingKudamuzhukku ? null : _saveKudamuzhukku,
                    icon: _isSavingKudamuzhukku
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
                      _isSavingKudamuzhukku
                          ? (_editingKudamuzhukkuId != null
                                ? 'Updating...'
                                : 'Saving...')
                          : (_editingKudamuzhukkuId != null
                                ? 'Update Details'
                                : 'Save Details'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF524EE1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
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
        const SizedBox(height: 32),

        // Table Card
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: Colors.indigo.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'குடமுழுக்கு பட்டியல் (Kudamuzhukku Records)',
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
                    onPressed: _fetchKudamuzhukkus,
                    icon: const Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.indigo,
                    ),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(color: Colors.indigo, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Table list (Scrollable)
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
                    columnSpacing: 32,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'தல & தலைமை பெயர்',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'காலம் / வகை',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'தொடக்க / முடிவு தேதி',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'நேரம்',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ACTIONS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                    ],
                    rows: _isLoadingKudamuzhukkus
                        ? [
                            const DataRow(
                              cells: [
                                DataCell(CircularProgressIndicator()),
                                DataCell(Text('Loading...')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ],
                            ),
                          ]
                        : _kudamuzhukkus.isEmpty
                        ? [
                            const DataRow(
                              cells: [
                                DataCell(Text('-')),
                                DataCell(Text('No Records Found')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ],
                            ),
                          ]
                        : _kudamuzhukkus.map((k) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    '#${k['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        k['temple_name']?.toString() ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        k['chief_name']?.toString() ?? '-',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        k['period']?.toString() ?? '-',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        k['type']?.toString() ?? '-',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${(k['start_date'] ?? '').toString().split('T').first} to ${(k['end_date'] ?? '').toString().split('T').first}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    k['time']?.toString() ?? '-',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
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
                                          size: 18,
                                        ),
                                        onPressed: () => _editKudamuzhukku(k),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade400,
                                          size: 18,
                                        ),
                                        onPressed: () => _deleteKudamuzhukku(k),
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
    );
  }

  // ==================== HELPERS ====================
  Widget _buildResponsiveThreeRow(Widget child1, Widget child2, Widget child3) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        if (isMobile) {
          return Column(
            children: [
              child1,
              const SizedBox(height: 16),
              child2,
              const SizedBox(height: 16),
              child3,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child1),
            const SizedBox(width: 16),
            Expanded(child: child2),
            const SizedBox(width: 16),
            Expanded(child: child3),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: [
              child1,
              if (child2 is! SizedBox) const SizedBox(height: 16),
              child2,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child1),
            const SizedBox(width: 16),
            Expanded(child: child2),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
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
              borderSide: const BorderSide(color: Color(0xFF524EE1)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String selectedValue,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    List<String> safeItems = List.from(items);
    if (!safeItems.contains(selectedValue) && selectedValue.isNotEmpty) {
      safeItems.add(selectedValue);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedValue,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                    items: safeItems.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            color: value.startsWith('Select')
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
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

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          decoration: InputDecoration(
            hintText: 'dd-mm-yyyy',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
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
              borderSide: const BorderSide(color: Color(0xFF524EE1)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectTime(context, controller),
          decoration: InputDecoration(
            hintText: '--:--',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(
              Icons.access_time_outlined,
              size: 18,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
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
              borderSide: const BorderSide(color: Color(0xFF524EE1)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildYagasalaiCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isYagasalaiPoojaChecked = !_isYagasalaiPoojaChecked;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _isYagasalaiPoojaChecked
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: _isYagasalaiPoojaChecked
                    ? const Color(0xFF524EE1)
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'யாகசாலை பூஜை',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
