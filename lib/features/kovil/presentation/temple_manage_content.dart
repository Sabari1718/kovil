import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kovil_dropdown_provider.dart';
import '../data/kovil_dropdown_models.dart';

class TempleManageContent extends ConsumerStatefulWidget {
  final Function(String screen, {Map<String, dynamic>? arguments})?
  onScreenSelected;
  const TempleManageContent({super.key, this.onScreenSelected});

  @override
  ConsumerState<TempleManageContent> createState() =>
      _TempleManageContentState();
}

class _TempleManageContentState extends ConsumerState<TempleManageContent> {
  final String _defaultReligion = '-- Select Religion --';
  late String _selectedReligion;

  final String _defaultDeitiesWorship = '-- Select Deities Worship --';
  late String _selectedDeitiesWorship;

  // Text Controllers
  final TextEditingController _mulavarNameController = TextEditingController();
  final TextEditingController _templeNameController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'இந்தியா',
  );

  // Selected Categories
  List<int> _selectedPrimaryCategoryIds = [];
  List<int> _selectedSubCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _selectedReligion = _defaultReligion;
    _selectedDeitiesWorship = _defaultDeitiesWorship;
  }

  @override
  void dispose() {
    _mulavarNameController.dispose();
    _templeNameController.dispose();
    _pincodeController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _selectedReligion = _defaultReligion;
      _selectedDeitiesWorship = _defaultDeitiesWorship;
      _mulavarNameController.clear();
      _templeNameController.clear();
      _pincodeController.clear();
      _villageController.clear();
      _districtController.clear();
      _stateController.clear();
      _countryController.text = 'இந்தியா';
      _selectedPrimaryCategoryIds.clear();
      _selectedSubCategoryIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'புதிய கோவில் சேர்க்க (Add New Temple)',
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
            'கீழே உள்ள படிவத்தைப் பூர்த்தி செய்து புதிய கோவில் விவரங்களைச் சேர்க்கவும்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Main Card
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
                // Form Fields
                _buildResponsiveRow(
                  _buildTextField(
                    'மூலவர் பெயர் (Mulavar Name)',
                    'எ.கா: ஸ்ரீ விநாயகர்',
                    _mulavarNameController,
                  ),
                  _buildTextField(
                    'கோவில் பெயர் (Temple Name)',
                    'எ.கா: அருள்மிகு விநாயகர் கோவில்',
                    _templeNameController,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResponsiveRow(
                  _buildTextField(
                    'பின்கோடு (Pincode)',
                    '# 6 இலக்க பின்கோடு',
                    _pincodeController,
                  ),
                  _buildTextField(
                    'ஊர் (Village/Town)',
                    'ஊரின் பெயரை உள்ளிடவும்',
                    _villageController,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResponsiveRow(
                  _buildTextField(
                    'மாவட்டம் (District)',
                    'மாவட்டத்தின் பெயரை உள்ளிடவும்',
                    _districtController,
                  ),
                  _buildTextField(
                    'மாநிலம் (State)',
                    'மாநிலத்தின் பெயரை உள்ளிடவும்',
                    _stateController,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResponsiveRow(
                  _buildTextField(
                    'நாடு (Country)',
                    'இந்தியா',
                    _countryController,
                    prefixIcon: const Icon(
                      Icons.public,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox.shrink(), // Placeholder for empty slot to match responsiveness
                ),
                const SizedBox(height: 24),

                // Dropdowns
                _buildResponsiveRow(
                  ref
                      .watch(sectorsProvider)
                      .when(
                        data: (sectors) {
                          final items = [
                            _defaultReligion,
                            'Hindu',
                          ];
                          if (!items.contains(_selectedReligion)) {
                            _selectedReligion = _defaultReligion;
                          }
                          return _buildDropdownField(
                            'மதம் (Religion) *',
                            _selectedReligion,
                            items,
                            (val) {
                              setState(() {
                                _selectedReligion = val!;
                                _selectedDeitiesWorship =
                                    _defaultDeitiesWorship;
                              });
                            },
                            isRedAsterisk: true,
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => Text('Error: $err'),
                      ),
                  ref
                      .watch(subSectorsProvider)
                      .when(
                        data: (subSectors) {
                          final filteredSubSectors = subSectors
                              .where((e) => e.sectorName == _selectedReligion)
                              .toList();
                          final items = [
                            _defaultDeitiesWorship,
                            ...filteredSubSectors.map((e) => e.subSectorName),
                          ];
                          if (!items.contains(_selectedDeitiesWorship)) {
                            // Safe state update outside build phase if necessary, or just rely on items having the default
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted &&
                                  _selectedDeitiesWorship !=
                                      _defaultDeitiesWorship) {
                                setState(
                                  () => _selectedDeitiesWorship =
                                      _defaultDeitiesWorship,
                                );
                              }
                            });
                          }

                          // fallback if _selectedDeitiesWorship is completely invalid for some reason during build
                          final displayValue =
                              items.contains(_selectedDeitiesWorship)
                              ? _selectedDeitiesWorship
                              : _defaultDeitiesWorship;

                          return _buildDropdownField(
                            'தெய்வங்கள் வழிபாடு (Deities Worship) *',
                            displayValue,
                            items,
                            (val) =>
                                setState(() => _selectedDeitiesWorship = val!),
                            isRedAsterisk: true,
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => Text('Error: $err'),
                      ),
                ),
                const SizedBox(height: 24),

                // Categories
                _buildCategoriesSection(),

                const SizedBox(height: 16),

                // Selected Chips
                _buildSelectedChips(),

                const SizedBox(height: 48),

                // Action Buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: _buildCancelButton(),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: _buildNextStepButton(),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildCancelButton()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildNextStepButton()),
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

  Widget _buildCategoriesSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final primarySection = _buildPrimaryCategoriesCard();
        final subSection = _buildSubCategoriesCard();

        if (isMobile) {
          return Column(
            children: [primarySection, const SizedBox(height: 16), subSection],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: primarySection),
            const SizedBox(width: 16),
            Expanded(child: subSection),
          ],
        );
      },
    );
  }

  Widget _buildPrimaryCategoriesCard() {
    final subSectors = ref.watch(subSectorsProvider).value ?? [];
    final selectedSubSector = subSectors
        .where((s) => s.subSectorName == _selectedDeitiesWorship)
        .firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Primary Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                ref
                    .watch(categoriesProvider)
                    .when(
                      data: (categories) {
                        final filtered = selectedSubSector == null
                            ? []
                            : categories
                                  .where(
                                    (c) =>
                                        c.subSectorId == selectedSubSector.id &&
                                        c.categoryType != 'secondary',
                                  )
                                  .toList();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filtered.length} Available',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ref
                .watch(categoriesProvider)
                .when(
                  data: (categories) {
                    if (selectedSubSector == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Select Deities Worship first to load primary categories.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    }

                    final filtered = categories
                        .where(
                          (c) =>
                              c.subSectorId == selectedSubSector.id &&
                              c.categoryType != 'secondary',
                        )
                        .toList();
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No primary categories found.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: filtered.map((c) {
                        return Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            title: Text(
                              c.categoryName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            value: _selectedPrimaryCategoryIds.contains(c.id),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedPrimaryCategoryIds.add(c.id);
                                } else {
                                  _selectedPrimaryCategoryIds.remove(c.id);
                                }
                                // Clear sub-categories when primary changes
                                _selectedSubCategoryIds.clear();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sub Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                ref
                    .watch(categoriesProvider)
                    .when(
                      data: (categories) {
                        final filtered = _selectedPrimaryCategoryIds.isEmpty
                            ? []
                            : categories
                                  .where(
                                    (c) => _selectedPrimaryCategoryIds.contains(
                                      c.parentCategoryId,
                                    ),
                                  )
                                  .toList();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filtered.length} Showing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ref
                .watch(categoriesProvider)
                .when(
                  data: (categories) {
                    if (_selectedPrimaryCategoryIds.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'Select primary categories first to load sub categories.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final filtered = categories
                        .where(
                          (c) => _selectedPrimaryCategoryIds.contains(
                            c.parentCategoryId,
                          ),
                        )
                        .toList();
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'No sub categories found for selected primary categories.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: filtered.map((c) {
                        return Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            title: Text(
                              c.categoryName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            value: _selectedSubCategoryIds.contains(c.id),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedSubCategoryIds.add(c.id);
                                } else {
                                  _selectedSubCategoryIds.remove(c.id);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChips() {
    return ref
        .watch(categoriesProvider)
        .when(
          data: (categories) {
            if (_selectedPrimaryCategoryIds.isEmpty &&
                _selectedSubCategoryIds.isEmpty) {
              return const SizedBox();
            }

            final selectedPrimary = categories
                .where((c) => _selectedPrimaryCategoryIds.contains(c.id))
                .toList();
            final selectedSub = categories
                .where((c) => _selectedSubCategoryIds.contains(c.id))
                .toList();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedPrimary.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8, right: 8),
                          child: Text(
                            'Primary:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedPrimary.map((c) {
                              return InputChip(
                                label: Text(
                                  c.categoryName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade50,
                                deleteIconColor: Colors.blueAccent,
                                onDeleted: () {
                                  setState(() {
                                    _selectedPrimaryCategoryIds.remove(c.id);
                                    // Remove child subcategories if primary is removed
                                    final childrenToRemove = categories
                                        .where(
                                          (sub) => sub.parentCategoryId == c.id,
                                        )
                                        .map((sub) => sub.id);
                                    _selectedSubCategoryIds.removeWhere(
                                      (id) => childrenToRemove.contains(id),
                                    );
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.blue.shade100),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  if (selectedPrimary.isNotEmpty && selectedSub.isNotEmpty)
                    const SizedBox(height: 16),
                  if (selectedSub.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8, right: 8),
                          child: Text(
                            'Sub:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedSub.map((c) {
                              return InputChip(
                                label: Text(
                                  c.categoryName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade50,
                                deleteIconColor: Colors.blueAccent,
                                onDeleted: () {
                                  setState(() {
                                    _selectedSubCategoryIds.remove(c.id);
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.blue.shade100),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        );
  }

  Widget _buildDropdownField(
    String label,
    String selectedValue,
    List<String> items,
    Function(String?) onChanged, {
    bool isRedAsterisk = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isRedAsterisk
                  ? const Color(0xFF1E1B4B)
                  : const Color(0xFF524EE1),
            ),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
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

  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
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
    TextEditingController controller, {
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: prefixIcon,
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

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _clearForm,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Cancel'),
    );
  }

  Widget _buildNextStepButton() {
    return ElevatedButton(
      onPressed: () async {
        // Validate dropdowns
        if (_selectedReligion == _defaultReligion ||
            _selectedDeitiesWorship == _defaultDeitiesWorship) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select Religion and Deities Worship.'),
            ),
          );
          return;
        }

        // Find the selected sector and sub-sector models
        final sectors = ref.read(sectorsProvider).value ?? [];
        final selectedSector = sectors.firstWhere(
          (s) => s.sectorName == _selectedReligion,
        );

        final subSectors = ref.read(subSectorsProvider).value ?? [];
        final selectedSubSector = subSectors.firstWhere(
          (s) => s.subSectorName == _selectedDeitiesWorship,
        );

        final data = {
          'country': _countryController.text,
          'district': _districtController.text,
          'mulavar_name': _mulavarNameController.text,
          'pincode': _pincodeController.text,
          'primary_category_ids': _selectedPrimaryCategoryIds,
          'sector_id': selectedSector.id,
          'sector_name': selectedSector.sectorName,
          'sector_title_id': selectedSector.sectorTitleId,
          'sector_title_name': selectedSector.sectorTitleName,
          'state': _stateController.text,
          'sub_category_ids': _selectedSubCategoryIds,
          'sub_sector_id': selectedSubSector.id,
          'sub_sector_name': selectedSubSector.subSectorName,
          'temple_name': _templeNameController.text,
          'village_name': _villageController.text,
        };

        try {
          final templeId = await ref
              .read(kovilApiRepositoryProvider)
              .addTemple(data);
          if (templeId != null && mounted) {
            await CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');

            final String mulavar = _mulavarNameController.text;
            final String templeName = _templeNameController.text;

            _clearForm();

            if (widget.onScreenSelected != null) {
              widget.onScreenSelected!(
                'கோவில்',
                arguments: {
                  'basicId': templeId,
                  'mulavarName': mulavar,
                  'templeName': templeName,
                },
              );
            }
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add temple.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF524EE1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Next Step'),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}
