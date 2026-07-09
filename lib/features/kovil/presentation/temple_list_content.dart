import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/kovil_api_repository.dart';
import '../providers/kovil_dropdown_provider.dart';
import 'temple_extra_details_content.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class TempleListContent extends ConsumerStatefulWidget {
  final Function(String) onScreenSelected;
  const TempleListContent({super.key, required this.onScreenSelected});

  @override
  ConsumerState<TempleListContent> createState() => _TempleListContentState();
}

class _TempleListContentState extends ConsumerState<TempleListContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _pageSize = 10;
  int _currentPage = 1;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allTemples = [];
  List<Map<String, dynamic>> _filteredTemples = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterList);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTemples();
    });
  }

  Future<void> _fetchTemples() async {
    setState(() => _isLoading = true);
    final repository = ref.read(kovilApiRepositoryProvider);
    final temples = await repository.getTempleDetails();
    if (mounted) {
      setState(() {
        _allTemples = temples;
        _filteredTemples = _allTemples;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTemples = _allTemples.where((temple) {
        final names = (temple['other_names'] ?? temple['temple_name'] ?? '')
            .toString()
            .toLowerCase();
        final special = (temple['special_features'] ?? '')
            .toString()
            .toLowerCase();
        final id = (temple['id'] ?? '').toString().toLowerCase();
        return names.contains(query) ||
            special.contains(query) ||
            id.contains(query);
      }).toList();
      _currentPage = 1; // Reset to first page on search
    });
  }

  void _editTemple(Map<String, dynamic> templeData) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 800,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  title: Text(
                    'கோவில் திருத்தம் (Edit Temple) - #${templeData['id']}',
                    style: const TextStyle(
                      color: Color(0xFF1E1B4B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: TempleExtraDetailsContent(
                  basicId: templeData['id'] is int
                      ? templeData['id']
                      : int.tryParse(templeData['id'].toString()),
                  initialData: templeData,
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // Refresh list after editing
      _fetchTemples();
    });
  }

  Future<void> _deleteTemple(Map<String, dynamic> temple) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      final repository = ref.read(kovilApiRepositoryProvider);
      int? templeId = temple['id'] is int
          ? temple['id']
          : int.tryParse(temple['id'].toString());
      if (templeId != null) {
        // Attempt to delete via API
        bool success = await repository.deleteTempleDetails(templeId);
        if (success) {
          // Remove locally to ensure it disappears
          setState(() {
            _allTemples.removeWhere((t) => t['id'] == temple['id']);
            _filterList();
          });
          if (mounted) {
            await CustomDeleteDialog.showDeleted(context);
          }
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
  }

  @override
  Widget build(BuildContext context) {
    // Paginated list calculation
    final totalItems = _filteredTemples.length;
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize) > totalItems
        ? totalItems
        : (startIndex + _pageSize);
    final displayedTemples = totalItems > 0
        ? _filteredTemples.sublist(startIndex, endIndex)
        : <Map<String, dynamic>>[];

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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'கோவில் பட்டியல் (Temple List)',
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
            'அனைத்து கோவில் விவரங்களை இங்கே நிர்வகிக்கவும்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Main Card containing search, controls and list table
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
                // Top controls row (+ Add Temple Button & Controls)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final addButton = ElevatedButton.icon(
                      onPressed: () {
                        widget.onScreenSelected('கோவில் சேர்க்க');
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('கோவில் சேர்க்க'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF524EE1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: double.infinity, child: addButton),
                          const SizedBox(height: 16),
                          _buildSearchField(),
                          const SizedBox(height: 12),
                          _buildPageSizeSelector(),
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildSearchField()),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            _buildPageSizeSelector(),
                            const SizedBox(width: 16),
                            addButton,
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (!_isLoading)
                  // Responsive Table
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
                        horizontalMargin: 12,
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
                              'தல பெயர்கள்',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'தல சிறப்பு',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'தொன்மை',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'அமைப்பு',
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
                              'பாடல் பெற்ற',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'தேதி',
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
                            ? []
                            : displayedTemples.map((temple) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        temple['id']?.toString() ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          (temple['other_names'] ??
                                                  temple['temple_name'] ??
                                                  '')
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          (temple['special_features'] ?? '')
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 180,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.history,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                (temple['heritage'] ?? '')
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 180,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.architecture,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                (temple['temple_structure'] ??
                                                        '')
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
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
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          (temple['status'] ?? '').toString(),
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          (temple['song_place']?.toString() ==
                                                  '1'
                                              ? 'ஆம்'
                                              : 'இல்லை'),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (temple['created_date'] ?? '')
                                            .toString()
                                            .split('T')
                                            .first,
                                        style: const TextStyle(
                                          color: Colors.black54,
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
                                                _editTemple(temple),
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
                                            onPressed: () =>
                                                _deleteTemple(temple),
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
                const SizedBox(height: 24),

                // Pagination Footer
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final paginationButtons = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '< Prev',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF524EE1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: endIndex < totalItems
                              ? () => setState(() => _currentPage++)
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Next >',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          Text(
                            'Showing ${totalItems > 0 ? startIndex + 1 : 0} to $endIndex of $totalItems temples',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          paginationButtons,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${totalItems > 0 ? startIndex + 1 : 0} to $endIndex of $totalItems temples',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        paginationButtons,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name or ID...',
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
    );
  }

  Widget _buildPageSizeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Page Size:',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _pageSize,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              items: [5, 10, 20, 50].map((int val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(val.toString()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _pageSize = val;
                    _currentPage = 1;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
