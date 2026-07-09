import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kulatheivam/core/network/api_client.dart';
import 'package:kulatheivam/features/kulam/data/kulam_api_repository.dart';

class KulaDeivamMappingContent extends StatefulWidget {
  const KulaDeivamMappingContent({super.key});

  @override
  State<KulaDeivamMappingContent> createState() =>
      _KulaDeivamMappingContentState();
}

class _KulaDeivamMappingContentState extends State<KulaDeivamMappingContent> {
  final KulamApiRepository _apiRepository = KulamApiRepository(ApiClient());
  List<dynamic> _communities = [];
  List<dynamic> _subCommunities = [];
  List<dynamic> _kulas = [];
  List<dynamic> _kulaDeivams = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final String _defaultTopDropdown =
      '-- புதிய குல தெய்வம் சேர்க்கவும் (Add New Deity Mapping) --';
  late String _selectedTopDropdown;

  final String _defaultCommunity =
      '-- சமூகம் தேர்ந்தெடுக்கவும் (Select Parent Community) --';
  late String _selectedCommunity;

  final String _defaultSubCommunity =
      '-- உட்பிரிவு தேர்ந்தெடுக்கவும் (Select Sub-Community) --';
  late String _selectedSubCommunity;

  final String _defaultKulam = '-- குலம் தேர்ந்தெடுக்கவும் (Select Kulam) --';
  late String _selectedKulam;

  // Text Controllers
  final TextEditingController _nameTamilController = TextEditingController();
  final TextEditingController _nameEnglishController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();

  // Image states
  XFile? _imageFile;
  XFile? _logoFile;
  XFile? _iconFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedTopDropdown = _defaultTopDropdown;
    _selectedCommunity = _defaultCommunity;
    _selectedSubCommunity = _defaultSubCommunity;
    _selectedKulam = _defaultKulam;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final communities = await _apiRepository.fetchCommunities();
      final subCommunities = await _apiRepository.fetchSubCommunities();
      final kulas = await _apiRepository.fetchKulas();
      final kulaDeivams = await _apiRepository.fetchKulaDeivams();
      if (mounted) {
        setState(() {
          _communities = communities;
          _subCommunities = subCommunities;
          _kulas = kulas;
          _kulaDeivams = kulaDeivams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameTamilController.dispose();
    _nameEnglishController.dispose();
    _titleController.dispose();
    _infoController.dispose();
    _descriptionController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _selectedTopDropdown = _defaultTopDropdown;
      _selectedCommunity = _defaultCommunity;
      _selectedSubCommunity = _defaultSubCommunity;
      _selectedKulam = _defaultKulam;
      _nameTamilController.clear();
      _nameEnglishController.clear();
      _titleController.clear();
      _infoController.clear();
      _descriptionController.clear();
      _historyController.clear();
      _imageFile = null;
      _logoFile = null;
      _iconFile = null;
    });
  }

