import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import 'package:kulatheivam/core/widgets/searchable_dropdown.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kulatheivam/core/network/api_client.dart';
import 'package:kulatheivam/features/kulam/data/kulam_api_repository.dart';

class VagaiyaraManageContent extends StatefulWidget {
  const VagaiyaraManageContent({super.key});

  @override
  State<VagaiyaraManageContent> createState() => _VagaiyaraManageContentState();
}

class _VagaiyaraManageContentState extends State<VagaiyaraManageContent> {
  final KulamApiRepository _apiRepository = KulamApiRepository(ApiClient());
  List<dynamic> _communities = [];
  List<dynamic> _subCommunities = [];
  List<dynamic> _kulas = [];
  List<dynamic> _kulaDeivams = [];
  List<dynamic> _vagaiyaras = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final String _defaultTopDropdown =
      '-- புதிய வகைரா சேர்க்கவும் (Add New Vagaiyara) --';
  late String _selectedTopDropdown;

  final String _defaultCommunity =
      '-- சமூகம் தேர்ந்தெடுக்கவும் (Select Community) --';
  late String _selectedCommunity;

  final String _defaultSubCommunity =
      '-- உட்பிரிவு தேர்ந்தெடுக்கவும் (Select Sub-Community) --';
  late String _selectedSubCommunity;

  final String _defaultKulam = '-- குலம் தேர்ந்தெடுக்கவும் (Select Kulam) --';
  late String _selectedKulam;

  final String _defaultKulaDeivam = '-- குலதெய்வம் தேர்ந்தெடுக்கவும் (Select Kula Deivam) --';
  late String _selectedKulaDeivam;

