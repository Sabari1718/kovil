import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/nirvagam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class NanKodaiyalarContent extends StatefulWidget {
  const NanKodaiyalarContent({super.key});

  @override
  State<NanKodaiyalarContent> createState() => _NanKodaiyalarContentState();
}

class _NanKodaiyalarContentState extends State<NanKodaiyalarContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _donationController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedType;
  bool _isActive = true;
  bool _isLoading = false;
  File? _selectedImage;
  int? _editingId;
  late final NirvagamApiRepository _apiRepository;
  List<Map<String, dynamic>> _records = [];

  final List<String> _typeList = [
    'நன்கொடையாளர் (Donor)',
    'தொண்டர் (Volunteer)',
    'இரண்டும் (Both)',
  ];

  @override
  void initState() {
    super.initState();
    _apiRepository = NirvagamApiRepository(ApiClient());
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getDonorsVolunteers();
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('பெயர் உள்ளிடவும்!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    String mapType(String? uiType) {
      if (uiType == 'தொண்டர் (Volunteer)') return 'Volunteer';
      if (uiType == 'இரண்டும் (Both)') return 'Both';
      return 'Donor';
    }

    final data = {
      'temple_id': '1',
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'type': mapType(_selectedType),
      'donation_details': _donationController.text.trim(),
      'assigned_service': _serviceController.text.trim(),
      'status': _isActive ? 'active' : 'inactive',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateDonorVolunteer(
        _editingId!,
        data,
        imageFile: _selectedImage,
      );
    } else {
      success = await _apiRepository.addDonorVolunteer(
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
    final success = await _apiRepository.deleteDonorVolunteer(id);
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
      _nameController.text = r['name']?.toString() ?? '';
      _phoneController.text = r['phone']?.toString() ?? '';
      _donationController.text = r['donation_details']?.toString() ?? '';
      _serviceController.text = r['assigned_service']?.toString() ?? '';
      _isActive = r['status'] == 'active';
      _selectedImage = null;

      final type = r['type']?.toString();
      if (type == 'Volunteer')
        _selectedType = 'தொண்டர் (Volunteer)';
      else if (type == 'Both')
        _selectedType = 'இரண்டும் (Both)';
      else
        _selectedType = 'நன்கொடையாளர் (Donor)';
    });
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _donationController.clear();
      _serviceController.clear();
      _selectedType = null;
      _isActive = true;
      _selectedImage = null;
      _editingId = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _donationController.dispose();
    _serviceController.dispose();
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
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildFormCard(),
          const SizedBox(height: 24),
          _buildListCard(),
        ],
      ),
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
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: Colors.pink,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'நன்கொடையாளர் & தொண்டர்கள் (Donors & Volunteers)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'நன்கொடையாளர்கள் மற்றும் தொண்டர்கள் விவரங்களை நிர்வகிக்கவும்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  // ─── Stats Row ────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final totalDonors = _records
        .where((r) => (r['type'] as String).contains('Donor'))
        .length;
    final totalVolunteers = _records
        .where((r) => (r['type'] as String).contains('Volunteer'))
        .length;

    return LayoutBuilder(
      builder: (ctx, bc) {
        final isWide = bc.maxWidth > 560;
        final cards = [
          _statCard(
            Icons.people_outline,
            Colors.blue,
            _records.length.toString(),
            'மொத்த நபர்கள்',
            '(Total Counts)',
          ),
          _statCard(
            Icons.attach_money_outlined,
            Colors.green,
            totalDonors.toString(),
            'நன்கொடையாளர்கள்',
            '(Donors)',
          ),
          _statCard(
            Icons.work_outline,
            Colors.teal,
            totalVolunteers.toString(),
            'தொண்டர்கள்',
            '(Volunteers)',
          ),
        ];
        if (isWide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          );
        }
        return Column(
          children: cards
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _statCard(
    IconData icon,
    Color color,
    String value,
    String label,
    String sub,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  sub,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Form Card ───────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return LayoutBuilder(
      builder: (context, bc) {
        final isWide = bc.maxWidth > 600;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecor(),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormFields()),
                    const SizedBox(width: 24),
                    _buildPhotoUpload('புகைப்படம் (Photo)'),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildPhotoUpload('புகைப்படம் (Photo)')),
                    const SizedBox(height: 20),
                    _buildFormFields(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: Colors.blue.shade600, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'தனிநபர் விவரங்கள் (Personal Details)',
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
        const SizedBox(height: 20),

        _textField(
          'பெயர் (Name) *',
          'எ.கா: ராஜேஷ் குமார்',
          _nameController,
          Icons.person_outline,
        ),
        const SizedBox(height: 16),

        _textField(
          'கைபேசி எண் (Phone Number)',
          'எ.கா: 9876543210',
          _phoneController,
          Icons.phone_outlined,
        ),
        const SizedBox(height: 16),

        _dropdownField(
          label: 'வகை (Type)',
          hint: 'நன்கொடையாளர் (Donor)',
          icon: Icons.description_outlined,
          value: _selectedType,
          items: _typeList,
          onChanged: (v) => setState(() => _selectedType = v),
        ),
        const SizedBox(height: 16),

        // Active / Inactive toggle
        const Text(
          'நிலை (Status)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _statusCard(true)),
            const SizedBox(width: 12),
            Expanded(child: _statusCard(false)),
          ],
        ),
        const SizedBox(height: 16),

        if (_selectedType == 'நன்கொடையாளர் (Donor)' ||
            _selectedType == 'இரண்டும் (Both)') ...[
          _multilineField(
            'நன்கொடை விவரங்கள் (Donation Details)',
            'எ.கா: 50,000 ரூபாய், அல்லது 10 மூட்டை அரிசி',
            _donationController,
            Icons.attach_money,
          ),
          const SizedBox(height: 16),
        ],

        if (_selectedType == 'தொண்டர் (Volunteer)' ||
            _selectedType == 'இரண்டும் (Both)') ...[
          _multilineField(
            'செய்யும் பணி (Assigned Service)',
            'எ.கா: அன்னதானம் வழங்குதல், கூட்ட நெரிசலை கட்டுப்படுத்துதல்',
            _serviceController,
            Icons.work_outline,
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 8),

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
              onPressed: _isLoading ? null : _saveData,
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
                    : (_editingId != null
                          ? 'Update & Register'
                          : 'Save & Register'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EE1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
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
    );
  }

  Widget _statusCard(bool isActiveCard) {
    final selected = isActiveCard ? _isActive : !_isActive;
    final label = isActiveCard ? 'செயலில்' : 'செயலற்றது';
    final subLabel = isActiveCard ? 'Active' : 'Inactive';
    final icon = isActiveCard
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    final selColor = isActiveCard
        ? const Color(0xFF6B4EE1)
        : Colors.grey.shade600;

    return GestureDetector(
      onTap: () => setState(() => _isActive = isActiveCard),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? selColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? selColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: _selectedImage != null
                ? ClipOval(
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.camera_alt_outlined,
                    size: 28,
                    color: Colors.grey.shade300,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'புகைப்படத்தை பதிவேற்றவும்',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── List Card ───────────────────────────────────────────────────────────────
  Widget _buildListCard() {
    final q = _searchController.text.toLowerCase();
    final filtered = _records.where((r) {
      return q.isEmpty ||
          (r['name']?.toString() ?? '').toLowerCase().contains(q) ||
          (r['phone']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_list_bulleted,
                    color: Colors.grey.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'பதிவு செய்யப்பட்டவர்கள் பட்டியல் (Registered Members)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 210,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'தேடல் (Search name, phone)...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
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
                columnSpacing: 16,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80,
                columns: const [
                  DataColumn(label: Text('#', style: _hStyle)),
                  DataColumn(
                    label: Text('பெயர் &\nபுகைப்படம்', style: _hStyle),
                  ),
                  DataColumn(label: Text('கைபேசி\nஎண்', style: _hStyle)),
                  DataColumn(label: Text('வகை\n(TYPE)', style: _hStyle)),
                  DataColumn(
                    label: Text('விவரங்கள்\n(DETAILS)', style: _hStyle),
                  ),
                  DataColumn(label: Text('நிலை', style: _hStyle)),
                  DataColumn(label: Text('ACTIONS', style: _hStyle)),
                ],
                rows: filtered.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final r = entry.value;
                  final isDonor = (r['type']?.toString() ?? '').contains(
                    'Donor',
                  );
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
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child:
                                  (r['photo_path'] != null &&
                                      r['photo_path'].toString().isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        '${ApiClient.baseUrl.replaceAll('/api', '')}/uploads/${r['photo_path']}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Icon(
                                          Icons.person_outline,
                                          size: 15,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      size: 15,
                                      color: Colors.grey.shade500,
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r['name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      DataCell(
                        Text(
                          r['phone']?.toString() ?? '',
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
                            color: isDonor
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isDonor ? 'நன்கொடையாளர்' : 'தொண்டர்',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDonor
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            isDonor
                                ? (r['donation_details']?.toString() ?? '')
                                : (r['assigned_service']?.toString() ?? ''),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (r['status'] == 'active')
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (r['status'] == 'active') ? 'செயலில்' : 'செயலற்று',
                            style: TextStyle(
                              fontSize: 11,
                              color: (r['status'] == 'active')
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  static const _hStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: Color(0xFF1E1B4B),
  );

  Widget _iconBtn(
    IconData icon,
    Color border,
    Color iconColor,
    VoidCallback onTap, {
    Color? bg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 15),
        onPressed: onTap,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
      ),
    );
  }

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

  Widget _multilineField(
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
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Icon(icon, size: 15, color: Colors.grey.shade400),
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
