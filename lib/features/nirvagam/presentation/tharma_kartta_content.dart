import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../data/nirvagam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class TharmaKartthaContent extends StatefulWidget {
  const TharmaKartthaContent({super.key});

  @override
  State<TharmaKartthaContent> createState() => _TharmaKartthaContentState();
}

class _TharmaKartthaContentState extends State<TharmaKartthaContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedUser;

  final List<String> _userList = [
    'raja - yudeshnpluss@gmail.com - 9003853604',
    'lohit - lovelylohit003@gmail.com - 9003853603',
    'Priya - priya@gmail.com - 9876543210',
  ];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late final NirvagamApiRepository _apiRepository;
  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _apiRepository = NirvagamApiRepository(ApiClient());
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiRepository.getTharumakatha();
      setState(() {
        _records = data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _apiRepository.deleteTharumakatha(id);
    if (success) {
      await CustomDeleteDialog.showDeleted(context);
      _fetchRecords();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('பிழை ஏற்பட்டது!')));
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedUser = null;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _workController.clear();
      _selectedImage = null;
      _editingId = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _workController.dispose();
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.key_outlined, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'தர்மகர்த்தாக்கள் விவரம் (Dharumakartha Management)',
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
        'கோவிலின் தர்மகர்த்தாக்கள் விவரங்களை நிர்வகிக்கவும் மற்றும் புதிய கோவில் உருவாக்கும் அனுமதிகளை வழங்கவும்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  // ─── Stats Row ────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (ctx, bc) {
        final isWide = bc.maxWidth > 560;
        final cards = [
          _statCard(
            Icons.people_outline,
            Colors.blue,
            '2',
            'மொத்த தர்மகர்த்தாக்கள்',
            '(Total Trustees)',
          ),
          _statCard(
            Icons.shield_outlined,
            Colors.green,
            '1',
            'கோவில் உருவாக்க அனுமதி',
            '(Allowed Creators)',
          ),
          _statCard(
            Icons.check_circle_outline,
            Colors.teal,
            '2',
            'செயலில் உள்ளவர்கள்',
            '(Active Status)',
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
                    _buildPhotoUpload(
                      'தர்மகர்த்தா புகைப்படம்\n(Trustee Photo)',
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _buildPhotoUpload(
                        'தர்மகர்த்தா புகைப்படம் (Trustee Photo)',
                      ),
                    ),
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

        // Select User
        _dropdownField(
          label: 'பயனரைத் தேர்ந்தெடுக்கவும் (Select Existing User) *',
          hint: '-- பயனரைத் தேர்ந்தெடுக்கவும் (Select User) --',
          icon: Icons.person_outline,
          value: _selectedUser,
          items: _userList,
          onChanged: (v) {
            setState(() {
              _selectedUser = v;
              if (v != null) {
                final parts = v.split(' - ');
                if (parts.isNotEmpty) _nameController.text = parts[0];
                if (parts.length > 1) _emailController.text = parts[1];
                if (parts.length > 2) _phoneController.text = parts[2];
              }
            });
          },
          suffixWidget: IconButton(
            icon: Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.blue.shade600,
              size: 20,
            ),
            onPressed: () {
              final r = {
                'id': _editingId?.toString() ?? 'New',
                'name': _nameController.text.trim().isEmpty
                    ? (_selectedUser?.split(' - ')[0] ?? '')
                    : _nameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'email': _emailController.text.trim(),
                'role': 'User',
                'assigned_work': _workController.text.trim().isEmpty
                    ? '--'
                    : _workController.text.trim(),
                'can_create_temple': 0,
                'status': 'Active',
                'photo_path': null,
              };
              _showProfileDialog(r);
            },
          ),
        ),
        const SizedBox(height: 16),

        _textField(
          'தர்மகர்த்தா பெயர் (Trustee Name)',
          'எ.கா: ராமசாமி',
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

        _textField(
          'மின்னஞ்சல் முகவரி (Email Address)',
          'trustee@example.com',
          _emailController,
          Icons.email_outlined,
        ),
        const SizedBox(height: 24),

        // Buttons — Wrap so they stack on narrow screens
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_nameController.text.trim().isEmpty &&
                          _selectedUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('பயனர் அல்லது பெயர் உள்ளிடவும்!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      final data = {
                        'temple_id': 1,
                        'name': _nameController.text.trim().isEmpty
                            ? (_selectedUser ?? '').split(' - ')[0]
                            : _nameController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'email': _emailController.text.trim(),
                        'role': '',
                        'assigned_work': _workController.text.trim().isEmpty
                            ? '--'
                            : _workController.text.trim(),
                        'can_create_temple': 0,
                        'status': 'active',
                      };

                      bool success;
                      if (_editingId == null) {
                        success = await _apiRepository.addTharumakatha(
                          data,
                          imageFile: _selectedImage,
                        );
                      } else {
                        success = await _apiRepository.updateTharumakatha(
                          _editingId!,
                          data,
                          imageFile: _selectedImage,
                        );
                      }

                      if (success) {
                        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
                        _clearForm();
                        _fetchRecords();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('பிழை ஏற்பட்டது!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        setState(() => _isLoading = false);
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
              label: Text(_editingId == null ? 'Save & Register' : 'Update'),
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
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? Icon(
                    Icons.camera_alt_outlined,
                    size: 28,
                    color: Colors.grey.shade300,
                  )
                : null,
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
          (r['name']?.toString().toLowerCase().contains(q) ?? false) ||
          (r['phone']?.toString().toLowerCase().contains(q) ?? false) ||
          (r['email']?.toString().toLowerCase().contains(q) ?? false);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Search
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
                      'தர்மகர்த்தாக்கள் பட்டியல் (Registered Trustees)',
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
                width: 200,
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
                  DataColumn(label: Text('தொடர்பு &\nROLE', style: _hStyle)),
                  DataColumn(label: Text('ஒதுக்கப்பட்ட\nபணி', style: _hStyle)),
                  DataColumn(label: Text('கோவில்\nஅனுமதி', style: _hStyle)),
                  DataColumn(label: Text('நிலை', style: _hStyle)),
                  DataColumn(label: Text('ACTIONS', style: _hStyle)),
                ],
                rows: filtered.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final r = entry.value;
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

                      // Name + photo
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
                              child: r['photo_path'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        'https://temple.jobes24x7.com/uploads/${r['photo_path']}',
                                        width: 30,
                                        height: 30,
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

                      // Contact + Role badge
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              r['phone']?.toString() ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              r['email']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (r['role'] != null &&
                                r['role'].toString().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  r['role'].toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      DataCell(
                        SizedBox(
                          width: 130,
                          child: Text(
                            r['assigned_work']?.toString() ?? '--',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Access badge
                      DataCell(
                        (r['can_create_temple']?.toString() == '1' ||
                                r['can_create_temple'] == 1 ||
                                r['can_create_temple'] == true)
                            ? _accessBadge(
                                'அனுமதி உண்டு',
                                '(Allowed)',
                                Colors.green.shade50,
                                Colors.green.shade700,
                              )
                            : _accessBadge(
                                'அனுமதி இல்லை',
                                '(No Access)',
                                Colors.red.shade50,
                                Colors.red.shade700,
                              ),
                      ),

                      // Status
                      DataCell(
                        Text(
                          r['status']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                r['status']?.toString().toLowerCase() ==
                                    'active'
                                ? Colors.green.shade700
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _iconBtn(
                              Icons.remove_red_eye_outlined,
                              Colors.grey.shade300,
                              Colors.grey.shade600,
                              () => _showProfileDialog(r),
                            ),
                            const SizedBox(width: 6),
                            _iconBtn(
                              Icons.edit_outlined,
                              Colors.grey.shade300,
                              Colors.grey.shade600,
                              () {
                                setState(() {
                                  _editingId = r['id'];
                                  _nameController.text =
                                      r['name']?.toString() ?? '';
                                  _phoneController.text =
                                      r['phone']?.toString() ?? '';
                                  _emailController.text =
                                      r['email']?.toString() ?? '';
                                  _workController.text =
                                      r['assigned_work']?.toString() ?? '';
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            _iconBtn(
                              Icons.delete_outline,
                              Colors.red.shade200,
                              Colors.red.shade400,
                              () => _deleteRecord(r['id']),
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

  void _showProfileDialog(Map<String, dynamic> r) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Banner
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFD1FAE5)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                // Profile & Call Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:
                              r['photo_path'] != null &&
                                  r['photo_path'].toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://temple.jobes24x7.com/uploads/${r['photo_path']}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                      Icons.person_outline,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                )
                              : (_selectedImage != null && r['id'] == 'New')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person_outline,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_outlined, size: 16),
                          label: const Text('Call Trustee'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Name and Role
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      Text(
                        'Role: ${r['role']?.toString() ?? 'User'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'OVERVIEW',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _detailRow(
                        Icons.person_outline,
                        'Trustee ID',
                        '#${r['id']}',
                      ),
                      _detailRow(
                        Icons.work_outline,
                        'Role / Designation',
                        r['role']?.toString().isNotEmpty == true
                            ? r['role'].toString()
                            : 'Member',
                      ),
                      _detailRow(
                        Icons.email_outlined,
                        'Email',
                        r['email']?.toString() ?? '--',
                      ),
                      _detailRow(
                        Icons.phone_outlined,
                        'Phone Number',
                        r['phone']?.toString() ?? '--',
                      ),
                      _detailRow(
                        Icons.assignment_outlined,
                        'Assigned Work',
                        r['assigned_work']?.toString() ?? '--',
                      ),
                      _detailRow(
                        Icons.security_outlined,
                        'Create Access',
                        (r['can_create_temple']?.toString() == '1' ||
                                r['can_create_temple'] == 1 ||
                                r['can_create_temple'] == true)
                            ? 'Yes'
                            : 'No',
                        isBadge: true,
                        badgeColor:
                            (r['can_create_temple']?.toString() == '1' ||
                                r['can_create_temple'] == 1 ||
                                r['can_create_temple'] == true)
                            ? Colors.green
                            : Colors.red,
                      ),
                      _detailRow(
                        Icons.show_chart,
                        'Status',
                        r['status']?.toString() ?? '',
                        isBadge: true,
                        badgeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (r['id'] != 'New') {
                            setState(() {
                              _editingId = int.tryParse(
                                r['id']?.toString() ?? '',
                              );
                              _nameController.text =
                                  r['name']?.toString() ?? '';
                              _phoneController.text =
                                  r['phone']?.toString() ?? '';
                              _emailController.text =
                                  r['email']?.toString() ?? '';
                              _workController.text =
                                  r['assigned_work']?.toString() ?? '';
                            });
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Trustee'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isBadge = false,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isBadge
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              badgeColor?.withOpacity(0.3) ??
                              Colors.transparent,
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF1E1B4B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _accessBadge(String line1, String line2, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            line1,
            style: TextStyle(
              fontSize: 10,
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(line2, style: TextStyle(fontSize: 9, color: fg)),
        ],
      ),
    );
  }

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

  Future<void> _showSearchableDropdown({
    required BuildContext context,
    required String? currentValue,
    required List<String> items,
    required Function(String?) onChanged,
  }) async {
    String searchQuery = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredItems = items
                .where(
                  (item) =>
                      item.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 400,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'பயனரைத் தேடவும் (Search user)...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
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
                          borderSide: const BorderSide(
                            color: Color(0xFF6B4EE1),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setStateDialog(() => searchQuery = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        onChanged(null);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          '-- தேர்வை நீக்கு (Clear Selection) --',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final parts = item.split(' - ');
                          final title = parts.isNotEmpty ? parts[0] : item;
                          final subtitle = parts.length > 1
                              ? parts.sublist(1).join('\n')
                              : '';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: subtitle.isNotEmpty
                                ? Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              onChanged(item);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Widget? suffixWidget,
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
      InkWell(
        onTap: () => _showSearchableDropdown(
          context: context,
          currentValue: value,
          items: items,
          onChanged: onChanged,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    color: value == null
                        ? Colors.grey.shade400
                        : Colors.black87,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.grey.shade500,
              ),
              if (suffixWidget != null) suffixWidget,
            ],
          ),
        ),
      ),
    ],
  );
}
