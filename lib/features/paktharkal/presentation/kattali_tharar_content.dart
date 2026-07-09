import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../data/paktharkal_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class KattaliTharalContent extends StatefulWidget {
  const KattaliTharalContent({super.key});

  @override
  State<KattaliTharalContent> createState() => _KattaliTharalContentState();
}

class _KattaliTharalContentState extends State<KattaliTharalContent> {
  final ScrollController _scrollController = ScrollController();
  // Toggle form
  bool _showForm = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Search
  final TextEditingController _searchController = TextEditingController();

  late final PaktharkalApiRepository _apiRepository;
  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _apiRepository = PaktharkalApiRepository(ApiClient());
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiRepository.getKattali();
      setState(() {
        _records = data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _apiRepository.deleteKattali(id);
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
      _nameController.clear();
      _designationController.clear();
      _phoneController.clear();
      _editingId = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
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
          _buildAddSection(),
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
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.indigo,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'கட்டளை தரங்கள் (HR & CE Officials)',
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
        'இந்து சமய அறநிலையத்துறை அதிகாரிகள் மற்றும் ஊழியர்களின் விவரங்களை நிர்வகிக்கலாம்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  // ─── Add Official Section ─────────────────────────────────────────────────────
  Widget _buildAddSection() {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        children: [
          // Always-visible header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'புதிய அதிகாரி (Add New)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _showForm
                    ? OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _showForm = false;
                          _clearForm();
                        }),
                        icon: const Icon(Icons.close, size: 15),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => setState(() => _showForm = true),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Official'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EE1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
              ],
            ),
          ),

          // Expandable form
          if (_showForm) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Name | Designation | Phone
                  _threeRow(
                    _textField(
                      'பெயர் (Name) *',
                      'Name...',
                      _nameController,
                      Icons.person_outline,
                    ),
                    _textField(
                      'பதவி (Designation)',
                      'Designation...',
                      _designationController,
                      Icons.work_outline,
                    ),
                    _textField(
                      'தொலைபேசி (Phone)',
                      'Phone No...',
                      _phoneController,
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'பெயர் கட்டாயம் உள்ளிடவும்!',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);
                                final data = {
                                  'name': _nameController.text.trim(),
                                  'designation': _designationController.text
                                      .trim(),
                                  'phone_number': _phoneController.text.trim(),
                                  'status': 'active',
                                };

                                bool success;
                                if (_editingId == null) {
                                  success = await _apiRepository.addKattali(
                                    data,
                                  );
                                } else {
                                  success = await _apiRepository.updateKattali(
                                    _editingId!,
                                    data,
                                  );
                                }

                                if (success) {
                                  CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
                                  setState(() => _showForm = false);
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
                        label: Text(_editingId == null ? 'Save' : 'Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EE1),
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
            ),
          ],
        ],
      ),
    );
  }

  // ─── Records List ─────────────────────────────────────────────────────────────
  Widget _buildListCard() {
    final q = _searchController.text.toLowerCase();
    final filtered = _records.where((r) {
      return q.isEmpty ||
          (r['name']?.toString().toLowerCase().contains(q) ?? false) ||
          (r['designation']?.toString().toLowerCase().contains(q) ?? false) ||
          (r['phone_number']?.toString().toLowerCase().contains(q) ?? false);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'அதிகாரிகள் பட்டியல் (Records)',
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
                    hintText: 'தேடல்...',
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

          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.grey.shade200),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columnSpacing: 24,
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
                      'அதிகாரி பெயர்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'பதவி',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'தொலைபேசி',
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

                      // Name
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.indigo.shade400,
                              ),
                            ),
                            const SizedBox(width: 10),
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

                      // Designation
                      DataCell(
                        Text(
                          r['designation']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      // Phone
                      DataCell(
                        Text(
                          r['phone_number']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B4EE1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
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
                                        r['name']?.toString() ?? '';
                                    _designationController.text =
                                        r['designation']?.toString() ?? '';
                                    _phoneController.text =
                                        r['phone_number']?.toString() ?? '';
                                    _showForm = true;
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
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                  size: 15,
                                ),
                                onPressed: () => _deleteRecord(r['id']),
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                              ),
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

  // ─── Helpers ──────────────────────────────────────────────────────────────────
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
      if (bc.maxWidth < 750) {
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
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      TextField(controller: ctrl, decoration: _inputDecoration(hint, icon)),
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
          borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
        ),
        filled: true,
        fillColor: Colors.white,
      );
}
