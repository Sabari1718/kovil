import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:kulatheivam/features/deities/data/deities_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class AddNewDeitiesWizardContent extends ConsumerStatefulWidget {
  final Function(String, {Map<String, dynamic>? arguments}) onScreenSelected;
  
  const AddNewDeitiesWizardContent({super.key, required this.onScreenSelected});

  @override
  ConsumerState<AddNewDeitiesWizardContent> createState() => _AddNewDeitiesWizardContentState();
}

class _AddNewDeitiesWizardContentState extends ConsumerState<AddNewDeitiesWizardContent> {
  int _currentStep = 0;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'சிவன்',
      'subtitle': 'Siva',
      'image': 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    },
    {
      'title': 'விஷ்ணு',
      'subtitle': 'Vishnu',
      'image': 'https://images.unsplash.com/photo-1598816824967-0c7499bf336c?auto=format&fit=crop&w=500&q=60',
    },
    {
      'title': 'குலதெய்வம்',
      'subtitle': 'Kulatheivam',
      'image': 'https://images.unsplash.com/photo-1621213032549-0d12e697ce71?auto=format&fit=crop&w=500&q=60',
    },
    {
      'title': 'இஷ்ட தெய்வங்கள்',
      'subtitle': 'Ista Deivangal',
      'image': 'https://images.unsplash.com/photo-1571167530149-c1105fa4c28b?auto=format&fit=crop&w=500&q=60',
    },
    {
      'title': 'கிராமம் தெய்வங்கள்',
      'subtitle': 'Grama Deivangal',
      'image': 'https://images.unsplash.com/photo-1618306066223-9c869910c8ce?auto=format&fit=crop&w=500&q=60',
    },
  ];

  Uint8List? _mainPhotoBytes;
  bool _separateSannidhi = false;
  bool _auspiciousDayTime = false;
  final List<Map<String, dynamic>> _deityForms = [
    {'image': null, 'speciality': ''}
  ];

  // Step 2 variables
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _relationshipStatusCtrl = TextEditingController(); // For உடனுறை தெய்வம்
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

  Future<void> _saveRecord() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('தெய்வத்தின் பெயரை உள்ளிடவும் (Name is required)', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      setState(() => _currentStep = 0); // Go back to step 1
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(deitiesApiRepositoryProvider);
    
    // Construct basic data map
    final data = {
      'name': _nameCtrl.text.trim(),
      'deitySpeciality': _deitySpecialityCtrl.text.trim(),
      'worshipMethod': _worshipMethodCtrl.text.trim(),
      'prayerRequest': _prayerRequestCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'specialName': jsonEncode(_specialName),
      'specialDays': _specialDaysCtrl.text.trim(),
      'specialPuja': _specialPujaCtrl.text.trim(),
      'fastings': _fastingsCtrl.text.trim(),
      'separateSannidhi': _separateSannidhi ? 'true' : 'false',
      'hasPujaTime': _auspiciousDayTime ? 'true' : 'false',
      'pujaTimes': jsonEncode(_pujaTimes),
      'deivamType': _deivamType == 'ஆண் தெய்வம் (Male Deity)' ? 'male' : _deivamType == 'பெண் தெய்வம் (Female Deity)' ? 'female' : 'others',
      'relationship': _relationshipCtrl.text.trim(),
      'relationship_status': _relationshipStatusCtrl.text.trim(),
      'deityCategory': _selectedCategory ?? 'சிவன்',
      'status': 'Active',
      'valipadu': jsonEncode(_valipadu),
      'poojaiMuraigal': jsonEncode(_poojaiMuraigal),
      'ukuthaMalar': jsonEncode(_ukuthaMalar),
      'ukuthaUnavu': jsonEncode(_ukuthaUnavu),
      'naivethiyam': jsonEncode(_naivethiyam),
      'parayanam': jsonEncode(_parayanam),
      'venduthalgal': jsonEncode(_venduthalgal),
      'venduthalNiraivetraPoojai': jsonEncode(_venduthalNiraivetraPoojai),
      'venduthalNiraivuPoojai': jsonEncode(_venduthalNiraivuPoojai),
      'yagangal': jsonEncode(_yagangal),
      'temple_id': '1', // Hardcoded for now based on user payload
    };

    // Prepare roopangal data and extra images
    List<Map<String, dynamic>> roopangalData = [];
    Map<String, Uint8List> extraImages = {};
    for (int i = 0; i < _deityForms.length; i++) {
      final form = _deityForms[i];
      final hasImage = form['image'] != null;
      roopangalData.add({
        'sirapu': form['speciality'],
        'image': '',
        'hasImage': hasImage,
      });
      if (hasImage) {
        extraImages['roopangal_image_$i'] = form['image'];
      }
    }
    data['roopangal_data'] = jsonEncode(roopangalData);

    // Main photo handling (using dummy file to get XFile, or we should rewrite repo to take Uint8List directly. Wait, XFile.fromData works!)
    XFile? mainPhoto;
    if (_mainPhotoBytes != null) {
      mainPhoto = XFile.fromData(_mainPhotoBytes!, name: 'photo.jpg');
    }

    // Removed API Call: final success = await repo.addKovilDeivangal(data, mainPhoto, extraImages: extraImages.isNotEmpty ? extraImages : null);
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    final success = true;

    setState(() => _isLoading = false);

    if (success && mounted) {
      CustomDeleteDialog.showSuccess(
        context,
        message: 'புதிய தெய்வம் வெற்றிகரமாக சேமிக்கப்பட்டது',
      );
      
      // Add to table
      setState(() {
        _savedDeities.add({
          'name': data['name'],
          'deityCategory': data['deityCategory'],
          'relationship': data['relationship'],
          'deitySpeciality': data['deitySpeciality'],
          'worshipMethod': data['worshipMethod'],
          'fastings': data['fastings'],
          'deivamType': data['deivamType'],
          'status': data['status'],
        });
      });
      
      _clearForm();
      // Optional: Navigate or refresh
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'), backgroundColor: Colors.red),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _currentStep = 0;
      _mainPhotoBytes = null;
      _separateSannidhi = false;
      _auspiciousDayTime = false;
      _deityForms.clear();
      _deityForms.add({'image': null, 'speciality': ''});
      _nameCtrl.clear();
      _relationshipStatusCtrl.clear();
      _relationshipCtrl.clear();
      _deitySpecialityCtrl.clear();
      _worshipMethodCtrl.clear();
      _prayerRequestCtrl.clear();
      _notesCtrl.clear();
      _specialDaysCtrl.clear();
      _specialPujaCtrl.clear();
      _fastingsCtrl.clear();
      _deivamType = 'Select வகை (Gender)';
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
            Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'புதிய பதிவு (Add New Deity) - Step 1: Select Category',
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
        _buildCategoryGrid(isDark, theme),
        const SizedBox(height: 40),
        Row(
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
              onPressed: _selectedCategory != null ? () {
                setState(() {
                  _currentStep = 1;
                });
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB01254),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next Step →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2Content(bool isDark, ThemeData theme) {
    final selectedCategoryData = _categories.firstWhere((c) => c['title'] == _selectedCategory, orElse: () => _categories[0]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'புதிய பதிவு (Add New Deity) - Step 2: Basic Details',
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
        const SizedBox(height: 32),
        
        // Basic Details Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'அடிப்படை விவரங்கள் (Basic Details)',
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800;
                  return Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 2 : 0,
                        child: Column(
                          children: [
                            if (constraints.maxWidth > 600) ...[
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('வகை (Gender)', 'Select வகை (Gender)', isDropdown: true, dropdownItems: ['Select வகை (Gender)', 'ஆண் தெய்வம் (Male Deity)', 'பெண் தெய்வம் (Female Deity)', 'மற்றவை (Other)'], value: _deivamType, onChanged: (v) => setState(() => _deivamType = v ?? 'Select வகை (Gender)'), isDark: isDark)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('பெயர்', 'தெய்வத்தின் பெயர்...', controller: _nameCtrl, isDark: isDark)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('உடனுறை தெய்வம்', 'எ.கா: பார்வதி...', controller: _relationshipStatusCtrl, isDark: isDark)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('தொடர்பு (Relationship)', 'எ.கா: தந்தை...', controller: _relationshipCtrl, isDark: isDark)),
                                ],
                              ),
                            ] else ...[
                              _buildTextField('வகை (Gender)', 'Select வகை (Gender)', isDropdown: true, dropdownItems: ['Select வகை (Gender)', 'ஆண் தெய்வம் (Male Deity)', 'பெண் தெய்வம் (Female Deity)', 'மற்றவை (Other)'], value: _deivamType, onChanged: (v) => setState(() => _deivamType = v ?? 'Select வகை (Gender)'), isDark: isDark),
                              const SizedBox(height: 16),
                              _buildTextField('பெயர்', 'தெய்வத்தின் பெயர்...', controller: _nameCtrl, isDark: isDark),
                              const SizedBox(height: 16),
                              _buildTextField('உடனுறை தெய்வம்', 'எ.கா: பார்வதி...', controller: _relationshipStatusCtrl, isDark: isDark),
                              const SizedBox(height: 16),
                              _buildTextField('தொடர்பு (Relationship)', 'எ.கா: தந்தை...', controller: _relationshipCtrl, isDark: isDark),
                            ],
                          ],
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: 24),
                      if (!isDesktop) const SizedBox(height: 24),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('புகைப்படம் (Photo)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                            const SizedBox(height: 8),
                            _buildDashedUploadBox(isDark, theme),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Deity Forms Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.collections_outlined, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ரூபங்கள் (Deity Forms / Incarnations)',
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
              ..._deityForms.asMap().entries.map((entry) {
                int idx = entry.key;
                var form = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 450;
                        
                        Widget imageBox = GestureDetector(
                          onTap: () => _pickDeityFormImage(idx),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                            ),
                            child: form['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(form['image'] as Uint8List, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, color: Colors.grey.shade500),
                                    const SizedBox(height: 8),
                                    Text('படம் தேர்வு செய்', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                                  ],
                                ),
                          ),
                        );
                        
                        Widget closeBtn = IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _deityForms.removeAt(idx);
                            });
                          },
                        );
                        
                        Widget textFieldBox = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('சிறப்பு (Speciality)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                            const SizedBox(height: 8),
                            TextField(
                              maxLines: 3,
                              controller: TextEditingController(text: form['speciality'])..selection = TextSelection.collapsed(offset: form['speciality'].length),
                              onChanged: (val) {
                                form['speciality'] = val;
                              },
                              decoration: InputDecoration(
                                hintText: 'ரூபத்தின் சிறப்பு விவரங்கள்...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        );

                        if (isSmall) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  imageBox,
                                  closeBtn,
                                ],
                              ),
                              const SizedBox(height: 16),
                              textFieldBox,
                            ],
                          );
                        }
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageBox,
                            const SizedBox(width: 16),
                            Expanded(child: textFieldBox),
                            const SizedBox(width: 8),
                            closeBtn,
                          ],
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _deityForms.add({'image': null, 'speciality': ''});
                  });
                },
                icon: const Icon(Icons.add, color: Color(0xFFB01254)),
                label: const Text('மேலும் ரூபங்கள் சேர்க்க (Add More Forms)', style: TextStyle(color: Color(0xFFB01254))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB01254)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
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
                  _currentStep = 2; // Move to step 3 later
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
        ),
      ],
    );
  }

  Widget _buildSelectedCategoryBanner(Map<String, dynamic> selectedCategoryData, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE4EC), // light pink
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 450;
          
          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        selectedCategoryData['image'], 
                        width: 48, 
                        height: 48, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48, 
                          height: 48, 
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SELECTED CATEGORY',
                            style: TextStyle(color: Color(0xFFB01254), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedCategoryData['title']} (${selectedCategoryData['subtitle']})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black12),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Edit Category'),
                  ),
                ),
              ],
            );
          }
          
          return Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  selectedCategoryData['image'], 
                  width: 48, 
                  height: 48, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48, 
                    height: 48, 
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECTED CATEGORY',
                      style: TextStyle(color: Color(0xFFB01254), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedCategoryData['title']} (${selectedCategoryData['subtitle']})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black12),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Edit Category'),
              ),
            ],
          );
        },
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
        Row(
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
        int crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['title'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['title'];
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
                            child: Image.network(
                              category['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    category['subtitle'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
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
          // Table Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              
              if (isSmallScreen) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'புதிய தெய்வங்களைச் சேர்க்க (Add New Deities) பட்டியல்',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'பெயர் மூலம் தேடு...',
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
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.list, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'புதிய தெய்வங்களைச் சேர்க்க (Add New Deities) பட்டியல்',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'பெயர் மூலம் தேடு...',
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
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Data Table
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
                DataColumn(label: Text('பெயர்\n(NAME)')),
                DataColumn(label: Text('தெய்வம்\n(DEITY)')),
                DataColumn(label: Text('தொடர்பு\n(RELATIONSHIP)')),
                DataColumn(label: Text('சிறப்பு')),
                DataColumn(label: Text('வழிபாட்டு\nமுறை')),
                DataColumn(label: Text('விரதகள்')),
                DataColumn(label: Text('வகை')),
                DataColumn(label: Text('நிலை')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: _savedDeities.map((deity) {
                return DataRow(
                  cells: [
                    DataCell(Text(deity['name'] ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB01254).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(deity['deityCategory'] ?? '-', style: const TextStyle(color: Color(0xFFB01254), fontSize: 12)),
                      ),
                    ),
                    DataCell(Text(deity['relationship']?.toString().isNotEmpty == true ? deity['relationship'] : '-')),
                    DataCell(Text(deity['deitySpeciality']?.toString().isNotEmpty == true ? deity['deitySpeciality'] : '-')),
                    DataCell(Text(deity['worshipMethod']?.toString().isNotEmpty == true ? deity['worshipMethod'] : '-')),
                    DataCell(Text(deity['fastings']?.toString().isNotEmpty == true ? deity['fastings'] : '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(deity['deivamType'] == 'male' ? 'ஆண்' : deity['deivamType'] == 'female' ? 'பெண்' : 'மற்றவை', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                      ),
                    ),
                    DataCell(Text(deity['status'] ?? 'Active', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                            onPressed: () {
                              setState(() => _currentStep = 1);
                            },
                            splashRadius: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            onPressed: () {},
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
