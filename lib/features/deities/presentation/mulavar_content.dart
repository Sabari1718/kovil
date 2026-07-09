import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/deities_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class MulavarContent extends ConsumerStatefulWidget {
  const MulavarContent({super.key});

  @override
  ConsumerState<MulavarContent> createState() => _MulavarContentState();
}

class _MulavarContentState extends ConsumerState<MulavarContent> {
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingMoolavars = false;
  bool _isSavingMoolavar = false;
  List<Map<String, dynamic>> _moolavars = [];

  // Dropdown Defaults
  final String _defaultStatus = '-- Select நிலை (Status) --';
  late String _selectedStatus;

  final String _defaultGopuram = '-- Select விமானம் / கோபுரம் --';
  late String _selectedGopuram;

  // Single Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _thirunamamController = TextEditingController();
  final TextEditingController _thirunamamSpecialityController =
      TextEditingController();
  final TextEditingController _vahanaController = TextEditingController();
  final TextEditingController _sthalaVrikshamController =
      TextEditingController();
  final TextEditingController _flowerController = TextEditingController();
  final TextEditingController _worshipTimeController = TextEditingController();

  // Dynamic Text Controllers Lists
  final List<TextEditingController> _specialNameControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _deityFormControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _deityFormSpecialityControllers = [
    TextEditingController(),
  ];

  // Checkboxes
  bool _hasUtsavarPhoto = false;
  bool _hasChariotPhoto = false;
  bool _hasBalipitham = false;
  bool _hasKodimaram = false;

  // Image files states
  List<XFile> _moolavarPhotos = [];
  XFile? _utsavarPhoto;
  XFile? _chariotPhoto;