  // Text Controllers
  final TextEditingController _ourGenNameTamilController = TextEditingController();
  final TextEditingController _ourGenNameEnglishController = TextEditingController();
  final TextEditingController _ancestorGenNameTamilController = TextEditingController();
  final TextEditingController _ancestorGenNameEnglishController = TextEditingController();
  final TextEditingController _nativePlaceController = TextEditingController();
  final TextEditingController _currentPlaceController = TextEditingController();
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
    _selectedKulaDeivam = _defaultKulaDeivam;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final communities = await _apiRepository.fetchCommunities();
      final subCommunities = await _apiRepository.fetchSubCommunities();
      final kulas = await _apiRepository.fetchKulas();
      final kulaDeivams = await _apiRepository.fetchKulaDeivams();
      final vagaiyaras = await _apiRepository.fetchVagaiyaras();
      if (mounted) {
        setState(() {
          _communities = communities;
          _subCommunities = subCommunities;
          _kulas = kulas;
          _kulaDeivams = kulaDeivams;
          _vagaiyaras = vagaiyaras;
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
    _ourGenNameTamilController.dispose();
    _ourGenNameEnglishController.dispose();
    _ancestorGenNameTamilController.dispose();
    _ancestorGenNameEnglishController.dispose();
    _nativePlaceController.dispose();
    _currentPlaceController.dispose();
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
      _selectedKulaDeivam = _defaultKulaDeivam;
      _ourGenNameTamilController.clear();
      _ourGenNameEnglishController.clear();
      _ancestorGenNameTamilController.clear();
      _ancestorGenNameEnglishController.clear();
      _nativePlaceController.clear();
      _currentPlaceController.clear();
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
    if (_selectedCommunity == _defaultCommunity || 
        _selectedKulam == _defaultKulam || 
        _selectedKulaDeivam == _defaultKulaDeivam || 
        _ourGenNameTamilController.text.trim().isEmpty || 
        _ancestorGenNameTamilController.text.trim().isEmpty) {
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
        'kula_deivam_id': int.parse(_selectedKulaDeivam),
        'our_gen_name_tamil': _ourGenNameTamilController.text.trim(),
        'our_gen_name_english': _ourGenNameEnglishController.text.trim(),
        'ancestor_gen_name_tamil': _ancestorGenNameTamilController.text.trim(),
        'ancestor_gen_name_english': _ancestorGenNameEnglishController.text.trim(),
        'native_place': _nativePlaceController.text.trim(),
        'current_place': _currentPlaceController.text.trim(),
        'title': _titleController.text.trim(),
        'info': _infoController.text.trim(),
        'description': _descriptionController.text.trim(),
        'history': _historyController.text.trim(),
      };

      if (_imageFile != null) payload['image_path'] = await _getBase64(_imageFile);
      if (_logoFile != null) payload['logo_path'] = await _getBase64(_logoFile);
      if (_iconFile != null) payload['icon_path'] = await _getBase64(_iconFile);

      if (_selectedTopDropdown == _defaultTopDropdown) {
        await _apiRepository.createVagaiyara(payload);
        if (mounted) {
          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        }
      } else {
        final selectedId = int.parse(_selectedTopDropdown);
        payload['id'] = selectedId;
        await _apiRepository.updateVagaiyara(selectedId, payload);
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

  Future<void> _deleteVagaiyara() async {
    if (_selectedTopDropdown == _defaultTopDropdown) return;
    final selectedId = int.parse(_selectedTopDropdown);
    
    final confirm = await CustomDeleteDialog.showConfirmation(
      context,
      title: 'நிச்சயமாக நீக்க\nவேண்டுமா?',
      message: 'இந்த வகையராவின் விபரம் நிரந்தரமாக நீக்கப்படும்! (Delete this vagaiyara?)',
    );
    
    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await _apiRepository.deleteVagaiyara(selectedId);
        if (mounted) {
          CustomDeleteDialog.showSuccess(
            context,
            title: 'வெற்றி',
            message: 'வகையராவின் விவரம் நீக்கப்பட்டது (Vagaiyara deleted successfully)',
          );
        }
        _clearForm();
        await _fetchData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting vagaiyara: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.people_alt, color: Colors.indigo, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'வகைரா நிர்வகித்தல் (Vagaiyara Management)',
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
            'வகைரா கிளைகள், சொந்த ஊர் மற்றும் தற்போதைய இருப்பிட விவரங்களை நிர்வகிக்கவும்.',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ஏற்கனவே உள்ள வகைராவைத் தேர்ந்தெடுத்து திருத்த அல்லது நீக்க (Select to Edit/Delete)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF524EE1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SearchableDropdown(
                            items: _vagaiyaras,
                            hint: _defaultTopDropdown,
                            displayBuilder: (v) {
                              final t = v['our_gen_name_tamil'] ?? v['vagaiyara_name_tamil'] ?? '';
                              final e = v['our_gen_name_english'] ?? v['vagaiyara_name_english'] ?? '';
                              return e.toString().isNotEmpty ? '$t ($e)' : t;
                            },
                            valueKey: 'id',
                            selectedValue: _selectedTopDropdown == _defaultTopDropdown ? null : _selectedTopDropdown,
                            onChanged: (val) {
                              final actualVal = val ?? _defaultTopDropdown;
                              setState(() {
                                _selectedTopDropdown = actualVal;
                                if (actualVal == _defaultTopDropdown) {
                                  _clearForm();
                                } else {
                                  final v = _vagaiyaras.firstWhere((item) => item['id'].toString() == actualVal, orElse: () => null);
                                  if (v != null) {
                                    _selectedCommunity = v['community_id']?.toString() ?? _defaultCommunity;
                                    _selectedSubCommunity = v['sub_community_id'] != null && v['sub_community_id'] != 0 ? v['sub_community_id'].toString() : _defaultSubCommunity;
                                    _selectedKulam = v['kula_id']?.toString() ?? _defaultKulam;
                                    _selectedKulaDeivam = v['kula_deivam_id']?.toString() ?? _defaultKulaDeivam;
                                    
                                    _ourGenNameTamilController.text = v['our_gen_name_tamil'] ?? v['vagaiyara_name_tamil'] ?? '';
                                    _ourGenNameEnglishController.text = v['our_gen_name_english'] ?? v['vagaiyara_name_english'] ?? '';
                                    _ancestorGenNameTamilController.text = v['ancestor_gen_name_tamil'] ?? '';
                                    _ancestorGenNameEnglishController.text = v['ancestor_gen_name_english'] ?? '';
                                    _nativePlaceController.text = v['native_place'] ?? '';
                                    _currentPlaceController.text = v['current_place'] ?? '';
                                    _titleController.text = v['title'] ?? '';
                                    _infoController.text = v['info'] ?? '';
                                    _descriptionController.text = v['description'] ?? '';
                                    _historyController.text = v['history'] ?? '';
                                  }
                                }
                              });
                            },
                            searchTitle: 'வகையரா (Select Vagaiyara)',
                            resetOptionLabel: 'புதிய வகைரா சேர்க்கவும் (Add New Vagaiyara)',
                          ),
                        ),
                        if (_selectedTopDropdown != _defaultTopDropdown) ...[
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _deleteVagaiyara,
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            label: const Text('நீக்கு (Delete)', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
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
                        'புதிய வகைரா சேர்த்தல் (Add New Vagaiyara)',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'சமூகம் (Select Community)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SearchableDropdown(
                      items: _communities,
                      hint: _defaultCommunity,
                      displayBuilder: (c) {
                        final t = c['community_name_tamil'] ?? '';
                        final e = c['community_name_english'] ?? '';
                        return e.toString().isNotEmpty ? '$t ($e)' : t;
                      },
                      valueKey: 'id',
                      selectedValue: _selectedCommunity == _defaultCommunity ? null : _selectedCommunity,
                      onChanged: (val) {
                        final actualVal = val ?? _defaultCommunity;
                        setState(() {
                          _selectedCommunity = actualVal;
                          _selectedSubCommunity = _defaultSubCommunity;
                          _selectedKulam = _defaultKulam;
                          _selectedKulaDeivam = _defaultKulaDeivam;
                        });
                      },
                      searchTitle: 'சமூகம் (Select Community)',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sub-Community, Kulam & Kula Deivam Dropdowns
                LayoutBuilder(
                  builder: (context, constraints) {
                    final subCommunityList = _subCommunities.where((sc) => sc['community_id'].toString() == _selectedCommunity).toList();
                    
                    final kulamList = _kulas.where((k) => k['sub_community_id'].toString() == _selectedSubCommunity).toList();
                    
                    final kulaDeivamList = _kulaDeivams.where((kd) => 
                      (_selectedCommunity == _defaultCommunity || kd['community_id'].toString() == _selectedCommunity) &&
                      (_selectedSubCommunity == _defaultSubCommunity || kd['sub_community_id'].toString() == _selectedSubCommunity || kd['sub_community_id'] == 0 || kd['sub_community_id'] == null) &&
                      (_selectedKulam == _defaultKulam || kd['kula_id'].toString() == _selectedKulam || kd['kula_id'] == 0 || kd['kula_id'] == null)
                    ).toList();

                    final isMobile = constraints.maxWidth < 600;
                    
                    Widget buildSubCommunityField() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'உட்பிரிவு (Select Sub-Community)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SearchableDropdown(
                            items: subCommunityList,
                            hint: _defaultSubCommunity,
                            displayBuilder: (sc) {
                              final t = sc['sub_community_name_tamil'] ?? '';
                              final e = sc['sub_community_name_english'] ?? '';
                              return e.toString().isNotEmpty ? '$t ($e)' : t;
                            },
                            valueKey: 'id',
                            selectedValue: _selectedSubCommunity == _defaultSubCommunity ? null : _selectedSubCommunity,
                            onChanged: (val) {
                              final actualVal = val ?? _defaultSubCommunity;
                              setState(() {
                                _selectedSubCommunity = actualVal;
                                _selectedKulam = _defaultKulam;
                                _selectedKulaDeivam = _defaultKulaDeivam;
                              });
                            },
                            searchTitle: 'உட்பிரிவு (Select Sub-Community)',
                          ),
                        ],
                      );
                    }

                    Widget buildKulamField() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'குலம் (Select Kulam)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SearchableDropdown(
                            items: kulamList,
                            hint: _defaultKulam,
                            displayBuilder: (k) {
                              final t = k['kula_name_tamil'] ?? '';
                              final e = k['kula_name_english'] ?? '';
                              return e.toString().isNotEmpty ? '$t ($e)' : t;
                            },
                            valueKey: 'id',
                            selectedValue: _selectedKulam == _defaultKulam ? null : _selectedKulam,
                            onChanged: (val) {
                              final actualVal = val ?? _defaultKulam;
                              setState(() {
                                _selectedKulam = actualVal;
                                _selectedKulaDeivam = _defaultKulaDeivam;
                              });
                            },
                            searchTitle: 'குலம் (Select Kulam)',
                          ),
                        ],
                      );
                    }

