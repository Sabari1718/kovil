import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import '../data/deities_api_repository.dart';

class AddDeitiesContent extends ConsumerStatefulWidget {
  final Function(String, {Map<String, dynamic>? arguments}) onScreenSelected;
  const AddDeitiesContent({super.key, required this.onScreenSelected});

  @override
  ConsumerState<AddDeitiesContent> createState() => _AddDeitiesContentState();
}

class _AddDeitiesContentState extends ConsumerState<AddDeitiesContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final String _defaultDeityType = 'அனைத்து வகைகள் (தவிர மூலவர்)';
  late String _selectedDeityType;

  List<Map<String, dynamic>> _allDeities = [];
  List<Map<String, dynamic>> _filteredDeities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDeityType = _defaultDeityType;
    _searchController.addListener(_filterList);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllDeities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllDeities() async {
    setState(() => _isLoading = true);
    final repo = ref.read(deitiesApiRepositoryProvider);
    List<Map<String, dynamic>> combined = [];

    try {
      final parivaraResp = await repo.fetchParivaraDeivams();
      if (parivaraResp['code'] == 200 && parivaraResp['data'] != null) {
        final list = List<Map<String, dynamic>>.from(parivaraResp['data']);
        for (var item in list) {
          combined.add({
            'id': item['id'],
            'name': item['name'] ?? '',
            'type': 'பரிவார தெய்வங்கள்',
            'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
            'status': item['status'] == 1 ? 'Active' : 'Inactive',
            'raw': item,
          });
        }
      }

      final kovilResp = await repo.fetchKovilDeivangal();
      if (kovilResp['code'] == 200 && kovilResp['data'] != null) {
        final list = List<Map<String, dynamic>>.from(kovilResp['data']);
        for (var item in list) {
          combined.add({
            'id': item['id'],
            'name': item['name'] ?? '',
            'type': 'கோவில் தெய்வங்கள்',
            'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
            'status': item['status'] == 1 || item['status'] == 'Active' ? 'Active' : 'Inactive',
            'raw': item,
          });
        }
      }

      final pigaraList = await repo.getPigaraDeivams();
      for (var item in pigaraList) {
        combined.add({
          'id': item['id'],
          'name': item['name'] ?? '',
          'type': 'பிகரா தெய்வங்கள்',
          'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
          'status': item['status'] == 1 ? 'Active' : 'Inactive',
          'raw': item,
        });
      }

      final upaList = await repo.getUbaDeivams();
      for (var item in upaList) {
        combined.add({
          'id': item['id'],
          'name': item['name'] ?? '',
          'type': 'உப தெய்வங்கள்',
          'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
          'status': item['status'] == 1 ? 'Active' : 'Inactive',
          'raw': item,
        });
      }

      final kavalList = await repo.getKavalDeivams();
      for (var item in kavalList) {
        combined.add({
          'id': item['id'],
          'name': item['name'] ?? '',
          'type': 'காவல் தெய்வங்கள்',
          'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
          'status': item['status'] == 1 ? 'Active' : 'Inactive',
          'raw': item,
        });
      }

      final baliList = await repo.getBaliDeivams();
      for (var item in baliList) {
        combined.add({
          'id': item['id'],
          'name': item['name'] ?? '',
          'type': 'பாலி தெய்வங்கள்',
          'pooja': item['worshipMethod'] ?? item['specialPuja'] ?? '-',
          'status': item['status'] == 1 ? 'Active' : 'Inactive',
          'raw': item,
        });
      }
    } catch (e) {
      print('Error fetching deities: $e');
    }

    if (mounted) {
      setState(() {
        _allDeities = combined;
        _isLoading = false;
      });
      _filterList();
    }
  }

  Future<void> _deleteDeity(int id, String type) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      setState(() => _isLoading = true);
      final repo = ref.read(deitiesApiRepositoryProvider);
      bool success = false;
      if (type == 'பரிவார தெய்வங்கள்') {
        success = await repo.deleteParivaraDeivam(id);
      } else if (type == 'பிகரா தெய்வங்கள்') {
        success = await repo.deletePigaraDeivam(id);
      } else if (type == 'உப தெய்வங்கள்') {
        success = await repo.deleteUbaDeivam(id);
      } else if (type == 'காவல் தெய்வங்கள்') {
        success = await repo.deleteKavalDeivam(id);
      } else if (type == 'பாலி தெய்வங்கள்') {
        success = await repo.deleteBaliDeivam(id);
      } else if (type == 'கோவில் தெய்வங்கள்') {
        success = await repo.deleteKovilDeivangal(id);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          await CustomDeleteDialog.showDeleted(context);
          _fetchAllDeities();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete deity'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDeities = _allDeities.where((deity) {
        final matchesSearch = deity['name']!.toLowerCase().contains(query);
        final matchesType =
            _selectedDeityType == _defaultDeityType ||
            deity['type'] == _selectedDeityType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, color: Colors.indigo, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'தெய்வங்கள் மேலாண்மை (Deities Management)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'அனைத்து வகையான தெய்வங்கள் மற்றும் அவர்களின் பூஜை விவரங்களை இங்கே நிர்வகிக்கலாம்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Quick Navigation Cards (Grid)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _buildQuickCard('பரிவார தெய்வங்கள்', 'PARIVARA DEITIES', const [
                Color(0xFF4F46E5),
                Color(0xFF3730A3),
              ], Icons.people_outline),
              _buildQuickCard('பிகரா தெய்வங்கள்', 'PIGARA DEITIES', const [
                Color(0xFF0D9488),
                Color(0xFF115E59),
              ], Icons.shield_outlined),
              _buildQuickCard('உப தெய்வங்கள்', 'UPA DEITIES', const [
                Color(0xFF8B5CF6),
                Color(0xFF6D28D9),
              ], Icons.layers_outlined),
              _buildQuickCard('காவல் தெய்வங்கள்', 'KAVAL DEITIES', const [
                Color(0xFFEF4444),
                Color(0xFF991B1B),
              ], Icons.security),
              _buildQuickCard('பாலி தெய்வங்கள்', 'BALI DEITIES', const [
                Color(0xFFF59E0B),
                Color(0xFFD97706),
              ], Icons.menu_book),
              _buildQuickCard(
                'கோவில் தெய்வங்கள்',
                'KOVIL DEITIES',
                const [Color(0xFFEC4899), Color(0xFFBE185D)],
                Icons.favorite_border,
                targetScreen: 'கோவில் தெய்வங்கள் சேர்க்க',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Main Card containing table
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
                // List Title and Add Button
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
                                  'அனைத்து தெய்வங்கள் பட்டியல்',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1B4B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAddDeityPopupMenu(),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              'அனைத்து தெய்வங்கள் பட்டியல்',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ],
                        ),
                        _buildAddDeityPopupMenu(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Search and Filters
                _buildSearchAndFilters(),
                const SizedBox(height: 24),

                // Table (Scrollable horizontally)
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
                            'படம்',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'தெய்வ பெயர்',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'தெய்வ வகை',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'பூஜைகள்',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'நிலை',
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
                      rows: _isLoading
                          ? [
                              const DataRow(
                                cells: [
                                  DataCell(SizedBox()),
                                  DataCell(SizedBox()),
                                  DataCell(
                                    Center(child: CircularProgressIndicator()),
                                  ),
                                  DataCell(SizedBox()),
                                  DataCell(SizedBox()),
                                  DataCell(SizedBox()),
                                ],
                              ),
                            ]
                          : _filteredDeities.map((deity) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    CircleAvatar(
                                      backgroundColor: Colors.indigo.shade50,
                                      radius: 18,
                                      child: Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: Colors.indigo.shade400,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      deity['name'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _buildTypeBadge(deity['type'].toString()),
                                  ),
                                  DataCell(
                                    Text(
                                      deity['pooja'].toString(),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _buildStatusBadge(
                                      deity['status'].toString(),
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
                                          onPressed: () {
                                            final type = deity['type'];
                                            if (type != null) {
                                              String screenName = type.toString();
                                              if (screenName == 'கோவில் தெய்வங்கள்') {
                                                screenName = 'கோவில் தெய்வங்கள் சேர்க்க';
                                              }
                                              widget.onScreenSelected(
                                                screenName,
                                                arguments: {'editDeity': deity['raw']},
                                              );
                                            }
                                          },
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
                                            _deleteDeity(
                                              int.parse(deity['id'].toString()),
                                              deity['type'].toString(),
                                            );
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
    );
  }

  Widget _buildQuickCard(
    String title,
    String subtitle,
    List<Color> colors,
    IconData icon, {
    String? targetScreen,
  }) {
    return InkWell(
      onTap: () {
        widget.onScreenSelected(targetScreen ?? title);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            Text(
              'நிர்வகிக்க >',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDeityPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (val) {
        String screenName = val;
        if (screenName == 'கோவில் தெய்வங்கள்') {
          screenName = 'கோவில் தெய்வங்கள் சேர்க்க';
        }
        widget.onScreenSelected(screenName);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        _buildPopupMenuItem('கோவில் தெய்வங்கள்', Icons.favorite_border),
        _buildPopupMenuItem('பரிவார தெய்வங்கள்', Icons.people_outline),
        _buildPopupMenuItem('பிகரா தெய்வங்கள்', Icons.shield_outlined),
        _buildPopupMenuItem('உப தெய்வங்கள்', Icons.layers_outlined),
        _buildPopupMenuItem('பாலி தெய்வங்கள்', Icons.menu_book),
        _buildPopupMenuItem('காவல் தெய்வங்கள்', Icons.security),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF524EE1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'புதிய தெய்வம் சேர்க்க',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.indigo.shade400, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildDeityTypeDropdown(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSearchField()),
            const SizedBox(width: 16),
            Expanded(child: _buildDeityTypeDropdown()),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'தேடல் (Search)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'பெயர் மூலம் தேடு...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
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

  Widget _buildDeityTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'தெய்வ வகை (Deity Type)',
          style: TextStyle(
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
              value: _selectedDeityType,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items:
                  [
                    _defaultDeityType,
                    'கோவில் தெய்வங்கள்',
                    'பரிவார தெய்வங்கள்',
                    'பிகரா தெய்வங்கள்',
                    'உப தெய்வங்கள்',
                    'பாலி தெய்வங்கள்',
                    'காவல் தெய்வங்கள்',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          color: value == _defaultDeityType
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedDeityType = val;
                    _filterList();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = Colors.grey;
    switch (type) {
      case 'கோவில் தெய்வங்கள்':
        color = Colors.pink;
        break;
      case 'பரிவார தெய்வங்கள்':
        color = Colors.blue;
        break;
      case 'பிகரா தெய்வங்கள்':
        color = Colors.teal;
        break;
      case 'உப தெய்வங்கள்':
        color = Colors.purple;
        break;
      case 'பாலி தெய்வங்கள்':
        color = Colors.orange;
        break;
      case 'காவல் தெய்வங்கள்':
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.green : Colors.blue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