  int? _editMoolavarId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = _defaultStatus;
    _selectedGopuram = _defaultGopuram;
    _fetchMoolavars();
  }

  Future<void> _fetchMoolavars() async {
    setState(() => _isLoadingMoolavars = true);
    final repo = ref.read(deitiesApiRepositoryProvider);
    final data = await repo.getMoolavars();
    if (mounted) {
      setState(() {
        _moolavars = data;
        _isLoadingMoolavars = false;
      });
    }
  }

  Future<void> _saveMoolavar() async {
    setState(() => _isSavingMoolavar = true);

    String specialNames = _specialNameControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    String deityForms = _deityFormControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    String formSpecialities = _deityFormSpecialityControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');

    final data = {
      'status': _selectedStatus == _defaultStatus ? '' : _selectedStatus,
      'name': _nameController.text.trim(),
      'deity_name': _thirunamamController.text.trim(),
      'special_name': specialNames,
      'deity_form': deityForms,
      'form_speciality': formSpecialities,
      'divine_speciality': _thirunamamSpecialityController.text.trim(),
      'vehicle': _vahanaController.text.trim(),
      'temple_tree': _sthalaVrikshamController.text.trim(),
      'preferred_flower': _flowerController.text.trim(),
      'vimana_level': _selectedGopuram == _defaultGopuram
          ? ''
          : _selectedGopuram,
      'worship_time': _worshipTimeController.text.trim(),
      'utsavar_photo': _hasUtsavarPhoto ? '1' : '0',
      'chariot_photo': _hasChariotPhoto ? '1' : '0',
      'balipitham': _hasBalipitham ? '1' : '0',
      'kodimaram': _hasKodimaram ? '1' : '0',
      'temple_id': '1', // Hardcoded as per your payload
    };

    final repo = ref.read(deitiesApiRepositoryProvider);
    final success = _editMoolavarId != null
        ? await repo.updateMoolavar(
            _editMoolavarId!,
            data,
            _moolavarPhotos,
            _utsavarPhoto,
            _chariotPhoto,
          )
        : await repo.addMoolavar(
            data,
            _moolavarPhotos,
            _utsavarPhoto,
            _chariotPhoto,
          );

    if (mounted) {
      setState(() => _isSavingMoolavar = false);
      if (success) {
        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        _clearForm();
        await Future.delayed(const Duration(milliseconds: 500));
        _fetchMoolavars();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('சேமிப்பதில் பிழை ஏற்பட்டது.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _thirunamamController.dispose();
    _thirunamamSpecialityController.dispose();
    _vahanaController.dispose();
    _sthalaVrikshamController.dispose();
    _flowerController.dispose();
    _worshipTimeController.dispose();

    for (var controller in _specialNameControllers) {
      controller.dispose();
    }
    for (var controller in _deityFormControllers) {
      controller.dispose();
    }
    for (var controller in _deityFormSpecialityControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _cancelEdit() {
    _clearForm();
  }

  void _editMoolavar(Map<String, dynamic> moolavar) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    _clearForm();
    setState(() {
      _editMoolavarId = moolavar['id'];

      final status = moolavar['status']?.toString() ?? '';
      final allowedStatuses = [
        _defaultStatus,
        'அருவம்',
        'உருவம்',
        'அருவுருவம்',
      ];
      _selectedStatus = allowedStatuses.contains(status)
          ? status
          : _defaultStatus;

      final gopuram = moolavar['vimana_level']?.toString() ?? '';
      final allowedGopurams = [
        _defaultGopuram,
        'ஒன்று',
        'மூன்று',
        'ஐந்து',
        'ஏழு',
        'ஒன்பது',
        'பதினொன்று',
      ];
      _selectedGopuram = allowedGopurams.contains(gopuram)
          ? gopuram
          : _defaultGopuram;

      _nameController.text = moolavar['name']?.toString() ?? '';
      _thirunamamController.text = moolavar['deity_name']?.toString() ?? '';
      _thirunamamSpecialityController.text =
          moolavar['divine_speciality']?.toString() ?? '';
      _vahanaController.text = moolavar['vehicle']?.toString() ?? '';
      _sthalaVrikshamController.text =
          moolavar['temple_tree']?.toString() ?? '';
      _flowerController.text = moolavar['preferred_flower']?.toString() ?? '';
      _worshipTimeController.text = moolavar['worship_time']?.toString() ?? '';

      // Special Names
      final sNames = (moolavar['special_name']?.toString() ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (sNames.isNotEmpty) {
        _specialNameControllers.clear();
        for (var name in sNames) {
          _specialNameControllers.add(TextEditingController(text: name));
        }
      }

      // Deity Forms
      final dForms = (moolavar['deity_form']?.toString() ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (dForms.isNotEmpty) {
        _deityFormControllers.clear();
        for (var form in dForms) {
          _deityFormControllers.add(TextEditingController(text: form));
        }
      }

      // Form Specialities
      final fSpecs = (moolavar['form_speciality']?.toString() ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (fSpecs.isNotEmpty) {
        _deityFormSpecialityControllers.clear();
        for (var spec in fSpecs) {
          _deityFormSpecialityControllers.add(
            TextEditingController(text: spec),
          );
        }
      }

      // Checkboxes
      _hasUtsavarPhoto =
          moolavar['utsavar_photo'] == 1 || moolavar['utsavar_photo'] == '1';
      _hasChariotPhoto =
          moolavar['chariot_photo'] == 1 || moolavar['chariot_photo'] == '1';
      _hasBalipitham =
          moolavar['balipitham'] == 1 || moolavar['balipitham'] == '1';
      _hasKodimaram =
          moolavar['kodimaram'] == 1 || moolavar['kodimaram'] == '1';

      // Photos (Note: We do not prepopulate XFiles for existing photos, only allow adding new ones)
    });

    _scrollController.jumpTo(0);
  }

  Future<void> _deleteMoolavar(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      final repo = ref.read(deitiesApiRepositoryProvider);
      final success = await repo.deleteMoolavar(id);
      if (mounted) {
        if (success) {
          await CustomDeleteDialog.showDeleted(context);
          _fetchMoolavars();
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
  }

  void _clearForm() {
    setState(() {
      _selectedStatus = _defaultStatus;
      _selectedGopuram = _defaultGopuram;

      _nameController.clear();
      _thirunamamController.clear();
      _thirunamamSpecialityController.clear();
      _vahanaController.clear();
      _sthalaVrikshamController.clear();
      _flowerController.clear();
      _worshipTimeController.clear();

      // Reset dynamic lists to single empty controller
      for (var controller in _specialNameControllers) {
        controller.dispose();
      }
      _specialNameControllers.clear();
      _specialNameControllers.add(TextEditingController());

      for (var controller in _deityFormControllers) {
        controller.dispose();
      }
      _deityFormControllers.clear();
      _deityFormControllers.add(TextEditingController());

      for (var controller in _deityFormSpecialityControllers) {
        controller.dispose();
      }
      _deityFormSpecialityControllers.clear();
      _deityFormSpecialityControllers.add(TextEditingController());

      // Reset checkboxes
      _hasUtsavarPhoto = false;
      _hasChariotPhoto = false;
      _hasBalipitham = false;
      _hasKodimaram = false;

      // Reset images
      _moolavarPhotos.clear();
      _utsavarPhoto = null;
      _chariotPhoto = null;
      _editMoolavarId = null;
    });
  }

  Future<void> _pickImage(void Function(XFile?) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          onPicked(image);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickMoolavarImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _moolavarPhotos.addAll(images);
          if (_moolavarPhotos.length > 5) {
            _moolavarPhotos = _moolavarPhotos.sublist(0, 5);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
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
                      'மூலவர் விவரங்கள் (Moolavar Details)',
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
            'கோவிலின் மூலவர் பற்றிய அனைத்து தகவல்களையும் இங்கே நிர்வகிக்கலாம்.',
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
                // Sub-Header
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
                        'புதிய மூலவர் பதிவு (Add New Moolavar)',
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

                // Row 1: Status, Mulavar Name, Thirunamam
                _buildResponsiveThreeRow(
                  _buildDropdownField(
                    'நிலை (Status)',
                    _selectedStatus,
                    [_defaultStatus, 'அருவம்', 'உருவம்', 'அருவுருவம்'],
                    (val) => setState(() => _selectedStatus = val!),
                  ),
                  _buildTextField('மூலவர் பெயர்', 'பெயர்...', _nameController),
                  _buildTextField(
                    'திருநாமம்',
                    'திருநாமம்...',
                    _thirunamamController,
                  ),
                ),
                const SizedBox(height: 24),

                // Row 2: Dynamic fields (Special Name, Deity Form, Form Speciality)
                _buildResponsiveThreeRow(
                  _buildDynamicFieldsList(
                    'சிறப்பு பெயர்',
                    'சிறப்பு பெயர்...',
                    _specialNameControllers,
                  ),
                  _buildDynamicFieldsList(
                    'திருவுருவம்',
                    'திருவுருவம்...',
                    _deityFormControllers,
                  ),
                  _buildDynamicFieldsList(
                    'திருவுருவச் சிறப்பு',
                    'சிறப்பு...',
                    _deityFormSpecialityControllers,
                  ),
                ),
                const SizedBox(height: 24),

                // Row 3: Thirunamam Speciality, Vahana, Sthala Vriksham
                _buildResponsiveThreeRow(
                  _buildTextField(
                    'திருநாமச் சிறப்பு',
                    'சிறப்புக்கள்...',
                    _thirunamamSpecialityController,
                  ),
                  _buildTextField('வாகனம்', 'வாகனம்...', _vahanaController),
                  _buildTextField(
                    'தல விருட்சம்',
                    'விருட்சம்...',
                    _sthalaVrikshamController,
                  ),
                ),
                const SizedBox(height: 24),

                // Row 4: Auspicious Flower, Vimanam/Gopuram, Worship Timing
                _buildResponsiveThreeRow(
                  _buildTextField('உகந்த மலர்', 'மலர்...', _flowerController),
                  _buildDropdownField(
                    'விமானம் / கோபுரம்',
                    _selectedGopuram,
                    [
                      _defaultGopuram,
                      'ஒன்று',
                      'மூன்று',
                      'ஐந்து',
                      'ஏழு',
                      'ஒன்பது',
                      'பதினொன்று',
                    ],
                    (val) => setState(() => _selectedGopuram = val!),
                  ),
                  _buildTextField(
                    'வணக்கம் நேரம்',
                    'எ.கா: காலை 6:00 - 8:00',
                    _worshipTimeController,
                  ),
                ),
                const SizedBox(height: 32),

                // Row 5: Photos Row
                _buildPhotosRow(),
                const SizedBox(height: 24),

                // Row 6: Checkboxes
                _buildCheckboxesRow(),
                const SizedBox(height: 40),

                // Row 7: Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildDataTableSection(),
        ],
      ),
    );
  }

  // Responsive layout for 3 columns (side-by-side on large screens, stacked on mobile)
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

  // Dynamic Fields Builder with "Add More" and close "X" buttons
  Widget _buildDynamicFieldsList(
    String label,
    String hint,
    List<TextEditingController> controllers,
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
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
                ),
                if (controllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controllers[index].dispose();
                        controllers.removeAt(index);
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              controllers.add(TextEditingController());
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF524EE1), width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Color(0xFF524EE1), size: 14),
                SizedBox(width: 4),
                Text(
                  'Add More (மேலும் சேர்க்க)',
                  style: TextStyle(
                    color: Color(0xFF524EE1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        if (isMobile) {
          return Column(
            children: [
              _buildMoolavarPhotoBox(),
              const SizedBox(height: 24),
              _buildUtsavarPhotoBox(),
              const SizedBox(height: 24),
              _buildChariotPhotoBox(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildMoolavarPhotoBox()),
            const SizedBox(width: 16),
            Expanded(child: _buildUtsavarPhotoBox()),
            const SizedBox(width: 16),
            Expanded(child: _buildChariotPhotoBox()),
          ],
        );
      },
    );
  }

  Widget _buildMoolavarPhotoBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'மூலவர் புகைப்படம் (Moolavar Photos - Max 5)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickMoolavarImages,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _moolavarPhotos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey,
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose Photos (Max 5)',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _moolavarPhotos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0,
                          ),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: FileImage(
                                    File(_moolavarPhotos[index].path),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _moolavarPhotos.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtsavarPhotoBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _hasUtsavarPhoto,
                onChanged: (val) {
                  setState(() {
                    _hasUtsavarPhoto = val ?? false;
                    if (!_hasUtsavarPhoto) _utsavarPhoto = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'உற்சவர் புகைப்படம்',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _hasUtsavarPhoto
              ? () => _pickImage((file) => _utsavarPhoto = file)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: _hasUtsavarPhoto ? 1.0 : 0.4,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _utsavarPhoto == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose Utsavar Photo',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_utsavarPhoto!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _utsavarPhoto = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChariotPhotoBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _hasChariotPhoto,
                onChanged: (val) {
                  setState(() {
                    _hasChariotPhoto = val ?? false;
                    if (!_hasChariotPhoto) _chariotPhoto = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'தேர் புகைப்படம்',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _hasChariotPhoto
              ? () => _pickImage((file) => _chariotPhoto = file)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: _hasChariotPhoto ? 1.0 : 0.4,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _chariotPhoto == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose Chariot Photo',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_chariotPhoto!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _chariotPhoto = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxesRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _hasBalipitham,
                onChanged: (val) {
                  setState(() {
                    _hasBalipitham = val ?? false;
                  });
                },
              ),
              const SizedBox(width: 4),
              const Text(
                'பலிபீடம் (Balipitham)',
                style: TextStyle(fontSize: 13, color: Color(0xFF1E1B4B)),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _hasKodimaram,
                onChanged: (val) {
                  setState(() {
                    _hasKodimaram = val ?? false;
                  });
                },
              ),
              const SizedBox(width: 4),
              const Text(
                'கொடி மரம் (Kodimaram)',
                style: TextStyle(fontSize: 13, color: Color(0xFF1E1B4B)),
              ),
            ],
          ),
        ],
      ),
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
      onPressed: _editMoolavarId != null ? _cancelEdit : _clearForm,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(_editMoolavarId != null ? 'Cancel Edit' : 'Clear Form'),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSavingMoolavar ? null : _saveMoolavar,
      icon: _isSavingMoolavar
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.save_outlined, size: 18),
      label: Text(
        _isSavingMoolavar
            ? (_editMoolavarId != null ? 'Updating...' : 'Saving...')
            : (_editMoolavarId != null ? 'Update Record' : 'Save Record'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF524EE1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildDataTableSection() {
    if (_isLoadingMoolavars) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_moolavars.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    const Icon(Icons.list_alt, color: Colors.indigo, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'மூலவர் பட்டியல் (Moolavar List)',
                        style: TextStyle(
                          fontSize: 18,
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
              OutlinedButton.icon(
                onPressed: _fetchMoolavars,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: BorderSide(color: Colors.indigo.shade200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(
                  label: Text(
                    'ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'பெயர் & திருமேனி',
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
                    'விமானம்',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'வாகனம்',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'தேதி',
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
              rows: _moolavars.map((moolavar) {
                final id = moolavar['id']?.toString() ?? '-';
                final name = moolavar['name'] ?? '-';
                final deityName = moolavar['deity_name'] ?? '-';
                final status = moolavar['status'] ?? '-';
                final vimanam = moolavar['vimana_level'] ?? '-';
                final vehicle = moolavar['vehicle'] ?? '-';

                // Format date roughly if available
                String dateStr = '-';
                if (moolavar['created_date'] != null) {
                  try {
                    final dt = DateTime.parse(moolavar['created_date']);
                    dateStr =
                        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                  } catch (_) {
                    dateStr = moolavar['created_date']
                        .toString()
                        .split('T')
                        .first;
                  }
                }

                return DataRow(
                  cells: [
                    DataCell(Text('#$id')),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (deityName != '-')
                            Text(
                              deityName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    DataCell(Text(status)),
                    DataCell(Text(vimanam)),
                    DataCell(Text(vehicle)),
                    DataCell(Text(dateStr)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_red_eye,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () =>
                                _showMoolavarDetailsDialog(moolavar),
                            tooltip: 'View',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                              size: 20,
                            ),
                            onPressed: () => _editMoolavar(moolavar),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteMoolavar(
                              int.tryParse(moolavar['id']?.toString() ?? '') ??
                                  0,
                            ),
                            tooltip: 'Delete',
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

  void _showMoolavarDetailsDialog(Map<String, dynamic> moolavar) {
    _scrollController.jumpTo(0);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 800,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF524EE1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'மூலவர் விவரம் (Moolavar Details)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photos Column
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'மூலவர் புகைப்படம்',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildImageThumbnail(
                              moolavar['photo']?.toString() ?? '',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'உற்சவர்',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildImageThumbnail(
                                        moolavar['utsavar_file']?.toString() ??
                                            '',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'தேர்',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildImageThumbnail(
                                        moolavar['chariot_file']?.toString() ??
                                            '',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Details Column
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            _buildDetailItem(
                              'பெயர்',
                              moolavar['name']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'திருநாமம்',
                              moolavar['deity_name']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'நிலை',
                              moolavar['status']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'சிறப்புப் பெயர்',
                              moolavar['special_name']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'திருமேனி',
                              moolavar['deity_form']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'வாகனம்',
                              moolavar['vehicle']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'விருட்சம்',
                              moolavar['temple_tree']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'மலர்',
                              moolavar['preferred_flower']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'விமானம்',
                              moolavar['vimana_level']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'சிறப்பு',
                              moolavar['divine_speciality']?.toString() ?? '-',
                            ),
                            _buildDetailItem(
                              'நேரம்',
                              moolavar['worship_time']?.toString() ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF524EE1),
                      ),
                      child: const Text(
                        'Close Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String filename) {
    if (filename.isEmpty || filename == 'null') {
      return Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    String firstFile = filename;
    if (filename.contains(',')) {
      firstFile = filename.split(',').first;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        'https://temple.jobes24x7.com/storage/$firstFile',
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }
}
