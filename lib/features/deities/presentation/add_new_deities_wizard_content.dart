import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import '../data/shiva_murtis_data.dart';
import '../data/deity_master_data.dart';
import '../data/shiva_associated_data.dart';
import 'widgets/shiva_structured_registration_widget.dart';

class AddNewDeitiesWizardContent extends ConsumerStatefulWidget {
  final Function(String, {Map<String, dynamic>? arguments}) onScreenSelected;
  
  const AddNewDeitiesWizardContent({super.key, required this.onScreenSelected});

  @override
  ConsumerState<AddNewDeitiesWizardContent> createState() => _AddNewDeitiesWizardContentState();
}

class _AddNewDeitiesWizardContentState extends ConsumerState<AddNewDeitiesWizardContent> {
  int _currentStep = 0;
  String? _selectedCategory;

  bool get _isShivaCategory =>
      _selectedCategory == 'சிவன்' ||
      _selectedCategory?.toLowerCase() == 'siva' ||
      _selectedCategory?.toLowerCase() == 'shiva';

  bool get _isVishnuCategory =>
      _selectedCategory == 'விஷ்ணு' ||
      _selectedCategory?.toLowerCase() == 'vishnu';

  bool get _isKuladeivamCategory =>
      _selectedCategory == 'குல தெய்வம்' ||
      _selectedCategory?.toLowerCase().contains('kula') == true;

  bool get _isIshtaDeivamCategory =>
      _selectedCategory == 'இஷ்ட தெய்வம்' ||
      _selectedCategory?.toLowerCase().contains('ishta') == true;

  bool get _isGramaDeivamCategory =>
      _selectedCategory == 'கிராம தெய்வம்' ||
      _selectedCategory?.toLowerCase().contains('grama') == true;

  bool get _isMuruganCategory =>
      _selectedCategory == 'முருகன்' ||
      _selectedCategory?.toLowerCase() == 'murugan';

