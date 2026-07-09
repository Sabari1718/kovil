import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/deities_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class KovilDeitiesContent extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editDeity;
  const KovilDeitiesContent({super.key, this.editDeity});

  @override
  ConsumerState<KovilDeitiesContent> createState() =>
      _KovilDeitiesContentState();
}

class _KovilDeitiesContentState extends ConsumerState<KovilDeitiesContent> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int? _editingId;

  // Dropdown Defaults
  final String _defaultDeityType = 'Select தெய்வம்';
  late String _selectedDeityType;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _worshipMethodController =
      TextEditingController();
  final TextEditingController _prayerRequestController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<TextEditingController> _specialNameControllers = [
    TextEditingController(),
  ];
  final TextEditingController _specialDaysController = TextEditingController();
  final TextEditingController _specialPoojaController = TextEditingController();
  final TextEditingController _fastingController = TextEditingController();

  // Checkbox State
  bool _hasSeparateSannidhi = false;

  // Selected Photo State
  XFile? _deityPhoto;

  // List Search & Data
  final TextEditingController _listSearchController = TextEditingController();
  List<Map<String, dynamic>> _allDeities = [];
  List<Map<String, dynamic>> _filteredDeities = [];

  // Currently editing type
  String? _editingType;

  final List<String> _deityTypes = [
    'ஆண் தெய்வம்',
    'பெண் தெய்வம்',
    'மற்றவை',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDeityType = _defaultDeityType;
    _listSearchController.addListener(_filterList);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllDeities();
      if (widget.editDeity != null) {
        _editDeity(widget.editDeity!);
      }
    });
  }

  Future<void> _fetchAllDeities() async {
    setState(() => _isLoading = true);
    final repo = ref.read(deitiesApiRepositoryProvider);
    List<Map<String, dynamic>> combined = [];

    try {
      final resp = await repo.fetchKovilDeivangal();
      if (resp['code'] == 200 && resp['data'] != null) {
        final list = List<Map<String, dynamic>>.from(resp['data']);
        for (var item in list) {
          combined.add({
            'id': item['id'],
            'name': item['name'] ?? '',
            'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
            'status': item['status'] == 1 || item['status'] == 'Active'
                ? 'Active'
                : 'Inactive',
            'deitySpeciality': item['deitySpeciality'] ?? '-',
            'fastings': item['fastings'] ?? '-',
            'worshipMethod': item['worshipMethod'] ?? '-',
            'deivamType': item['deivamType'] ?? '-',
            'raw': item,
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching deities: $e');
    }

    if (mounted) {
      setState(() {
        _allDeities = combined;
        _isLoading = false;
      });
      _filterList();
    }
  }

  Future<void> _saveDeity() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('பெயர் உள்ளிடவும்')));
      return;
    }

    if (_selectedDeityType == _defaultDeityType) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('தெய்வ வகையை தேர்ந்தெடுக்கவும்')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(deitiesApiRepositoryProvider);

    final specialNames = _specialNameControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .join(', ');

    final data = {
      'name': _nameController.text,
      'deitySpeciality': _specialityController.text,
      'worshipMethod': _worshipMethodController.text,
      'prayerRequest': _prayerRequestController.text,
      'notes': _noteController.text,
      'specialName': specialNames,
      'specialDays': _specialDaysController.text,
      'specialPuja': _specialPoojaController.text,
      'fastings': _fastingController.text,
      'separateSannidhi': _hasSeparateSannidhi ? 'true' : 'false',
      'deivamType': _selectedDeityType == 'ஆண் தெய்வம்'
          ? 'male'
          : _selectedDeityType == 'பெண் தெய்வம்'
              ? 'female'
              : 'others',
      'status': 'Active',
      'temple_id': '1',
    };

    bool success = false;

    if (_editingId != null) {
      success = await repo.updateKovilDeivangal(
        _editingId!,
        data,
        _deityPhoto,
      );
    } else {
      success = await repo.addKovilDeivangal(data, _deityPhoto);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        CustomDeleteDialog.showSuccess(
          context,
          message: _editingId != null
              ? 'கோவில் தெய்வம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது'
              : 'கோவில் தெய்வம் வெற்றிகரமாக சேமிக்கப்பட்டது',
        );
      }
      _clearForm();
      _fetchAllDeities();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save record')));
      }
    }
  }

  void _editDeity(Map<String, dynamic> deityListItem) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    final deity = deityListItem['raw'] ?? deityListItem;

    setState(() {
      _editingId = int.tryParse(deity['id']?.toString() ?? '');
      _editingType = deityListItem['type'] ?? deity['type'];

      _nameController.text = deity['name'] ?? '';
      _specialityController.text = deity['deitySpeciality'] ?? '';
      _worshipMethodController.text = deity['worshipMethod'] ?? '';
      _prayerRequestController.text = deity['prayerRequest'] ?? '';
      _noteController.text = deity['notes'] ?? '';

      final specialNameStr = deity['specialName']?.toString() ?? '';
      for (var c in _specialNameControllers) {
        c.dispose();
      }
      if (specialNameStr.isEmpty) {
        _specialNameControllers = [TextEditingController()];
      } else {
        _specialNameControllers = specialNameStr
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => TextEditingController(text: s))
            .toList();
        if (_specialNameControllers.isEmpty) {
          _specialNameControllers = [TextEditingController()];
        }
      }

      _specialDaysController.text = deity['specialDays'] ?? '';
      _specialPoojaController.text = deity['specialPuja'] ?? '';
      _fastingController.text = deity['fastings'] ?? '';

      if (_editingType != null && _deityTypes.contains(_editingType)) {
        _selectedDeityType = _editingType!;
      } else {
        _selectedDeityType = _defaultDeityType;
      }

      _hasSeparateSannidhi =
          deity['separateSannidhi'] == true ||
          deity['separateSannidhi'] == 'true' ||
          deity['separateSannidhi'] == 1;
      _deityPhoto = null;
    });
  }

  Future<void> _deleteDeity(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      setState(() => _isLoading = true);
      final repo = ref.read(deitiesApiRepositoryProvider);
      bool success = await repo.deleteKovilDeivangal(id);

      setState(() => _isLoading = false);
      if (success) {
        if (mounted) await CustomDeleteDialog.showDeleted(context);
        _fetchAllDeities();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete record'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialityController.dispose();
    _worshipMethodController.dispose();
    _prayerRequestController.dispose();
    _noteController.dispose();
    for (var c in _specialNameControllers) {
      c.dispose();
    }
    _specialDaysController.dispose();
    _specialPoojaController.dispose();
    _fastingController.dispose();
    _listSearchController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _editingType = null;
      _selectedDeityType = _defaultDeityType;
      _nameController.clear();
      _specialityController.clear();
      _worshipMethodController.clear();
      _prayerRequestController.clear();
      _noteController.clear();
      for (var c in _specialNameControllers) {
        c.dispose();
      }
      _specialNameControllers = [TextEditingController()];
      _specialDaysController.clear();
      _specialPoojaController.clear();
      _fastingController.clear();
      _hasSeparateSannidhi = false;
      _deityPhoto = null;
    });
  }

  void _filterList() {
    final query = _listSearchController.text.toLowerCase();
    setState(() {
      _filteredDeities = _allDeities.where((deity) {
        return (deity['name']?.toString().toLowerCase().contains(query) ??
                false) ||
            (deity['deitySpeciality']?.toString().toLowerCase().contains(
                  query,
                ) ??
                false);
      }).toList();
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _deityPhoto = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          Column(
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
                      Icons.temple_buddhist,
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
                          'கோவில் தெய்வங்கள் சேர்க்க (Kovil Deities)',
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
                'கோவில் தெய்வங்கள் சேர்க்க (Kovil Deities) விவரங்களை இங்கே நிர்வகிக்கலாம்.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),

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
                    // Form Card Header
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
                            'புதிய பதிவு (Add New Deity)',
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

                    // Row 1: Name, Photo selector, Speciality
                    _buildResponsiveThreeRow(
                      _buildTextField(
                        'பெயர்',
                        'தெய்வத்தின் பெயர்...',
                        _nameController,
                      ),
                      _buildPhotoSelectorField(),
                      _buildTextField(
                        'இறைவனின் சிறப்பு',
                        'சிறப்பு...',
                        _specialityController,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row 2: Worship Method, Prayer Request, Note
                    _buildResponsiveThreeRow(
                      _buildTextField(
                        'வழிபாட்டு முறை',
                        'வழிபாட்டு முறை...',
                        _worshipMethodController,
                      ),
                      _buildTextField(
                        'பிரார்த்தனை வேண்டுதல்',
                        'வேண்டுதல்...',
                        _prayerRequestController,
                      ),
                      _buildTextField(
                        'குறிப்பு',
                        'குறிப்புகள்...',
                        _noteController,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row 3: Special Name, Special Days, Special Pooja
                    _buildResponsiveThreeRow(
                      _buildDynamicSpecialNameFields(),
                      _buildTextField(
                        'விசேஷ நாட்கள்',
                        'நாட்கள்...',
                        _specialDaysController,
                      ),
                      _buildTextField(
                        'சிறப்பு பூஜை',
                        'பூஜை...',
                        _specialPoojaController,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row 4: Fasting, Deity Dropdown, Separate Sannidhi Checkbox
                    _buildResponsiveThreeRow(
                      _buildTextField(
                        'விரதங்கள்',
                        'விரதங்கள்...',
                        _fastingController,
                      ),
                      _buildDropdownField(
                        'தெய்வம்',
                        _selectedDeityType,
                        [_defaultDeityType, ..._deityTypes],
                        (val) => setState(() => _selectedDeityType = val!),
                      ),
                      _buildCheckboxField(
                        'தனி சன்னதி உள்ளது (Separate Sannidhi)',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // List Card
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
                    // List Header with search & refresh
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        if (isMobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    color: Colors.indigo.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'கோவில் தெய்வங்கள் சேர்க்க (Kovil Deities) பட்டியல்',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E1B4B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildListSearchField(),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: _buildRefreshButton(),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  color: Colors.indigo.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'கோவில் தெய்வங்கள் சேர்க்க (Kovil Deities) பட்டியல்',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1B4B),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Expanded(child: _buildListSearchField()),
                            const SizedBox(width: 16),
                            _buildRefreshButton(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.grey.shade200),
                        child: _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey.shade50,
                                ),
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      '#',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'பெயர்',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'சிறப்பு',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'வழிபாட்டு முறை',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'விரதங்கள்',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'வகை',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'நிலை',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'ACTIONS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _filteredDeities.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final deity = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text('${index + 1}'),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.indigo.shade50,
                                              radius: 16,
                                              child: Icon(
                                                Icons.person_outline,
                                                size: 16,
                                                color: Colors.indigo.shade400,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              deity['name'] ?? '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            deity['deitySpeciality'] ?? '-',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            deity['worshipMethod'] ?? '-',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            deity['fastings'] ?? '-',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          deity['deivamType'] == 'male'
                                              ? 'ஆண்'
                                              : deity['deivamType'] == 'female'
                                                  ? 'பெண்'
                                                  : deity['deivamType'] ==
                                                          'others'
                                                      ? 'மற்றவை'
                                                      : deity['deivamType'] ??
                                                          '-',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: deity['status'] == 'Active'
                                                ? Colors.green.shade50
                                                : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            deity['status'] ?? '-',
                                            style: TextStyle(
                                              color: deity['status'] == 'Active'
                                                  ? Colors.green
                                                  : Colors.red,
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
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _editDeity(deity),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red.shade400,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                _scrollController.jumpTo(0);
                                                final id = int.tryParse(
                                                  deity['id']?.toString() ?? '',
                                                );
                                                if (id != null) {
                                                  _deleteDeity(id);
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
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
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveThreeRow(Widget child1, Widget child2, Widget child3) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
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

  Widget _buildDynamicSpecialNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'விசேஷ பெயர்',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        ..._specialNameControllers.asMap().entries.map((entry) {
          int idx = entry.key;
          TextEditingController controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'விசேஷ பெயர்...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.indigo),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (_specialNameControllers.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _specialNameControllers[idx].dispose();
                          _specialNameControllers.removeAt(idx);
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _specialNameControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('+ Add More (மேலும் சேர்க்க)'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.indigo.shade200),
            ),
            foregroundColor: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade400,
              ),
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: item == _defaultDeityType
                          ? Colors.grey.shade400
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _hasSeparateSannidhi,
              onChanged: (val) {
                setState(() {
                  _hasSeparateSannidhi = val ?? false;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: Colors.indigo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelectorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'புகைப்படம்',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  _deityPhoto != null
                      ? Icons.check_circle
                      : Icons.file_upload_outlined,
                  color: _deityPhoto != null
                      ? Colors.green
                      : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _deityPhoto != null
                        ? _deityPhoto!.name
                        : 'புகைப்படம் தேர்வு செய்',
                    style: TextStyle(
                      color: _deityPhoto != null
                          ? Colors.black87
                          : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 16,
      runSpacing: 16,
      children: [
        TextButton(
          onPressed: _clearForm,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Text(
            'Clear Form',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _saveDeity,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save_outlined, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _editingId != null ? 'Update Record' : 'Save Record',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListSearchField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextField(
        controller: _listSearchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return InkWell(
      onTap: _fetchAllDeities,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.indigo.shade600, size: 18),
            const SizedBox(width: 8),
            Text(
              'Refresh',
              style: TextStyle(
                color: Colors.indigo.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
