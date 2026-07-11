import 'package:flutter/material.dart';
import '../../kulam/presentation/vagaiyara_manage_content.dart';
import '../../../core/network/api_client.dart';
import '../data/paktharkal_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import 'package:kulatheivam/core/widgets/searchable_dropdown.dart';

class KulamMakkalContent extends StatefulWidget {
  const KulamMakkalContent({super.key});

  @override
  State<KulamMakkalContent> createState() => _KulamMakkalContentState();
}

class _KulamMakkalContentState extends State<KulamMakkalContent> {
  final ScrollController _scrollController = ScrollController();

  // Step variables
  int _currentStep = 0;

  // Form controllers & State
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late final PaktharkalApiRepository _apiRepository;
  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  int? _editingId;

  // Step 1
  List<Map<String, dynamic>> _vagaiyaraList = [];
  String? _selectedVagairaId;
  String _familyType = 'muthaiya';

  // Step 2
  List<Map<String, dynamic>> _members = [];

  // Step 3
  String _deceasedStatus = 'இல்லை (No)';
  List<Map<String, dynamic>> _deceasedMembers = [];

  @override
  void initState() {
    super.initState();
    _apiRepository = PaktharkalApiRepository(ApiClient());
    _addMember(); // Add first member by default
    _fetchRecords();
  }

  void _addMember() {
    setState(() {
      _members.add({
        'phone': TextEditingController(),
        'name': TextEditingController(),
        'relation': '-- தேர்ந்தெடுக்கவும் --',
      });
    });
  }

  void _addDeceasedMember() {
    setState(() {
      _deceasedMembers.add({
        'name': TextEditingController(),
        'generation_no': '-- தேர்ந்தெடுக்கவும் --',
        'status': 'இயற்கை எய்தியவர்',
      });
    });
  }

  void _removeMember(int index) {
    setState(() {
      _members[index]['phone'].dispose();
      _members[index]['name'].dispose();
      _members.removeAt(index);
    });
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final vagaiyaras = await _apiRepository.getVagaiyaras();
      final data = await _apiRepository.getKullamPeople();
      setState(() {
        _vagaiyaraList = vagaiyaras;
        if (_vagaiyaraList.isNotEmpty && _selectedVagairaId == null) {
          _selectedVagairaId = _vagaiyaraList.first['id']?.toString();
        }
        _records = data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _apiRepository.deleteKullamPeople(id);
    if (success) {
      await CustomDeleteDialog.showDeleted(context);
      _fetchRecords();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('பிழை ஏற்பட்டது!')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _currentStep = 0;
      if (_vagaiyaraList.isNotEmpty) {
        _selectedVagairaId = _vagaiyaraList.first['id']?.toString();
      } else {
        _selectedVagairaId = null;
      }
      _nicknameController.clear();
      _familyType = 'muthaiya';

      // Dispose old controllers
      for (var m in _members) {
        m['phone'].dispose();
        m['name'].dispose();
      }
      for (var dm in _deceasedMembers) {
        dm['name'].dispose();
      }
      _members.clear();
      _deceasedMembers.clear();
      _addMember();

      _deceasedStatus = 'இல்லை (No)';
      _editingId = null;
    });
  }

  Future<void> _saveOrUpdate() async {
    if (_selectedVagairaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('வகைராவை தேர்ந்தெடுக்கவும்')),
      );
      return;
    }
    setState(() => _isLoading = true);

    // Prepare Data for API (Modified for new schema)
    final data = {
      'vagaiyara': _selectedVagairaId,
      'vagaiyara_nickname': _nicknameController.text.trim(),
      'family_type': _familyType,
      'parent_family_id': null,
      'status': 'active',
      'family_members': _members.map((m) {
        int gen = 1;
        final relStr = m['relation']?.toString() ?? '1';
        if (relStr.contains(' ')) {
          gen = int.tryParse(relStr.split(' ')[0]) ?? 1;
        } else {
          gen = int.tryParse(relStr) ?? 1;
        }
        return {
          'phone_number': m['phone'].text.trim(),
          'member_name': m['name'].text.trim(),
          'generation_no': gen.toString(),
        };
      }).toList(),
      'eerapu_members': _deceasedStatus == 'ஆம் (Yes)'
          ? _deceasedMembers.map((dm) {
              int gen = 1;
              final relStr = dm['generation_no']?.toString() ?? '1';
              if (relStr.contains(' ')) {
                gen = int.tryParse(relStr.split(' ')[0]) ?? 1;
              } else {
                gen = int.tryParse(relStr) ?? 1;
              }
              return {
                'name': dm['name'].text.trim(),
                'kula_deivam_id': null,
                'generation_no': gen.toString(),
                'status': dm['status'] ?? 'இயற்கை எய்தியவர்',
              };
            }).toList()
          : [],
    };