  bool get _isVinayagarCategory =>
      _selectedCategory == 'விநாயகர்' ||
      _selectedCategory?.toLowerCase() == 'vinayagar' ||
      _selectedCategory?.toLowerCase() == 'ganesha' ||
      _selectedCategory?.toLowerCase() == 'ganapathi';

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'shiva',
      'title': 'சிவன்',
      'subtitle': 'Shiva',
      'image': 'assets/images/category/shiva.png',
    },
    {
      'id': 'vishnu',
      'title': 'விஷ்ணு',
      'subtitle': 'Vishnu',
      'image': 'assets/images/category/vishnu.png',
    },
    {
      'id': 'kuladeivam',
      'title': 'குல தெய்வம்',
      'subtitle': 'Kuladeivam',
      'image': 'assets/images/category/kuladeivam.png',
    },
    {
      'id': 'ishtadeivam',
      'title': 'இஷ்ட தெய்வம்',
      'subtitle': 'Ishta Deivam',
      'image': 'assets/images/category/ishtadeivam.png',
    },
    {
      'id': 'gramadeivam',
      'title': 'கிராம தெய்வம்',
      'subtitle': 'Grama Deivam',
      'image': 'assets/images/category/gramadeivam.png',
    },
  ];

  Widget _buildDevotionalImage(String imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    final isAsset = imagePath.startsWith('assets/');
    if (isAsset) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: const Color(0xFFB01254).withOpacity(0.08),
          child: const Center(
            child: Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 36),
          ),
        ),
      );
    }
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFB01254).withOpacity(0.08),
        child: const Center(
          child: Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 36),
        ),
      ),
    );
  }

  static const String _storageKey = 'kovil_primary_deities_data_v1';
  static const String _photosStorageKey = 'kovil_deity_photos_v1';
  static const String _formsStorageKey = 'kovil_deity_forms_v1';
  static const String _nayanmarsStorageKey = 'kovil_deity_nayanmars_v1';
  static const String _siddharsStorageKey = 'kovil_deity_siddhars_v1';
  static const String _familyStorageKey = 'kovil_deity_family_v1';

  final List<PhotoReferenceRecord> _allPersistedPhotos = [];
  final List<DeityFormRecord> _allPersistedForms = [];
  final List<NayanmarRecord> _allPersistedNayanmars = [];
  final List<SiddharRecord> _allPersistedSiddhars = [];
  final List<DeityFamilyRelationshipRecord> _allPersistedFamily = [];

  final TextEditingController _tamilNameCtrl = TextEditingController();
  final TextEditingController _searchTableCtrl = TextEditingController();
  String? _editingDeityId;
  String _tableCategoryFilter = 'all';
  String _searchTableQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedDeities();
    _searchTableCtrl.addListener(() {
      setState(() {
        _searchTableQuery = _searchTableCtrl.text;
      });
    });
  }

  Uint8List? _mainPhotoBytes;
  bool _separateSannidhi = false;
  bool _auspiciousDayTime = false;
  final List<Map<String, dynamic>> _deityForms = [
    {'image': null, 'speciality': ''}
  ];

  // Step 2 variables
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _deityTitleCtrl = TextEditingController();
  final TextEditingController _avatarCtrl = TextEditingController();
  final TextEditingController _deityFormCtrl = TextEditingController();
  final TextEditingController _parentDeityCtrl = TextEditingController();
  final TextEditingController _relationshipStatusCtrl = TextEditingController(); // For உடனுறை தெய்வம் / Consorts
  final TextEditingController _relationshipCtrl = TextEditingController();
  String _deivamType = 'Select வகை (Gender)';

  // Step 3 variables
  final TextEditingController _deitySpecialityCtrl = TextEditingController();
  final TextEditingController _worshipMethodCtrl = TextEditingController();
  final TextEditingController _prayerRequestCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  
  List<String> _specialName = [];
  List<String> _valipadu = [];
  List<String> _poojaiMuraigal = [];
  List<String> _ukuthaMalar = [];
  List<String> _ukuthaUnavu = [];
  List<String> _naivethiyam = [];
  List<String> _parayanam = [];
  List<String> _venduthalgal = [];
  List<String> _venduthalNiraivetraPoojai = [];
  List<String> _venduthalNiraivuPoojai = [];
  List<String> _yagangal = [];

  // Step 4 variables
  final TextEditingController _specialDaysCtrl = TextEditingController();
  final TextEditingController _specialPujaCtrl = TextEditingController();
  final TextEditingController _fastingsCtrl = TextEditingController();
  List<Map<String, String>> _pujaTimes = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tamilNameCtrl.dispose();
    _searchTableCtrl.dispose();
    _deityTitleCtrl.dispose();
    _avatarCtrl.dispose();
    _deityFormCtrl.dispose();
    _parentDeityCtrl.dispose();
    _relationshipStatusCtrl.dispose();
    _relationshipCtrl.dispose();
    _deitySpecialityCtrl.dispose();
    _worshipMethodCtrl.dispose();
    _prayerRequestCtrl.dispose();
    _notesCtrl.dispose();
    _specialDaysCtrl.dispose();
    _specialPujaCtrl.dispose();
    _fastingsCtrl.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _savedDeities = [];
  bool _isLoading = false;

  String _getPrimaryDeityId(String? categoryTitle) {
    if (categoryTitle == null) return 'shiva';
    final lower = categoryTitle.toLowerCase().replaceAll(' ', '');
    if (lower.contains('சிவன்') || lower.contains('shiva') || lower.contains('siva')) return 'shiva';
    if (lower.contains('விஷ்ணு') || lower.contains('vishnu')) return 'vishnu';
    if (lower.contains('குல') || lower.contains('kula')) return 'kuladeivam';
    if (lower.contains('இஷ்ட') || lower.contains('ishta')) return 'ishtadeivam';
    if (lower.contains('கிராம') || lower.contains('grama')) return 'gramadeivam';
    if (lower.contains('முருகன்') || lower.contains('murugan')) return 'murugan';
    if (lower.contains('விநாயகர்') || lower.contains('vinayagar') || lower.contains('ganesha') || lower.contains('ganapathi')) return 'vinayagar';
    return lower;
  }

  List<Map<String, dynamic>> _getDeitiesForCategory(String? categoryTitle) {
    if (categoryTitle == null) return [];
    final id = _getPrimaryDeityId(categoryTitle);
    return _savedDeities.where((d) {
      final dId = d['primaryDeityId'] ?? _getPrimaryDeityId(d['primaryDeityCategory'] ?? d['deityCategory']);
      return dId == id;
    }).toList();
  }

  Future<void> _loadSavedDeities() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Primary Deities
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        setState(() {
          _savedDeities.clear();
          for (var item in decoded) {
            final map = Map<String, dynamic>.from(item);
            if (map['deityPhoto'] != null && map['deityPhoto'].toString().isNotEmpty) {
              try {
                map['mainPhotoBytes'] = base64Decode(map['deityPhoto']);
              } catch (_) {}
            }
            _savedDeities.add(map);
          }
        });
      }

      // 2. Separate Photos
      final rawPhotos = prefs.getString(_photosStorageKey);
      if (rawPhotos != null && rawPhotos.isNotEmpty) {
        final List<dynamic> decPhotos = jsonDecode(rawPhotos);
        _allPersistedPhotos.clear();
        _allPersistedPhotos.addAll(decPhotos.map((p) => PhotoReferenceRecord.fromJson(p)));
      }

      // 3. Separate Forms
      final rawForms = prefs.getString(_formsStorageKey);
      if (rawForms != null && rawForms.isNotEmpty) {
        final List<dynamic> decForms = jsonDecode(rawForms);
        _allPersistedForms.clear();
        _allPersistedForms.addAll(decForms.map((f) => DeityFormRecord.fromJson(f)));
      }

      // 4. Separate Nayanmars
      final rawNayanmars = prefs.getString(_nayanmarsStorageKey);
      if (rawNayanmars != null && rawNayanmars.isNotEmpty) {
        final List<dynamic> decNayanmars = jsonDecode(rawNayanmars);
        _allPersistedNayanmars.clear();
        _allPersistedNayanmars.addAll(decNayanmars.map((n) => NayanmarRecord.fromJson(n)));
      }

      // 5. Separate Siddhars
      final rawSiddhars = prefs.getString(_siddharsStorageKey);
      if (rawSiddhars != null && rawSiddhars.isNotEmpty) {
        final List<dynamic> decSiddhars = jsonDecode(rawSiddhars);
        _allPersistedSiddhars.clear();
        _allPersistedSiddhars.addAll(decSiddhars.map((s) => SiddharRecord.fromJson(s)));
      }

      // 6. Separate Family Relationships
      final rawFamily = prefs.getString(_familyStorageKey);
      if (rawFamily != null && rawFamily.isNotEmpty) {
        final List<dynamic> decFamily = jsonDecode(rawFamily);
        _allPersistedFamily.clear();
        _allPersistedFamily.addAll(decFamily.map((fm) => DeityFamilyRelationshipRecord.fromJson(fm)));
      }
    } catch (e) {
      debugPrint('Error loading saved deities: $e');
    }
  }

  Future<void> _persistAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toSave = _savedDeities.map((d) {
        final copy = Map<String, dynamic>.from(d);
        copy.remove('mainPhotoBytes');
        return copy;
      }).toList();
      await prefs.setString(_storageKey, jsonEncode(toSave));

      await prefs.setString(
        _photosStorageKey,
        jsonEncode(_allPersistedPhotos.map((p) => p.toJson()).toList()),
      );
      await prefs.setString(
        _formsStorageKey,
        jsonEncode(_allPersistedForms.map((f) => f.toJson()).toList()),
      );
      await prefs.setString(
        _nayanmarsStorageKey,
        jsonEncode(_allPersistedNayanmars.map((n) => n.toJson()).toList()),
      );
      await prefs.setString(
        _siddharsStorageKey,
        jsonEncode(_allPersistedSiddhars.map((s) => s.toJson()).toList()),
      );
      await prefs.setString(
        _familyStorageKey,
        jsonEncode(_allPersistedFamily.map((fm) => fm.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error persisting data: $e');
    }
  }

  Future<void> _persistSavedDeities() async {
    await _persistAllData();
  }

  Future<void> _saveStructuredPrimaryDeity(
    Map<String, dynamic> deityRecord,
    List<PhotoReferenceRecord> photos,
    List<DeityFormRecord> forms,
    List<NayanmarRecord> nayanmars,
    List<SiddharRecord> siddhars,
    List<DeityFamilyRelationshipRecord> family,
  ) async {
    setState(() => _isLoading = true);

    final deityId = deityRecord['id']?.toString() ?? 'shiva';

    // Update separate collections
    _allPersistedPhotos.removeWhere((p) => p.deityId == deityId);
    _allPersistedPhotos.addAll(photos);

    _allPersistedForms.removeWhere((f) => f.primaryDeityId == deityId);
    _allPersistedForms.addAll(forms);

    _allPersistedNayanmars.removeWhere((n) => n.primaryDeityId == deityId);
    _allPersistedNayanmars.addAll(nayanmars);

    _allPersistedSiddhars.removeWhere((s) => s.primaryDeityId == deityId);
    _allPersistedSiddhars.addAll(siddhars);

    _allPersistedFamily.removeWhere((fm) => fm.primaryDeityId == deityId);
    _allPersistedFamily.addAll(family);

    // Update or insert primary deity
    final idx = _savedDeities.indexWhere((d) => d['id']?.toString() == deityId);
    if (idx != -1) {
      _savedDeities[idx] = deityRecord;
    } else {
      _savedDeities.add(deityRecord);
    }

    await _persistAllData();

    setState(() {
      _isLoading = false;
      _editingDeityId = null;
    });

    if (mounted) {
      CustomDeleteDialog.showSuccess(
        context,
        message: '${deityRecord['tamilName']} முதன்மை தெய்வம் மற்றும் தொடர்புடைய தகவல்கள் வெற்றிகரமாக சேமிக்கப்பட்டன!',
      );
    }
  }

  void _clearManualAddForm() {
    setState(() {
      _editingDeityId = null;
      _nameCtrl.clear();
      _tamilNameCtrl.clear();
      _deityTitleCtrl.clear();
      _avatarCtrl.clear();
      _deityFormCtrl.clear();
      _parentDeityCtrl.clear();
      _relationshipStatusCtrl.clear();
      _relationshipCtrl.clear();
      _deitySpecialityCtrl.clear();
      _deivamType = 'Select வகை (Gender)';
      _mainPhotoBytes = null;
      _deityForms.clear();
      _deityForms.add({
        'image': null,
        'speciality': '',
        'name_ta': '',
        'name_en': '',
        'parent_deity': '',
        'image_url': null,
        'shiva_id': null,
      });
    });
  }

  void _clearForm() {
    setState(() {
      _currentStep = 0;
      _selectedCategory = null;
      _clearManualAddForm();
      _separateSannidhi = false;
      _auspiciousDayTime = false;
      _worshipMethodCtrl.clear();
      _prayerRequestCtrl.clear();
      _notesCtrl.clear();
      _specialDaysCtrl.clear();
      _specialPujaCtrl.clear();
      _fastingsCtrl.clear();
      _specialName = [];
      _valipadu = [];
      _poojaiMuraigal = [];
      _ukuthaMalar = [];
      _ukuthaUnavu = [];
      _naivethiyam = [];
      _parayanam = [];
      _venduthalgal = [];
      _venduthalNiraivetraPoojai = [];
      _venduthalNiraivuPoojai = [];
      _yagangal = [];
      _pujaTimes = [];
    });
  }

  void _onCategorySelected(String categoryTitle) {
    if (_selectedCategory != categoryTitle) {
      _selectedCategory = categoryTitle;
      _editingDeityId = null;
      _clearManualAddForm();
    }
  }

  void _loadDeityForEdit(Map<String, dynamic> deity) {
    setState(() {
      _editingDeityId = deity['id']?.toString();
      _selectedCategory = deity['primaryDeityCategory'] ?? deity['deityCategory'] ?? _selectedCategory ?? 'சிவன்';
      _tamilNameCtrl.text = deity['tamilName'] ?? deity['name'] ?? '';
      _nameCtrl.text = deity['deityName'] ?? '';
      _deityTitleCtrl.text = deity['deityTitle'] ?? '';
      _avatarCtrl.text = deity['avatar'] ?? '';
      _deityFormCtrl.text = deity['deityForm'] ?? '';
      _parentDeityCtrl.text = deity['parentDeityId'] ?? deity['parentDeity'] ?? '';
      _relationshipCtrl.text = deity['relationship'] ?? '';
      _relationshipStatusCtrl.text = deity['associatedDeities'] ?? deity['relationship_status'] ?? '';
      _deitySpecialityCtrl.text = deity['description'] ?? deity['deitySpeciality'] ?? '';
      _worshipMethodCtrl.text = deity['worshipMethod'] ?? '';
      _fastingsCtrl.text = deity['fastings'] ?? '';
      _notesCtrl.text = deity['notes'] ?? '';
      _mainPhotoBytes = deity['mainPhotoBytes'] as Uint8List?;

      // Hydrate separate structured collections if editing
      final deityId = _editingDeityId;
      if (deityId != null) {
        final photos = _allPersistedPhotos.where((p) => p.deityId == deityId).toList();
        final forms = _allPersistedForms.where((f) => f.primaryDeityId == deityId).toList();
        final nayanmars = _allPersistedNayanmars.where((n) => n.primaryDeityId == deityId).toList();
        final siddhars = _allPersistedSiddhars.where((s) => s.primaryDeityId == deityId).toList();
        final family = _allPersistedFamily.where((fm) => fm.primaryDeityId == deityId).toList();

        if (photos.isNotEmpty && (deity['photoReferences'] == null || (deity['photoReferences'] as List).isEmpty)) {
          deity['photoReferences'] = photos.map((p) => p.toJson()).toList();
        }
        if (forms.isNotEmpty && (deity['forms'] == null || (deity['forms'] as List).isEmpty)) {
          deity['forms'] = forms.map((f) => f.toJson()).toList();
        }
        if (nayanmars.isNotEmpty && (deity['nayanmars'] == null || (deity['nayanmars'] as List).isEmpty)) {
          deity['nayanmars'] = nayanmars.map((n) => n.toJson()).toList();
        }
        if (siddhars.isNotEmpty && (deity['siddhars'] == null || (deity['siddhars'] as List).isEmpty)) {
          deity['siddhars'] = siddhars.map((s) => s.toJson()).toList();
        }
        if (family.isNotEmpty && (deity['familyMembers'] == null || (deity['familyMembers'] as List).isEmpty)) {
          deity['familyMembers'] = family.map((fm) => fm.toJson()).toList();
        }
      }

      final type = (deity['gender'] ?? deity['deivamType'] ?? '').toString().toLowerCase();
      if (type == 'male' || type.contains('ஆண்')) {
        _deivamType = 'ஆண் தெய்வம் (Male Deity)';
      } else if (type == 'female' || type.contains('பெண்')) {
        _deivamType = 'பெண் தெய்வம் (Female Deity)';
      } else if (type.isNotEmpty) {
        _deivamType = 'மற்றவை (Other)';
      } else {
        _deivamType = 'Select வகை (Gender)';
      }

      _currentStep = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deity['tamilName'] ?? deity['name']} விவரங்கள் திருத்துவதற்காக ஏற்றப்பட்டன (Loaded for editing)'),
        backgroundColor: const Color(0xFFB01254),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteDeity(Map<String, dynamic> deity) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      setState(() {
        final deityId = deity['id']?.toString();
        _savedDeities.removeWhere((d) => d['id'] == deity['id']);
        if (deityId != null) {
          _allPersistedPhotos.removeWhere((p) => p.deityId == deityId);
          _allPersistedForms.removeWhere((f) => f.primaryDeityId == deityId);
          _allPersistedNayanmars.removeWhere((n) => n.primaryDeityId == deityId);
          _allPersistedSiddhars.removeWhere((s) => s.primaryDeityId == deityId);
          _allPersistedFamily.removeWhere((fm) => fm.primaryDeityId == deityId);
        }
        if (_editingDeityId == deity['id']) {
          _clearManualAddForm();
        }
      });
      await _persistAllData();
      if (mounted) {
        await CustomDeleteDialog.showDeleted(context);
      }
    }
  }

  Future<void> _saveManualDeity() async {
    final deityName = _nameCtrl.text.trim();
    final tamilName = _tamilNameCtrl.text.trim();

    if (deityName.isEmpty && tamilName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('தெய்வத்தின் பெயரை உள்ளிடவும் (Deity Name is required)', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_deivamType == 'Select வகை (Gender)' || _deivamType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('தெய்வத்தின் வகையைத் (பாலினம்) தேர்வு செய்யவும் (Gender is required)', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final primaryCategory = _selectedCategory ?? 'சிவன்';
    final primaryId = _getPrimaryDeityId(primaryCategory);
    final finalTamilName = tamilName.isNotEmpty ? tamilName : deityName;
    final finalDeityName = deityName.isNotEmpty ? deityName : tamilName;
    final genderCode = _deivamType.contains('ஆண்') ? 'male' : (_deivamType.contains('பெண்') ? 'female' : 'other');

    final record = {
      'id': _editingDeityId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'primaryDeityId': primaryId,
      'primaryDeityCategory': primaryCategory,
      'deityCategory': primaryCategory,
      'deityName': finalDeityName,
      'tamilName': finalTamilName,
      'name': finalTamilName,
      'gender': genderCode,
      'deivamType': genderCode,
      'relationship': _relationshipCtrl.text.trim(),
      'relationship_status': _relationshipCtrl.text.trim(),
      'parentDeityId': _parentDeityCtrl.text.trim(),
      'parentDeity': _parentDeityCtrl.text.trim(),
      'deityPhoto': _mainPhotoBytes != null ? base64Encode(_mainPhotoBytes!) : '',
      'mainPhotoBytes': _mainPhotoBytes,
      'description': _deitySpecialityCtrl.text.trim(),
      'deitySpeciality': _deitySpecialityCtrl.text.trim(),
      'worshipMethod': _worshipMethodCtrl.text.trim(),
      'prayerRequest': _prayerRequestCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'status': 'Active',
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (_editingDeityId != null) {
      final index = _savedDeities.indexWhere((d) => d['id'] == _editingDeityId);
      if (index != -1) {
        _savedDeities[index] = record;
      } else {
        _savedDeities.add(record);
      }
    } else {
      _savedDeities.add(record);
    }

    await _persistSavedDeities();

    setState(() => _isLoading = false);

    if (mounted) {
      CustomDeleteDialog.showSuccess(
        context,
        message: _editingDeityId != null
            ? '$finalTamilName தெய்வம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது'
            : '$finalTamilName தெய்வம் $primaryCategory முதன்மை தெய்வத்தின் கீழ் வெற்றிகரமாக சேமிக்கப்பட்டது',
      );
      _clearManualAddForm();
    }
  }

  Future<void> _saveRecord() async {
    await _saveManualDeity();
  }

  Future<void> _pickMainImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _mainPhotoBytes = bytes;
      });
    }
  }

  Future<void> _pickDeityFormImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _deityForms[index]['image'] = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.settings, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'புதிய தெய்வங்களைச் சேர்க்க (Add New Deities)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'கோவிலின் புதிய தெய்வங்களைச் சேர்க்க (add new deities) விவரங்களை இங்கே நிர்வகிக்கலாம்.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Stepper Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  // Custom Horizontal Stepper (simplified for UI)
                  _buildStepperUI(isDark, theme),
                  
                  const SizedBox(height: 32),
                  _buildCurrentStepContent(isDark, theme),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildDataTable(isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark, ThemeData theme) {
    if (_currentStep == 0) {
      return _buildStep1Content(isDark, theme);
    } else if (_currentStep == 1) {
      return _buildStep2Content(isDark, theme);
    } else if (_currentStep == 2) {
      return _buildStep3Content(isDark, theme);
    } else if (_currentStep == 3) {
      return _buildStep4Content(isDark, theme);
    }
    return _buildStep1Content(isDark, theme);
  }

  Widget _buildStep1Content(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.temple_hindu, color: theme.primaryColor, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'முதன்மை தெய்வம் தேர்வு (Select Primary Deity Category)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'முதன்மை தெய்வங்களில் (Shiva, Vishnu, Kuladeivam, Ishta Deivam, Grama Deivam) ஒன்றைத் தேர்வு செய்து, அதன் கீழ் தெய்வங்களை ஒவ்வொன்றாக சேர்க்கலாம்.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        _buildCategoryGrid(isDark, theme),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 450;
            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _selectedCategory != null
                        ? () {
                            setState(() {
                              _currentStep = 1;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01254),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Next Step →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedCategory != null
                      ? () {
                          setState(() {
                            _currentStep = 1;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB01254),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Next Step →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2Content(bool isDark, ThemeData theme) {
    final selectedCategoryData = _categories.firstWhere(
      (c) => c['title'] == _selectedCategory,
      orElse: () => _categories[0],
    );

    final deitiesUnderCurrentCategory = _getDeitiesForCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Icon(Icons.temple_hindu, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'முதன்மை தெய்வம்: ${_selectedCategory ?? 'சிவன்'} - தெய்வங்கள் மேலாண்மை',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Selected Category Banner
        _buildSelectedCategoryBanner(selectedCategoryData, isDark),
        const SizedBox(height: 28),

        if (_isShivaCategory) ...[
          ShivaStructuredRegistrationWidget(
            isDark: isDark,
            theme: theme,
            deitiesUnderCurrentCategory: deitiesUnderCurrentCategory,
            editingDeity: _editingDeityId != null
                ? _savedDeities.firstWhere(
                    (d) => d['id']?.toString() == _editingDeityId,
                    orElse: () => {},
                  )
                : null,
            onSavePrimaryDeity: (deityRecord, photos, forms, nayanmars, siddhars, family) async {
              await _saveStructuredPrimaryDeity(deityRecord, photos, forms, nayanmars, siddhars, family);
            },
            onCancelEdit: () {
              setState(() {
                _editingDeityId = null;
                _clearManualAddForm();
              });
            },
            onEditDeity: (deity) {
              _loadDeityForEdit(deity);
            },
            onDeleteDeity: (deity) {
              _deleteDeity(deity);
            },
          ),
          const SizedBox(height: 28),
          _buildDeitiesListUnderPrimaryDeity(deitiesUnderCurrentCategory, isDark, theme),
        ] else ...[
          // 1. Deities list under this Primary Deity
          _buildDeitiesListUnderPrimaryDeity(deitiesUnderCurrentCategory, isDark, theme),
          const SizedBox(height: 28),

          // 2. Manual Deity Entry Form
          _buildManualDeityAddCard(isDark, theme),
        ],
        const SizedBox(height: 32),

        // Navigation Row
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;
            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 2; // Optional step 3 for extra details
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01254),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('கூடுதல் விவரங்கள் (Extra Details) →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('முதன்மை தெய்வங்கள் (Categories)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('முதன்மை தெய்வங்கள் (Categories)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 2; // Optional step 3 for extra details
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB01254),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('கூடுதல் விவரங்கள் (Extra Details) →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeitiesListUnderPrimaryDeity(List<Map<String, dynamic>> deities, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 420;
              final iconBox = Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB01254).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 20),
              );

              final textCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedCategory முதன்மை தெய்வத்தின் கீழ் உள்ள தெய்வங்கள்',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Deities under $_selectedCategory (${deities.length} தெய்வங்கள்)',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              );

              final countBadge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB01254),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${deities.length} தெய்வங்கள்',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconBox,
                        const SizedBox(width: 10),
                        Expanded(child: textCol),
                      ],
                    ),
                    const SizedBox(height: 8),
                    countBadge,
                  ],
                );
              }

              return Row(
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(child: textCol),
                  const SizedBox(width: 8),
                  countBadge,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (deities.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.playlist_add, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    '$_selectedCategory முதன்மை தெய்வத்தின் கீழ் இதுவரை தெய்வங்கள் சேர்க்கப்படவில்லை.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'கீழே உள்ள படிவத்தில் விவரங்களை உள்ளிட்டு "தெய்வத்தை சேமி" பட்டனை அழுத்தி சேர்க்கவும்.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 12,
                ),
                dataTextStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                ),
                columns: const [
                  DataColumn(label: Text('படம்\n(PHOTO)')),
                  DataColumn(label: Text('தமிழ் பெயர்\n(TAMIL NAME)')),
                  DataColumn(label: Text('ஆங்கிலப் பெயர்\n(NAME)')),
                  DataColumn(label: Text('பாலினம்\n(GENDER)')),
                  DataColumn(label: Text('தொடர்பு\n(RELATIONSHIP)')),
                  DataColumn(label: Text('பெற்றோர்\n(PARENT)')),
                  DataColumn(label: Text('விளக்கம்\n(DESCRIPTION)')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: deities.map((deity) {
                  final photoBytes = deity['mainPhotoBytes'] as Uint8List?;
                  final isMale = (deity['gender'] ?? '').toString() == 'male';
                  final isFemale = (deity['gender'] ?? '').toString() == 'female';

                  return DataRow(
                    cells: [
                      DataCell(
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                          backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                          child: photoBytes == null
                              ? const Icon(Icons.temple_hindu, size: 16, color: Color(0xFFB01254))
                              : null,
                        ),
                      ),
                      DataCell(Text(deity['tamilName'] ?? deity['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(deity['deityName'] ?? '-')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMale ? Colors.blue.shade50 : (isFemale ? Colors.pink.shade50 : Colors.purple.shade50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isMale ? 'ஆண்' : (isFemale ? 'பெண்' : 'மற்றவை'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isMale ? Colors.blue.shade800 : (isFemale ? Colors.pink.shade800 : Colors.purple.shade800),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(deity['relationship']?.toString().isNotEmpty == true ? deity['relationship'] : '-'),
                            if ((deity['forms'] as List?)?.isNotEmpty == true ||
                                (deity['familyMembers'] as List?)?.isNotEmpty == true ||
                                (deity['nayanmars'] as List?)?.isNotEmpty == true ||
                                (deity['siddhars'] as List?)?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  if ((deity['forms'] as List?)?.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text('${(deity['forms'] as List).length} Forms', style: TextStyle(fontSize: 9, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                    ),
                                  if ((deity['familyMembers'] as List?)?.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text('${(deity['familyMembers'] as List).length} Family', style: TextStyle(fontSize: 9, color: Colors.pink.shade800, fontWeight: FontWeight.bold)),
                                    ),
                                  if (((deity['nayanmars'] as List?)?.isNotEmpty == true) || ((deity['siddhars'] as List?)?.isNotEmpty == true))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        '${((deity['nayanmars'] as List?)?.length ?? 0) + ((deity['siddhars'] as List?)?.length ?? 0)} Saints',
                                        style: TextStyle(fontSize: 9, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(Text(deity['parentDeityId']?.toString().isNotEmpty == true ? deity['parentDeityId'] : (deity['parentDeity']?.toString().isNotEmpty == true ? deity['parentDeity'] : '-'))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            deity['description']?.toString().isNotEmpty == true ? deity['description'] : (deity['deitySpeciality']?.toString().isNotEmpty == true ? deity['deitySpeciality'] : '-'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                              tooltip: 'திருத்து (Edit)',
                              onPressed: () => _loadDeityForEdit(deity),
                              splashRadius: 18,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'நீக்கு (Delete)',
                              onPressed: () => _deleteDeity(deity),
                              splashRadius: 18,
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

  Widget _buildManualDeityAddCard(bool isDark, ThemeData theme) {
    final isEditing = _editingDeityId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: isEditing ? const Color(0xFFB01254) : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          width: isEditing ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;
              final titleRow = Row(
                children: [
                  Icon(isEditing ? Icons.edit_note : Icons.person_add_alt_1, color: const Color(0xFFB01254), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'தெய்வத்தை திருத்து (Edit Deity) - ${_tamilNameCtrl.text.isNotEmpty ? _tamilNameCtrl.text : _nameCtrl.text}'
                          : 'புதிய தெய்வம் சேர்க்க (Add Deity Under $_selectedCategory)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              );

              final cancelBtn = isEditing
                  ? TextButton.icon(
                      onPressed: _clearManualAddForm,
                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                      label: const Text('திருத்துவதை ரத்து செய்', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    )
                  : null;

              if (isSmall && cancelBtn != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: cancelBtn),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleRow),
                  if (cancelBtn != null) cancelBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Layout Builder for responsive input
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 700;

              final tamilNameField = _buildTextField(
                'தமிழ் பெயர் (Tamil Name) *',
                'எ.கா: சிவன், பார்வதி, கணேசர், முருகன்...',
                controller: _tamilNameCtrl,
                isDark: isDark,
              );

              final nameField = _buildTextField(
                'பெயர் / ஆங்கிலப் பெயர் (Deity Name in English) *',
                'e.g. Shiva, Parvati, Ganesha, Murugan...',
                controller: _nameCtrl,
                isDark: isDark,
              );

              final genderField = _buildTextField(
                'வகை / பாலினம் (Gender) *',
                'Select வகை (Gender)',
                isDropdown: true,
                dropdownItems: [
                  'Select வகை (Gender)',
                  'ஆண் தெய்வம் (Male Deity)',
                  'பெண் தெய்வம் (Female Deity)',
                  'மற்றவை (Other)',
                ],
                value: _deivamType,
                onChanged: (v) => setState(() => _deivamType = v ?? 'Select வகை (Gender)'),
                isDark: isDark,
              );

              final relationshipField = _buildTextField(
                'தொடர்பு / உறவுமுறை (Relationship)',
                'எ.கா: மூலவர், உடனுறை தெய்வம், துணைவி, மகன்...',
                controller: _relationshipCtrl,
                isDark: isDark,
              );

              final parentDeityField = _buildTextField(
                'பெற்றோர் தெய்வம் (Parent Deity - Optional)',
                'எ.கா: சிவபெருமான் & பார்வதி தேவி...',
                controller: _parentDeityCtrl,
                isDark: isDark,
              );

              final descriptionField = _buildTextField(
                'விளக்கம் / குறிப்பு (Description)',
                'தெய்வத்தின் சிறப்பு அல்லது குறிப்பு...',
                controller: _deitySpecialityCtrl,
                isDark: isDark,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: tamilNameField),
                        const SizedBox(width: 16),
                        Expanded(child: nameField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: genderField),
                        const SizedBox(width: 16),
                        Expanded(child: relationshipField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: parentDeityField),
                        const SizedBox(width: 16),
                        Expanded(child: descriptionField),
                      ],
                    ),
                  ] else ...[
                    tamilNameField,
                    const SizedBox(height: 16),
                    nameField,
                    const SizedBox(height: 16),
                    genderField,
                    const SizedBox(height: 16),
                    relationshipField,
                    const SizedBox(height: 16),
                    parentDeityField,
                    const SizedBox(height: 16),
                    descriptionField,
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'புகைப்படம் (Deity Photo)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDashedUploadBox(isDark, theme),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveManualDeity,
                        icon: Icon(isEditing ? Icons.update : Icons.save, size: 18),
                        label: Text(
                          isEditing
                              ? 'தெய்வத்தை புதுப்பி (Update Deity)'
                              : 'தெய்வத்தை சேமி (Save Deity Under $_selectedCategory)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB01254),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _clearManualAddForm,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('படிவத்தை அழி (Clear)'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCategoryBanner(Map<String, dynamic> selectedCategoryData, bool isDark) {
    final deitiesCount = _getDeitiesForCategory(selectedCategoryData['title']).length;
    final headerTitle = '${selectedCategoryData['title']} (${selectedCategoryData['subtitle']})';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE4EC), // light pink
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 500;
          
          Widget imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildDevotionalImage(
              selectedCategoryData['image'], 
              width: 48, 
              height: 48, 
              fit: BoxFit.cover,
            ),
          );

          Widget textColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  const Text(
                    'PRIMARY DEITY (முதன்மை தெய்வம்)',
                    style: TextStyle(color: Color(0xFFB01254), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  _buildCategoryBadge('$deitiesCount தெய்வங்கள்'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                headerTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ],
          );

          Widget editButton = OutlinedButton(
            onPressed: () => setState(() => _currentStep = 0),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFB01254)),
              foregroundColor: const Color(0xFFB01254),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Edit Category / மாற்றுக'),
          );

          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    imageWidget,
                    const SizedBox(width: 12),
                    Expanded(child: textColumn),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: editButton,
                ),
              ],
            );
          }

          return Row(
            children: [
              imageWidget,
              const SizedBox(width: 16),
              Expanded(child: textColumn),
              const SizedBox(width: 12),
              editButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFB01254),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFormHeaderForCategory(int idx, Map<String, dynamic> form, bool isDark) {
    if (_isShivaCategory) {
      return _buildFormHeader(
        title: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? '${form['shiva_id'] != null ? '#${form['shiva_id']} ' : ''}${form['name_ta']} (${form['name_en'] ?? ''})'
            : 'சிவ வடிவம் (Shiva Form)',
        btnLabel: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? 'மாற்று (Change)'
            : '64 மூர்த்தியிலிருந்து தேர்வு',
        onTap: () => _showShivaMurtiSelectionDialog(formIndex: idx),
        isDark: isDark,
        hasSelection: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty,
      );
    } else if (_isVishnuCategory) {
      return _buildFormHeader(
        title: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? '${form['name_ta']} (${form['name_en'] ?? ''})'
            : 'விஷ்ணு அவதாரம் / திருக்கோலம் (Vishnu Form / Avatar)',
        btnLabel: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? 'மாற்று (Change)'
            : 'அவதாரம் / திருக்கோலத்திலிருந்து தேர்வு',
        onTap: () => _showVishnuSelectionDialog(formIndex: idx),
        isDark: isDark,
        hasSelection: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty,
      );
    } else if (_isMuruganCategory) {
      return _buildFormHeader(
        title: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? '${form['name_ta']} (${form['name_en'] ?? ''})'
            : 'முருகன் திருக்கோலம் (Murugan Form)',
        btnLabel: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? 'மாற்று (Change)'
            : '9 திருக்கோலங்களிலிருந்து தேர்வு',
        onTap: () => _showMuruganSelectionDialog(formIndex: idx),
        isDark: isDark,
        hasSelection: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty,
      );
    } else if (_isVinayagarCategory) {
      return _buildFormHeader(
        title: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? '${form['name_ta']} (${form['name_en'] ?? ''})'
            : 'கணபதி திருமேனி (Ganesha Form)',
        btnLabel: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty
            ? 'மாற்று (Change)'
            : '32 திருமேனிகளிலிருந்து தேர்வு',
        onTap: () => _showVinayagarSelectionDialog(formIndex: idx),
        isDark: isDark,
        hasSelection: form['name_ta'] != null && form['name_ta'].toString().isNotEmpty,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFormHeader({
    required String title,
    required String btnLabel,
    required VoidCallback onTap,
    required bool isDark,
    required bool hasSelection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: hasSelection
                      ? const Color(0xFFB01254)
                      : (isDark ? Colors.white70 : const Color(0xFF1E1B4B)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFFB01254)),
                    const SizedBox(width: 4),
                    Text(
                      btnLabel,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFB01254), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildDeityNameField(bool isDark) {
    if (_isShivaCategory) {
      return _buildShivaNameField(isDark);
    } else if (_isVishnuCategory) {
      return _buildVishnuNameField(isDark);
    } else if (_isMuruganCategory) {
      return _buildMuruganNameField(isDark);
    } else if (_isVinayagarCategory) {
      return _buildVinayagarNameField(isDark);
    }
    return _buildTextField('பெயர்', 'தெய்வத்தின் பெயர்...', controller: _nameCtrl, isDark: isDark);
  }

  Widget _buildVishnuNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: 'பெயர் / திருநாமம் (Vishnu Name) ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showVishnuSelectionDialog(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFB01254).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB01254).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, size: 13, color: Color(0xFFB01254)),
                    SizedBox(width: 4),
                    Text(
                      '18 திருநாமங்கள் பட்டியல்',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'திருநாமத்தைத் தேர்வு செய் அல்லது தட்டச்சு செய்...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.temple_hindu, size: 20, color: Color(0xFFB01254)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFFB01254), size: 20),
              tooltip: 'விஷ்ணு திருநாமங்கள் & வடிவங்கள்',
              onPressed: () => _showVishnuSelectionDialog(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB01254), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildMuruganNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: 'பெயர் / திருநாமம் (Murugan Name) ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showMuruganSelectionDialog(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFB01254).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB01254).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, size: 13, color: Color(0xFFB01254)),
                    SizedBox(width: 4),
                    Text(
                      '13 திருநாமங்கள் பட்டியல்',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'முருகன் பெயரைத் தேர்வு செய் அல்லது தட்டச்சு செய்...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.temple_hindu, size: 20, color: Color(0xFFB01254)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFFB01254), size: 20),
              tooltip: 'முருகன் திருநாமங்கள் & வடிவங்கள்',
              onPressed: () => _showMuruganSelectionDialog(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB01254), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildVinayagarNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: 'பெயர் / திருநாமம் (Vinayagar Name) ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showVinayagarSelectionDialog(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFB01254).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB01254).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, size: 13, color: Color(0xFFB01254)),
                    SizedBox(width: 4),
                    Text(
                      '10 திருநாமங்கள் பட்டியல்',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'விநாயகர் பெயரைத் தேர்வு செய் அல்லது தட்டச்சு செய்...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.temple_hindu, size: 20, color: Color(0xFFB01254)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFFB01254), size: 20),
              tooltip: 'விநாயகர் திருநாமங்கள் & 32 திருமேனிகள்',
              onPressed: () => _showVinayagarSelectionDialog(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB01254), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDependentDetailRows(bool isDark, bool isRowLayout) {
    if (_isVishnuCategory) {
      final avatarValue = _avatarCtrl.text.isNotEmpty && VishnuMasterData.dashavatara.any((a) => a.displayName == _avatarCtrl.text)
          ? _avatarCtrl.text
          : 'பொருந்தாது / இல்லை (None)';
      final formValue = _deityFormCtrl.text.isNotEmpty && VishnuMasterData.additionalForms.any((f) => f.displayName == _deityFormCtrl.text)
          ? _deityFormCtrl.text
          : 'பொருந்தாது / இல்லை (None)';
      final consortValue = _relationshipStatusCtrl.text.isNotEmpty && VishnuMasterData.associatedConsorts.contains(_relationshipStatusCtrl.text)
          ? _relationshipStatusCtrl.text
          : 'Select உடனுறை தெய்வம்';

      final avatarField = _buildTextField(
        'அவதாரம் (Dashavatara - 10 Avatars)',
        'Select அவதாரம்',
        isDropdown: true,
        dropdownItems: ['பொருந்தாது / இல்லை (None)', ...VishnuMasterData.dashavatara.map((a) => a.displayName)],
        value: avatarValue,
        onChanged: _onSelectVishnuAvatar,
        isDark: isDark,
      );

      final formField = _buildTextField(
        'திருக்கோலம் / வடிவம் (11 Vishnu Temple Forms)',
        'Select திருக்கோலம்',
        isDropdown: true,
        dropdownItems: ['பொருந்தாது / இல்லை (None)', ...VishnuMasterData.additionalForms.map((f) => f.displayName)],
        value: formValue,
        onChanged: _onSelectVishnuForm,
        isDark: isDark,
      );

      final consortField = _buildTextField(
        'உடனுறை தெய்வம் (Associated Consort)',
        'Select உடனுறை தெய்வம்',
        isDropdown: true,
        dropdownItems: ['Select உடனுறை தெய்வம்', ...VishnuMasterData.associatedConsorts],
        value: consortValue,
        onChanged: (v) => setState(() => _relationshipStatusCtrl.text = (v == 'Select உடனுறை தெய்வம்' ? '' : v ?? '')),
        isDark: isDark,
      );

      final relField = _buildTextField(
        'தொடர்பு (Relationship)',
        'எ.கா: காக்கும் கடவுள்...',
        controller: _relationshipCtrl,
        isDark: isDark,
      );

      if (isRowLayout) {
        return [
          Row(
            children: [
              Expanded(child: avatarField),
              const SizedBox(width: 16),
              Expanded(child: formField),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: consortField),
              const SizedBox(width: 16),
              Expanded(child: relField),
            ],
          ),
        ];
      } else {
        return [
          avatarField,
          const SizedBox(height: 16),
          formField,
          const SizedBox(height: 16),
          consortField,
          const SizedBox(height: 16),
          relField,
        ];
      }
    } else if (_isMuruganCategory) {
      final formValue = _deityFormCtrl.text.isNotEmpty && MuruganMasterData.templeForms.any((f) => f.displayName == _deityFormCtrl.text)
          ? _deityFormCtrl.text
          : 'Select திருக்கோலம் (Temple Form)';
      final consortValue = _relationshipStatusCtrl.text.isNotEmpty && MuruganMasterData.associatedConsorts.contains(_relationshipStatusCtrl.text)
          ? _relationshipStatusCtrl.text
          : 'Select உடனுறை தெய்வம்';

      final formField = _buildTextField(
        'திருக்கோலம் / வடிவம் (9 Murugan Temple Forms)',
        'Select திருக்கோலம்',
        isDropdown: true,
        dropdownItems: ['Select திருக்கோலம் (Temple Form)', ...MuruganMasterData.templeForms.map((f) => f.displayName)],
        value: formValue,
        onChanged: _onSelectMuruganForm,
        isDark: isDark,
      );

      final parentField = _buildTextField(
        'பெற்றோர் தெய்வம் (Parent Deity)',
        'சிவபெருமான் & பார்வதி தேவி...',
        controller: _parentDeityCtrl,
        isDark: isDark,
      );

      final consortField = _buildTextField(
        'உடனுறை தெய்வம் (Associated Consort)',
        'Select உடனுறை தெய்வம்',
        isDropdown: true,
        dropdownItems: ['Select உடனுறை தெய்வம்', ...MuruganMasterData.associatedConsorts],
        value: consortValue,
        onChanged: (v) => setState(() => _relationshipStatusCtrl.text = (v == 'Select உடனுறை தெய்வம்' ? '' : v ?? '')),
        isDark: isDark,
      );

      final relField = _buildTextField(
        'தொடர்பு (Relationship)',
        'தந்தை & தாய்...',
        controller: _relationshipCtrl,
        isDark: isDark,
      );

      if (isRowLayout) {
        return [
          Row(
            children: [
              Expanded(child: formField),
              const SizedBox(width: 16),
              Expanded(child: parentField),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: consortField),
              const SizedBox(width: 16),
              Expanded(child: relField),
            ],
          ),
        ];
      } else {
        return [
          formField,
          const SizedBox(height: 16),
          parentField,
          const SizedBox(height: 16),
          consortField,
          const SizedBox(height: 16),
          relField,
        ];
      }
    } else if (_isVinayagarCategory) {
      final formValue = _deityFormCtrl.text.isNotEmpty && VinayagarMasterData.traditional32Forms.any((f) => f.displayName == _deityFormCtrl.text)
          ? _deityFormCtrl.text
          : 'Select கணபதி திருமேனி (Ganesha Form)';
      final consortValue = _relationshipStatusCtrl.text.isNotEmpty && VinayagarMasterData.associatedConsorts.contains(_relationshipStatusCtrl.text)
          ? _relationshipStatusCtrl.text
          : 'Select உடனுறை தெய்வம்';

      final formField = _buildTextField(
        '32 கணபதி திருமேனிகள் (32 Ganesha Forms)',
        'Select கணபதி திருமேனி',
        isDropdown: true,
        dropdownItems: ['Select கணபதி திருமேனி (Ganesha Form)', ...VinayagarMasterData.traditional32Forms.map((f) => f.displayName)],
        value: formValue,
        onChanged: _onSelectVinayagarForm,
        isDark: isDark,
      );

      final parentField = _buildTextField(
        'பெற்றோர் தெய்வம் (Parent Deity)',
        'சிவபெருமான் & பார்வதி தேவி...',
        controller: _parentDeityCtrl,
        isDark: isDark,
      );

      final consortField = _buildTextField(
        'உடனுறை தெய்வம் (Associated Consort)',
        'Select உடனுறை தெய்வம்',
        isDropdown: true,
        dropdownItems: ['Select உடனுறை தெய்வம்', ...VinayagarMasterData.associatedConsorts],
        value: consortValue,
        onChanged: (v) => setState(() => _relationshipStatusCtrl.text = (v == 'Select உடனுறை தெய்வம்' ? '' : v ?? '')),
        isDark: isDark,
      );

      final relField = _buildTextField(
        'தொடர்பு (Relationship)',
        'தந்தை & தாய்...',
        controller: _relationshipCtrl,
        isDark: isDark,
      );

      if (isRowLayout) {
        return [
          Row(
            children: [
              Expanded(child: formField),
              const SizedBox(width: 16),
              Expanded(child: parentField),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: consortField),
              const SizedBox(width: 16),
              Expanded(child: relField),
            ],
          ),
        ];
      } else {
        return [
          formField,
          const SizedBox(height: 16),
          parentField,
          const SizedBox(height: 16),
          consortField,
          const SizedBox(height: 16),
          relField,
        ];
      }
    } else {
      final consortField = _buildTextField('உடனுறை தெய்வம்', 'எ.கா: பார்வதி...', controller: _relationshipStatusCtrl, isDark: isDark);
      final relField = _buildTextField('தொடர்பு (Relationship)', 'எ.கா: தந்தை...', controller: _relationshipCtrl, isDark: isDark);

      if (isRowLayout) {
        return [
          Row(
            children: [
              Expanded(child: consortField),
              const SizedBox(width: 16),
              Expanded(child: relField),
            ],
          ),
        ];
      } else {
        return [
          consortField,
          const SizedBox(height: 16),
          relField,
        ];
      }
    }
  }

  void _onSelectVishnuAvatar(String? val) {
    setState(() {
      if (val == null || val == 'பொருந்தாது / இல்லை (None)') {
        _avatarCtrl.clear();
      } else {
        _avatarCtrl.text = val;
        final avatar = VishnuMasterData.dashavatara.firstWhere(
          (a) => a.displayName == val,
          orElse: () => VishnuMasterData.dashavatara.first,
        );
        if (_nameCtrl.text.isEmpty || _nameCtrl.text.startsWith('விஷ்ணு')) {
          _nameCtrl.text = avatar.displayName;
          _deityTitleCtrl.text = avatar.nameEn;
        }
        if (_deitySpecialityCtrl.text.isEmpty) {
          _deitySpecialityCtrl.text = avatar.description;
        }
        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = avatar.nameTa;
          _deityForms[0]['name_en'] = avatar.nameEn;
          _deityForms[0]['speciality'] = avatar.description;
          _deityForms[0]['parent_deity'] = 'விஷ்ணு பரம்பொருள்';
          if (avatar.image.isNotEmpty) {
            _deityForms[0]['image_url'] = avatar.image;
          }
        }
      }
    });
  }

  void _onSelectVishnuForm(String? val) {
    setState(() {
      if (val == null || val == 'பொருந்தாது / இல்லை (None)') {
        _deityFormCtrl.clear();
      } else {
        _deityFormCtrl.text = val;
        final form = VishnuMasterData.additionalForms.firstWhere(
          (f) => f.displayName == val,
          orElse: () => VishnuMasterData.additionalForms.first,
        );
        if (_nameCtrl.text.isEmpty || _nameCtrl.text.startsWith('விஷ்ணு')) {
          _nameCtrl.text = form.displayName;
          _deityTitleCtrl.text = form.nameEn;
        }
        if (_deitySpecialityCtrl.text.isEmpty) {
          _deitySpecialityCtrl.text = form.description;
        }
        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = form.nameTa;
          _deityForms[0]['name_en'] = form.nameEn;
          _deityForms[0]['speciality'] = form.description;
          _deityForms[0]['parent_deity'] = 'விஷ்ணு பரம்பொருள்';
        }
      }
    });
  }

  void _onSelectMuruganForm(String? val) {
    setState(() {
      if (val == null || val == 'Select திருக்கோலம் (Temple Form)') {
        _deityFormCtrl.clear();
      } else {
        _deityFormCtrl.text = val;
        final form = MuruganMasterData.templeForms.firstWhere(
          (f) => f.displayName == val,
          orElse: () => MuruganMasterData.templeForms.first,
        );
        if (_nameCtrl.text.isEmpty || _nameCtrl.text.startsWith('முருகன்')) {
          _nameCtrl.text = form.displayName;
          _deityTitleCtrl.text = form.nameEn;
        }
        if (_deitySpecialityCtrl.text.isEmpty) {
          _deitySpecialityCtrl.text = form.description;
        }
        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = form.nameTa;
          _deityForms[0]['name_en'] = form.nameEn;
          _deityForms[0]['speciality'] = form.description;
          _deityForms[0]['parent_deity'] = MuruganMasterData.defaultParentDeity;
        }
      }
    });
  }

  void _onSelectVinayagarForm(String? val) {
    setState(() {
      if (val == null || val == 'Select கணபதி திருமேனி (Ganesha Form)') {
        _deityFormCtrl.clear();
      } else {
        _deityFormCtrl.text = val;
        final form = VinayagarMasterData.traditional32Forms.firstWhere(
          (f) => f.displayName == val,
          orElse: () => VinayagarMasterData.traditional32Forms.first,
        );
        if (_nameCtrl.text.isEmpty || _nameCtrl.text.startsWith('விநாயகர்') || _nameCtrl.text.startsWith('கணபதி')) {
          _nameCtrl.text = form.displayName;
          _deityTitleCtrl.text = form.nameEn;
        }
        if (_deitySpecialityCtrl.text.isEmpty) {
          _deitySpecialityCtrl.text = form.description;
        }
        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = form.nameTa;
          _deityForms[0]['name_en'] = form.nameEn;
          _deityForms[0]['speciality'] = form.description;
          _deityForms[0]['parent_deity'] = VinayagarMasterData.defaultParentDeity;
        }
      }
    });
  }

  Future<void> _showVishnuSelectionDialog({int? formIndex}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String searchQuery = '';
        String currentFilter = formIndex != null ? 'forms' : 'all';

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final List<Map<String, dynamic>> allItems = [
              ...VishnuMasterData.namesAndTitles.map((n) => {
                'title': n.displayName,
                'name_ta': n.nameTa,
                'name_en': n.nameEn,
                'category': 'names',
                'badge': 'திருநாமம் (Title)',
                'desc': n.description ?? '',
                'image': '',
              }),
              ...VishnuMasterData.dashavatara.map((a) => {
                'title': a.displayName,
                'name_ta': a.nameTa,
                'name_en': a.nameEn,
                'category': 'avatars',
                'badge': 'தசாவதாரம் #${a.id}',
                'desc': a.description,
                'image': a.image,
              }),
              ...VishnuMasterData.additionalForms.map((f) => {
                'title': f.displayName,
                'name_ta': f.nameTa,
                'name_en': f.nameEn,
                'category': 'forms',
                'badge': 'திருக்கோலம் #${f.id}',
                'desc': f.description,
                'image': f.image,
              }),
            ];

            final filteredList = allItems.where((item) {
              final matchesFilter = currentFilter == 'all' || item['category'] == currentFilter;
              final q = searchQuery.toLowerCase().trim();
              if (q.isEmpty) return matchesFilter;
              final matchesQuery = item['title'].toString().toLowerCase().contains(q) ||
                  item['name_en'].toString().toLowerCase().contains(q) ||
                  item['desc'].toString().toLowerCase().contains(q);
              return matchesFilter && matchesQuery;
            }).toList();

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB01254).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'விஷ்ணு தெய்வ வடிவங்கள் & திருநாமங்கள்',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '18 திருநாமங்கள், 10 தசாவதாரம் & 11 திருக்கோலங்கள்',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) => setDialogState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'பெயர் அல்லது ஆங்கிலத்தில் தேடுங்கள் (e.g. Rama, கிருஷ்ணன், Narasimha)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'அனைத்தும் (${allItems.length})',
                            isSelected: currentFilter == 'all',
                            onTap: () => setDialogState(() => currentFilter = 'all'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '18 திருநாமங்கள் (18)',
                            isSelected: currentFilter == 'names',
                            onTap: () => setDialogState(() => currentFilter = 'names'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '10 தசாவதாரம் (10)',
                            isSelected: currentFilter == 'avatars',
                            onTap: () => setDialogState(() => currentFilter = 'avatars'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '11 திருக்கோலங்கள் (11)',
                            isSelected: currentFilter == 'forms',
                            onTap: () => setDialogState(() => currentFilter = 'forms'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${filteredList.length} பதிவுகள் காட்டப்படுகின்றன',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Text('பொருந்தும் பதிவுகள் எதுவும் இல்லை', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                            )
                          : ListView.separated(
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              itemBuilder: (context, idx) {
                                final item = filteredList[idx];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                                    foregroundColor: const Color(0xFFB01254),
                                    child: const Icon(Icons.temple_hindu, size: 20),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name_ta'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E1B4B)),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item['category'] == 'avatars' ? Colors.amber.shade100 : (item['category'] == 'forms' ? Colors.blue.shade100 : Colors.green.shade100),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item['badge'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: item['category'] == 'avatars' ? Colors.amber.shade900 : (item['category'] == 'forms' ? Colors.blue.shade900 : Colors.green.shade900),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${item['name_en']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                                      if (item['desc'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(item['desc'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                      ],
                                    ],
                                  ),
                                  onTap: () {
                                    _onSelectVishnuItem(item, formIndex: formIndex);
                                    Navigator.of(ctx).pop();
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

  void _onSelectVishnuItem(Map<String, dynamic> item, {int? formIndex}) {
    setState(() {
      if (formIndex == null) {
        _nameCtrl.text = item['title'];
        _deityTitleCtrl.text = item['name_en'];
        _deivamType = VishnuMasterData.defaultGender;

        if (item['category'] == 'avatars') {
          _avatarCtrl.text = item['title'];
        } else if (item['category'] == 'forms') {
          _deityFormCtrl.text = item['title'];
        }

        if (_deitySpecialityCtrl.text.isEmpty && item['desc'].toString().isNotEmpty) {
          _deitySpecialityCtrl.text = item['desc'];
        }

        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = item['name_ta'];
          _deityForms[0]['name_en'] = item['name_en'];
          _deityForms[0]['speciality'] = item['desc'];
          _deityForms[0]['parent_deity'] = 'விஷ்ணு பரம்பொருள்';
          if (item['image'].toString().isNotEmpty) {
            _deityForms[0]['image_url'] = item['image'];
          }
        }
      } else if (formIndex >= 0 && formIndex < _deityForms.length) {
        final isDuplicate = _deityForms.asMap().entries.any(
          (e) => e.key != formIndex && (e.value['name_en'] == item['name_en'] || e.value['name_ta'] == item['name_ta']),
        );
        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name_ta']} ஏற்கனவே ரூபங்கள் பட்டியலில் உள்ளது (Already added in forms).'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          return;
        }
        _deityForms[formIndex]['name_ta'] = item['name_ta'];
        _deityForms[formIndex]['name_en'] = item['name_en'];
        _deityForms[formIndex]['speciality'] = item['desc'];
        _deityForms[formIndex]['parent_deity'] = 'விஷ்ணு பரம்பொருள்';
        if (item['image'].toString().isNotEmpty) {
          _deityForms[formIndex]['image_url'] = item['image'];
        }
      }
    });
  }

  Future<void> _showMuruganSelectionDialog({int? formIndex}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String searchQuery = '';
        String currentFilter = formIndex != null ? 'forms' : 'all';

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final List<Map<String, dynamic>> allItems = [
              ...MuruganMasterData.namesAndTitles.map((n) => {
                'title': n.displayName,
                'name_ta': n.nameTa,
                'name_en': n.nameEn,
                'category': 'names',
                'badge': 'திருநாமம் (Title)',
                'desc': n.description ?? '',
              }),
              ...MuruganMasterData.templeForms.map((f) => {
                'title': f.displayName,
                'name_ta': f.nameTa,
                'name_en': f.nameEn,
                'category': 'forms',
                'badge': 'திருக்கோலம் #${f.id}',
                'desc': f.description,
              }),
            ];

            final filteredList = allItems.where((item) {
              final matchesFilter = currentFilter == 'all' || item['category'] == currentFilter;
              final q = searchQuery.toLowerCase().trim();
              if (q.isEmpty) return matchesFilter;
              final matchesQuery = item['title'].toString().toLowerCase().contains(q) ||
                  item['name_en'].toString().toLowerCase().contains(q) ||
                  item['desc'].toString().toLowerCase().contains(q);
              return matchesFilter && matchesQuery;
            }).toList();

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB01254).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'முருகன் திருநாமங்கள் & திருக்கோலங்கள்',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '13 திருநாமங்கள் & 9 திருக்கோலங்கள் (Temple Forms)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) => setDialogState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'பெயர் அல்லது திருக்கோலம் தேடுங்கள் (e.g. Palani, சண்முகர்)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'அனைத்தும் (${allItems.length})',
                            isSelected: currentFilter == 'all',
                            onTap: () => setDialogState(() => currentFilter = 'all'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '13 திருநாமங்கள் (13)',
                            isSelected: currentFilter == 'names',
                            onTap: () => setDialogState(() => currentFilter = 'names'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '9 திருக்கோலங்கள் (9)',
                            isSelected: currentFilter == 'forms',
                            onTap: () => setDialogState(() => currentFilter = 'forms'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${filteredList.length} வடிவங்கள் காட்டப்படுகின்றன',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Text('பொருந்தும் வடிவங்கள் எதுவும் இல்லை', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                            )
                          : ListView.separated(
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              itemBuilder: (context, idx) {
                                final item = filteredList[idx];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                                    foregroundColor: const Color(0xFFB01254),
                                    child: const Icon(Icons.temple_hindu, size: 20),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name_ta'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E1B4B)),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item['category'] == 'forms' ? Colors.blue.shade100 : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item['badge'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: item['category'] == 'forms' ? Colors.blue.shade900 : Colors.green.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${item['name_en']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                                      if (item['desc'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(item['desc'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                      ],
                                    ],
                                  ),
                                  onTap: () {
                                    _onSelectMuruganItem(item, formIndex: formIndex);
                                    Navigator.of(ctx).pop();
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

  void _onSelectMuruganItem(Map<String, dynamic> item, {int? formIndex}) {
    setState(() {
      if (formIndex == null) {
        _nameCtrl.text = item['title'];
        _deityTitleCtrl.text = item['name_en'];
        _deivamType = MuruganMasterData.defaultGender;
        _parentDeityCtrl.text = MuruganMasterData.defaultParentDeity;
        _relationshipCtrl.text = MuruganMasterData.defaultRelationship;

        if (item['category'] == 'forms') {
          _deityFormCtrl.text = item['title'];
        }

        if (_deitySpecialityCtrl.text.isEmpty && item['desc'].toString().isNotEmpty) {
          _deitySpecialityCtrl.text = item['desc'];
        }

        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = item['name_ta'];
          _deityForms[0]['name_en'] = item['name_en'];
          _deityForms[0]['speciality'] = item['desc'];
          _deityForms[0]['parent_deity'] = MuruganMasterData.defaultParentDeity;
        }
      } else if (formIndex >= 0 && formIndex < _deityForms.length) {
        final isDuplicate = _deityForms.asMap().entries.any(
          (e) => e.key != formIndex && (e.value['name_en'] == item['name_en'] || e.value['name_ta'] == item['name_ta']),
        );
        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name_ta']} ஏற்கனவே ரூபங்கள் பட்டியலில் உள்ளது (Already added in forms).'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          return;
        }
        _deityForms[formIndex]['name_ta'] = item['name_ta'];
        _deityForms[formIndex]['name_en'] = item['name_en'];
        _deityForms[formIndex]['speciality'] = item['desc'];
        _deityForms[formIndex]['parent_deity'] = MuruganMasterData.defaultParentDeity;
      }
    });
  }

  Future<void> _showVinayagarSelectionDialog({int? formIndex}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String searchQuery = '';
        String currentFilter = formIndex != null ? 'forms' : 'all';

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final List<Map<String, dynamic>> allItems = [
              ...VinayagarMasterData.namesAndTitles.map((n) => {
                'title': n.displayName,
                'name_ta': n.nameTa,
                'name_en': n.nameEn,
                'category': 'names',
                'badge': 'திருநாமம் (Title)',
                'desc': n.description ?? '',
              }),
              ...VinayagarMasterData.traditional32Forms.map((f) => {
                'title': f.displayName,
                'name_ta': f.nameTa,
                'name_en': f.nameEn,
                'category': 'forms',
                'badge': '32 திருமேனி #${f.id}',
                'desc': f.description,
              }),
            ];

            final filteredList = allItems.where((item) {
              final matchesFilter = currentFilter == 'all' || item['category'] == currentFilter;
              final q = searchQuery.toLowerCase().trim();
              if (q.isEmpty) return matchesFilter;
              final matchesQuery = item['title'].toString().toLowerCase().contains(q) ||
                  item['name_en'].toString().toLowerCase().contains(q) ||
                  item['desc'].toString().toLowerCase().contains(q);
              return matchesFilter && matchesQuery;
            }).toList();

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB01254).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'விநாயகர் திருநாமங்கள் & 32 திருமேனிகள்',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '10 திருநாமங்கள் & 32 பாரம்பரிய கணபதி திருமேனிகள்',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) => setDialogState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'பெயர் அல்லது வடிவம் தேடுங்கள் (e.g. Bala, சித்தி, Heramba)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'அனைத்தும் (${allItems.length})',
                            isSelected: currentFilter == 'all',
                            onTap: () => setDialogState(() => currentFilter = 'all'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '10 திருநாமங்கள் (10)',
                            isSelected: currentFilter == 'names',
                            onTap: () => setDialogState(() => currentFilter = 'names'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '32 திருமேனிகள் (32)',
                            isSelected: currentFilter == 'forms',
                            onTap: () => setDialogState(() => currentFilter = 'forms'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${filteredList.length} வடிவங்கள் காட்டப்படுகின்றன',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Text('பொருந்தும் வடிவங்கள் எதுவும் இல்லை', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                            )
                          : ListView.separated(
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              itemBuilder: (context, idx) {
                                final item = filteredList[idx];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                                    foregroundColor: const Color(0xFFB01254),
                                    child: const Icon(Icons.temple_hindu, size: 20),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name_ta'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E1B4B)),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item['category'] == 'forms' ? Colors.purple.shade100 : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item['badge'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: item['category'] == 'forms' ? Colors.purple.shade900 : Colors.green.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${item['name_en']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                                      if (item['desc'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(item['desc'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                      ],
                                    ],
                                  ),
                                  onTap: () {
                                    _onSelectVinayagarItem(item, formIndex: formIndex);
                                    Navigator.of(ctx).pop();
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

  void _onSelectVinayagarItem(Map<String, dynamic> item, {int? formIndex}) {
    setState(() {
      if (formIndex == null) {
        _nameCtrl.text = item['title'];
        _deityTitleCtrl.text = item['name_en'];
        _deivamType = VinayagarMasterData.defaultGender;
        _parentDeityCtrl.text = VinayagarMasterData.defaultParentDeity;
        _relationshipCtrl.text = VinayagarMasterData.defaultRelationship;

        if (item['category'] == 'forms') {
          _deityFormCtrl.text = item['title'];
        }

        if (_deitySpecialityCtrl.text.isEmpty && item['desc'].toString().isNotEmpty) {
          _deitySpecialityCtrl.text = item['desc'];
        }

        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = item['name_ta'];
          _deityForms[0]['name_en'] = item['name_en'];
          _deityForms[0]['speciality'] = item['desc'];
          _deityForms[0]['parent_deity'] = VinayagarMasterData.defaultParentDeity;
        }
      } else if (formIndex >= 0 && formIndex < _deityForms.length) {
        final isDuplicate = _deityForms.asMap().entries.any(
          (e) => e.key != formIndex && (e.value['name_en'] == item['name_en'] || e.value['name_ta'] == item['name_ta']),
        );
        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name_ta']} ஏற்கனவே ரூபங்கள் பட்டியலில் உள்ளது (Already added in forms).'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          return;
        }
        _deityForms[formIndex]['name_ta'] = item['name_ta'];
        _deityForms[formIndex]['name_en'] = item['name_en'];
        _deityForms[formIndex]['speciality'] = item['desc'];
        _deityForms[formIndex]['parent_deity'] = VinayagarMasterData.defaultParentDeity;
      }
    });
  }

  Widget _buildShivaNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: 'பெயர் (64 சிவ மூர்த்தங்கள்) ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showShivaMurtiSelectionDialog(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFB01254).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB01254).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, size: 13, color: Color(0xFFB01254)),
                    SizedBox(width: 4),
                    Text(
                      '64 பட்டியல் (List)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB01254),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'சிவ மூர்த்தியைத் தேர்வு செய் அல்லது தட்டச்சு செய்...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.temple_hindu, size: 20, color: Color(0xFFB01254)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFFB01254), size: 20),
              tooltip: '64 சிவ மூர்த்தங்கள் பட்டியல்',
              onPressed: () => _showShivaMurtiSelectionDialog(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB01254), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _onSelectShivaMurti(ShivaMurtiModel murti, {int? formIndex}) {
    setState(() {
      if (formIndex == null) {
        // Main Deity Selection
        _nameCtrl.text = '${murti.tamilName} – ${murti.englishName}';
        
        // Auto-sync gender
        if (murti.genderClassification == 'other' || murti.genderClassification == 'composite') {
          _deivamType = 'மற்றவை (Other)';
        } else if (murti.genderClassification == 'female') {
          _deivamType = 'பெண் தெய்வம் (Female Deity)';
        } else {
          _deivamType = 'ஆண் தெய்வம் (Male Deity)';
        }

        // Prefill consort & relationship if empty
        if (_relationshipStatusCtrl.text.isEmpty && murti.defaultConsort.isNotEmpty) {
          _relationshipStatusCtrl.text = murti.defaultConsort;
        }
        if (_relationshipCtrl.text.isEmpty) {
          _relationshipCtrl.text = murti.defaultRelationship;
        }
        if (_deitySpecialityCtrl.text.isEmpty) {
          _deitySpecialityCtrl.text = murti.speciality;
        }

        // Populate the primary form entry in _deityForms
        if (_deityForms.isNotEmpty) {
          _deityForms[0]['name_ta'] = murti.tamilName;
          _deityForms[0]['name_en'] = murti.englishName;
          _deityForms[0]['speciality'] = murti.description;
          _deityForms[0]['parent_deity'] = murti.parentDeity;
          _deityForms[0]['image_url'] = murti.image;
          _deityForms[0]['shiva_id'] = murti.id;
        }
      } else if (formIndex >= 0 && formIndex < _deityForms.length) {
        // Incarnation / Form selection
        // Check for duplicates
        final isDuplicate = _deityForms.asMap().entries.any(
          (e) => e.key != formIndex && e.value['shiva_id'] == murti.id,
        );

        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${murti.tamilName} ஏற்கனவே ரூபங்கள் பட்டியலில் உள்ளது (Already added in forms).'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          return;
        }

        _deityForms[formIndex]['name_ta'] = murti.tamilName;
        _deityForms[formIndex]['name_en'] = murti.englishName;
        _deityForms[formIndex]['speciality'] = murti.description;
        _deityForms[formIndex]['parent_deity'] = murti.parentDeity;
        _deityForms[formIndex]['image_url'] = murti.image;
        _deityForms[formIndex]['shiva_id'] = murti.id;
      }
    });
  }

  Future<void> _showShivaMurtiSelectionDialog({int? formIndex}) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine initial gender filter
    String activeFilter = 'all';
    if (_deivamType == 'ஆண் தெய்வம் (Male Deity)') {
      activeFilter = 'male';
    } else if (_deivamType == 'மற்றவை (Other)') {
      activeFilter = 'other';
    } else if (_deivamType == 'பெண் தெய்வம் (Female Deity)') {
      activeFilter = 'female';
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String searchQuery = '';
        String currentFilter = activeFilter;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final List<ShivaMurtiModel> filteredList = ShivaMurtisMasterData.search(
              searchQuery,
              genderFilter: currentFilter,
            );

            final allCount = ShivaMurtisMasterData.all64Murtis.length;
            final maleCount = ShivaMurtisMasterData.filterByGender('male').length;
            final otherCount = ShivaMurtisMasterData.filterByGender('other').length;

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB01254).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.temple_hindu, color: Color(0xFFB01254), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'அறுபத்து நான்கு சிவ மூர்த்தங்கள்',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '64 Shiva Murtis Master Dataset ($allCount Records)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search input
                    TextField(
                      autofocus: false,
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'பெயர், எண் அல்லது ஆங்கிலத்தில் தேடுங்கள் (e.g. 1, லிங்கம், Nataraja)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFFB01254), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter chips: All (64), Male (57), Other/Composite (7)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'அனைத்தும் (All $allCount)',
                            isSelected: currentFilter == 'all',
                            onTap: () => setDialogState(() => currentFilter = 'all'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'ஆண் தெய்வம் ($maleCount)',
                            isSelected: currentFilter == 'male',
                            onTap: () => setDialogState(() => currentFilter = 'male'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'மற்றவை / ஆண்-பெண் இணைவு ($otherCount)',
                            isSelected: currentFilter == 'other',
                            onTap: () => setDialogState(() => currentFilter = 'other'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Results Count
                    Text(
                      '${filteredList.length} வடிவங்கள் காட்டப்படுகின்றன (Showing ${filteredList.length} Murtis)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),

                    // List
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'வடிவங்கள் எதுவும் பொருந்தவில்லை',
                                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        searchQuery = '';
                                        currentFilter = 'all';
                                      });
                                    },
                                    child: const Text('அனைத்து 64 மூர்த்தங்களையும் காட்டு (Show All 64)'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              itemBuilder: (context, idx) {
                                final murti = filteredList[idx];
                                final isComposite = murti.genderClassification == 'other' || murti.genderClassification == 'composite';

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: isComposite
                                        ? Colors.purple.shade50
                                        : const Color(0xFFB01254).withOpacity(0.1),
                                    foregroundColor: isComposite
                                        ? Colors.purple.shade700
                                        : const Color(0xFFB01254),
                                    child: Text(
                                      '${murti.id}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          murti.tamilName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isComposite
                                              ? Colors.purple.shade100
                                              : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isComposite ? 'மற்றவை / இணைவு' : 'ஆண் தெய்வம்',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isComposite
                                                ? Colors.purple.shade900
                                                : Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${murti.englishName} • ${murti.formClassification}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        murti.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    _onSelectShivaMurti(murti, formIndex: formIndex);
                                    Navigator.of(ctx).pop();
                                  },
                                );
                              },
                            ),
                    ),
                    
                    const SizedBox(height: 12),
                    // Action footer: Add custom verified Shiva form
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'மூல நூல்: காரணாகமம் / காமிகாகமம்',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('கூடுதல் சிவ வடிவப் பெயரை நேரடியாக தட்டச்சு செய்யலாம் (Type custom form name directly)'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text('கூடுதல் சிவ வடிவம் (Custom Form)', style: TextStyle(fontSize: 12)),
                        ),
                      ],
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB01254)
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB01254)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildIconTextField(String label, String hint, IconData icon, bool isDark, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicListCard(String title, String hint, IconData icon, String emptyText, bool isDark, ThemeData theme, {ValueChanged<List<String>>? onChanged}) {
    return DynamicListCardWidget(
      title: title,
      hint: hint,
      icon: icon,
      emptyText: emptyText,
      isDark: isDark,
      theme: theme,
      onChanged: onChanged,
    );
  }

  Widget _buildStep3Content(bool isDark, ThemeData theme) {
    final selectedCategoryData = _categories.firstWhere((c) => c['title'] == _selectedCategory, orElse: () => _categories[0]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'புதிய பதிவு (Add New Deity) - Step 3: Deity Specialities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildSelectedCategoryBanner(selectedCategoryData, isDark),
        
        const SizedBox(height: 32),
        
        Row(
          children: [
            Icon(Icons.star_border, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'இறைவன் சிறப்புகள் (Deity Specialities)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'பொதுவான சிறப்புகள் (GENERAL SPECIALITIES)',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;
            if (isSmall) {
              return Column(
                children: [
                  _buildIconTextField('இறைவனின் சிறப்பு', 'சிறப்பு...', Icons.info_outline, isDark, controller: _deitySpecialityCtrl),
                  const SizedBox(height: 16),
                  _buildIconTextField('வழிபாட்டு முறை', 'வழிபாட்டு முறை...', Icons.monitor_heart_outlined, isDark, controller: _worshipMethodCtrl),
                  const SizedBox(height: 16),
                  _buildIconTextField('பிரார்த்தனை (வேண்டுதல்)', 'வேண்டுதல்...', Icons.favorite_border, isDark, controller: _prayerRequestCtrl),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildIconTextField('இறைவனின் சிறப்பு', 'சிறப்பு...', Icons.info_outline, isDark, controller: _deitySpecialityCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildIconTextField('வழிபாட்டு முறை', 'வழிபாட்டு முறை...', Icons.monitor_heart_outlined, isDark, controller: _worshipMethodCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildIconTextField('பிரார்த்தனை (வேண்டுதல்)', 'வேண்டுதல்...', Icons.favorite_border, isDark, controller: _prayerRequestCtrl)),
              ],
            );
          }
        ),
        const SizedBox(height: 24),
        _buildIconTextField('குறிப்பு', 'குறிப்புகள்...', Icons.description_outlined, isDark, controller: _notesCtrl),
        
        const SizedBox(height: 40),
        
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'பூஜை & வழிபாட்டு முறைகள் (PUJA & WORSHIP METHODS)',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return Column(
                children: [
                  _buildDynamicListCard('சிறப்பு வழிபாடு', 'சிறப்பு வழிபாடு...', Icons.monitor_heart_outlined, 'சிறப்பு வழிபாடு விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _valipadu = v)),
                  const SizedBox(height: 16),
                  _buildDynamicListCard('பூஜை முறைகள்', 'பூஜை முறைகள்...', Icons.monitor_heart_outlined, 'பூஜை முறைகள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _poojaiMuraigal = v)),
                  const SizedBox(height: 16),
                  _buildDynamicListCard('யாகங்கள்', 'யாகங்கள்...', Icons.local_fire_department_outlined, 'யாகங்கள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _yagangal = v)),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDynamicListCard('சிறப்பு வழிபாடு', 'சிறப்பு வழிபாடு...', Icons.monitor_heart_outlined, 'சிறப்பு வழிபாடு விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _valipadu = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDynamicListCard('பூஜை முறைகள்', 'பூஜை முறைகள்...', Icons.monitor_heart_outlined, 'பூஜை முறைகள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _poojaiMuraigal = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDynamicListCard('யாகங்கள்', 'யாகங்கள்...', Icons.local_fire_department_outlined, 'யாகங்கள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _yagangal = v))),
              ],
            );
          }
        ),
        
        const SizedBox(height: 40),
        
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'பிரார்த்தனைகள் & வேண்டுதல்கள் (PRAYERS & WISHES)',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return Column(
                children: [
                  _buildDynamicListCard('வேண்டுதல்கள்', 'வேண்டுதல்கள்...', Icons.favorite_border, 'வேண்டுதல்கள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _venduthalgal = v)),
                  const SizedBox(height: 16),
                  _buildDynamicListCard('வேண்டுதல் நிறைவேற்ற பூஜைகள்', 'வேண்டுதல் நிறைவேற்ற...', Icons.favorite_border, 'வேண்டுதல் நிறைவேற்ற பூஜைகள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _venduthalNiraivetraPoojai = v)),
                  const SizedBox(height: 16),
                  _buildDynamicListCard('வேண்டுதல் நிறைவு பூஜைகள்', 'வேண்டுதல் நிறைவு...', Icons.favorite_border, 'வேண்டுதல் நிறைவு பூஜைகள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _venduthalNiraivuPoojai = v)),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDynamicListCard('வேண்டுதல்கள்', 'வேண்டுதல்கள்...', Icons.favorite_border, 'வேண்டுதல்கள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _venduthalgal = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDynamicListCard('வேண்டுதல் நிறைவேற்ற பூஜைகள்', 'வேண்டுதல் நிறைவேற்ற...', Icons.favorite_border, 'வேண்டுதல் நிறைவேற்ற பூஜைகள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _venduthalNiraivetraPoojai = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDynamicListCard('வேண்டுதல் நிறைவு பூஜைகள்', 'வேண்டுதல் நிறைவு...', Icons.favorite_border, 'வேண்டுதல் நிறைவு பூஜைகள் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _venduthalNiraivuPoojai = v))),
              ],
            );
          }
        ),
        
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 450;
            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 3; // Move to step 4
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01254),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Next Step →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1; // Back to step 2
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1; // Back to step 2
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 3; // Move to step 4
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB01254),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Next Step →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          title: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
          value: value,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          activeColor: const Color(0xFFB01254),
        ),
      ),
    );
  }

  Widget _buildStep4Content(bool isDark, ThemeData theme) {
    final selectedCategoryData = _categories.firstWhere((c) => c['title'] == _selectedCategory, orElse: () => _categories[0]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'புதிய பதிவு (Add New Deity) - Step 4: Special & Puja Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildSelectedCategoryBanner(selectedCategoryData, isDark),
        
        const SizedBox(height: 32),
        
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'விசேஷ & பூஜை விவரங்கள் (Special & Puja Details)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'விசேஷ & விரத விவரங்கள் (SPECIAL & FASTING DETAILS)',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return Column(
                children: [
                  _buildDynamicListCard('விசேஷ பெயர்', 'விசேஷ பெயர்...', Icons.person_outline, 'விசேஷ பெயர் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _specialName = v)),
                  const SizedBox(height: 16),
                  _buildIconTextField('விசேஷ நாட்கள்', 'நாட்கள்...', Icons.calendar_today_outlined, isDark, controller: _specialDaysCtrl),
                  const SizedBox(height: 16),
                  _buildIconTextField('சிறப்பு பூஜை', 'பூஜை...', Icons.settings_outlined, isDark, controller: _specialPujaCtrl),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDynamicListCard('விசேஷ பெயர்', 'விசேஷ பெயர்...', Icons.person_outline, 'விசேஷ பெயர் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _specialName = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildIconTextField('விசேஷ நாட்கள்', 'நாட்கள்...', Icons.calendar_today_outlined, isDark, controller: _specialDaysCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildIconTextField('சிறப்பு பூஜை', 'பூஜை...', Icons.settings_outlined, isDark, controller: _specialPujaCtrl)),
              ],
            );
          }
        ),
        
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return Column(
                children: [
                  _buildIconTextField('விரதங்கள்', 'விரதங்கள்...', Icons.brightness_3_outlined, isDark, controller: _fastingsCtrl),
                  const SizedBox(height: 16),
                  _buildCheckbox('தனி சன்னதி உள்ளது (Separate Sannidhi)', _separateSannidhi, (v) => setState(() => _separateSannidhi = v ?? false), isDark),
                  const SizedBox(height: 16),
                  _buildCheckbox('பூஜைக்கு உகந்த நாள்/நேரம் உள்ளதா?', _auspiciousDayTime, (v) => setState(() => _auspiciousDayTime = v ?? false), isDark),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildIconTextField('விரதங்கள்', 'விரதங்கள்...', Icons.favorite_border, isDark)),
                const SizedBox(width: 16),
                Expanded(child: _buildCheckbox('தனி சன்னதி உள்ளது (Separate Sannidhi)', _separateSannidhi, (v) => setState(() => _separateSannidhi = v ?? false), isDark)),
                const SizedBox(width: 16),
                Expanded(child: _buildCheckbox('பூஜைக்கு உகந்த நாள்/நேரம் உள்ளதா?', _auspiciousDayTime, (v) => setState(() => _auspiciousDayTime = v ?? false), isDark)),
              ],
            );
          }
        ),
        
        if (_auspiciousDayTime)
          AuspiciousTimeSectionWidget(isDark: isDark, theme: theme, onChanged: (v) => setState(() => _pujaTimes = v)),

        const SizedBox(height: 40),
        
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'உகந்தவை & நைவேத்திய விவரங்கள் (AUSPICIOUS ITEMS & FOOD OFFERING DETAILS)',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return Column(
                children: [
                  _buildDynamicListCard('உகந்த மலர்', 'எ.கா: செம்பருத்தி, மல்லிகை...', Icons.local_florist_outlined, 'உகந்த மலர் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _ukuthaMalar = v)),
                  const SizedBox(height: 16),
                  _buildDynamicListCard('உகந்த உணவு', 'எ.கா: பொங்கல், சுண்டல்...', Icons.restaurant_outlined, 'உகந்த உணவு விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _ukuthaUnavu = v)),
                  const SizedBox(height: 16),
                  _buildDynamicListCard('நைவேத்தியம்', 'எ.கா: சக்கரை பொங்கல், ...', Icons.favorite_border, 'நைவேத்தியம் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _naivethiyam = v)),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDynamicListCard('உகந்த மலர்', 'எ.கா: செம்பருத்தி, மல்லிகை...', Icons.local_florist_outlined, 'உகந்த மலர் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _ukuthaMalar = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDynamicListCard('உகந்த உணவு', 'எ.கா: பொங்கல், சுண்டல்...', Icons.restaurant_outlined, 'உகந்த உணவு விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _ukuthaUnavu = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDynamicListCard('நைவேத்தியம்', 'எ.கா: சக்கரை பொங்கல், ...', Icons.favorite_border, 'நைவேத்தியம் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _naivethiyam = v))),
              ],
            );
          }
        ),
        
        const SizedBox(height: 40),
        
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'பாராயண விவரங்கள் (RECITATION DETAILS)',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return _buildDynamicListCard('பாராயணம்', 'எ.கா: கந்த சஷ்டி கவசம், 6...', Icons.favorite_border, 'பாராயணம் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _parayanam = v));
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildDynamicListCard('பாராயணம்', 'எ.கா: கந்த சஷ்டி கவசம், 6...', Icons.favorite_border, 'பாராயணம் விவரங்கள் இல்லை.', isDark, theme, onChanged: (v) => setState(() => _parayanam = v))),
                const Expanded(flex: 2, child: SizedBox()), // Push to the left
              ],
            );
          }
        ),

        const SizedBox(height: 40),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 16,
          spacing: 16,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep = 2; // Back to step 3
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                OutlinedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveRecord,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Saving...' : 'Save Record', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB01254),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {bool isDropdown = false, List<String> dropdownItems = const [], TextEditingController? controller, ValueChanged<String?>? onChanged, String? value, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
        const SizedBox(height: 8),
        if (isDropdown)
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            value: value ?? (dropdownItems.isNotEmpty ? dropdownItems.first : null),
            items: dropdownItems.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)))).toList(),
            onChanged: onChanged ?? (v) {},
          )
        else
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildDashedUploadBox(bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: _pickMainImage,
      child: Container(
        height: 140, // Match height of two text fields
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), // Pretend it's dashed or dotted
        ),
        child: _mainPhotoBytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_mainPhotoBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: theme.primaryColor, size: 32),
                  const SizedBox(height: 12),
                  Text('புகைப்படம் தேர்வு செய்', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('PNG, JPG (Max 5MB)', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStepperUI(bool isDark, ThemeData theme) {
    final steps = [
      '1. வகை (Category)',
      '2. விவரங்கள் (Basic Details)',
      '3. சிறப்புகள் (Specialities)',
      '4. பூஜை விவரங்கள் (Puja)',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isPassed = index < _currentStep;
          
          return Row(
            children: [
              Container(
                width: 150, // Fixed width to prevent shrinking too much
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? theme.primaryColor : (isPassed ? theme.primaryColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? theme.primaryColor : (isPassed ? theme.primaryColor : (isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 30,
                  height: 1,
                  color: isPassed ? theme.primaryColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDark, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 950 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: constraints.maxWidth > 950 ? 0.72 : (constraints.maxWidth > 600 ? 0.78 : 0.82),
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['title'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _onCategorySelected(category['title']);
                });
              },
              onDoubleTap: () {
                setState(() {
                  _onCategorySelected(category['title']);
                  _currentStep = 1;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFB01254) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFFB01254).withOpacity(0.2), blurRadius: 8, spreadRadius: 2)
                  ] : null,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: _buildDevotionalImage(
                              category['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    category['title'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    category['subtitle'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB01254).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_getDeitiesForCategory(category['title']).length} தெய்வங்கள்',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB01254),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB01254),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
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

  Widget _buildDataTable(bool isDark, ThemeData theme) {
    final filteredDeities = _savedDeities.where((deity) {
      final matchesCat = _tableCategoryFilter == 'all' ||
          (deity['primaryDeityId'] ?? _getPrimaryDeityId(deity['primaryDeityCategory'] ?? deity['deityCategory'])) == _tableCategoryFilter;
      final q = _searchTableQuery.toLowerCase().trim();
      if (q.isEmpty) return matchesCat;
      final matchesQ = (deity['name'] ?? '').toString().toLowerCase().contains(q) ||
          (deity['tamilName'] ?? '').toString().toLowerCase().contains(q) ||
          (deity['deityName'] ?? '').toString().toLowerCase().contains(q) ||
          (deity['relationship'] ?? '').toString().toLowerCase().contains(q);
      return matchesCat && matchesQ;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          // Table Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;

              final titleRow = Row(
                children: [
                  Icon(Icons.list_alt, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'தெய்வங்கள் முதன்மை பட்டியல் (All Primary Deities List)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              );

              final searchBox = Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchTableCtrl,
                      decoration: InputDecoration(
                        hintText: 'பெயர் அல்லது உறவுமுறை மூலம் தேடு...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _loadSavedDeities();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              );

              if (isSmallScreen) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 16),
                    searchBox,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 16),
                  SizedBox(width: 380, child: searchBox),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Primary Deity Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'அனைத்தும் (All ${_savedDeities.length})',
                  isSelected: _tableCategoryFilter == 'all',
                  onTap: () => setState(() => _tableCategoryFilter = 'all'),
                  isDark: isDark,
                ),
                for (final cat in _categories) ...[
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '${cat['title']} (${_getDeitiesForCategory(cat['title']).length})',
                    isSelected: _tableCategoryFilter == cat['id'],
                    onTap: () => setState(() => _tableCategoryFilter = cat['id']),
                    isDark: isDark,
                  ),
                ],
                if (_getDeitiesForCategory('murugan').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'முருகன் (${_getDeitiesForCategory('murugan').length})',
                    isSelected: _tableCategoryFilter == 'murugan',
                    onTap: () => setState(() => _tableCategoryFilter = 'murugan'),
                    isDark: isDark,
                  ),
                ],
                if (_getDeitiesForCategory('vinayagar').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'விநாயகர் (${_getDeitiesForCategory('vinayagar').length})',
                    isSelected: _tableCategoryFilter == 'vinayagar',
                    onTap: () => setState(() => _tableCategoryFilter = 'vinayagar'),
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Data Table
          if (filteredDeities.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'பதிவுகள் எதுவும் இல்லை (No deities found)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 12,
                ),
                dataTextStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                ),
                columns: const [
                  DataColumn(label: Text('படம்\n(PHOTO)')),
                  DataColumn(label: Text('தமிழ் பெயர்\n(TAMIL)')),
                  DataColumn(label: Text('ஆங்கிலப் பெயர்\n(NAME)')),
                  DataColumn(label: Text('முதன்மை தெய்வம்\n(PRIMARY)')),
                  DataColumn(label: Text('பாலினம்\n(GENDER)')),
                  DataColumn(label: Text('தொடர்பு\n(RELATIONSHIP)')),
                  DataColumn(label: Text('பெற்றோர்\n(PARENT)')),
                  DataColumn(label: Text('சிறப்பு / விளக்கம்\n(DESCRIPTION)')),
                  DataColumn(label: Text('நிலை\n(STATUS)')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: filteredDeities.map((deity) {
                  final photoBytes = deity['mainPhotoBytes'] as Uint8List?;
                  final isMale = (deity['gender'] ?? deity['deivamType'] ?? '').toString() == 'male';
                  final isFemale = (deity['gender'] ?? deity['deivamType'] ?? '').toString() == 'female';

                  return DataRow(
                    cells: [
                      DataCell(
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                          backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                          child: photoBytes == null
                              ? const Icon(Icons.temple_hindu, size: 16, color: Color(0xFFB01254))
                              : null,
                        ),
                      ),
                      DataCell(Text(deity['tamilName'] ?? deity['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(deity['deityName'] ?? '-')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB01254).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            deity['primaryDeityCategory'] ?? deity['deityCategory'] ?? '-',
                            style: const TextStyle(color: Color(0xFFB01254), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMale ? Colors.blue.shade50 : (isFemale ? Colors.pink.shade50 : Colors.purple.shade50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isMale ? 'ஆண்' : (isFemale ? 'பெண்' : 'மற்றவை'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isMale ? Colors.blue.shade800 : (isFemale ? Colors.pink.shade800 : Colors.purple.shade800),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(deity['relationship']?.toString().isNotEmpty == true ? deity['relationship'] : '-'),
                            if ((deity['forms'] as List?)?.isNotEmpty == true ||
                                (deity['familyMembers'] as List?)?.isNotEmpty == true ||
                                (deity['nayanmars'] as List?)?.isNotEmpty == true ||
                                (deity['siddhars'] as List?)?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  if ((deity['forms'] as List?)?.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text('${(deity['forms'] as List).length} Forms', style: TextStyle(fontSize: 9, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                    ),
                                  if ((deity['familyMembers'] as List?)?.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text('${(deity['familyMembers'] as List).length} Family', style: TextStyle(fontSize: 9, color: Colors.pink.shade800, fontWeight: FontWeight.bold)),
                                    ),
                                  if (((deity['nayanmars'] as List?)?.isNotEmpty == true) || ((deity['siddhars'] as List?)?.isNotEmpty == true))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        '${((deity['nayanmars'] as List?)?.length ?? 0) + ((deity['siddhars'] as List?)?.length ?? 0)} Saints',
                                        style: TextStyle(fontSize: 9, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(Text(deity['parentDeityId']?.toString().isNotEmpty == true ? deity['parentDeityId'] : (deity['parentDeity']?.toString().isNotEmpty == true ? deity['parentDeity'] : '-'))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            deity['description']?.toString().isNotEmpty == true ? deity['description'] : (deity['deitySpeciality']?.toString().isNotEmpty == true ? deity['deitySpeciality'] : '-'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(deity['status'] ?? 'Active', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                              tooltip: 'திருத்து (Edit)',
                              onPressed: () {
                                _loadDeityForEdit(deity);
                              },
                              splashRadius: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'நீக்கு (Delete)',
                              onPressed: () {
                                _deleteDeity(deity);
                              },
                              splashRadius: 20,
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
}

class DynamicListCardWidget extends StatefulWidget {
  final String title;
  final String hint;
  final IconData icon;
  final String emptyText;
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<List<String>>? onChanged;

  const DynamicListCardWidget({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.emptyText,
    required this.isDark,
    required this.theme,
    this.onChanged,
  });

  @override
  State<DynamicListCardWidget> createState() => _DynamicListCardWidgetState();
}

class _DynamicListCardWidgetState extends State<DynamicListCardWidget> {
  final List<String> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_items.contains(text)) {
      setState(() {
        _items.add(text);
        _controller.clear();
      });
      widget.onChanged?.call(_items);
    }
  }

  void _removeItem(String item) {
    setState(() {
      _items.remove(item);
    });
    widget.onChanged?.call(_items);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: widget.theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black87))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _addItem(),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: widget.theme.primaryColor,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addItem,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            Text(widget.emptyText, style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade500))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item, style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeItem(item),
                        child: Icon(Icons.close, size: 14, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class AuspiciousTimeSectionWidget extends StatefulWidget {
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<List<Map<String, String>>>? onChanged;

  const AuspiciousTimeSectionWidget({super.key, required this.isDark, required this.theme, this.onChanged});

  @override
  State<AuspiciousTimeSectionWidget> createState() => _AuspiciousTimeSectionWidgetState();
}

class _AuspiciousTimeSectionWidgetState extends State<AuspiciousTimeSectionWidget> {
  final List<Map<String, String>> _items = [];
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _dayCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();

  void _addItem() {
    if (_titleCtrl.text.isNotEmpty || _dayCtrl.text.isNotEmpty || _timeCtrl.text.isNotEmpty) {
      setState(() {
        _items.add({
          'title': _titleCtrl.text,
          'day': _dayCtrl.text,
          'time': _timeCtrl.text,
        });
        _titleCtrl.clear();
        _dayCtrl.clear();
        _timeCtrl.clear();
      });
      widget.onChanged?.call(_items);
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.onChanged?.call(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'பூஜைக்கு உகந்த நாள்/நேரம் விவரங்கள்',
          style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            if (isSmall) {
              return Column(
                children: [
                   _buildInput(_titleCtrl, 'பூஜை தலைப்பு (எ.கா: அ...', Icons.settings_outlined),
                   const SizedBox(height: 8),
                   _buildInput(_dayCtrl, 'பூஜைக்கு உகந்த நாள் (எ...', Icons.calendar_today_outlined),
                   const SizedBox(height: 8),
                   _buildInput(_timeCtrl, 'பூஜைக்கு உகந்த நேரம் (...', Icons.access_time_outlined),
                   const SizedBox(height: 12),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       onPressed: _addItem,
                       icon: const Icon(Icons.add, size: 16),
                       label: const Text('சேர்க்க (Add)'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFB01254),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                     ),
                   ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildInput(_titleCtrl, 'பூஜை தலைப்பு (எ.கா: அ...', Icons.settings_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(_dayCtrl, 'பூஜைக்கு உகந்த நாள் (எ...', Icons.calendar_today_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(_timeCtrl, 'பூஜைக்கு உகந்த நேரம் (...', Icons.access_time_outlined)),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('சேர்க்க (Add)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB01254),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 24),
        if (_items.isEmpty)
          Text('நாள்/நேரம் விவரங்கள் எதுவும் சேர்க்கப்படவில்லை.', style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade500))
        else
          Column(
            children: _items.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
                  border: Border.all(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (item['title']!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.settings_outlined, size: 14, color: Colors.purple),
                                const SizedBox(width: 4),
                                Flexible(child: Text('தலைப்பு: ${item['title']}', style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600))),
                              ],
                            ),
                          if (item['day']!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFB01254)),
                                const SizedBox(width: 4),
                                Flexible(child: Text('நாள்: ${item['day']}', style: const TextStyle(fontSize: 12, color: Color(0xFFB01254), fontWeight: FontWeight.w600))),
                              ],
                            ),
                          if (item['time']!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_outlined, size: 14, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                Flexible(child: Text('நேரம்: ${item['time']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600))),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _removeItem(idx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
