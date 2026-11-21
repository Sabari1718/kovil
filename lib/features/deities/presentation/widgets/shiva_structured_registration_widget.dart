import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/shiva_associated_data.dart';
import '../../data/shiva_murtis_data.dart';

class ShivaStructuredRegistrationWidget extends StatefulWidget {
  final bool isDark;
  final ThemeData theme;
  final List<Map<String, dynamic>> deitiesUnderCurrentCategory;
  final Map<String, dynamic>? editingDeity;
  final Function(
    Map<String, dynamic> deityRecord,
    List<PhotoReferenceRecord> photos,
    List<DeityFormRecord> forms,
    List<NayanmarRecord> nayanmars,
    List<SiddharRecord> siddhars,
    List<DeityFamilyRelationshipRecord> family,
  ) onSavePrimaryDeity;
  final VoidCallback onCancelEdit;
  final Function(Map<String, dynamic> deity) onEditDeity;
  final Function(Map<String, dynamic> deity) onDeleteDeity;

  const ShivaStructuredRegistrationWidget({
    super.key,
    required this.isDark,
    required this.theme,
    required this.deitiesUnderCurrentCategory,
    this.editingDeity,
    required this.onSavePrimaryDeity,
    required this.onCancelEdit,
    required this.onEditDeity,
    required this.onDeleteDeity,
  });

  @override
  State<ShivaStructuredRegistrationWidget> createState() =>
      _ShivaStructuredRegistrationWidgetState();
}