                    Widget buildKulaDeivamField() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'குலதெய்வம் (Select Kula Deivam)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SearchableDropdown(
                            items: kulaDeivamList,
                            hint: _defaultKulaDeivam,
                            displayBuilder: (kd) {
                              final t = kd['deity_name_tamil'] ?? '';
                              final e = kd['deity_name_english'] ?? '';
                              return e.toString().isNotEmpty ? '$t ($e)' : t;
                            },
                            valueKey: 'id',
                            selectedValue: _selectedKulaDeivam == _defaultKulaDeivam ? null : _selectedKulaDeivam,
                            onChanged: (val) {
                              final actualVal = val ?? _defaultKulaDeivam;
                              setState(() => _selectedKulaDeivam = actualVal);
                            },
                            searchTitle: 'குலதெய்வம் (Select Kula Deivam)',
                          ),
                        ],
                      );
                    }

                    if (isMobile) {
                      return Column(
                        children: [
                          buildSubCommunityField(),
                          const SizedBox(height: 16),
                          buildKulamField(),
                          const SizedBox(height: 16),
                          buildKulaDeivamField(),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: buildSubCommunityField()),
                        const SizedBox(width: 16),
                        Expanded(child: buildKulamField()),
                        const SizedBox(width: 16),
                        Expanded(child: buildKulaDeivamField()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Form Fields (Name)
                if (_selectedKulaDeivam == _defaultKulaDeivam)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'வகைரா பெயரை உள்ளிட முதலில் குலதெய்வத்தை தேர்ந்தெடுக்கவும் (Please select Kula Deivam first to enter Vagaiyara details)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  _buildResponsiveRow(
                    _buildTextField(
                      'எங்களது தலைமுறை வகைரா (Our Generation Vagaiyara - தமிழ்) *',
                      'எ.கா முத்தையா வகைரா',
                      _ourGenNameTamilController,
                    ),
                    _buildTextField(
                      'Our Generation Vagaiyara (English)',
                      'e.g. Muthaiya Vagaiyara',
                      _ourGenNameEnglishController,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildResponsiveRow(
                    _buildTextField(
                      'முன்னோர் தலைமுறை வகைரா (Ancestor Generation Vagaiyara - தமிழ்) *',
                      'எ.கா சின்னசாமி வகைரா',
                      _ancestorGenNameTamilController,
                    ),
                    _buildTextField(
                      'Ancestor Generation Vagaiyara (English)',
                      'e.g. Chinnasamy Vagaiyara',
                      _ancestorGenNameEnglishController,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Form Fields (Places)
                _buildResponsiveRow(
                  _buildTextField(
                    'சொந்த ஊர் (Native Place)',
                    'எ.கா பல்லடம் (Palladam)',
                    _nativePlaceController,
                  ),
                  _buildTextField(
                    'இப்போ இருக்குற ஊர் (Current Place)',
                    'எ.கா கோயம்புத்தூர் (Coimbatore)',
                    _currentPlaceController,
                  ),
                ),
                const SizedBox(height: 16),

                // Form Fields (Title & Info)
                _buildResponsiveRow(
                  _buildTextField(
                    'தலைப்பு (Title)',
                    'எ.கா முத்தையா வகைரா வம்சம்',
                    _titleController,
                  ),
                  _buildTextField(
                    'தகவல் (Info)',
                    'எ.கா குல வரலாறு உடையவர்கள்',
                    _infoController,
                  ),
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
                  'வகைராவைப் பற்றிய ஒரு சிறிய குறிப்பு...',
                  _descriptionController,
                ),
                const SizedBox(height: 24),

                // Additional Details ExpansionTile
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: Material(
                    color: Colors.transparent,
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
                          'வகைராவின் பூர்வீகம், வரலாறு, மற்றும் கோவில்கள்...',
                          _historyController,
                          minLines: 4,
                        ),
                      ],
                    ),
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
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveOrUpdate,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save_outlined, size: 18),
      label: const Text('வகைராவைச் சேர் (Save)'),
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
