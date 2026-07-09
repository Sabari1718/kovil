import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/deities_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class UpaDeitiesContent extends StatefulWidget {
  final Map<String, dynamic>? editDeity;
  const UpaDeitiesContent({super.key, this.editDeity});

  @override
  State<UpaDeitiesContent> createState() => _UpaDeitiesContentState();
}

class _UpaDeitiesContentState extends State<UpaDeitiesContent> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final DeitiesApiRepository _apiRepository = DeitiesApiRepository(ApiClient());
  bool _isLoading = false;
  int? _editingId;

  // Dropdown Default
  final String _defaultGender = '-- Select தெய்வம் --';
  late String _selectedGender;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _worshipMethodController =
      TextEditingController();
  final TextEditingController _prayerRequestController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _specialNameController = TextEditingController();
  final TextEditingController _specialDaysController = TextEditingController();
  final TextEditingController _specialPoojaController = TextEditingController();
  final TextEditingController _fastingController = TextEditingController();

  // Checkbox State
  bool _hasSeparateSannidhi = false;

  // Selected Photo State
  XFile? _deityPhoto;

  // List Search & Mock Data
  final TextEditingController _listSearchController = TextEditingController();
  List<Map<String, dynamic>> _allUpaDeities = [];
  List<Map<String, dynamic>> _filteredUpaDeities = [];

  @override
  void initState() {
    super.initState();
    _selectedGender = _defaultGender;
    _listSearchController.addListener(_filterList);
    _fetchUpaDeities();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editDeity != null) {
        _editDeity(widget.editDeity!);
      }
    });
  }

  Future<void> _fetchUpaDeities() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getUbaDeivams();
    setState(() {
      _allUpaDeities = data;
      _filteredUpaDeities = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialityController.dispose();
    _worshipMethodController.dispose();
    _prayerRequestController.dispose();
    _noteController.dispose();
    _specialNameController.dispose();
    _specialDaysController.dispose();
    _specialPoojaController.dispose();
    _fastingController.dispose();
    _listSearchController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedGender = _defaultGender;
      _nameController.clear();
      _specialityController.clear();
      _worshipMethodController.clear();
      _prayerRequestController.clear();
      _noteController.clear();
      _specialNameController.clear();
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
      _filteredUpaDeities = _allUpaDeities.where((deity) {
        return (deity['name']?.toString().toLowerCase().contains(query) ??
                false) ||
            (deity['deitySpeciality']?.toString().toLowerCase().contains(
                  query,
                ) ??
                false);
      }).toList();
    });
  }

  Future<void> _saveDeity() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('பெயர் உள்ளிடவும்')));
      return;
    }
    setState(() => _isLoading = true);

    String genderValue = 'others';
    if (_selectedGender == 'ஆண் தெய்வம்') genderValue = 'male';
    if (_selectedGender == 'பெண் தெய்வம்') genderValue = 'female';

    final data = {
      'name': _nameController.text,
      'deitySpeciality': _specialityController.text,
      'worshipMethod': _worshipMethodController.text,
      'prayerRequest': _prayerRequestController.text,
      'notes': _noteController.text,
      'specialName': _specialNameController.text,
      'specialDays': _specialDaysController.text,
      'specialPuja': _specialPoojaController.text,
      'fastings': _fastingController.text,
      'separateSannidhi': _hasSeparateSannidhi ? 'true' : 'false',
      'deivamType': genderValue,
      'status': 'Active',
      'templeId': '1',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateUbaDeivam(
        _editingId!,
        data,
        _deityPhoto,
      );
    } else {
      success = await _apiRepository.addUbaDeivam(data, _deityPhoto);
    }

    setState(() => _isLoading = false);

    if (success) {
      CustomDeleteDialog.showSuccess(context, message: _editingId != null
            ? 'உப தெய்வம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது'
            : 'உப தெய்வம் வெற்றிகரமாக சேமிக்கப்பட்டது',);
      _clearForm();
      _fetchUpaDeities();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save record')));
    }
  }

  void _editDeity(Map<String, dynamic> deity) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    setState(() {
      _editingId = int.tryParse(deity['id']?.toString() ?? '');
      _nameController.text = deity['name'] ?? '';
      _specialityController.text = deity['deitySpeciality'] ?? '';
      _worshipMethodController.text = deity['worshipMethod'] ?? '';
      _prayerRequestController.text = deity['prayerRequest'] ?? '';
      _noteController.text = deity['notes'] ?? '';
      _specialNameController.text = deity['specialName'] ?? '';
      _specialDaysController.text = deity['specialDays'] ?? '';
      _specialPoojaController.text = deity['specialPuja'] ?? '';
      _fastingController.text = deity['fastings'] ?? '';

      if (deity['deivamType'] == 'male') {
        _selectedGender = 'ஆண் தெய்வம்';
      } else if (deity['deivamType'] == 'female') {
        _selectedGender = 'பெண் தெய்வம்';
      } else if (deity['deivamType'] != null &&
          deity['deivamType'].toString().isNotEmpty) {
        _selectedGender = 'மற்றவை';
      } else {
        _selectedGender = _defaultGender;
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
      final success = await _apiRepository.deleteUbaDeivam(id);
      setState(() => _isLoading = false);
      if (success) {
        await CustomDeleteDialog.showDeleted(context);
        _fetchUpaDeities();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete record'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    return Stack(
      children: [
        SingleChildScrollView(
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
                      Icons.filter_vintage,
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
                          'உப தெய்வங்கள் (Upa Deities)',
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
                'கோவிலின் உப தெய்வங்கள் (upa deities) விவரங்களை இங்கே நிர்வகிக்கலாம்.',
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
                      _buildTextField(
                        'விசேஷ பெயர்',
                        'விசேஷ பெயர்...',
                        _specialNameController,
                      ),
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

                    // Row 4: Fasting, Gender Dropdown, Separate Sannidhi Checkbox
                    _buildResponsiveThreeRow(
                      _buildTextField(
                        'விரதங்கள்',
                        'விரதங்கள்...',
                        _fastingController,
                      ),
                      _buildDropdownField(
                        'தெய்வம்',
                        _selectedGender,
                        [
                          _defaultGender,
                          'ஆண் தெய்வம்',
                          'பெண் தெய்வம்',
                          'மற்றவை',
                        ],
                        (val) => setState(() => _selectedGender = val!),
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
                                      'உப தெய்வங்கள் பட்டியல்',
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
                                  'உப தெய்வங்கள் (Upa Deities) பட்டியல்',
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
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey.shade50,
                          ),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(
                              label: Text(
                                '#',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'பெயர்',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'சிறப்பு',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'வழிபாட்டு முறை',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'விரதங்கள்',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'வகை',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'நிலை',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ACTIONS',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: _filteredUpaDeities.map((deity) {
                            return DataRow(
                              cells: [
                                DataCell(Text(deity['id']?.toString() ?? '-')),
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.indigo.shade50,
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
                                    width: 220,
                                    child: Text(
                                      deity['deitySpeciality'] ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      deity['worshipMethod'] ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      deity['fastings'] ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    deity['deivamType'] == 'male'
                                        ? 'ஆண் தெய்வம்'
                                        : deity['deivamType'] == 'female'
                                        ? 'பெண் தெய்வம்'
                                        : 'மற்றவை',
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
                                      borderRadius: BorderRadius.circular(12),
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
                                        onPressed: () => _editDeity(deity),
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
                                        onPressed: () {
                                          _scrollController.jumpTo(0);
                                          final id = int.tryParse(
                                            deity['id']?.toString() ?? '',
                                          );
                                          if (id != null) _deleteDeity(id);
                                        },
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: value.startsWith('--')
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
    );
  }

  Widget _buildPhotoSelectorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'புகைப்படம்',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _deityPhoto == null
                        ? 'புகைப்படம் தேர்வு செய்'
                        : _deityPhoto!.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: _deityPhoto == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (_deityPhoto != null)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _deityPhoto = null;
                      });
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'சன்னதி',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _hasSeparateSannidhi,
                onChanged: (val) {
                  setState(() {
                    _hasSeparateSannidhi = val ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: _buildClearButton()),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: _buildSaveButton()),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildClearButton()),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildSaveButton()),
          ],
        );
      },
    );
  }

  Widget _buildClearButton() {
    return OutlinedButton(
      onPressed: _clearForm,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Clear Form'),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _saveDeity,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save_outlined, size: 18),
      label: Text(_editingId == null ? 'Save Record' : 'Update Record'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF524EE1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildListSearchField() {
    return TextField(
      controller: _listSearchController,
      decoration: InputDecoration(
        hintText: 'பெயர் மூலம் தேடு...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
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
    );
  }

  Widget _buildRefreshButton() {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _listSearchController.clear();
        });
        _fetchUpaDeities();
      },
      icon: const Icon(Icons.refresh, size: 16),
      label: const Text('Refresh', style: TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.indigo,
        side: BorderSide(color: Colors.indigo.shade200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