class _ShivaStructuredRegistrationWidgetState
    extends State<ShivaStructuredRegistrationWidget> {
  int _activeTab = 0; // 0: Primary Deity & Photos, 1: Forms, 2: Family, 3: Saints & Siddhars
  int _saintsSubTab = 0; // 0: 63 Nayanmars, 1: Siddhars

  // STEP 1: Primary Deity Controllers
  late TextEditingController _primaryCategoryCtrl;
  late TextEditingController _tamilNameCtrl;
  late TextEditingController _englishNameCtrl;
  late TextEditingController _descriptionCtrl;
  String _selectedRoleGender = 'Male deity';

  // STEP 2: Deity Photos
  Uint8List? _primaryPhotoBytes;
  final List<PhotoReferenceRecord> _photoReferences = [];

  // STEP 3: Associated Saints & Siddhars
  final List<NayanmarRecord> _associatedNayanmars = [];
  final List<SiddharRecord> _associatedSiddhars = [];

  // STEP 4: Family Relationships
  final List<DeityFamilyRelationshipRecord> _familyMembers = [];

  // STEP 5: Deity Forms
  final List<DeityFormRecord> _deityForms = [];

  // Form input controllers for Forms tab
  final TextEditingController _formTaNameCtrl = TextEditingController();
  final TextEditingController _formEnNameCtrl = TextEditingController();
  final TextEditingController _formDescCtrl = TextEditingController();
  Uint8List? _formPhotoBytes;
  String? _editingFormId;

  // Family input controllers
  final TextEditingController _familyTaNameCtrl = TextEditingController();
  final TextEditingController _familyEnNameCtrl = TextEditingController();
  final TextEditingController _familyDescCtrl = TextEditingController();
  String _familyRelationshipType = 'Wife / Consort';
  String _familyGender = 'Female deity';
  Uint8List? _familyPhotoBytes;
  String? _editingFamilyId;

  // Siddhar input controllers
  final TextEditingController _siddharTaNameCtrl = TextEditingController();
  final TextEditingController _siddharEnNameCtrl = TextEditingController();
  final TextEditingController _siddharDescCtrl = TextEditingController();
  String _siddharTradition = '18 Siddhars (பதினெண் சித்தர்கள்)';
  Uint8List? _siddharPhotoBytes;
  String? _editingSiddharId;

  // Nayanmar search
  final TextEditingController _nayanmarSearchCtrl = TextEditingController();
  String _nayanmarSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _primaryCategoryCtrl = TextEditingController(text: 'Primary Deity');
    _tamilNameCtrl = TextEditingController(text: 'சிவன்');
    _englishNameCtrl = TextEditingController(text: 'Lord Shiva');
    _descriptionCtrl = TextEditingController(
      text: 'சிவபெருமான் - சைவ சமயத்தின் முழுமுதற் பரம்பொருள்',
    );
    _nayanmarSearchCtrl.addListener(() {
      setState(() {
        _nayanmarSearchQuery = _nayanmarSearchCtrl.text.trim().toLowerCase();
      });
    });

    _populateFromEditingDeity();
  }

  @override
  void didUpdateWidget(covariant ShivaStructuredRegistrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingDeity != oldWidget.editingDeity) {
      _populateFromEditingDeity();
    }
  }

  void _populateFromEditingDeity() {
    if (widget.editingDeity != null) {
      final d = widget.editingDeity!;
      _tamilNameCtrl.text = d['tamilName'] ?? d['name'] ?? 'சிவன்';
      _englishNameCtrl.text = d['englishName'] ?? d['deityName'] ?? 'Lord Shiva';
      _primaryCategoryCtrl.text = d['category'] ?? d['primaryDeityCategory'] ?? 'Primary Deity';
      _descriptionCtrl.text = d['description'] ?? d['deitySpeciality'] ?? '';

      final gender = (d['roleGender'] ?? d['gender'] ?? '').toString().toLowerCase();
      if (gender.contains('female') || gender.contains('பெண்')) {
        _selectedRoleGender = 'Female deity';
      } else if (gender.contains('both') || gender.contains('இருபாலர்') || gender.contains('இணைவு') || gender.contains('combined')) {
        _selectedRoleGender = 'Both / Combined form';
      } else if (gender.contains('other') || gender.contains('மற்றவை')) {
        _selectedRoleGender = 'Other / Not specified';
      } else {
        _selectedRoleGender = 'Male deity';
      }

      if (d['mainPhotoBytes'] is Uint8List) {
        _primaryPhotoBytes = d['mainPhotoBytes'] as Uint8List;
      } else if (d['deityPhoto'] != null && d['deityPhoto'].toString().isNotEmpty) {
        try {
          _primaryPhotoBytes = base64Decode(d['deityPhoto']);
        } catch (_) {}
      }

      // Load associated records
      _photoReferences.clear();
      if (d['photoReferences'] is List) {
        for (var p in d['photoReferences']) {
          _photoReferences.add(PhotoReferenceRecord.fromJson(p));
        }
      }

      _deityForms.clear();
      if (d['forms'] is List) {
        for (var f in d['forms']) {
          _deityForms.add(DeityFormRecord.fromJson(f));
        }
      }

      _associatedNayanmars.clear();
      if (d['nayanmars'] is List) {
        for (var n in d['nayanmars']) {
          _associatedNayanmars.add(NayanmarRecord.fromJson(n));
        }
      }

      _associatedSiddhars.clear();
      if (d['siddhars'] is List) {
        for (var s in d['siddhars']) {
          _associatedSiddhars.add(SiddharRecord.fromJson(s));
        }
      }

      _familyMembers.clear();
      if (d['familyMembers'] is List) {
        for (var fm in d['familyMembers']) {
          _familyMembers.add(DeityFamilyRelationshipRecord.fromJson(fm));
        }
      }
    }
  }

  @override
  void dispose() {
    _primaryCategoryCtrl.dispose();
    _tamilNameCtrl.dispose();
    _englishNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _formTaNameCtrl.dispose();
    _formEnNameCtrl.dispose();
    _formDescCtrl.dispose();
    _familyTaNameCtrl.dispose();
    _familyEnNameCtrl.dispose();
    _familyDescCtrl.dispose();
    _siddharTaNameCtrl.dispose();
    _siddharEnNameCtrl.dispose();
    _siddharDescCtrl.dispose();
    _nayanmarSearchCtrl.dispose();
    super.dispose();
  }

  void _resetActiveDeity() {
    setState(() {
      _tamilNameCtrl.text = 'சிவன்';
      _englishNameCtrl.text = 'Lord Shiva';
      _primaryCategoryCtrl.text = 'Primary Deity';
      _descriptionCtrl.text = 'சிவபெருமான் - சைவ சமயத்தின் முழுமுதற் பரம்பொருள்';
      _selectedRoleGender = 'Male deity';
      _primaryPhotoBytes = null;
      _photoReferences.clear();
      _deityForms.clear();
      _associatedNayanmars.clear();
      _associatedSiddhars.clear();
      _familyMembers.clear();
      _clearFormInput();
      _clearFamilyInput();
      _clearSiddharInput();
    });
  }

  void _clearFormInput() {
    setState(() {
      _editingFormId = null;
      _formTaNameCtrl.clear();
      _formEnNameCtrl.clear();
      _formDescCtrl.clear();
      _formPhotoBytes = null;
    });
  }

  void _clearFamilyInput() {
    setState(() {
      _editingFamilyId = null;
      _familyTaNameCtrl.clear();
      _familyEnNameCtrl.clear();
      _familyDescCtrl.clear();
      _familyRelationshipType = 'Wife / Consort';
      _familyGender = 'Female deity';
      _familyPhotoBytes = null;
    });
  }

  void _clearSiddharInput() {
    setState(() {
      _editingSiddharId = null;
      _siddharTaNameCtrl.clear();
      _siddharEnNameCtrl.clear();
      _siddharDescCtrl.clear();
      _siddharTradition = '18 Siddhars (பதினெண் சித்தர்கள்)';
      _siddharPhotoBytes = null;
    });
  }

  Future<void> _pickPrimaryPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _primaryPhotoBytes = bytes;
      });
    }
  }

  Future<void> _pickFormPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _formPhotoBytes = bytes;
      });
    }
  }

  Future<void> _pickFamilyPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _familyPhotoBytes = bytes;
      });
    }
  }

  Future<void> _pickSiddharPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _siddharPhotoBytes = bytes;
      });
    }
  }

  // Duplicate checks
  void _saveOrUpdateForm() {
    final ta = _formTaNameCtrl.text.trim();
    final en = _formEnNameCtrl.text.trim();
    if (ta.isEmpty && en.isEmpty) {
      _showWarningSnackBar('வடிவத்தின் பெயரை உள்ளிடவும் (Form name is required)');
      return;
    }

    final isDuplicate = _deityForms.any(
      (f) =>
          f.id != _editingFormId &&
          (f.nameTa.toLowerCase() == ta.toLowerCase() ||
              (en.isNotEmpty && f.nameEn.toLowerCase() == en.toLowerCase())),
    );

    if (isDuplicate) {
      _showWarningSnackBar('$ta வடிவம் ஏற்கனவே சேர்க்கப்பட்டுள்ளது (Duplicate form)!');
      return;
    }

    setState(() {
      final formId = _editingFormId ?? 'form_${DateTime.now().millisecondsSinceEpoch}';
      final photoBase64 = _formPhotoBytes != null ? base64Encode(_formPhotoBytes!) : null;

      final newForm = DeityFormRecord(
        id: formId,
        primaryDeityId: 'shiva',
        nameTa: ta.isNotEmpty ? ta : en,
        nameEn: en.isNotEmpty ? en : ta,
        description: _formDescCtrl.text.trim(),
        photo: '',
        photoBase64: photoBase64,
        photoRefId: 'photo_form_$formId',
      );

      if (_editingFormId != null) {
        final idx = _deityForms.indexWhere((f) => f.id == _editingFormId);
        if (idx != -1) _deityForms[idx] = newForm;
      } else {
        _deityForms.add(newForm);
      }

      // Also create separate photo reference if photo was picked
      if (_formPhotoBytes != null) {
        _photoReferences.removeWhere((p) => p.targetType == 'form' && p.targetName == newForm.nameEn);
        _photoReferences.add(
          PhotoReferenceRecord(
            id: 'photo_form_$formId',
            deityId: 'shiva',
            targetType: 'form',
            targetName: newForm.nameEn,
            photoBase64: photoBase64,
            description: '${newForm.nameTa} திருவுருவப் படம்',
            createdAt: DateTime.now(),
          ),
        );
      }

      _clearFormInput();
    });

    _showSuccessSnackBar('சிவ வடிவம் வெற்றிகரமாக சேர்க்கப்பட்டது');
  }

  void _saveOrUpdateFamilyMember() {
    final ta = _familyTaNameCtrl.text.trim();
    final en = _familyEnNameCtrl.text.trim();
    if (ta.isEmpty && en.isEmpty) {
      _showWarningSnackBar('உறவுமுறைத் தெய்வத்தின் பெயரை உள்ளிடவும்');
      return;
    }

    final isDuplicate = _familyMembers.any(
      (fm) =>
          fm.id != _editingFamilyId &&
          (fm.deityNameTa.toLowerCase() == ta.toLowerCase() ||
              (en.isNotEmpty && fm.deityNameEn.toLowerCase() == en.toLowerCase())) &&
          fm.relationshipType == _familyRelationshipType,
    );

    if (isDuplicate) {
      _showWarningSnackBar('$ta ($_familyRelationshipType) ஏற்கனவே உள்ளது (Duplicate family record)!');
      return;
    }

    setState(() {
      final familyId = _editingFamilyId ?? 'fam_${DateTime.now().millisecondsSinceEpoch}';
      final photoBase64 = _familyPhotoBytes != null ? base64Encode(_familyPhotoBytes!) : null;

      final newFamily = DeityFamilyRelationshipRecord(
        id: familyId,
        primaryDeityId: 'shiva',
        deityNameTa: ta.isNotEmpty ? ta : en,
        deityNameEn: en.isNotEmpty ? en : ta,
        relationshipType: _familyRelationshipType,
        gender: _familyGender,
        description: _familyDescCtrl.text.trim(),
        photoBase64: photoBase64,
      );

      if (_editingFamilyId != null) {
        final idx = _familyMembers.indexWhere((fm) => fm.id == _editingFamilyId);
        if (idx != -1) _familyMembers[idx] = newFamily;
      } else {
        _familyMembers.add(newFamily);
      }

      _clearFamilyInput();
    });

    _showSuccessSnackBar('குடும்ப உறவுமுறைத் தெய்வம் சேர்க்கப்பட்டது');
  }

  void _addNayanmar(NayanmarRecord record) {
    final isDuplicate = _associatedNayanmars.any(
      (n) => n.tamilName == record.tamilName || n.englishName.toLowerCase() == record.englishName.toLowerCase(),
    );
    if (isDuplicate) {
      _showWarningSnackBar('${record.tamilName} ஏற்கனவே சேர்க்கப்பட்டுள்ளது (Already added)!');
      return;
    }

    setState(() {
      _associatedNayanmars.add(record);
    });
    _showSuccessSnackBar('${record.tamilName} அடியார் பட்டியலில் சேர்க்கப்பட்டார்');
  }

  void _addSiddhar(SiddharRecord record) {
    final isDuplicate = _associatedSiddhars.any(
      (s) => s.tamilName == record.tamilName || s.englishName.toLowerCase() == record.englishName.toLowerCase(),
    );
    if (isDuplicate) {
      _showWarningSnackBar('${record.tamilName} சித்தர் ஏற்கனவே சேர்க்கப்பட்டுள்ளார் (Already added)!');
      return;
    }

    setState(() {
      _associatedSiddhars.add(record);
    });
    _showSuccessSnackBar('${record.tamilName} சித்தர் பட்டியலில் சேர்க்கப்பட்டார்');
  }

  void _saveOrUpdateCustomSiddhar() {
    final ta = _siddharTaNameCtrl.text.trim();
    final en = _siddharEnNameCtrl.text.trim();
    if (ta.isEmpty && en.isEmpty) {
      _showWarningSnackBar('சித்தரின் பெயரை உள்ளிடவும்');
      return;
    }

    final isDuplicate = _associatedSiddhars.any(
      (s) =>
          s.id != _editingSiddharId &&
          (s.tamilName.toLowerCase() == ta.toLowerCase() ||
              (en.isNotEmpty && s.englishName.toLowerCase() == en.toLowerCase())),
    );

    if (isDuplicate) {
      _showWarningSnackBar('$ta சித்தர் ஏற்கனவே பட்டியலில் உள்ளார்');
      return;
    }

    setState(() {
      final siddharId = _editingSiddharId ?? 'siddhar_${DateTime.now().millisecondsSinceEpoch}';
      final photoBase64 = _siddharPhotoBytes != null ? base64Encode(_siddharPhotoBytes!) : null;

      final newSiddhar = SiddharRecord(
        id: siddharId,
        primaryDeityId: 'shiva',
        tamilName: ta.isNotEmpty ? ta : en,
        englishName: en.isNotEmpty ? en : ta,
        siddharTradition: _siddharTradition,
        shortDescription: _siddharDescCtrl.text.trim(),
        photoBase64: photoBase64,
      );

      if (_editingSiddharId != null) {
        final idx = _associatedSiddhars.indexWhere((s) => s.id == _editingSiddharId);
        if (idx != -1) _associatedSiddhars[idx] = newSiddhar;
      } else {
        _associatedSiddhars.add(newSiddhar);
      }

      _clearSiddharInput();
    });

    _showSuccessSnackBar('சித்தர் விவரம் சேமிக்கப்பட்டது');
  }

  Future<void> _showAddAdditionalPhotoDialog() async {
    final labelCtrl = TextEditingController();
    Uint8List? localBytes;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_photo_alternate, color: Color(0xFFB01254)),
                  SizedBox(width: 8),
                  Text('கூடுதல் சிவ வடிவப் படம்', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('படிவத்தின் பெயர் அல்லது குறிப்பு (Form / Photo Label):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(
                        hintText: 'எ.கா: நடராஜர், அர்த்தநாரீஸ்வரர்...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('புகைப்படம் தேர்வு செய் (Select Photo):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final img = await picker.pickImage(source: ImageSource.gallery);
                          if (img != null) {
                            final b = await img.readAsBytes();
                            setDialogState(() {
                              localBytes = b;
                            });
                          }
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFB01254).withOpacity(0.5), style: BorderStyle.solid),
                          ),
                          child: localBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(localBytes!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, color: Color(0xFFB01254), size: 36),
                                    SizedBox(height: 4),
                                    Text('படத்தை தேர்வு செய்', style: TextStyle(fontSize: 11, color: Color(0xFFB01254))),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('ரத்து'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final label = labelCtrl.text.trim();
                    if (label.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('படத்திற்கான பெயரை உள்ளிடவும்')),
                      );
                      return;
                    }
                    if (localBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('புகைப்படத்தைத் தேர்வு செய்யவும்')),
                      );
                      return;
                    }

                    setState(() {
                      _photoReferences.add(
                        PhotoReferenceRecord(
                          id: 'photo_ref_${DateTime.now().millisecondsSinceEpoch}',
                          deityId: 'shiva',
                          targetType: 'form',
                          targetName: label,
                          photoBase64: base64Encode(localBytes!),
                          description: '$label திருவுருவப் படம்',
                          createdAt: DateTime.now(),
                        ),
                      );
                    });
                    Navigator.pop(dialogCtx);
                    _showSuccessSnackBar('கூடுதல் புகைப்படம் குறிப்புடன் சேர்க்கப்பட்டது');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB01254),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('சேர் (Add)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveFinalPrimaryDeity() {
    final ta = _tamilNameCtrl.text.trim();
    final en = _englishNameCtrl.text.trim();
    if (ta.isEmpty && en.isEmpty) {
      _showWarningSnackBar('முதன்மை தெய்வத்தின் பெயரை உள்ளிடவும்');
      return;
    }

    final deityId = widget.editingDeity?['id']?.toString() ?? 'shiva';
    final primaryPhotoBase64 = _primaryPhotoBytes != null ? base64Encode(_primaryPhotoBytes!) : '';

    // Ensure primary photo is also tracked in photoReferences separately
    final updatedPhotoRefs = List<PhotoReferenceRecord>.from(_photoReferences);
    if (_primaryPhotoBytes != null) {
      updatedPhotoRefs.removeWhere((p) => p.targetType == 'primary');
      updatedPhotoRefs.insert(
        0,
        PhotoReferenceRecord(
          id: 'photo_primary_$deityId',
          deityId: deityId,
          targetType: 'primary',
          targetName: en.isNotEmpty ? en : 'Lord Shiva',
          photoBase64: primaryPhotoBase64,
          description: 'முதன்மை தெய்வப் புகைப்படம் (Primary Deity Photo)',
          createdAt: DateTime.now(),
        ),
      );
    }

    final genderCode = _selectedRoleGender.contains('Female')
        ? 'female'
        : (_selectedRoleGender.contains('Both')
            ? 'both'
            : (_selectedRoleGender.contains('Other') ? 'other' : 'male'));

    final primaryRecord = {
      'id': deityId,
      'primaryDeityId': 'shiva',
      'primaryDeityCategory': 'சிவன்',
      'category': 'Primary Deity',
      'deityCategory': 'Primary Deity',
      'tamilName': ta.isNotEmpty ? ta : 'சிவன்',
      'englishName': en.isNotEmpty ? en : 'Lord Shiva',
      'deityName': en.isNotEmpty ? en : 'Lord Shiva',
      'name': ta.isNotEmpty ? ta : 'சிவன்',
      'gender': genderCode,
      'roleGender': _selectedRoleGender,
      'deivamType': genderCode,
      'relationship': 'முதன்மை தெய்வம் (Primary Deity)',
      'relationship_status': 'முதன்மை தெய்வம்',
      'parentDeityId': '',
      'parentDeity': '',
      'deityPhoto': primaryPhotoBase64,
      'mainPhotoBytes': _primaryPhotoBytes,
      'description': _descriptionCtrl.text.trim().isNotEmpty
          ? _descriptionCtrl.text.trim()
          : 'சிவபெருமான் - சைவ சமயத்தின் முழுமுதற் பரம்பொருள்',
      'deitySpeciality': _descriptionCtrl.text.trim(),
      'photoReferences': updatedPhotoRefs.map((p) => p.toJson()).toList(),
      'forms': _deityForms.map((f) => f.toJson()).toList(),
      'nayanmars': _associatedNayanmars.map((n) => n.toJson()).toList(),
      'siddhars': _associatedSiddhars.map((s) => s.toJson()).toList(),
      'familyMembers': _familyMembers.map((fm) => fm.toJson()).toList(),
      'status': 'Active',
      'createdAt': widget.editingDeity?['createdAt'] ?? DateTime.now().toIso8601String(),
    };

    widget.onSavePrimaryDeity(
      primaryRecord,
      updatedPhotoRefs,
      _deityForms,
      _associatedNayanmars,
      _associatedSiddhars,
      _familyMembers,
    );
  }

  void _showWarningSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB01254),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.editingDeity != null
              ? const Color(0xFFB01254)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          width: widget.editingDeity != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registration Header
          _buildHeaderBanner(isDark),

          // Structured Tabs Navigation
          _buildTabsHeader(isDark),

          // Tab Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildActiveTabContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(bool isDark) {
    final isEditing = widget.editingDeity != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFB01254).withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFB01254),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.temple_hindu, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'முதன்மை தெய்வம் திருத்துதல்: ${_tamilNameCtrl.text} (${_englishNameCtrl.text})'
                      : 'சிவபெருமான் - கட்டமைக்கப்பட்ட முதன்மைத் தெய்வப் பதிவு (Structured Deity Registration)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Primary Deity System: Forms, Photos, Saints, Siddhars & Family Relationships',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            OutlinedButton.icon(
              onPressed: widget.onCancelEdit,
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              label: const Text('Cancel Edit', style: TextStyle(color: Colors.grey, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabsHeader(bool isDark) {
    final tabs = [
      {'title': '1. முதன்மை & படங்கள்', 'sub': 'Primary & Photos', 'icon': Icons.account_circle},
      {'title': '2. சிவ வடிவங்கள்', 'sub': 'Forms (${_deityForms.length})', 'icon': Icons.auto_awesome},
      {'title': '3. குடும்ப உறவுகள்', 'sub': 'Family (${_familyMembers.length})', 'icon': Icons.people_alt},
      {'title': '4. அடியார்கள் & சித்தர்கள்', 'sub': 'Saints (${_associatedNayanmars.length}) / Siddhars (${_associatedSiddhars.length})', 'icon': Icons.self_improvement},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (idx) {
            final isSel = _activeTab == idx;
            final item = tabs[idx];

            return InkWell(
              onTap: () => setState(() => _activeTab = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSel ? const Color(0xFFB01254) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  color: isSel ? const Color(0xFFB01254).withOpacity(0.04) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isSel ? const Color(0xFFB01254) : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? const Color(0xFFB01254) : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        Text(
                          item['sub'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSel ? const Color(0xFFB01254) : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isDark) {
    switch (_activeTab) {
      case 0:
        return _buildPrimaryDeityAndPhotosTab(isDark);
      case 1:
        return _buildShivaFormsTab(isDark);
      case 2:
        return _buildFamilyRelationshipsTab(isDark);
      case 3:
        return _buildSaintsAndSiddharsTab(isDark);
      default:
        return _buildPrimaryDeityAndPhotosTab(isDark);
    }
  }

  // ==========================================
  // TAB 0: STEP 1 & STEP 2 (Primary Deity & Photos)
  // ==========================================
  Widget _buildPrimaryDeityAndPhotosTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Description
        Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Color(0xFFB01254)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'முதன்மை தெய்வப் பதிவு (STEP 1 & STEP 2): தமிழ் மற்றும் ஆங்கிலப் பெயர்கள், பாலினம், முதன்மைப் படம் மற்றும் கூடுதல் புகைப்படக் குறிப்புகள்.',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Text Fields Row
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 700;

            final categoryField = _buildFieldContainer(
              label: 'வகை / அந்தஸ்து (Category) *',
              child: TextField(
                controller: _primaryCategoryCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category, color: Color(0xFFB01254), size: 18),
                  suffixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB01254).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Primary', style: TextStyle(color: Color(0xFFB01254), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              isDark: isDark,
            );

            final roleGenderField = _buildFieldContainer(
              label: 'தெய்வப் பாலினம் / Role (Gender) *',
              child: DropdownButtonFormField<String>(
                value: _selectedRoleGender,
                items: ShivaAssociatedMasterData.genderRoleOptions.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (v) => setState(() => _selectedRoleGender = v ?? 'Male deity'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.wc, color: Color(0xFFB01254), size: 18),
                ),
              ),
              isDark: isDark,
            );

            final taNameField = _buildFieldContainer(
              label: 'தமிழ் பெயர் (Tamil Name) *',
              child: TextField(
                controller: _tamilNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'எ.கா: சிவன் / Sivan',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.language, color: Color(0xFFB01254), size: 18),
                ),
              ),
              isDark: isDark,
            );

            final enNameField = _buildFieldContainer(
              label: 'ஆங்கிலப் பெயர் (English Name) *',
              child: TextField(
                controller: _englishNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Lord Shiva / Shiva',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.spellcheck, color: Color(0xFFB01254), size: 18),
                ),
              ),
              isDark: isDark,
            );

            if (isDesktop) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: taNameField),
                      const SizedBox(width: 16),
                      Expanded(child: enNameField),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: categoryField),
                      const SizedBox(width: 16),
                      Expanded(child: roleGenderField),
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                taNameField,
                const SizedBox(height: 14),
                enNameField,
                const SizedBox(height: 14),
                categoryField,
                const SizedBox(height: 14),
                roleGenderField,
              ],
            );
          },
        ),

        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'விளக்கம் / குறிப்பு (Description)',
          child: TextField(
            controller: _descriptionCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'தெய்வத்தின் சிறப்பு மற்றும் குறிப்புகள்...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          isDark: isDark,
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Photos Section Header
        const Text(
          'STEP 2: தெய்வப் புகைப்படங்கள் (Primary & Additional Form Photos)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
        ),
        const SizedBox(height: 4),
        Text(
          'முதன்மை தெய்வப் புகைப்படத்தை பதிவேற்றலாம். மேலும், சிவனின் வெவ்வேறு வடிவங்களுக்கான புகைப்படங்களை தனித்தனிக் குறிப்புகளாகச் சேமிக்கலாம்.',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Primary Photo Upload Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('முதன்மை தெய்வப் புகைப்படம் (Primary Deity Photo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  if (_primaryPhotoBytes != null)
                    TextButton.icon(
                      onPressed: () => setState(() => _primaryPhotoBytes = null),
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      label: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontSize: 11)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _pickPrimaryPhoto,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF333333) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFB01254).withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                      ],
                    ),
                    child: _primaryPhotoBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(_primaryPhotoBytes!, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined, color: Color(0xFFB01254), size: 38),
                              const SizedBox(height: 8),
                              const Text('புகைப்படம் பதிவேற்றுக', style: TextStyle(color: Color(0xFFB01254), fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Click to upload image', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Additional Photos for Shiva Forms
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('சிவ வடிவங்களின் புகைப்படக் குறிப்புகள் (Form Photo References)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('தனித்தனி புகைப்படக் குறிப்புகளாகச் சேமிக்கப்படும் (${_photoReferences.length} குறிப்புகள்)', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddAdditionalPhotoDialog,
                    icon: const Icon(Icons.add_photo_alternate, size: 16),
                    label: const Text('புகைப்படம் சேர்'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01254),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_photoReferences.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text('கூடுதல் புகைப்படங்கள் எதுவும் இன்னும் சேர்க்கப்படவில்லை.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _photoReferences.map((ref) {
                    Uint8List? b;
                    if (ref.photoBase64 != null && ref.photoBase64!.isNotEmpty) {
                      try {
                        b = base64Decode(ref.photoBase64!);
                      } catch (_) {}
                    }

                    return Container(
                      width: 140,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 90,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: b != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(b, fit: BoxFit.cover),
                                  )
                                : const Center(child: Icon(Icons.photo, color: Colors.grey)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ref.targetName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ref.targetType, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _photoReferences.removeWhere((p) => p.id == ref.id);
                                  });
                                },
                                splashRadius: 16,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Action Buttons Row
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _saveFinalPrimaryDeity,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('சிவபெருமானை முதன்மை தெய்வமாக சேமி (Save Shiva)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB01254),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _resetActiveDeity,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('படிவத்தை மீட்டமை (Reset)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: STEP 5 (Deity Forms: 12 Forms & 64 Murtis)
  // ==========================================
  Widget _buildShivaFormsTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFB01254), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'STEP 5: சிவ வடிவங்கள் (Forms of Shiva: Nataraja, Dakshinamurthy, Ardhanarishvara...)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _show64MurtisDialog,
              icon: const Icon(Icons.list_alt, size: 14, color: Color(0xFFB01254)),
              label: const Text('64 மூர்த்தங்கள் முழு அட்டவணை', style: TextStyle(fontSize: 11, color: Color(0xFFB01254))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFB01254)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '12 முக்கிய சிவ வடிவங்களை விரைவாகத் தேர்வு செய்ய கீழே உள்ள பொத்தான்களை அழுத்தலாம்:',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        const SizedBox(height: 10),

        // Quick Pick Chips for 12 Prominent Shiva Forms
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ShivaAssociatedMasterData.prominent12ShivaForms.map((form) {
              final isAlreadyAdded = _deityForms.any((f) => f.nameTa == form.nameTa || f.nameEn == form.nameEn);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: isAlreadyAdded
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      : const Icon(Icons.add, color: Color(0xFFB01254), size: 16),
                  label: Text(form.nameEn, style: TextStyle(fontSize: 11, fontWeight: isAlreadyAdded ? FontWeight.bold : FontWeight.normal)),
                  backgroundColor: isAlreadyAdded ? Colors.green.shade50 : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFDE4EC)),
                  onPressed: () {
                    setState(() {
                      _formTaNameCtrl.text = form.nameTa;
                      _formEnNameCtrl.text = form.nameEn;
                      _formDescCtrl.text = form.description;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Form Entry Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _editingFormId != null ? 'சிவ வடிவத்தைத் திருத்து (Edit Shiva Form)' : 'புதிய சிவ வடிவம் பதிவு செய் (Add Shiva Form)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (_editingFormId != null)
                    TextButton(
                      onPressed: _clearFormInput,
                      child: const Text('ரத்து (Cancel)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 650;
                  final ta = _buildFieldContainer(
                    label: 'தமிழ் பெயர் (Tamil Name) *',
                    child: TextField(controller: _formTaNameCtrl, decoration: const InputDecoration(hintText: 'எ.கா: நடராஜர்', border: OutlineInputBorder(), isDense: true)),
                    isDark: isDark,
                  );
                  final en = _buildFieldContainer(
                    label: 'ஆங்கிலப் பெயர் (English Name) *',
                    child: TextField(controller: _formEnNameCtrl, decoration: const InputDecoration(hintText: 'e.g. Nataraja', border: OutlineInputBorder(), isDense: true)),
                    isDark: isDark,
                  );

                  if (isDesktop) {
                    return Row(children: [Expanded(child: ta), const SizedBox(width: 14), Expanded(child: en)]);
                  }
                  return Column(children: [ta, const SizedBox(height: 12), en]);
                },
              ),
              const SizedBox(height: 12),
              _buildFieldContainer(
                label: 'தத்துவம் / விளக்கம் (Description)',
                child: TextField(controller: _formDescCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'வடிவத்தின் ஆன்மீக விளக்கம்...', border: OutlineInputBorder(), isDense: true)),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFormPhoto,
                    icon: const Icon(Icons.photo_camera, size: 16),
                    label: const Text('வடிவப் படம் தேர்வு'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_formPhotoBytes != null)
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(_formPhotoBytes!, width: 36, height: 36, fit: BoxFit.cover),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                          onPressed: () => setState(() => _formPhotoBytes = null),
                        ),
                      ],
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _saveOrUpdateForm,
                    icon: Icon(_editingFormId != null ? Icons.update : Icons.add, size: 16),
                    label: Text(_editingFormId != null ? 'வடிவத்தைப் புதுப்பி' : 'வடிவத்தைச் சேர்'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01254),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Added Forms List
        Text(
          'பதிவு செய்யப்பட்ட சிவ வடிவங்கள் (${_deityForms.length} வடிவங்கள்):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (_deityForms.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text('சிவ வடிவங்கள் எதுவும் இன்னும் சேர்க்கப்படவில்லை.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _deityForms.map((f) {
              Uint8List? imgBytes;
              if (f.photoBase64 != null && f.photoBase64!.isNotEmpty) {
                try {
                  imgBytes = base64Decode(f.photoBase64!);
                } catch (_) {}
              }

              return Container(
                width: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                      backgroundImage: imgBytes != null ? MemoryImage(imgBytes) : null,
                      child: imgBytes == null ? const Icon(Icons.temple_hindu, size: 20, color: Color(0xFFB01254)) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.nameTa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(f.nameEn, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB01254).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Primary Ref: Shiva', style: TextStyle(fontSize: 9, color: Color(0xFFB01254), fontWeight: FontWeight.bold)),
                          ),
                          if (f.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(f.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              _editingFormId = f.id;
                              _formTaNameCtrl.text = f.nameTa;
                              _formEnNameCtrl.text = f.nameEn;
                              _formDescCtrl.text = f.description;
                              _formPhotoBytes = imgBytes;
                            });
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _deityForms.removeWhere((item) => item.id == f.id);
                            });
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ==========================================
  // TAB 2: STEP 4 (Family Relationships)
  // ==========================================
  Widget _buildFamilyRelationshipsTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_alt, color: Color(0xFFB01254), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'STEP 4: குடும்ப உறவுமுறைத் தெய்வங்கள் (Family Relationships)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'குறிப்பு: அனைத்து தொடர்புடைய தெய்வங்களும் குடும்ப உறுப்பினர்கள் அல்ல. குடும்ப உறுப்பினர்களான பார்வதி (துணைவி), முருகன் (மகன்), விநாயகர் (மகன்) ஆகியோரை இங்கே உறவுமுறையுடன் பதிவு செய்யலாம்.',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Suggestion Chips for Shiva's Family
        const Text('சிவபெருமானின் முதன்மைக் குடும்ப உறவுகள் (Quick Suggestions):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ShivaAssociatedMasterData.defaultShivaFamily.map((fam) {
              final isAlreadyAdded = _familyMembers.any((fm) => fm.deityNameTa == fam.deityNameTa || fm.deityNameEn == fam.deityNameEn);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: isAlreadyAdded
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      : const Icon(Icons.add, color: Color(0xFFB01254), size: 16),
                  label: Text('${fam.deityNameTa} (${fam.relationshipType})', style: const TextStyle(fontSize: 11)),
                  backgroundColor: isAlreadyAdded ? Colors.green.shade50 : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFDE4EC)),
                  onPressed: () {
                    setState(() {
                      _familyTaNameCtrl.text = fam.deityNameTa;
                      _familyEnNameCtrl.text = fam.deityNameEn;
                      _familyRelationshipType = fam.relationshipType;
                      _familyGender = fam.gender;
                      _familyDescCtrl.text = fam.description;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Family Entry Form Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _editingFamilyId != null ? 'குடும்ப உறவுமுறைத் தெய்வத்தைத் திருத்து' : 'புதிய குடும்ப உறவுமுறைத் தெய்வம் சேர்க்க',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (_editingFamilyId != null)
                    TextButton(onPressed: _clearFamilyInput, child: const Text('ரத்து', style: TextStyle(fontSize: 11, color: Colors.grey))),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 650;
                  final ta = _buildFieldContainer(
                    label: 'தெய்வத்தின் பெயர் (தமிழ்) *',
                    child: TextField(controller: _familyTaNameCtrl, decoration: const InputDecoration(hintText: 'எ.கா: பார்வதி', border: OutlineInputBorder(), isDense: true)),
                    isDark: isDark,
                  );
                  final en = _buildFieldContainer(
                    label: 'தெய்வத்தின் பெயர் (ஆங்கிலம்) *',
                    child: TextField(controller: _familyEnNameCtrl, decoration: const InputDecoration(hintText: 'e.g. Parvati', border: OutlineInputBorder(), isDense: true)),
                    isDark: isDark,
                  );

                  if (isDesktop) {
                    return Row(children: [Expanded(child: ta), const SizedBox(width: 14), Expanded(child: en)]);
                  }
                  return Column(children: [ta, const SizedBox(height: 12), en]);
                },
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 650;
                  final rel = _buildFieldContainer(
                    label: 'உறவுமுறை வகை (Relationship Type) *',
                    child: DropdownButtonFormField<String>(
                      value: _familyRelationshipType,
                      items: ShivaAssociatedMasterData.relationshipTypes.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _familyRelationshipType = v ?? 'Other'),
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                    isDark: isDark,
                  );
                  final gen = _buildFieldContainer(
                    label: 'பாலினம் (Gender) *',
                    child: DropdownButtonFormField<String>(
                      value: _familyGender,
                      items: ShivaAssociatedMasterData.genderRoleOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _familyGender = v ?? 'Female deity'),
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                    isDark: isDark,
                  );

                  if (isDesktop) {
                    return Row(children: [Expanded(child: rel), const SizedBox(width: 14), Expanded(child: gen)]);
                  }
                  return Column(children: [rel, const SizedBox(height: 12), gen]);
                },
              ),
              const SizedBox(height: 12),
              _buildFieldContainer(
                label: 'விளக்கம் / சிறப்பு (Description)',
                child: TextField(controller: _familyDescCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'உறவுமுறையின் சிறப்பு...', border: OutlineInputBorder(), isDense: true)),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFamilyPhoto,
                    icon: const Icon(Icons.photo_camera, size: 16),
                    label: const Text('படம் தேர்வு'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 12),
                  if (_familyPhotoBytes != null)
                    Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.memory(_familyPhotoBytes!, width: 36, height: 36, fit: BoxFit.cover)),
                        IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.red), onPressed: () => setState(() => _familyPhotoBytes = null)),
                      ],
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _saveOrUpdateFamilyMember,
                    icon: Icon(_editingFamilyId != null ? Icons.update : Icons.add, size: 16),
                    label: Text(_editingFamilyId != null ? 'புதுப்பி' : 'குடும்ப உறவைச் சேர்'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB01254), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Family Members List
        Text(
          'பதிவு செய்யப்பட்ட குடும்ப உறுப்பினர்கள் (${_familyMembers.length} தெய்வங்கள்):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (_familyMembers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text('குடும்ப உறுப்பினர்கள் எதுவும் இன்னும் சேர்க்கப்படவில்லை.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _familyMembers.map((fam) {
              Uint8List? imgBytes;
              if (fam.photoBase64 != null && fam.photoBase64!.isNotEmpty) {
                try {
                  imgBytes = base64Decode(fam.photoBase64!);
                } catch (_) {}
              }

              return Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                      backgroundImage: imgBytes != null ? MemoryImage(imgBytes) : null,
                      child: imgBytes == null ? const Icon(Icons.person, size: 20, color: Color(0xFFB01254)) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fam.deityNameTa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(fam.deityNameEn, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFB01254), borderRadius: BorderRadius.circular(4)),
                                child: Text(fam.relationshipType, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text(fam.gender, style: TextStyle(color: Colors.purple.shade800, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          if (fam.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(fam.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              _editingFamilyId = fam.id;
                              _familyTaNameCtrl.text = fam.deityNameTa;
                              _familyEnNameCtrl.text = fam.deityNameEn;
                              _familyRelationshipType = fam.relationshipType;
                              _familyGender = fam.gender;
                              _familyDescCtrl.text = fam.description;
                              _familyPhotoBytes = imgBytes;
                            });
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _familyMembers.removeWhere((item) => item.id == fam.id);
                            });
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ==========================================
  // TAB 3: STEP 3 (Associated Saints & Siddhars)
  // ==========================================
  Widget _buildSaintsAndSiddharsTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-tabs for Nayanmars vs Siddhars
        Row(
          children: [
            Expanded(
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text('A. 63 நாயன்மார்கள் (${_associatedNayanmars.length})'),
                    icon: const Icon(Icons.menu_book),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('B. சித்தர்கள் (${_associatedSiddhars.length})'),
                    icon: const Icon(Icons.self_improvement),
                  ),
                ],
                selected: {_saintsSubTab},
                onSelectionChanged: (set) {
                  setState(() => _saintsSubTab = set.first);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (_saintsSubTab == 0)
          _buildNayanmarsSection(isDark)
        else
          _buildSiddharsSection(isDark),
      ],
    );
  }

  Widget _buildNayanmarsSection(bool isDark) {
    final filteredMasterNayanmars = ShivaAssociatedMasterData.all63Nayanmars.where((n) {
      if (_nayanmarSearchQuery.isEmpty) return true;
      return n.tamilName.toLowerCase().contains(_nayanmarSearchQuery) ||
          n.englishName.toLowerCase().contains(_nayanmarSearchQuery) ||
          n.shortDescription.toLowerCase().contains(_nayanmarSearchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFFB01254), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'அறுபத்து மூன்று நாயன்மார்கள் (63 Traditional Nayanmars)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFB01254).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('Relationship: Shaivite Saint / Devotee of Shiva', style: TextStyle(fontSize: 10, color: Color(0xFFB01254), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Search Bar for 63 Nayanmars
        TextField(
          controller: _nayanmarSearchCtrl,
          decoration: InputDecoration(
            hintText: '63 நாயன்மார்களைத் தேடு (Search Nayanmar name or description)...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _nayanmarSearchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => _nayanmarSearchCtrl.clear())
                : null,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        // Quick add list from 63 Nayanmars
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: filteredMasterNayanmars.isEmpty
              ? const Center(child: Text('பொருத்தமான நாயன்மார் பதிவுகள் இல்லை'))
              : ListView.separated(
                  itemCount: filteredMasterNayanmars.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final n = filteredMasterNayanmars[idx];
                    final isAdded = _associatedNayanmars.any((item) => item.tamilName == n.tamilName);

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                        child: Text('${idx + 1}', style: const TextStyle(fontSize: 10, color: Color(0xFFB01254), fontWeight: FontWeight.bold)),
                      ),
                      title: Text(n.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text(n.shortDescription, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                      trailing: isAdded
                          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                          : ElevatedButton(
                              onPressed: () => _addNayanmar(n),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB01254),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              child: const Text('சேர் (Add)'),
                            ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 20),

        // Associated Nayanmars List
        Text(
          'கோவிலில் பதிவு செய்யப்பட்ட நாயன்மார்கள் (${_associatedNayanmars.length} அடியார்கள்):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (_associatedNayanmars.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text('நாயன்மார்கள் எதுவும் இன்னும் சேர்க்கப்படவில்லை.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _associatedNayanmars.map((n) {
              return Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFFDE4EC),
                      child: Icon(Icons.auto_stories, size: 18, color: Color(0xFFB01254)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.tamilName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(n.englishName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Shaivite Saint / Devotee', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          Text(n.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _associatedNayanmars.removeWhere((item) => item.id == n.id);
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSiddharsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.self_improvement, color: Color(0xFFB01254), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'சித்தர்கள் மரபு (Siddhars Tradition - 18 Siddhars & Regional Traditions)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB01254)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'முக்கிய விதிமுறை: சித்தர்கள் சிவபெருமானின் அருள் பெற்ற ஞானிகள்; இவர்கள் சிவபெருமானின் குடும்ப உறுப்பினர்களாகக் கருதப்படுவதில்லை. தனிப் பிரிவாக இங்கே நிர்வகிக்கப்படுகின்றனர்.',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick add from 18 Traditional Siddhars
        const Text('18 சித்தர்கள் விரைவுத் தேர்வு (Quick Add 18 Siddhars):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ShivaAssociatedMasterData.traditional18Siddhars.map((s) {
              final isAlreadyAdded = _associatedSiddhars.any((item) => item.tamilName == s.tamilName);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: isAlreadyAdded
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      : const Icon(Icons.add, color: Color(0xFFB01254), size: 16),
                  label: Text(s.tamilName, style: const TextStyle(fontSize: 11)),
                  backgroundColor: isAlreadyAdded ? Colors.green.shade50 : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFDE4EC)),
                  onPressed: () => _addSiddhar(s),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Custom Siddhar Form Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _editingSiddharId != null ? 'சித்தர் விவரத்தைத் திருத்து' : 'வட்டார / இதர சித்தர் பதிவு செய் (Add Custom / Regional Siddhar)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (_editingSiddharId != null)
                    TextButton(onPressed: _clearSiddharInput, child: const Text('ரத்து', style: TextStyle(fontSize: 11, color: Colors.grey))),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 650;
                  final ta = _buildFieldContainer(
                    label: 'சித்தர் பெயர் (தமிழ்) *',
                    child: TextField(controller: _siddharTaNameCtrl, decoration: const InputDecoration(hintText: 'எ.கா: சிவவாக்கியர்', border: OutlineInputBorder(), isDense: true)),
                    isDark: isDark,
                  );
                  final en = _buildFieldContainer(
                    label: 'சித்தர் பெயர் (ஆங்கிலம்) *',
                    child: TextField(controller: _siddharEnNameCtrl, decoration: const InputDecoration(hintText: 'e.g. Siva Vakkiyar', border: OutlineInputBorder(), isDense: true)),
                    isDark: isDark,
                  );

                  if (isDesktop) {
                    return Row(children: [Expanded(child: ta), const SizedBox(width: 14), Expanded(child: en)]);
                  }
                  return Column(children: [ta, const SizedBox(height: 12), en]);
                },
              ),
              const SizedBox(height: 12),
              _buildFieldContainer(
                label: 'சித்தர் மரபு (Siddhar Tradition) *',
                child: DropdownButtonFormField<String>(
                  value: _siddharTradition,
                  items: ShivaAssociatedMasterData.siddharTraditionOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _siddharTradition = v ?? '18 Siddhars (பதினெண் சித்தர்கள்)'),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildFieldContainer(
                label: 'சிறப்பு / வரலாறு (Description)',
                child: TextField(controller: _siddharDescCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'சித்தரின் அருளாட்சி மற்றும் ஜீவசமாதி தலம்...', border: OutlineInputBorder(), isDense: true)),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickSiddharPhoto,
                    icon: const Icon(Icons.photo_camera, size: 16),
                    label: const Text('படம் தேர்வு'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 12),
                  if (_siddharPhotoBytes != null)
                    Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.memory(_siddharPhotoBytes!, width: 36, height: 36, fit: BoxFit.cover)),
                        IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.red), onPressed: () => setState(() => _siddharPhotoBytes = null)),
                      ],
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _saveOrUpdateCustomSiddhar,
                    icon: Icon(_editingSiddharId != null ? Icons.update : Icons.add, size: 16),
                    label: Text(_editingSiddharId != null ? 'புதுப்பி' : 'சித்தரைச் சேர்'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB01254), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Siddhars List
        Text(
          'கோவிலில் பதிவு செய்யப்பட்ட சித்தர்கள் (${_associatedSiddhars.length} சித்தர்கள்):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (_associatedSiddhars.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text('சித்தர்கள் எதுவும் இன்னும் சேர்க்கப்படவில்லை.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _associatedSiddhars.map((s) {
              Uint8List? imgBytes;
              if (s.photoBase64 != null && s.photoBase64!.isNotEmpty) {
                try {
                  imgBytes = base64Decode(s.photoBase64!);
                } catch (_) {}
              }

              return Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: imgBytes != null ? MemoryImage(imgBytes) : null,
                      child: imgBytes == null ? const Icon(Icons.self_improvement, size: 18, color: Colors.blue) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.tamilName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(s.englishName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(s.siddharTradition, style: TextStyle(color: Colors.teal.shade800, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          Text(s.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _associatedSiddhars.removeWhere((item) => item.id == s.id);
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // Helper dialog to browse 64 Murtis
  Future<void> _show64MurtisDialog() async {
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final list = ShivaMurtisMasterData.search(query);

            return Dialog(
              backgroundColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('64 சிவ மூர்த்தங்கள் பட்டியல்', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB01254))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(dialogCtx)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'மூர்த்தியைத் தேடு...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => setDialogState(() => query = v),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final m = list[idx];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFB01254).withOpacity(0.1),
                              child: Text('${m.id}', style: const TextStyle(fontSize: 9, color: Color(0xFFB01254), fontWeight: FontWeight.bold)),
                            ),
                            title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            subtitle: Text(m.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                            trailing: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _formTaNameCtrl.text = m.tamilName;
                                  _formEnNameCtrl.text = m.englishName;
                                  _formDescCtrl.text = m.description;
                                });
                                Navigator.pop(dialogCtx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB01254),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              child: const Text('தேர்வு செய்'),
                            ),
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

  Widget _buildFieldContainer({required String label, required Widget child, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
