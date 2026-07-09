import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kovil_dropdown_provider.dart';
import '../data/kovil_dropdown_models.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class TempleExtraDetailsContent extends ConsumerStatefulWidget {
  final int? basicId;
  final String? mulavarName;
  final String? templeName;
  final Map<String, dynamic>? initialData;

  const TempleExtraDetailsContent({
    super.key,
    this.basicId,
    this.mulavarName,
    this.templeName,
    this.initialData,
  });

  @override
  ConsumerState<TempleExtraDetailsContent> createState() =>
      _TempleExtraDetailsContentState();
}

class _TempleExtraDetailsContentState
    extends ConsumerState<TempleExtraDetailsContent> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  // Stepper State
  int _currentStep = 0;

  // Dropdowns Default
  final String _defaultTier = 'ஒன்று';
  late String _selectedTier;

  final String _defaultDeity = 'தெய்வத்தை தேர்ந்தெடுக்கவும் (Select Deity)';
  final String _defaultDirection =
      'திசையை தேர்ந்தெடுக்கவும் (Select Direction)';

  // Static Form Controllers
  late final TextEditingController _mulavarNameController;
  late final TextEditingController _templeNameController;
  final TextEditingController _heritageController = TextEditingController(
    text: '1500 ஆண்டுகள் பழமை வாய்ந்த தலம்',
  );
  final TextEditingController _structureController = TextEditingController(
    text: 'கருவறை அர்த்தமண்டபம், பிரகாரங்கள்...',
  );
  final TextEditingController _sanctumController = TextEditingController(
    text: 'மூன்று பிரகாரங்களும், கொடிமரம், பலிபீடம்...',
  );
  final TextEditingController
  _specialFeaturesController = TextEditingController(
    text:
        'இங்கு விஷ்ணு பகவான் கோபாலகிருஷ்ணனாக அருள்பாலிக்கிறார். மூலவர் சிலை நின்ற கோலத்தில் அமைந்துள்ளது.',
  );
  final TextEditingController
  _characteristicsController = TextEditingController(
    text:
        'காலத்துக்கு முந்தைய பழங்காலக் கல் சிற்பங்கள், நந்தவனம் மற்றும் அழகிய சிற்பங்கள் அமையப்பெற்றுள்ளது.',
  );
  final TextEditingController _miraclesController = TextEditingController(
    text:
        'கிருஷ்ணரின் மேல்தாள ஒலி இரவு நேரத்தில் சில சமயம் கேட்பதாக பக்தர்கள் நம்புகின்றனர்.',
  );
  final TextEditingController _historyController = TextEditingController(
    text:
        'முனிவர் ஒருவர் இங்கு தவம் செய்தபோது கிருஷ்ணர் காட்சியளித்து அருள் புரிந்ததாக தல வரலாறு கூறுகிறது.',
  );

  // Worship Type Selection State
  String _selectedWorshipType = 'குலத்தவர் + பொது';

  // Dynamic Lists State
  final List<TextEditingController> _mandapamControllers = [];
  final List<Map<String, dynamic>> _deityDirectionRows = [];
  final List<TextEditingController> _otherNameControllers = [];
  final List<TextEditingController> _deityControllers = [];

  // Checkboxes State
  bool _isRajagopuramDirectionChecked = true;
  String _selectedRajagopuramDirection = 'கிழக்கு';
  bool _isSongPlaceChecked = true;

  // Song Place Controllers
  final TextEditingController _songSungByController = TextEditingController(
    text: 'பாடல் பாடியவர் பெயர்...',
  );
  final TextEditingController _whichPathiController = TextEditingController(
    text: 'எந்தப் பதி / பகுதி...',
  );
  final TextEditingController _songNoteController = TextEditingController(
    text: 'ஆழ்வார்கள் இந்த தலத்தைப் புகழ்ந்து பல பாசுரங்கள் பாடியுள்ளனர்.',
  );

  // Tab 4 State
  String _selectedCommunity = '-- சமூகம் தேர்ந்தெடுக்கவும் --';
  String _selectedSubCommunity = '-- உட்பிரிவு தேர்ந்தெடுக்கவும் --';
  String _selectedKulam = '-- குலம் தேர்ந்தெடுக்கவும் --';
  String _selectedVagaiyara = '-- வகையறா தேர்ந்தெடுக்கவும் --';
  final TextEditingController _tharpothaiyaVagaiyaraController =
      TextEditingController();
  final TextEditingController _wifeNameController = TextEditingController();
  final TextEditingController _wifeKulaDeivamController =
      TextEditingController();
  String _selectedGeneration = '-- தேர்ந்தெடுக்கவும் --';
  String _selectedMaritalStatus = 'Unmarried';

  // API Data
  bool _isLoadingDropdowns = true;
  List<CommunityModel> _allCommunities = [];
  List<SubCommunityModel> _allSubCommunities = [];
  List<SubCommunityModel> _filteredSubCommunities = [];
  List<KulamModel> _allKulas = [];
  List<KulamModel> _filteredKulas = [];
  KulaDeivamModel? _selectedKulaDeivam;
  List<KulaDeivamModel> _allKulaDeivams = [];
  List<KulaDeivamModel> _filteredKulaDeivams = [];
  List<VagaiyaraModel> _allVagaiyaras = [];
  List<VagaiyaraModel> _filteredVagaiyaras = [];
  List<SectorModel> _allDeitySectors = [];

  @override
  void initState() {
    super.initState();
    _selectedTier = _defaultTier;

    _mulavarNameController = TextEditingController(
      text: widget.mulavarName ?? 'ஸ்ரீ கோபாலகிருஷ்ணன்',
    );
    _templeNameController = TextEditingController(
      text: widget.templeName ?? 'ஸ்ரீ கோபாலகிருஷ்ணன் கோவில்',
    );

    // Initialize Mandapams default entries
    _mandapamControllers.add(TextEditingController(text: 'மகாமண்டபம்'));
    _mandapamControllers.add(TextEditingController(text: 'கல்யாண மண்டபம்'));
    _mandapamControllers.add(TextEditingController(text: 'சத்திரம்'));
    _mandapamControllers.add(
      TextEditingController(text: 'உபய நாயகரின் சன்னதி மண்டபம்'),
    );

    // Initialize Deities & Directions default entry
    _deityDirectionRows.add({
      'deity': _defaultDeity,
      'direction': _defaultDirection,
      'photo': null as XFile?,
    });

    // Initialize Other Names default entries
    _otherNameControllers.add(TextEditingController(text: 'கோபாலபுரம்'));
    _otherNameControllers.add(TextEditingController(text: 'நந்தவனம்'));

    // Load dropdown data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final repository = ref.read(kovilApiRepositoryProvider);

    try {
      final results = await Future.wait([
        repository.getCommunities(),
        repository.getSubCommunities(),
        repository.getKulas(),
        repository.getKulaDeivams(),
        repository.getVagaiyaras(),
        repository.getDeitySectors(),
      ]);

      if (mounted) {
        setState(() {
          _allCommunities = results[0] as List<CommunityModel>;
          _allSubCommunities = results[1] as List<SubCommunityModel>;
          _allKulas = results[2] as List<KulamModel>;
          _allKulaDeivams = results[3] as List<KulaDeivamModel>;
          _allVagaiyaras = results[4] as List<VagaiyaraModel>;
          _allDeitySectors = results[5] as List<SectorModel>;
          _isLoadingDropdowns = false;
        });
      }

      // If initialData is passed, prepopulate immediately
      if (widget.initialData != null) {
        _prepopulateForm(widget.initialData!);
      } else if (widget.basicId != null) {
        final basicDetail = await repository.getBasicDetail(widget.basicId!);
        if (basicDetail != null && mounted) {
          _prepopulateForm(basicDetail);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDropdowns = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  void _prepopulateForm(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      _heritageController.text = data['heritage'] ?? '';
      _structureController.text = data['temple_structure'] ?? '';
      _sanctumController.text = data['sanctum_structure'] ?? '';
      _specialFeaturesController.text = data['special_features'] ?? '';
      _characteristicsController.text = data['characteristics'] ?? '';
      _miraclesController.text = data['miracles'] ?? '';
      _historyController.text = data['history'] ?? '';

      _selectedTier = data['status'] ?? _defaultTier;
      
      if (data['worship_type'] != null && data['worship_type'].toString().isNotEmpty) {
        _selectedWorshipType = data['worship_type'];
      }
      if (data['rajagopuram_direction'] != null && data['rajagopuram_direction'].toString().isNotEmpty) {
        _selectedRajagopuramDirection = data['rajagopuram_direction'];
        _isRajagopuramDirectionChecked = true;
      } else {
        _isRajagopuramDirectionChecked = false;
      }

      // Song Place
      if (data['song_place'] == 1 ||
          data['song_place'] == '1' ||
          data['song_place'] == 'ஆம்') {
        _isSongPlaceChecked = true;
        _songSungByController.text = data['padal_padiyavar'] ?? '';
        _whichPathiController.text = data['entha_pathi'] ?? '';
        _songNoteController.text = data['song_note'] ?? '';
      }

      // Mandapams
      if (data['mandapams'] != null &&
          data['mandapams'].toString().isNotEmpty) {
        final mList = data['mandapams']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        _mandapamControllers.clear();
        for (var m in mList) {
          _mandapamControllers.add(TextEditingController(text: m));
        }
      }

      // Other Names
      if (data['other_names'] != null &&
          data['other_names'].toString().isNotEmpty) {
        final oList = data['other_names']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        _otherNameControllers.clear();
        for (var o in oList) {
          _otherNameControllers.add(TextEditingController(text: o));
        }
      }

      // Theivankal
      if (data['theivankal'] != null && data['theivankal'] is List) {
        _deityDirectionRows.clear();
        for (var t in data['theivankal']) {
          _deityDirectionRows.add({
            'deity': t['deivam'] ?? _defaultDeity,
            'direction': t['thesai'] ?? _defaultDirection,
            'api_image': t['photo'],
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _mulavarNameController.dispose();
    _templeNameController.dispose();
    _heritageController.dispose();
    _structureController.dispose();
    _sanctumController.dispose();
    _specialFeaturesController.dispose();
    _characteristicsController.dispose();
    _miraclesController.dispose();
    _historyController.dispose();
    _songSungByController.dispose();
    _whichPathiController.dispose();
    _songNoteController.dispose();
    _tharpothaiyaVagaiyaraController.dispose();
    _wifeNameController.dispose();
    _wifeKulaDeivamController.dispose();

    for (var controller in _mandapamControllers) {
      controller.dispose();
    }
    for (var controller in _otherNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _selectedTier = _defaultTier;
      _selectedWorshipType = 'குலத்தவர் + பொது';
      _isRajagopuramDirectionChecked = false;
      _isSongPlaceChecked = false;

      _mulavarNameController.clear();
      _templeNameController.clear();
      _heritageController.clear();
      _structureController.clear();
      _sanctumController.clear();
      _specialFeaturesController.clear();
      _characteristicsController.clear();
      _miraclesController.clear();
      _historyController.clear();
      _songSungByController.clear();
      _whichPathiController.clear();
      _songNoteController.clear();
      _tharpothaiyaVagaiyaraController.clear();
      _wifeNameController.clear();
      _wifeKulaDeivamController.clear();

      _selectedCommunity = '-- சமூகம் தேர்ந்தெடுக்கவும் --';
      _selectedSubCommunity = '-- உட்பிரிவு தேர்ந்தெடுக்கவும் --';
      _selectedKulam = '-- குலம் தேர்ந்தெடுக்கவும் --';
      _selectedVagaiyara = '-- வகையறா தேர்ந்தெடுக்கவும் --';
      _selectedGeneration = '-- தேர்ந்தெடுக்கவும் --';
      _selectedMaritalStatus = 'Unmarried';

      for (var controller in _mandapamControllers) {
        controller.dispose();
      }
      _mandapamControllers.clear();
      _mandapamControllers.add(TextEditingController());

      for (var controller in _otherNameControllers) {
        controller.dispose();
      }
      _otherNameControllers.clear();
      _otherNameControllers.add(TextEditingController());

      _deityDirectionRows.clear();
      _deityDirectionRows.add({
        'deity': _defaultDeity,
        'direction': _defaultDirection,
        'photo': null as XFile?,
      });
    });
  }

  Future<void> _pickDeityImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _deityDirectionRows[index]['photo'] = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking deity image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialData != null;

    if (isEditMode) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No top header because Dialog has its own header
            // Form Card Container
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
                  _buildOtherNamesField(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    'தல சிறப்பு',
                    'சிறப்பு...',
                    _specialFeaturesController,
                    Icons.stars_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildResponsiveThreeRow(
                    _buildTextField(
                      'தொன்மை',
                      'தொன்மை...',
                      _heritageController,
                      Icons.history,
                    ),
                    _buildTextField(
                      'கோயில் அமைப்பு',
                      'கோயில் அமைப்பு...',
                      _structureController,
                      Icons.architecture,
                    ),
                    _buildDropdownField(
                      'நிலை',
                      _selectedTier,
                      [
                        _defaultTier,
                        'மூன்று',
                        'ஐந்து',
                        'ஏழு',
                        'ஒன்பது',
                        'பதினொன்று',
                      ],
                      (val) => setState(() => _selectedTier = val!),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 32),
                  _buildWorshipTypeSelection(),
                  const SizedBox(height: 24),
                  _buildMandapamsField(),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 32),
                  _buildDeitiesDirectionsSection(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    'தல வரலாறு',
                    'வரலாறு...',
                    _historyController,
                    Icons.history_edu,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 32),
                  _buildSongPlaceSection(),
                  const SizedBox(height: 48),
                  _buildEditFormActions(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
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
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.temple_hindu_outlined,
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
                      'கோவில் கூடுதல் விவரங்கள் (Temple Extra Details)',
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
            'கோவிலின் வரலாறு, அமைப்பு மற்றும் சிறப்பம்சங்களை இங்கே பதிவிடவும்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          // Stepper / Tabs
          _buildCustomStepper(),
          const SizedBox(height: 24),

          // Form Card Container
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
                _buildCurrentStepContent(),
                const SizedBox(height: 48),
                _buildFormActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditFormActions() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 16,
      runSpacing: 16,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _saveTempleDetails,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Update Details ->'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF524EE1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomStepper() {
    final steps = [
      {'title': 'அடிப்படை விவரங்கள்', 'subtitle': 'Basic Details'},
      {'title': 'தெய்வங்கள்', 'subtitle': 'Deities'},
      {'title': 'வரலாறு & பாடல்கள்', 'subtitle': 'History & Songs'},
      {'title': 'சமூகம் & குலதெய்வம்', 'subtitle': 'Community & Deity'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(steps.length, (index) {
              final isSelected = _currentStep == index;
              final isCompleted = _currentStep > index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF524EE1)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isCompleted
                            ? Colors.green
                            : (isSelected
                                  ? const Color(0xFF524EE1)
                                  : Colors.grey.shade300),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[index]['title']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF524EE1)
                                  : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            steps[index]['subtitle']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
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
        );
      },
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicDetailsStep();
      case 1:
        return _buildDeitiesStep();
      case 2:
        return _buildHistoryAndSongsStep();
      case 3:
        return _buildCommunityAndDeityStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Mulavar Name, Temple Name, Heritage
        _buildResponsiveThreeRow(
          _buildTextField(
            'மூலவர் பெயர் (Mulavar Name)',
            'மூலவர் பெயர்...',
            _mulavarNameController,
            Icons.person_outline,
          ),
          _buildTextField(
            'கோவில் பெயர் (Temple Name)',
            'கோவில் பெயர்...',
            _templeNameController,
            Icons.home_outlined,
          ),
          _buildTextField(
            'தொன்மை (Heritage/Age)',
            'தொன்மை...',
            _heritageController,
            Icons.history,
          ),
        ),
        const SizedBox(height: 16),

        // Row 2: Temple Structure, Sanctum Structure, Number of Tiers Dropdown
        _buildResponsiveThreeRow(
          _buildTextField(
            'கோயில் அமைப்பு (Temple Structure)',
            'கோயில் அமைப்பு...',
            _structureController,
            Icons.architecture,
          ),
          _buildTextField(
            'திருக்கோவில் அமைப்பு (Sanctum Structure)',
            'திருக்கோவில் அமைப்பு...',
            _sanctumController,
            Icons.temple_hindu_outlined,
          ),
          _buildDropdownField(
            'நிலை (Number of Tiers)',
            _selectedTier,
            [_defaultTier, 'மூன்று', 'ஐந்து', 'ஏழு', 'ஒன்பது', 'பதினொன்று'],
            (val) => setState(() => _selectedTier = val!),
          ),
        ),
        const SizedBox(height: 24),

        // Row 3: Worship Type selection, Mandapams dynamic list
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 750;
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorshipTypeSelection(),
                  const SizedBox(height: 24),
                  _buildMandapamsField(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildWorshipTypeSelection()),
                const SizedBox(width: 24),
                Expanded(child: _buildMandapamsField()),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // Rajagopuram Checkbox
        _buildRajagopuramCheckbox(),
        const SizedBox(height: 24),

        // Other Names of Place dynamic list
        _buildOtherNamesField(),
      ],
    );
  }

  Widget _buildDeitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildDeitiesDirectionsSection()],
    );
  }

  Widget _buildHistoryAndSongsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'தல சிறப்பு (Special Features of the Place)',
          'தல சிறப்பு...',
          _specialFeaturesController,
          Icons.stars_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'சிறப்பம்சம் (Unique Characteristics)',
          'சிறப்பம்சம்...',
          _characteristicsController,
          Icons.info_outline,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'தல நடந்த அற்புதங்கள் (Miracles Happened)',
          'தல நடந்த அற்புதங்கள்...',
          _miraclesController,
          Icons.bolt,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'தல வரலாறு (History of the Place)',
          'தல வரலாறு...',
          _historyController,
          Icons.history_edu,
          maxLines: 3,
        ),
        const SizedBox(height: 32),

        // Is Song Place Section
        _buildSongPlaceSection(),
      ],
    );
  }

  Widget _buildCommunityAndDeityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people_alt_outlined, color: Colors.indigo.shade400),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'சமூகம் மற்றும் குலதெய்வம் (Community & Deity Details)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFF1F5F9)),
        const SizedBox(height: 24),

        // Row 1: Community, Sub-Community, Kulam
        _buildResponsiveThreeRow(
          _buildDropdownField(
            'சமூகம் (Select Community) *',
            _selectedCommunity,
            [
              '-- சமூகம் தேர்ந்தெடுக்கவும் --',
              ..._allCommunities.map(
                (e) => e.nameEnglish.isNotEmpty
                    ? '${e.nameTamil} (${e.nameEnglish})'
                    : e.nameTamil,
              ),
            ],
            (val) {
              setState(() {
                _selectedCommunity = val!;
                _selectedSubCommunity = '-- உட்பிரிவு தேர்ந்தெடுக்கவும் --';
                _selectedKulam = '-- குலம் தேர்ந்தெடுக்கவும் --';
                _filteredKulas = [];
                _filteredKulaDeivams = [];
                _filteredVagaiyaras = [];

                if (val != '-- சமூகம் தேர்ந்தெடுக்கவும் --') {
                  try {
                    final comm = _allCommunities.firstWhere(
                      (e) =>
                          (e.nameEnglish.isNotEmpty
                              ? '${e.nameTamil} (${e.nameEnglish})'
                              : e.nameTamil) ==
                          val,
                    );
                    _filteredSubCommunities = _allSubCommunities
                        .where((sc) => sc.communityId == comm.id)
                        .toList();
                  } catch (e) {
                    _filteredSubCommunities = [];
                  }
                } else {
                  _filteredSubCommunities = [];
                }
              });
            },
          ),
          _buildDropdownField(
            'உட்பிரிவு (Sub-Community)',
            _selectedSubCommunity,
            [
              '-- உட்பிரிவு தேர்ந்தெடுக்கவும் --',
              ..._filteredSubCommunities.map(
                (e) => e.nameEnglish.isNotEmpty
                    ? '${e.nameTamil} (${e.nameEnglish})'
                    : e.nameTamil,
              ),
            ],
            (val) {
              setState(() {
                _selectedSubCommunity = val!;
                _selectedKulam = '-- குலம் தேர்ந்தெடுக்கவும் --';
                _filteredKulaDeivams = [];
                _filteredVagaiyaras = [];
                if (val != '-- உட்பிரிவு தேர்ந்தெடுக்கவும் --') {
                  try {
                    final sub = _filteredSubCommunities.firstWhere(
                      (e) =>
                          (e.nameEnglish.isNotEmpty
                              ? '${e.nameTamil} (${e.nameEnglish})'
                              : e.nameTamil) ==
                          val,
                    );
                    _filteredKulas = _allKulas
                        .where((k) => k.subCommunityId == sub.id)
                        .toList();
                  } catch (e) {
                    _filteredKulas = [];
                  }
                } else {
                  _filteredKulas = [];
                }
              });
            },
          ),
          _buildDropdownField(
            'குலம் (Kulam)',
            _selectedKulam,
            [
              '-- குலம் தேர்ந்தெடுக்கவும் --',
              ..._filteredKulas.map(
                (e) => e.nameEnglish.isNotEmpty
                    ? '${e.nameTamil} (${e.nameEnglish})'
                    : e.nameTamil,
              ),
            ],
            (val) {
              setState(() {
                _selectedKulam = val!;
                _selectedVagaiyara = '-- வகையறா தேர்ந்தெடுக்கவும் --';
                _selectedKulaDeivam = null;
                if (val != '-- குலம் தேர்ந்தெடுக்கவும் --') {
                  try {
                    final kulam = _filteredKulas.firstWhere(
                      (e) =>
                          (e.nameEnglish.isNotEmpty
                              ? '${e.nameTamil} (${e.nameEnglish})'
                              : e.nameTamil) ==
                          val,
                    );
                    _filteredKulaDeivams = _allKulaDeivams
                        .where((kd) => kd.kulaId == kulam.id)
                        .toList();
                    _filteredVagaiyaras = _allVagaiyaras
                        .where((v) => v.kulaId == kulam.id)
                        .toList();
                  } catch (e) {
                    _filteredKulaDeivams = [];
                    _filteredVagaiyaras = [];
                  }
                } else {
                  _filteredKulaDeivams = [];
                  _filteredVagaiyaras = [];
                }
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Kula Deivam List Placeholder
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'குல தெய்வம் பட்டியல் (Kula Deivam List) *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'தங்கள் உட்பிரிவிற்குரிய குல தெய்வத்தை தேர்வு செய்யவும்.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            _filteredKulaDeivams.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'குலம் தேர்ந்தெடுத்தவுடன் குலதெய்வம் பட்டியல் காட்டப்படும். (Please select Kulam first)',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _filteredKulaDeivams.map((kd) {
                      final isSelected = _selectedKulaDeivam?.id == kd.id;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedKulaDeivam = kd;
                            // Optionally filter vagaiyaras further based on KulaDeivam
                            _filteredVagaiyaras = _allVagaiyaras
                                .where((v) => v.kulaDeivamId == kd.id)
                                .toList();
                            _selectedVagaiyara =
                                '-- வகையறா தேர்ந்தெடுக்கவும் --';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF524EE1)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? const Color(0xFF524EE1).withOpacity(0.05)
                                : Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kd.deityNameTamil,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (kd.deityNameEnglish.isNotEmpty)
                                Text(
                                  kd.deityNameEnglish,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
        const SizedBox(height: 32),

        // Row 3: Vagaiyara, Tharpothaiya Vagaiyara, Generation
        _buildResponsiveThreeRow(
          _buildDropdownField(
            'வகையறா (Select Vagaiyara)',
            _selectedVagaiyara,
            [
              '-- வகையறா தேர்ந்தெடுக்கவும் --',
              ..._filteredVagaiyaras.map(
                (e) => e.vagaiyaraNameEnglish.isNotEmpty
                    ? '${e.vagaiyaraNameTamil} (${e.vagaiyaraNameEnglish})'
                    : e.vagaiyaraNameTamil,
              ),
            ],
            (val) => setState(() => _selectedVagaiyara = val!),
          ),
          _buildTextField(
            'தற்போதைய வகையறா (Tharpothaiya Vagaiyara)',
            'தற்போதைய வகையறாவை உ...',
            _tharpothaiyaVagaiyaraController,
            Icons.domain,
          ),
          _buildDropdownField(
            'எந்த தலைமுறை (Select Generation)',
            _selectedGeneration,
            [
              '-- தேர்ந்தெடுக்கவும் --',
              '1-ஆம் தலைமுறை (1st Gen)',
              '2-ஆம் தலைமுறை (2nd Gen)',
              '3-ஆம் தலைமுறை (3rd Gen)',
              '4-ஆம் தலைமுறை (4th Gen)',
              '5-ஆம் தலைமுறை (5th Gen)',
              '6-ஆம் தலைமுறை (6th Gen)',
              '7-ஆம் தலைமுறை (7th Gen)',
              '8-ஆம் தலைமுறை (8th Gen)',
              '9-ஆம் தலைமுறை (9th Gen)',
              '10-ஆம் தலைமுறை + (10th Gen+)',
            ],
            (val) => setState(() => _selectedGeneration = val!),
          ),
        ),
        const SizedBox(height: 32),

        // Marital Status
        _buildResponsiveThreeRow(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'திருமணம் நிலை (Select Marital Status)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildRadioOption('Unmarried\n(திருமணமாகாதவர்)', 'Unmarried'),
                  _buildRadioOption('Married\n(திருமணமானவர்)', 'Married'),
                ],
              ),
            ],
          ),
          _selectedMaritalStatus == 'Married'
              ? _buildTextField(
                  'மனைவி பெயர் (Wife\'s Name)',
                  'மனைவி பெயரை உள்ளிடவும்',
                  _wifeNameController,
                  Icons.person_outline,
                )
              : const SizedBox.shrink(),
          _selectedMaritalStatus == 'Married'
              ? _buildTextField(
                  'மனைவியின் குலதெய்வம் (Wife\'s Kula Deivam)',
                  'எ.கா: முனீஸ்வரன் / காளியம்',
                  _wifeKulaDeivamController,
                  Icons.temple_hindu_outlined,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMaritalStatus = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedMaritalStatus,
            onChanged: (String? newValue) {
              setState(() {
                _selectedMaritalStatus = newValue!;
              });
            },
            activeColor: const Color(0xFF524EE1),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E1B4B)),
          ),
        ],
      ),
    );
  }

  // Row builder helper for 3 elements
  Widget _buildResponsiveThreeRow(Widget child1, Widget child2, Widget child3) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        if (isMobile) {
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
    IconData icon, {
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
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
    final validItems = items.contains(selectedValue)
        ? items
        : [...items, selectedValue];
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
              items: validItems.map((String value) {
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

  Widget _buildWorshipTypeSelection() {
    final options = ['குலத்தவர் மட்டும்', 'குலத்தவர் + பொது', 'பொது மட்டும்'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'வழிபாட்டு வகை (Worship Type)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = _selectedWorshipType == option;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedWorshipType = option;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo.shade50 : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF524EE1)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 16,
                      color: isSelected ? const Color(0xFF524EE1) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF1E1B4B)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMandapamsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'மண்டபங்கள் (Mandapams)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mandapamControllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mandapamControllers[index],
                    decoration: InputDecoration(
                      hintText: 'மண்டபத்தின் பெயர்...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.business,
                        size: 18,
                        color: Colors.grey.shade400,
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    if (_mandapamControllers.length > 1) {
                      setState(() {
                        _mandapamControllers[index].dispose();
                        _mandapamControllers.removeAt(index);
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _mandapamControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add More (மேலும் சேர்க்க)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF524EE1),
            side: const BorderSide(color: Color(0xFF524EE1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeitiesDirectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'தெய்வங்கள் மற்றும் திசைகள் (Deities and Directions)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _deityDirectionRows.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final rowData = _deityDirectionRows[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;

                  final deityDropdown = _buildDropdownField(
                    'தெய்வம் (Deity)',
                    rowData['deity'],
                    [
                      _defaultDeity,
                      ..._allDeitySectors.map((e) => e.sectorName),
                    ],
                    (val) {
                      setState(() {
                        rowData['deity'] = val!;
                        if (val != _defaultDeity) {
                          try {
                            final sector = _allDeitySectors.firstWhere(
                              (e) => e.sectorName == val,
                            );
                            final img = sector.imageUrl;
                            if (img != null && img.isNotEmpty) {
                              rowData['api_image'] = img.startsWith('http')
                                  ? img
                                  : 'https://srivagroups.in/uploads/sectors/$img';
                            } else {
                              rowData['api_image'] = null;
                            }
                          } catch (e) {
                            rowData['api_image'] = null;
                          }
                        } else {
                          rowData['api_image'] = null;
                        }
                      });
                    },
                  );

                  final directionDropdown = _buildDropdownField(
                    'திசை (Direction)',
                    rowData['direction'],
                    [
                      _defaultDirection,
                      'கிழக்கு',
                      'மேற்கு',
                      'தெற்கு',
                      'வடக்கு',
                      'வடகிழக்கு',
                      'தென்கிழக்கு',
                      'வடமேற்கு',
                      'தென்மேற்கு',
                    ],
                    (val) => setState(() => rowData['direction'] = val!),
                  );

                  Widget? imagePreview;
                  if (rowData['photo'] != null) {
                    final XFile photoFile = rowData['photo'];
                    imagePreview = kIsWeb
                        ? Image.network(
                            photoFile.path,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(photoFile.path),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          );
                  } else if (rowData['api_image'] != null) {
                    imagePreview = Image.network(
                      rowData['api_image'],
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey,
                      ),
                    );
                  }

                  final photoField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'புகைப்படம் (Photo)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (imagePreview != null)
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: imagePreview,
                                ),
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (rowData['photo'] != null) {
                                          rowData['photo'] = null;
                                        } else {
                                          rowData['api_image'] = null;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (imagePreview != null) const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDeityImage(index),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        imagePreview != null
                                            ? 'Change Photo'
                                            : 'Choose Photo',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        deityDropdown,
                        const SizedBox(height: 12),
                        directionDropdown,
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: photoField),
                            if (_deityDirectionRows.length > 1) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _deityDirectionRows.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: deityDropdown),
                      const SizedBox(width: 12),
                      Expanded(child: directionDropdown),
                      const SizedBox(width: 12),
                      photoField,
                      if (_deityDirectionRows.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _deityDirectionRows.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _deityDirectionRows.add({
                'deity': _defaultDeity,
                'direction': _defaultDirection,
                'photo': null,
              });
            });
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Deity (மேலும் தெய்வம் சேர்க்க)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF524EE1),
            side: const BorderSide(color: Color(0xFF524EE1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRajagopuramCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isRajagopuramDirectionChecked = !_isRajagopuramDirectionChecked;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isRajagopuramDirectionChecked
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: _isRajagopuramDirectionChecked
                      ? const Color(0xFF524EE1)
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'இராஜகோபுரம் திசை (Rajagopuram Direction)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isRajagopuramDirectionChecked) ...[
          const SizedBox(height: 16),
          _buildDropdownField(
            'திசை (Direction)',
            _selectedRajagopuramDirection,
            [
              'கிழக்கு',
              'மேற்கு',
              'தெற்கு',
              'வடக்கு',
              'வடகிழக்கு',
              'தென்கிழக்கு',
              'வடமேற்கு',
              'தென்மேற்கு',
            ],
            (val) => setState(() => _selectedRajagopuramDirection = val!),
          ),
        ],
      ],
    );
  }

  Widget _buildOtherNamesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'தல வேறு பெயர்கள் (Other Names of the Place)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _otherNameControllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otherNameControllers[index],
                    decoration: InputDecoration(
                      hintText: 'தல வேறு பெயர்...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.bookmark_outline,
                        size: 18,
                        color: Colors.grey.shade400,
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    if (_otherNameControllers.length > 1) {
                      setState(() {
                        _otherNameControllers[index].dispose();
                        _otherNameControllers.removeAt(index);
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _otherNameControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add More (மேலும் சேர்க்க)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF524EE1),
            side: const BorderSide(color: Color(0xFF524EE1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongPlaceSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isSongPlaceChecked = !_isSongPlaceChecked;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isSongPlaceChecked
                          ? Colors.green.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isSongPlaceChecked
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _isSongPlaceChecked
                                ? const Color(0xFF524EE1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _isSongPlaceChecked
                                  ? const Color(0xFF524EE1)
                                  : Colors.grey.shade400,
                            ),
                          ),
                          child: _isSongPlaceChecked
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.music_note,
                          size: 18,
                          color: _isSongPlaceChecked
                              ? Colors.green
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'பாடல் பெற்ற ஸ்தலமா (Is song place?)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _isSongPlaceChecked
                                  ? Colors.green.shade700
                                  : const Color(0xFF1E1B4B),
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
          if (_isSongPlaceChecked) ...[
            const SizedBox(height: 24),
            _buildResponsiveRow(
              _buildTextField(
                'பாடல் பாடியவர் (Song Sung By)',
                'பாடியவர் பெயர்...',
                _songSungByController,
                Icons.person_outline,
              ),
              _buildTextField(
                'எந்தப் பதி (Which Pathi)',
                'எந்தப் பதி / பகுதி...',
                _whichPathiController,
                Icons.pin_drop_outlined,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'பாடல் குறிப்பு (Song Note)',
              'பாடல் குறிப்பு...',
              _songNoteController,
              Icons.note_alt_outlined,
              maxLines: 3,
            ),
          ],
        ],
      ),
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

  Future<void> _saveTempleDetails() async {
    if (widget.basicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID காணவில்லை! சேமிக்க முடியாது.')),
      );
      return;
    }

    // Construct payload
    final payload = {
      'temple_basic_id': widget.initialData?['temple_basic_id'] ?? widget.basicId,
      'heritage': _heritageController.text,
      'temple_structure': _structureController.text,
      'sanctum_structure': _sanctumController.text,
      'special_features': _specialFeaturesController.text,
      'characteristics': _characteristicsController.text,
      'miracles': _miraclesController.text,
      'history': _historyController.text,
      'status': _selectedTier,
      'worship_type': _selectedWorshipType,
      'rajagopuram_direction': _isRajagopuramDirectionChecked ? _selectedRajagopuramDirection : '',
      'song_place': _isSongPlaceChecked,
      'padal_padiyavar': _songSungByController.text,
      'entha_pathi': _whichPathiController.text,
      'song_note': _songNoteController.text,
      'mandapams': _mandapamControllers.map((c) => c.text).join(', '),
      'other_names': _otherNameControllers.map((c) => c.text).join(', '),
      'theivankal': _deityDirectionRows.map((d) => {
        'deivam': d['deity'],
        'thesai': d['direction'],
        'photo': d['api_image'] ?? '',
      }).toList(),
      'active': 1,
    };

    final repository = ref.read(kovilApiRepositoryProvider);
    final success = await repository.updateTempleDetails(
      widget.basicId!,
      payload,
    );

    if (mounted) {
      if (success) {
        await CustomDeleteDialog.showSuccess(context, title: 'வெற்றிகரமாக மாற்றப்பட்டது', message: 'Update successful');
        // Maybe close dialog or clear form
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('கோவில் விவரங்களை சேமிப்பதில் பிழை ஏற்பட்டது!'),
          ),
        );
      }
    }
  }

  Widget _buildFormActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final backButton = OutlinedButton(
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              _clearForm();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(_currentStep == 0 ? 'Back' : 'Previous Step'),
        );

        final saveButton = ElevatedButton.icon(
          onPressed: () {
            if (_currentStep < 3) {
              setState(() {
                _currentStep++;
              });
            } else {
              _saveTempleDetails();
            }
          },
          icon: Icon(
            _currentStep == 3 ? Icons.save_as_outlined : Icons.arrow_forward,
            size: 18,
          ),
          label: Text(_currentStep == 3 ? 'Save Temple Details' : 'Next Step'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF524EE1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        );

        if (isMobile) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: backButton),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: saveButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: backButton),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: saveButton),
          ],
        );
      },
    );
  }
}