    bool success;
    if (_editingId == null) {
      success = await _apiRepository.addKullamPeople(data);
    } else {
      success = await _apiRepository.updateKullamPeople(_editingId!, data);
    }

    if (success) {
      if (mounted) {
        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
      }
      _clearForm();
      _fetchRecords();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('பிழை ஏற்பட்டது!')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _searchController.dispose();
    for (var m in _members) {
      m['phone'].dispose();
      m['name'].dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          _buildStepperCard(),
          const SizedBox(height: 24),
          _buildListCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Colors.indigo,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'பரம்பரையாக ஒரே ஊர் வசிப்பவர்கள்',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'கோவிலின் குல மக்கள் மற்றும் உறுப்பினர்களின் விவரங்களை இங்கே நிர்வகிக்கலாம்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  Widget _buildStepperCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue.shade600,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'புதிய குடும்பத்தை சேர்க்க (Add New Family)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Step ${_currentStep + 1} of 3',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(),
                const SizedBox(height: 32),

                // Form Content Based on Step
                if (_currentStep == 0) _buildStep1(),
                if (_currentStep == 1) _buildStep2(),
                if (_currentStep == 2) _buildStep3(),

                const SizedBox(height: 28),

                // Bottom Navigation
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 16,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _clearForm,
                      icon: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                      label: Text(
                        'Clear/Reset',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: () {
                              setState(() => _currentStep--);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Back (முந்தைய)',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _saveOrUpdate();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentStep < 2
                                ? const Color(0xFF524EE1)
                                : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading && _currentStep == 2
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentStep < 2
                                      ? 'Next (அடுத்து)'
                                      : 'Save (சேமிக்கவும்)',
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          return Row(
            children: [
              _buildStepIndicator(
                0,
                'அடிப்படை விவரங்கள்',
                'Family Basics',
                isSmall,
              ),
              _buildConnector(0),
              _buildStepIndicator(
                1,
                'குடும்ப கட்டமைப்பு',
                'Members & Gen',
                isSmall,
              ),
              _buildConnector(1),
              _buildStepIndicator(
                2,
                'இறப்பு விவரங்கள்',
                'Deceased Details',
                isSmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnector(int stepIndex) {
    final isActive = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 4,
        color: isActive ? const Color(0xFF524EE1) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepIndicator(
    int stepIndex,
    String title,
    String subtitle,
    bool isSmall,
  ) {
    final isActive = _currentStep >= stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF524EE1) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF524EE1) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (!isSmall) ...[
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF1E1B4B) : Colors.grey.shade500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ],
    );
  }

  // --- STEP 1 ---
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (ctx, bc) {
            if (bc.maxWidth < 600) {
              return Column(
                children: [
                  _vagairaDropdown(),
                  const SizedBox(height: 16),
                  _textField(
                    'குடும்பத்தின் பட்டப்பெயர் (Family Nickname) *',
                    'Nickname...',
                    _nicknameController,
                    Icons.local_offer_outlined,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _vagairaDropdown()),
                const SizedBox(width: 16),
                Expanded(
                  child: _textField(
                    'குடும்பத்தின் பட்டப்பெயர் (Family Nickname) *',
                    'Nickname...',
                    _nicknameController,
                    Icons.local_offer_outlined,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'குடும்ப வகை (Family Type) *',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: LayoutBuilder(
            builder: (ctx, bc) {
              final isSmall = bc.maxWidth < 500;
              final child1 = Material(
                color: Colors.transparent,
                child: RadioListTile<String>(
                  title: const Text(
                    'முத்தையா வகைரா (Original Family)',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: 'muthaiya',
                  groupValue: _familyType,
                  activeColor: const Color(0xFF524EE1),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) setState(() => _familyType = val);
                  },
                ),
              );
              final child2 = Material(
                color: Colors.transparent,
                child: RadioListTile<String>(
                  title: const Text(
                    'தற்போதைய வகைரா (Branch Family)',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: 'current',
                  groupValue: _familyType,
                  activeColor: const Color(0xFF524EE1),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) setState(() => _familyType = val);
                  },
                ),
              );

              if (isSmall) {
                return Column(children: [child1, child2]);
              }
              return Row(
                children: [
                  Expanded(child: child1),
                  Expanded(child: child2),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --- STEP 2 ---
  Widget _buildStep2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                    Icon(
                      Icons.people_alt_outlined,
                      color: Colors.blue.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'குடும்ப உறுப்பினர்கள் (Family Members)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _addMember,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Member'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF524EE1),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_members.length, (index) {
            return _buildMemberRow(index);
          }),
        ],
      ),
    );
  }

  Widget _buildMemberRow(int index) {
    final member = _members[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (ctx, bc) {
          if (bc.maxWidth < 600) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildMemberField(
                    'தொலைபேசி எண் (Phone Number)',
                    member['phone'],
                  ),
                  const SizedBox(height: 12),
                  _buildMemberField(
                    'உறுப்பினர் பெயர் (Member Name)',
                    member['name'],
                  ),
                  const SizedBox(height: 12),
                  _buildRelationDropdown(member, index),
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: _buildMemberField(
                  'தொலைபேசி எண் (Phone Number)',
                  member['phone'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildMemberField(
                  'உறுப்பினர் பெயர் (Member Name)',
                  member['name'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _buildRelationDropdown(member, index)),
              const SizedBox(width: 8),
              if (_members.length > 1)
                IconButton(
                  onPressed: () => _removeMember(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove',
                )
              else
                const SizedBox(width: 48), // placeholder to align
            ],
          );
        },
      ),
    );
  }

  Widget _buildMemberField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
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

  Widget _buildRelationDropdown(Map<String, dynamic> member, int index) {
    final List<String> relations = [
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
    ];

    if (!relations.contains(member['relation'])) {
      member['relation'] = relations.first;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: member['relation'],
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          items: relations.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: value.startsWith('--')
                      ? Colors.grey.shade600
                      : Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => member['relation'] = val);
            }
          },
        ),
      ),
    );
  }

  // --- STEP 3 ---
  Widget _buildStep3() {
    final List<String> statuses = [
      '-- தேர்ந்தெடுக்கவும் (Select Status) --',
      'இல்லை (No)',
      'ஆம் (Yes)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'இறப்பு நிலை (Select Deceased Status)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 400, // Matching standard dropdown width in previous rows
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _deceasedStatus,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: statuses.map((String value) {
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
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _deceasedStatus = val;
                    if (_deceasedStatus == 'ஆம் (Yes)' &&
                        _deceasedMembers.isEmpty) {
                      _addDeceasedMember();
                    }
                  });
                }
              },
            ),
          ),
        ),
        if (_deceasedStatus == 'ஆம் (Yes)') ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
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
                          Icon(
                            Icons.person_off_outlined,
                            color: Colors.red.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'இறந்த உறுப்பினர்கள் (Deceased Members)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addDeceasedMember,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Member'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(_deceasedMembers.length, (index) {
                  return _buildDeceasedMemberRow(index);
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeceasedMemberRow(int index) {
    final member = _deceasedMembers[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (ctx, bc) {
          if (bc.maxWidth < 600) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  _buildMemberField('பெயர் (Name)', member['name']),
                  const SizedBox(height: 12),
                  _buildDeceasedGenerationDropdown(member, index),
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: _buildMemberField('பெயர் (Name)', member['name']),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildDeceasedGenerationDropdown(member, index),
              ),
              if (_deceasedMembers.length > 1) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () =>
                      setState(() => _deceasedMembers.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove',
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeceasedGenerationDropdown(
    Map<String, dynamic> member,
    int index,
  ) {
    final List<String> relations = [
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
    ];

    if (!relations.contains(member['generation_no'])) {
      member['generation_no'] = '-- தேர்ந்தெடுக்கவும் --';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'தலைமுறை (Generation) *',
          style: const TextStyle(
            fontSize: 12,
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
              value: member['generation_no'],
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: relations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: value.startsWith('--')
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => member['generation_no'] = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard() {
    final q = _searchController.text.toLowerCase();
    final filtered = _records
        .where(
          (r) =>
              q.isEmpty ||
              (r['vagaiyara']?.toString().toLowerCase().contains(q) ?? false) ||
              (r['vagaiyara_nickname']?.toString().toLowerCase().contains(q) ??
                  false) ||
              (r['family_type']?.toString().toLowerCase().contains(q) ?? false),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
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
                    Icon(Icons.list, color: Colors.grey.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'உறுப்பினர்கள் பட்டியல் (Member Directory)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'தேடல்...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
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
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.grey.shade200),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columnSpacing: 40,
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'வகைரா & குடும்பத்தின் பட்டப்பெயர்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'குடும்ப விவரங்கள்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ACTIONS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                ],
                rows: filtered
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              r['id']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.people_alt_outlined,
                                    size: 16,
                                    color: Colors.indigo.shade500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      r['vagaiyara']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_offer_outlined,
                                          size: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          r['family_nickname']?.toString() ??
                                              '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  r['family_type']?.toString() == 'muthaiya'
                                      ? 'முத்தையா வகைரா'
                                      : 'தற்போதைய வகைரா',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Members: ${(r['family_members'] as List?)?.length ?? 0}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _actionButton(
                                  icon: Icons.edit_outlined,
                                  onTap: () {
                                    setState(() {
                                      _editingId = r['id'];
                                      _selectedVagairaId = r['vagaiyara_id']
                                          ?.toString();
                                      _nicknameController.text =
                                          r['family_nickname']?.toString() ??
                                          '';
                                      _familyType =
                                          r['family_type']?.toString() ??
                                          'muthaiya';
                                      // Load members
                                      _members.clear();
                                      if (r['family_members'] != null &&
                                          r['family_members'] is List) {
                                        for (var m in r['family_members']) {
                                          _members.add({
                                            'phone': TextEditingController(
                                              text:
                                                  m['phone_number']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                            'name': TextEditingController(
                                              text:
                                                  m['member_name']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                            'relation':
                                                '${m['generation_no'] ?? 1} (தலைமுறை)',
                                          });
                                        }
                                      }
                                      if (_members.isEmpty) {
                                        _addMember();
                                      }

                                      // Load Deceased Members
                                      _deceasedMembers.clear();
                                      if (r['eerapu_members'] != null &&
                                          r['eerapu_members'] is List &&
                                          (r['eerapu_members'] as List)
                                              .isNotEmpty) {
                                        _deceasedStatus = 'ஆம் (Yes)';
                                        for (var dm in r['eerapu_members']) {
                                          _deceasedMembers.add({
                                            'name': TextEditingController(
                                              text:
                                                  dm['name']?.toString() ?? '',
                                            ),
                                            'generation_no':
                                                '${dm['generation_no'] ?? 1} (தலைமுறை)',
                                            'status':
                                                dm['status']?.toString() ??
                                                'இயற்கை எய்தியவர்',
                                          });
                                        }
                                      } else {
                                        _deceasedStatus = 'இல்லை (No)';
                                      }
                                      _currentStep = 0;
                                    });
                                    _scrollController.animateTo(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _actionButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  onTap: () => _deleteRecord(r['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color ?? Colors.grey.shade700),
      ),
    );
  }

  Widget _vagairaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                text: 'வகைரா (Select Vagaiyara) ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
                children: [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final tabController = DefaultTabController.of(context);
                if (tabController != null) {
                  tabController.animateTo(5); // Index 5 is 'வகைரா'
                }
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.add,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'சேர்க்க',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SearchableDropdown(
          items: _vagaiyaraList,
          hint: 'வகைரா தேர்ந்தெடுக்கவும்',
          displayBuilder: (v) {
            final t = v['our_gen_name_tamil'] ?? v['vagaiyara_name_tamil'] ?? 'Unknown';
            final e = v['our_gen_name_english'] ?? v['vagaiyara_name_english'] ?? '';
            return e.toString().isNotEmpty ? '$t ($e)' : t;
          },
          valueKey: 'id',
          selectedValue: _selectedVagairaId,
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedVagairaId = val);
            }
          },
          searchTitle: 'வகைரா (Select Vagaiyara)',
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
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
}