  Future<String?> _getBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  Future<void> _saveOrUpdate() async {
    if (_nameTamilController.text.trim().isEmpty || _nameEnglishController.text.trim().isEmpty || _selectedCommunity == _defaultCommunity || _selectedKulam == _defaultKulam) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> payload = {
        'community_id': int.parse(_selectedCommunity),
        'sub_community_id': _selectedSubCommunity != _defaultSubCommunity ? int.parse(_selectedSubCommunity) : 0,
        'kula_id': int.parse(_selectedKulam),
        'deity_name_tamil': _nameTamilController.text.trim(),
        'deity_name_english': _nameEnglishController.text.trim(),
        'title': _titleController.text.trim(),
        'info': _infoController.text.trim(),
        'description': _descriptionController.text.trim(),
        'history': _historyController.text.trim(),
      };

      if (_imageFile != null) payload['image_path'] = await _getBase64(_imageFile);
      if (_logoFile != null) payload['logo_path'] = await _getBase64(_logoFile);
      if (_iconFile != null) payload['icon_path'] = await _getBase64(_iconFile);

      if (_selectedTopDropdown == _defaultTopDropdown) {
        await _apiRepository.createKulaDeivam(payload);
        if (mounted) {
          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        }
      } else {
        final selectedId = int.parse(_selectedTopDropdown);
        payload['id'] = selectedId;
        await _apiRepository.updateKulaDeivam(selectedId, payload);
        if (mounted) {
          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        }
      }

      _clearForm();
      await _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage(void Function(XFile?) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onPicked(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.temple_hindu_outlined, color: Colors.indigo, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'குல தெய்வம் (Kula Deivam Mapping)',
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
            'ஒவ்வொரு சமூகத்திற்கும் அவர்களின் குல தெய்வங்களை இங்கே இணைக்கலாம்.',
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
                // Top Dropdown
                _buildDropdownField(
                  'ஏற்கனவே உள்ள பதிவைத் தேர்ந்தெடுத்து திருத்த அல்லது நீக்க (Select to Edit/Delete)',
                  _selectedTopDropdown,
                  [
                    DropdownMenuItem<String>(
                      value: _defaultTopDropdown,
                      child: Text(_defaultTopDropdown, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ),
                    ..._kulaDeivams.map((kd) {
                      final val = kd['id'].toString();
                      final display = '${kd['deity_name_tamil']} (${kd['deity_name_english']})';
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(display, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      );
                    }).toList(),
                  ],
                  (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTopDropdown = val;
                        if (val == _defaultTopDropdown) {
                          _clearForm();
                        } else {
                          final selectedId = int.parse(val);
                          final kd = _kulaDeivams.firstWhere((k) => k['id'] == selectedId);
                          
                          _selectedCommunity = kd['community_id']?.toString() ?? _defaultCommunity;
                          _selectedSubCommunity = kd['sub_community_id'] == 0 ? _defaultSubCommunity : kd['sub_community_id']?.toString() ?? _defaultSubCommunity;
                          _selectedKulam = kd['kula_id']?.toString() ?? _defaultKulam;
                          
                          _nameTamilController.text = kd['deity_name_tamil'] ?? '';
                          _nameEnglishController.text = kd['deity_name_english'] ?? '';
                          _titleController.text = kd['title'] ?? '';
                          _infoController.text = kd['info'] ?? '';
                          _descriptionController.text = kd['description'] ?? '';
                          _historyController.text = kd['history'] ?? '';
                          
                          _imageFile = null;
                          _logoFile = null;
                          _iconFile = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Section Title
                Row(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: Colors.indigo.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'புதிய குலதெய்வம் சேர்த்தல் (Add New Deity Mapping)',
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

                // Community Dropdown
                _buildDropdownField(
                  'சமூகம் (Select Community) *',
                  _selectedCommunity,
                  [
                    DropdownMenuItem<String>(
                      value: _defaultCommunity,
                      child: Text(_defaultCommunity, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ),
                    ..._communities.map((c) {
                      final val = c['id'].toString();
                      final display = '${c['community_name_tamil']} (${c['community_name_english']})';
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(display, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      );
                    }).toList(),
                  ],
                  (val) {
                    if (val != null) setState(() {
                      _selectedCommunity = val;
                      _selectedSubCommunity = _defaultSubCommunity;
                      _selectedKulam = _defaultKulam;
                    });
                  },
                  isRedAsterisk: true,
                ),
                const SizedBox(height: 16),

                // Sub-Community & Kulam Dropdowns
                LayoutBuilder(
                  builder: (context, constraints) {
                    final subCommunityItems = [
                      DropdownMenuItem<String>(
                        value: _defaultSubCommunity,
                        child: Text(_defaultSubCommunity, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ),
                      ..._subCommunities.where((sc) => sc['community_id'].toString() == _selectedCommunity).map((sc) {
                        final val = sc['id'].toString();
                        final display = '${sc['sub_community_name_tamil']} (${sc['sub_community_name_english']})';
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(display, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        );
                      }).toList(),
                    ];

                    final kulamItems = [
                      DropdownMenuItem<String>(
                        value: _defaultKulam,
                        child: Text(_defaultKulam, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ),
                      ..._kulas.where((k) => k['sub_community_id'].toString() == _selectedSubCommunity).map((k) {
                        final val = k['id'].toString();
                        final display = '${k['kula_name_tamil']} (${k['kula_name_english']})';
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(display, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        );
                      }).toList(),
                    ];

                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        children: [
                          _buildDropdownField(
                            'உட்பிரிவு (Select Sub-Community) *',
                            _selectedSubCommunity,
                            subCommunityItems,
                            (val) {
                              if (val != null) setState(() {
                                _selectedSubCommunity = val;
                                _selectedKulam = _defaultKulam;
                              });
                            },
                            isRedAsterisk: true,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            'குலம் (Select Kulam) *',
                            _selectedKulam,
                            kulamItems,
                            (val) {
                              if (val != null) setState(() => _selectedKulam = val);
                            },
                            isRedAsterisk: true,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'உட்பிரிவு (Select Sub-Community) *',
                            _selectedSubCommunity,
                            subCommunityItems,
                            (val) {
                              if (val != null) setState(() {
                                _selectedSubCommunity = val;
                                _selectedKulam = _defaultKulam;
                              });
                            },
                            isRedAsterisk: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            'குலம் (Select Kulam) *',
                            _selectedKulam,
                            kulamItems,
                            (val) {
                              if (val != null) setState(() => _selectedKulam = val);
                            },
                            isRedAsterisk: true,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Form Fields
                _buildResponsiveRow(
                  _buildTextField(
                    'குல தெய்வம் பெயர் (தமிழ்) *',
                    'எ.கா ஸ்ரீ மாரியம்மன்',
                    _nameTamilController,
                  ),
                  _buildTextField(
                    'Kula Deity Name (English)',
                    'e.g. Sri Mariamman',
                    _nameEnglishController,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResponsiveRow(
                  _buildTextField(
                    'தலைப்பு (Title)',
                    'தலைப்பு...',
                    _titleController,
                  ),
                  _buildTextField('தகவல் (Info)', 'தகவல்...', _infoController),
                ),
                const SizedBox(height: 24),

                // Image Uploaders
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        children: [
                          _buildImageUploader(
                            'புகைப்படம் (Image)',
                            _imageFile,
                            () => _pickImage(
                              (f) => setState(() => _imageFile = f),
                            ),
                            () => setState(() => _imageFile = null),
                          ),
                          const SizedBox(height: 16),
                          _buildImageUploader(
                            'சின்னம் (Logo)',
                            _logoFile,
                            () => _pickImage(
                              (f) => setState(() => _logoFile = f),
                            ),
                            () => setState(() => _logoFile = null),
                          ),
                          const SizedBox(height: 16),
                          _buildImageUploader(
                            'ஐகான் (Icon)',
                            _iconFile,
                            () => _pickImage(
                              (f) => setState(() => _iconFile = f),
                            ),
                            () => setState(() => _iconFile = null),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildImageUploader(
                            'புகைப்படம் (Image)',
                            _imageFile,
                            () => _pickImage(
                              (f) => setState(() => _imageFile = f),
                            ),
                            () => setState(() => _imageFile = null),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImageUploader(
                            'சின்னம் (Logo)',
                            _logoFile,
                            () => _pickImage(
                              (f) => setState(() => _logoFile = f),
                            ),
                            () => setState(() => _logoFile = null),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImageUploader(
                            'ஐகான் (Icon)',
                            _iconFile,
                            () => _pickImage(
                              (f) => setState(() => _iconFile = f),
                            ),
                            () => setState(() => _iconFile = null),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Description
                _buildTextArea(
                  'சுருக்கமான விளக்கம் (Description)',
                  'சுருக்கமான விளக்கம்...',
                  _descriptionController,
                ),
                const SizedBox(height: 24),

                // Additional Details ExpansionTile
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      'கூடுதல் விவரங்கள் (Additional Details)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                    iconColor: Colors.indigo.shade600,
                    collapsedIconColor: Colors.indigo.shade600,
                    childrenPadding: const EdgeInsets.only(top: 8),
                    children: [
                      _buildTextArea(
                        'வரலாறு (History / Varalaru)',
                        'வரலாறு...',
                        _historyController,
                        minLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

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
                            child: _buildSaveButton(),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildCancelButton()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildSaveButton()),
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

  Widget _buildDropdownField(
    String label,
    String selectedValue,
    List<DropdownMenuItem<String>> items,
    void Function(String?) onChanged, {
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
              value: items.any((item) => item.value == selectedValue) ? selectedValue : items.first.value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: items,
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
          return Column(children: [child1, const SizedBox(height: 16), child2]);
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
    TextEditingController controller,
  ) {
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

  Widget _buildTextArea(
    String label,
    String hint,
    TextEditingController controller, {
    int minLines = 3,
  }) {
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
          maxLines: null,
          minLines: minLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.all(16),
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

  Widget _buildImageUploader(
    String label,
    XFile? file,
    VoidCallback onPick,
    VoidCallback onClear,
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
        if (file != null)
          Column(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  image: DecorationImage(
                    image: FileImage(File(file.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.red.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'நீக்கு (Clear)',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.none,
                ),
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey.shade400,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'பதிவேற்று',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: _clearForm,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('ரத்து (Cancel)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isEditing = _selectedTopDropdown != _defaultTopDropdown;
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveOrUpdate,
      icon: _isSaving
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.save_outlined, size: 18),
      label: Text(isEditing ? 'மாற்றங்களைச் சேமி (Update)' : 'சேமி (Save)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF524EE1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var dashWidth = 5.0;
    var dashSpace = 5.0;
    var startX = 0.0;

    // Top border
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Bottom border
    startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
    // Left border
    var startY = 0.0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Right border
    startY = 0.0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
