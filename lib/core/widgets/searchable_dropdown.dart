import 'package:flutter/material.dart';

class SearchableDropdown extends StatelessWidget {
  final List<dynamic> items;
  final String hint;
  final String Function(dynamic item) displayBuilder;
  final String valueKey;
  final String? selectedValue;
  final Function(String?) onChanged;
  final String searchTitle;
  final bool showSearch;
  final String? resetOptionLabel;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.hint,
    required this.displayBuilder,
    required this.valueKey,
    required this.selectedValue,
    required this.onChanged,
    required this.searchTitle,
    this.showSearch = true,
    this.resetOptionLabel,
  });

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SearchDialog(
          title: searchTitle,
          items: items,
          displayBuilder: displayBuilder,
          valueKey: valueKey,
          selectedValue: selectedValue,
          onChanged: onChanged,
          showSearch: showSearch,
          resetOptionLabel: resetOptionLabel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSearchDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: (() {
                if (selectedValue != null) {
                  dynamic selectedItem;
                  for (final item in items) {
                    if (item[valueKey]?.toString() == selectedValue) {
                      selectedItem = item;
                      break;
                    }
                  }
                  if (selectedItem != null) {
                    return Text(
                      displayBuilder(selectedItem),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                }
                return Text(
                  resetOptionLabel ?? hint,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              })(),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String Function(dynamic item) displayBuilder;
  final String valueKey;
  final String? selectedValue;
  final Function(String?) onChanged;
  final bool showSearch;
  final String? resetOptionLabel;

  const SearchDialog({
    super.key,
    required this.title,
    required this.items,
    required this.displayBuilder,
    required this.valueKey,
    required this.selectedValue,
    required this.onChanged,
    this.showSearch = true,
    this.resetOptionLabel,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filter);
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final display = widget.displayBuilder(item).toLowerCase();
        return display.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = List<dynamic>.from(_filteredItems);
    if (widget.title.contains('தலைமுறை') || widget.title.toLowerCase().contains('generation')) {
      // Keep generation in original numerical order
    } else {
      // Sort alphabetically (A to Z) based on displayBuilder Tamil/English display name
      sortedItems.sort((a, b) {
        final nameA = widget.displayBuilder(a).toLowerCase();
        final nameB = widget.displayBuilder(b).toLowerCase();
        return nameA.compareTo(nameB);
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (widget.showSearch) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search (தேடவும்)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: (sortedItems.isEmpty && widget.resetOptionLabel == null)
                  ? const Center(
                      child: Text(
                        'தகவல் எதுவும் இல்லை (No results found)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedItems.length + (widget.resetOptionLabel != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (widget.resetOptionLabel != null && index == 0) {
                          final isSelected = widget.selectedValue == null;

                          return ListTile(
                            title: Text(
                              widget.resetOptionLabel!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? const Color(0xFF524EE1) : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: Color(0xFF524EE1), size: 18)
                                : null,
                            onTap: () {
                              widget.onChanged(null);
                              Navigator.pop(context);
                            },
                          );
                        }

                        final actualIndex = widget.resetOptionLabel != null ? index - 1 : index;
                        final item = sortedItems[actualIndex];
                        final displayVal = widget.displayBuilder(item);
                        final val = item[widget.valueKey]?.toString() ?? '';
                        final isSelected = widget.selectedValue == val;

                        return ListTile(
                          title: Text(
                            displayVal,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? const Color(0xFF524EE1) : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Color(0xFF524EE1), size: 18)
                              : null,
                          onTap: () {
                            widget.onChanged(val);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
