import 'package:flutter/material.dart';
import 'package:kulatheivam/core/network/api_client.dart';
import 'package:kulatheivam/features/kulam/data/kulam_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class KulaDeivamWorshipContent extends StatefulWidget {
  final Function(String screenName)? onScreenSelected;

  const KulaDeivamWorshipContent({super.key, this.onScreenSelected});

  @override
  State<KulaDeivamWorshipContent> createState() =>
      _KulaDeivamWorshipContentState();
}

class _KulaDeivamWorshipContentState extends State<KulaDeivamWorshipContent> {
  final KulamApiRepository _apiRepository = KulamApiRepository(ApiClient());

  String? selectedCommunity;
  String? selectedSubCommunity;
  String? selectedKulam;
  String? selectedVagaiyara;
  String? selectedDeity;
  String? selectedGeneration;
  
  final TextEditingController _currentVagaiyaraController = TextEditingController();

  int _currentStep = 1;
  String? maritalStatus;
  String wifeName = '';
  String wifeDeity = '';

  List<dynamic> communities = [];
  List<dynamic> subCommunities = [];
  List<dynamic> kulas = [];
  List<dynamic> kulaDeivams = [];
  List<dynamic> vagaiyaras = [];
  List<dynamic> communitySelections = [];
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _currentVagaiyaraController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      final comms = await _apiRepository.fetchCommunities();
      final subComms = await _apiRepository.fetchSubCommunities();
      final fetchedKulas = await _apiRepository.fetchKulas();
      final fetchedDeivams = await _apiRepository.fetchKulaDeivams();
      final fetchedVagaiyaras = await _apiRepository.fetchVagaiyaras();
      final fetchedSelections = await _apiRepository.fetchCommunitySelections();

      setState(() {
        communities = comms;
        subCommunities = subComms;
        kulas = fetchedKulas;
        kulaDeivams = fetchedDeivams;
        vagaiyaras = fetchedVagaiyaras;
        communitySelections = fetchedSelections;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
              Icon(Icons.people_outline, color: Colors.indigo, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'குலதெய்வம் வழிபாடு',
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
            'சமூகம், உட்பிரிவு, குலதெய்வம், வகையறா மற்றும் குடும்ப திருமண விவரங்களை உள்ளிடும் படிவம்.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Custom Stepper
          _buildStepper(),

          const SizedBox(height: 32),

          // Active Step Content
          _buildActiveStep(),

          const SizedBox(height: 32),
          
          // Registered Submissions Database
          _buildRegisteredSubmissions(),
        ],
      ),
    );
  }

  Widget _buildActiveStep() {
    if (_currentStep == 1) return _buildStep1();
    if (_currentStep == 2) return _buildStep2();
    if (_currentStep == 3) return _buildStep3();
    return const SizedBox(); 
  }

  Widget _buildStep1() {
    return Container(
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
                // Step Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF524EE1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Text(
                            'சமூகம் & குலதெய்வம் (Community & Deity Details)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Text(
                              'தேவை',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Form Fields Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        children: [
                          _buildDropdownField(
                            label: 'சமூகம் (Select Community)',
                            isRequired: true,
                            items: communities,
                            hint: '-- சமூகம் தேர்ந்தெடுக்கவும் (Select Community) --',
                            displayBuilder: (item) {
                              final tamil = item['community_name_tamil'] ?? '';
                              final english = item['community_name_english'] ?? '';
                              if (english.toString().isNotEmpty) {
                                return '$tamil ($english)';
                              }
                              return tamil.toString();
                            },
                            valueKey: 'id',
                            selectedValue: selectedCommunity,
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                                selectedSubCommunity = null;
                                selectedKulam = null;
                                selectedDeity = null;
                                selectedVagaiyara = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            label: 'உட்பிரிவு (Select Sub-Community)',
                            isRequired: false,
                            items: subCommunities.where((s) => s['community_id'].toString() == selectedCommunity).toList(),
                            hint: '-- உட்பிரிவு தேர்ந்தெடுக்கவும் (Select Sub-Community) --',
                            displayBuilder: (item) {
                              final tamil = item['sub_community_name_tamil'] ?? '';
                              final english = item['sub_community_name_english'] ?? '';
                              if (english.toString().isNotEmpty) {
                                return '$tamil ($english)';
                              }
                              return tamil.toString();
                            },
                            valueKey: 'id',
                            selectedValue: selectedSubCommunity,
                            onChanged: (val) {
                              setState(() {
                                selectedSubCommunity = val;
                                selectedKulam = null;
                                selectedDeity = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            label: 'குலம் (Kulam)',
                            isRequired: false,
                            items: kulas.where((k) => k['sub_community_id'].toString() == selectedSubCommunity).toList(),
                            hint: '-- குலம் தேர்ந்தெடுக்கவும் (Select Kulam) --',
                            displayBuilder: (item) {
                              final tamil = item['kula_name_tamil'] ?? '';
                              final english = item['kula_name_english'] ?? '';
                              if (english.toString().isNotEmpty) {
                                return '$tamil ($english)';
                              }
                              return tamil.toString();
                            },
                            valueKey: 'id',
                            selectedValue: selectedKulam,
                            onChanged: (val) {
                              setState(() {
                                selectedKulam = val;
                                selectedDeity = null;
                              });
                            },
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'சமூகம் (Select Community)',
                            isRequired: true,
                            items: communities,
                            hint: '-- சமூகம் தேர்ந்தெடுக்கவும் --',
                            displayBuilder: (item) {
                              final tamil = item['community_name_tamil'] ?? '';
                              final english = item['community_name_english'] ?? '';
                              if (english.toString().isNotEmpty) {
                                return '$tamil ($english)';
                              }
                              return tamil.toString();
                            },
                            valueKey: 'id',
                            selectedValue: selectedCommunity,
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                                selectedSubCommunity = null;
                                selectedKulam = null;
                                selectedDeity = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'உட்பிரிவு (Select Sub-Community)',
                            isRequired: false,
                            items: subCommunities.where((s) => s['community_id'].toString() == selectedCommunity).toList(),
                            hint: '-- உட்பிரிவு தேர்ந்தெடுக்கவும் (Select Sub-Community) --',
                            displayBuilder: (item) {
                              final tamil = item['sub_community_name_tamil'] ?? '';
                              final english = item['sub_community_name_english'] ?? '';
                              if (english.toString().isNotEmpty) {
                                return '$tamil ($english)';
                              }
                              return tamil.toString();
                            },
                            valueKey: 'id',
                            selectedValue: selectedSubCommunity,
                            onChanged: (val) {
                              setState(() {
                                selectedSubCommunity = val;
                                selectedKulam = null;
                                selectedDeity = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'குலம் (Kulam)',
                            isRequired: false,
                            items: kulas.where((k) => k['sub_community_id'].toString() == selectedSubCommunity).toList(),
                            hint: '-- குலம் தேர்ந்தெடுக்கவும் (Select Kulam) --',
                            displayBuilder: (item) {
                              final tamil = item['kula_name_tamil'] ?? '';
                              final english = item['kula_name_english'] ?? '';
                              if (english.toString().isNotEmpty) {
                                return '$tamil ($english)';
                              }
                              return tamil.toString();
                            },
                            valueKey: 'id',
                            selectedValue: selectedKulam,
                            onChanged: (val) {
                              setState(() {
                                selectedKulam = val;
                                selectedDeity = null;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Deities Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'குல தெய்வம் பட்டியல் (Kula Deivam List) ',
                              style: TextStyle(
                                fontSize: 14,
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
                          const SizedBox(height: 4),
                          Text(
                            'தங்கள் உட்பிரிவிற்குரிய குல தெய்வத்தை தேர்வு செய்யவும்.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (widget.onScreenSelected != null) {
                                widget.onScreenSelected!('குல தெய்வம்');
                              }
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('தெய்வம் சேர்க்க'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'குல தெய்வம் பட்டியல் (Kula Deivam List) ',
                                  style: TextStyle(
                                    fontSize: 14,
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
                              const SizedBox(height: 4),
                              Text(
                                'தங்கள் உட்பிரிவிற்குரிய குல தெய்வத்தை தேர்வு செய்யவும்.',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onScreenSelected != null) {
                              widget.onScreenSelected!('குல தெய்வம்');
                            }
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('தெய்வம் சேர்க்க'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                if (selectedCommunity == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'சமூகம் தேர்ந்தெடுத்தவுடன் குலதெய்வம் பட்டியல் காட்டப்படும். (Please select community first)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Builder(builder: (context) {
                    var filteredDeities = kulaDeivams.where((d) => d['community_id'].toString() == selectedCommunity).toList();
                    if (selectedSubCommunity != null) {
                      filteredDeities = filteredDeities.where((d) {
                        final subId = d['sub_community_id'].toString();
                        return subId == selectedSubCommunity || subId == '0' || subId == 'null';
                      }).toList();
                    }
                    if (selectedKulam != null) {
                      filteredDeities = filteredDeities.where((d) {
                        final kulaId = d['kula_id'].toString();
                        return kulaId == selectedKulam || kulaId == '0' || kulaId == 'null';
                      }).toList();
                    }

                    if (filteredDeities.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'தெய்வங்கள் எதுவும் கிடைக்கவில்லை.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 1 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: isMobile ? 90 : 80,
                          ),
                          itemCount: filteredDeities.length,
                          itemBuilder: (context, index) {
                            final deity = filteredDeities[index];
                            final isSelected = selectedDeity == deity['id'].toString();
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDeity = deity['id'].toString();
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF524EE1) : Colors.grey.shade300,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (deity['image_path'] != null && deity['image_path'].toString().isNotEmpty) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          'https://temple.jobes24x7.com/api/uploads/${deity['image_path']}',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 48,
                                            height: 48,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            deity['deity_name_tamil'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? const Color(0xFF1E1B4B) : Colors.black87,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (deity['deity_name_english'] != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              deity['deity_name_english'],
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check_circle, color: Color(0xFF524EE1), size: 20),
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    );
                  }),
                
                const SizedBox(height: 32),
                
                // Next Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: (selectedCommunity != null && selectedKulam != null && selectedDeity != null) 
                          ? () {
                              setState(() {
                                _currentStep = 2;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF524EE1),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'அடுத்தது (Next) >',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStep2() {
    return Container(
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
          // Step Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF524EE1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'வகையறா & உறைவிடம் (Vagaiyara & Places)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'பூர்த்தி செய்யப்பட்டது',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Form Fields Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Column(
                  children: [
                    _buildDropdownField(
                      label: 'முந்தைய வகையரா (Muthaiya Vagaiyara)',
                      isRequired: true,
                      items: vagaiyaras.where((v) => v['community_id'].toString() == selectedCommunity).toList(),
                      hint: '-- வகையறா தேர்ந்தெடுக்கவும் --',
                      displayBuilder: (item) {
                        final tamil = item['vagaiyara_name_tamil'] ?? '';
                        final english = item['vagaiyara_name_english'] ?? '';
                        if (english.toString().isNotEmpty) {
                          return '$tamil ($english)';
                        }
                        return tamil.toString();
                      },
                      valueKey: 'id',
                      selectedValue: selectedVagaiyara,
                      onChanged: (val) {
                        setState(() {
                          selectedVagaiyara = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'தற்போதைய வகையறா (Tharpothaiya Vagaiyara)',
                      isRequired: true,
                      hint: 'தற்போதைய வகையராவை உள்ளிடவும்',
                      controller: _currentVagaiyaraController,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'எந்த தலைமுறை (Select Generation)',
                      isRequired: true,
                      items: [
                        {'id': '1', 'title': '1-ஆம் தலைமுறை (1st Gen)'},
                        {'id': '2', 'title': '2-ஆம் தலைமுறை (2nd Gen)'},
                        {'id': '3', 'title': '3-ஆம் தலைமுறை (3rd Gen)'},
                        {'id': '4', 'title': '4-ஆம் தலைமுறை (4th Gen)'},
                        {'id': '5', 'title': '5-ஆம் தலைமுறை (5th Gen)'},
                        {'id': '6', 'title': '6-ஆம் தலைமுறை (6th Gen)'},
                        {'id': '7', 'title': '7-ஆம் தலைமுறை (7th Gen)'},
                        {'id': '8', 'title': '8-ஆம் தலைமுறை (8th Gen)'},
                        {'id': '9', 'title': '9-ஆம் தலைமுறை (9th Gen)'},
                        {'id': '10', 'title': '10-ஆம் தலைமுறை + (10th Gen+)'},
                      ],
                      hint: '-- தலைமுறை தேர்ந்தெடுக்கவும் --',
                      displayBuilder: (item) => item['title']?.toString() ?? '',
                      valueKey: 'id',
                      selectedValue: selectedGeneration,
                      onChanged: (val) {
                        setState(() {
                          selectedGeneration = val;
                        });
                      },
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'முந்தைய வகையரா (Muthaiya Vagaiyara)',
                      isRequired: true,
                      items: vagaiyaras.where((v) => v['community_id'].toString() == selectedCommunity).toList(),
                      hint: '-- வகையறா தேர்ந்தெடுக்கவும் --',
                      displayBuilder: (item) {
                        final tamil = item['vagaiyara_name_tamil'] ?? '';
                        final english = item['vagaiyara_name_english'] ?? '';
                        if (english.toString().isNotEmpty) {
                          return '$tamil ($english)';
                        }
                        return tamil.toString();
                      },
                      valueKey: 'id',
                      selectedValue: selectedVagaiyara,
                      onChanged: (val) {
                        setState(() {
                          selectedVagaiyara = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'தற்போதைய வகையறா (Tharpothaiya Vagaiyara)',
                      isRequired: true,
                      hint: 'தற்போதைய வகையராவை உள்ளிடவும்',
                      controller: _currentVagaiyaraController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'எந்த தலைமுறை (Select Generation)',
                      isRequired: true,
                      items: [
                        {'id': '1', 'title': '1-ஆம் தலைமுறை (1st Gen)'},
                        {'id': '2', 'title': '2-ஆம் தலைமுறை (2nd Gen)'},
                        {'id': '3', 'title': '3-ஆம் தலைமுறை (3rd Gen)'},
                        {'id': '4', 'title': '4-ஆம் தலைமுறை (4th Gen)'},
                        {'id': '5', 'title': '5-ஆம் தலைமுறை (5th Gen)'},
                        {'id': '6', 'title': '6-ஆம் தலைமுறை (6th Gen)'},
                        {'id': '7', 'title': '7-ஆம் தலைமுறை (7th Gen)'},
                        {'id': '8', 'title': '8-ஆம் தலைமுறை (8th Gen)'},
                        {'id': '9', 'title': '9-ஆம் தலைமுறை (9th Gen)'},
                        {'id': '10', 'title': '10-ஆம் தலைமுறை + (10th Gen+)'},
                      ],
                      hint: '-- தலைமுறை தேர்ந்தெடுக்கவும் --',
                      displayBuilder: (item) => item['title']?.toString() ?? '',
                      valueKey: 'id',
                      selectedValue: selectedGeneration,
                      onChanged: (val) {
                        setState(() {
                          selectedGeneration = val;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Registered Submissions Note (Static for now)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final searchBox = Container(
                width: isMobile ? double.infinity : 250,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('தேடல் (சமூகம், குலதெய்வம், வகையறா...', style: TextStyle(color: Colors.grey.shade400, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );

              final textInfo = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_box, color: Colors.blue.shade400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'பதிவு செய்யப்பட்ட பட்டியல்கள் (Registered Submissions - Database)\n',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B), fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'தரவுத்தளத்தில் சேமிக்கப்பட்ட படிவங்களின் பதிவுகள். (Saved dynamically in Database)',
                            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textInfo,
                    const SizedBox(height: 16),
                    searchBox,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: textInfo),
                  const SizedBox(width: 16),
                  searchBox,
                ],
              );
            }
          ),

          const SizedBox(height: 32),

          // Actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 16,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('முந்தையது (Back)'),
              ),
              ElevatedButton(
                onPressed: (selectedVagaiyara != null && _currentVagaiyaraController.text.trim().isNotEmpty && selectedGeneration != null)
                    ? () {
                        setState(() {
                          _currentStep = 3;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF524EE1),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'அடுத்தது (Next) >',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Container(
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
          // Step Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF524EE1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'திருமண நிலை & குடும்ப விவரம் (Marital Status & Family)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        'தேவை',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Marital Status
          RichText(
            text: const TextSpan(
              text: 'திருமண நிலை (Select Marital Status)',
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
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final marriedBtn = _buildMaritalStatusCard(
                title: 'திருமணமானவர் (Married)',
                subtitle: 'மனைவி மற்றும் மனைவி வீட்டு குலதெய்வம் விவரங்களை வழங்கவும்.',
                icon: Icons.favorite,
                isSelected: maritalStatus == 'Married',
                onTap: () {
                  setState(() {
                    maritalStatus = 'Married';
                  });
                },
              );
              final unmarriedBtn = _buildMaritalStatusCard(
                title: 'திருமணமாகாதவர் (Unmarried)',
                subtitle: 'தங்கள் பிறப்பு வழியிலான சொந்த குடும்ப குலதெய்வத்துடன் தொடரும்.',
                icon: Icons.bookmark_border,
                isSelected: maritalStatus == 'Unmarried',
                onTap: () {
                  setState(() {
                    maritalStatus = 'Unmarried';
                  });
                },
              );

              if (isMobile) {
                return Column(
                  children: [
                    marriedBtn,
                    const SizedBox(height: 16),
                    unmarriedBtn,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: marriedBtn),
                  const SizedBox(width: 16),
                  Expanded(child: unmarriedBtn),
                ],
              );
            },
          ),

          if (maritalStatus == 'Married') ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium_outlined, color: Colors.blue.shade600, size: 20), // Placeholder icon
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'மனைவி & அவர் குலதெய்வம் விவரங்கள் (Wife Details)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      final wifeNameField = _buildInputField(
                        label: 'மனைவி பெயர் (Wife\'s Name)',
                        isRequired: true,
                        hint: 'மனைவி பெயரை உள்ளிடவும்',
                        icon: Icons.person_outline,
                        onChanged: (v) {
                          setState(() { wifeName = v; });
                        }
                      );
                      final wifeDeityField = _buildInputField(
                        label: 'மனைவியின் குலதெய்வம் (Wife\'s Kula Deivam)',
                        isRequired: true,
                        hint: 'எ.கா: முனீஸ்வரன் / காளியம்மன்',
                        note: '* நீங்கள் புதிய பெயரை தட்டச்சு செய்யலாம் அல்லது பட்டியலிலிருந்து தேர்வு செய்யலாம்',
                        onChanged: (v) {
                          setState(() { wifeDeity = v; });
                        }
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            wifeNameField,
                            const SizedBox(height: 16),
                            wifeDeityField,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: wifeNameField),
                          const SizedBox(width: 16),
                          Expanded(child: wifeDeityField),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 16,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 2;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('முந்தையது (Back)'),
              ),
              if (_isStep3Complete())
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveAllDetails,
                  icon: _isSaving 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('பதிவுகளைச் சேமிக்கவும் (Save All Details)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF524EE1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isStep3Complete() {
    if (maritalStatus == null) return false;
    if (maritalStatus == 'Married') {
      if (wifeName.trim().isEmpty || wifeDeity.trim().isEmpty) return false;
    }
    return true;
  }

  Future<void> _saveAllDetails() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final payload = {
        'community_id': int.tryParse(selectedCommunity ?? ''),
        if (selectedSubCommunity != null) 'sub_community_id': int.tryParse(selectedSubCommunity!),
        'kula_id': int.tryParse(selectedKulam ?? ''),
        'kula_deivam_id': int.tryParse(selectedDeity ?? ''),
        'vagaiyara_id': int.tryParse(selectedVagaiyara ?? ''),
        'tharpothaiya_vagaiyara': _currentVagaiyaraController.text.trim(),
        'generation_no': int.tryParse(selectedGeneration ?? ''),
        'marital_status': maritalStatus?.toLowerCase(),
        'spouse_name': wifeName.trim().isNotEmpty ? wifeName.trim() : null,
        'spouse_kula_deivam_id': wifeDeity.trim().isNotEmpty ? wifeDeity.trim() : null,
      };

      await _apiRepository.createCommunitySelection(payload);
      
      if (mounted) {
        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
      }

      // Refresh the list
      final fetchedSelections = await _apiRepository.fetchCommunitySelections();
      if (mounted) {
        setState(() {
          communitySelections = fetchedSelections;
          
          // Reset form
          _currentStep = 1;
          selectedCommunity = null;
          selectedSubCommunity = null;
          selectedKulam = null;
          selectedDeity = null;
          selectedVagaiyara = null;
          selectedGeneration = null;
          _currentVagaiyaraController.clear();
          maritalStatus = null;
          wifeName = '';
          wifeDeity = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteSubmission(int id) async {
    final confirmed = await CustomDeleteDialog.showConfirmation(context);
    if (!confirmed) return;

    try {
      await _apiRepository.deleteCommunitySelection(id);
      
      if (mounted) {
        await CustomDeleteDialog.showDeleted(context);
      }

      // Refresh the list
      final fetchedSelections = await _apiRepository.fetchCommunitySelections();
      if (mounted) {
        setState(() {
          communitySelections = fetchedSelections;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting data: $e')),
        );
      }
    }
  }

  Widget _buildMaritalStatusCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF524EE1) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF524EE1) : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1E1B4B) : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required bool isRequired,
    required String hint,
    IconData? icon,
    String? note,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400, size: 18) : null,
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
            fillColor: Colors.white,
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 6),
          Text(
            note,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ],
    );
  }
  
  Widget _buildTextField({
    required String label,
    required bool isRequired,
    required String hint,
    TextEditingController? controller,
    String? note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool isRequired,
    required List<dynamic> items,
    required String hint,
    required String Function(dynamic item) displayBuilder,
    required String valueKey,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    String? targetScreen;
    if (label.contains('சமூகம்')) {
      targetScreen = 'சமூகம்';
    } else if (label.contains('உட்பிரிவு')) {
      targetScreen = 'உட்பிரிவு';
    } else if (label.contains('குலம்')) {
      targetScreen = 'குலம்';
    } else if (label.contains('வகையறா')) {
      targetScreen = 'வகையறா';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (targetScreen != null && widget.onScreenSelected != null) {
                  widget.onScreenSelected!(targetScreen);
                }
              },
              child: const Text(
                '+ சேர்க்க',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
              hint: Text(
                hint,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: (() {
                final seen = <String>{};
                return items.where((item) {
                  final val = item[valueKey]?.toString() ?? '';
                  if (seen.contains(val)) return false;
                  seen.add(val);
                  return true;
                }).map((dynamic item) {
                  final displayValue = displayBuilder(item);
                  final value = item[valueKey]?.toString() ?? '';
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList();
              })(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStep(
            1,
            'சமூகம் & குலதெய்வம்',
            'Step 1: Community & Deity',
          ),
          _buildStepDivider(_currentStep >= 2),
          _buildStep(
            2,
            'வகையறா & உறைவிடம்',
            'Step 2: Vagaiyara & Places',
          ),
          _buildStepDivider(_currentStep >= 3),
          _buildStep(
            3,
            'குடும்ப விவரங்கள்',
            'Step 3: Family Details',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    int number,
    String title,
    String subtitle,
  ) {
    bool isActive = _currentStep >= number;
    bool isCompleted = _currentStep > number;

    return InkWell(
      onTap: () {
        setState(() {
          _currentStep = number;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : isActive
                      ? const Color(0xFF524EE1)
                      : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? const Color(0xFF1E1B4B)
                      : Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isActive ? const Color(0xFF10B981) : Colors.grey.shade300,
    );
  }

  Widget _buildRegisteredSubmissions() {
    return Container(
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
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'பதிவு செய்யப்பட்ட பட்டியல்கள் (Registered Submissions - Database)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'தரவுதளத்தில் சேமிக்கப்பட்ட படிவங்களின் பதிவுகள். (Saved dynamically in Database)',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Search box placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'தேடல் (சமூகம், குலதெய்வம், வகையரா)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              dataRowHeight: 80,
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('சமூகம்\nமற்றும்\nஉட்பிரிவு', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('குலம்\n(KULAM)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('குல தெய்வம்', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('வகையரா', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('சொந்த ஊர் /\nஇப்போதைய\nஊர்', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('தலைமுறை', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('திருமண நிலை &\nமனைவி விவரம்', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('செயல்பாடு\n(ACTIONS)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: communitySelections.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final submission = entry.value;

                final communityId = submission['community_id'].toString();
                final subCommunityId = submission['sub_community_id'].toString();
                final kulaId = submission['kula_id'].toString();
                final deivamId = submission['kula_deivam_id'].toString();
                final vagaiyaraId = submission['vagaiyara_id']?.toString();

                final c = communities.firstWhere((e) => e['id'].toString() == communityId, orElse: () => null);
                final sc = subCommunities.firstWhere((e) => e['id'].toString() == subCommunityId, orElse: () => null);
                final k = kulas.firstWhere((e) => e['id'].toString() == kulaId, orElse: () => null);
                final d = kulaDeivams.firstWhere((e) => e['id'].toString() == deivamId, orElse: () => null);
                final v = vagaiyaras.firstWhere((e) => e['id'].toString() == vagaiyaraId, orElse: () => null);

                final cTamil = c != null ? c['community_name_tamil'] : '';
                final cEng = c != null ? c['community_name_english'] : '';
                final scTamil = sc != null ? sc['sub_community_name_tamil'] : '';
                final scEng = sc != null ? sc['sub_community_name_english'] : '';

                final kTamil = k != null ? k['kula_name_tamil'] : '';
                final kEng = k != null ? k['kula_name_english'] : '';

                final dTamil = d != null ? d['deity_name_tamil'] : '';
                final dEng = d != null ? d['deity_name_english'] : '';
                final dImage = d != null ? d['image_path'] : null;

                final vTamil = v != null ? v['vagaiyara_name_tamil'] : submission['tharpothaiya_vagaiyara'] ?? 'Unknown';

                final generation = submission['generation_no'] ?? '';
                final tharpothaiya = submission['tharpothaiya_vagaiyara'] ?? 'Nill';
                
                // Assuming place mapping will be handled later, using Nill for now as per image.
                final nativePlace = 'Nill'; 
                final currentPlace = 'Nill';

                return DataRow(
                  cells: [
                    DataCell(Text(index.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cTamil ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('உட்பிரிவு: $scTamil ($scEng)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('$cTamil ($cEng)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kTamil ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('குலம் ($kEng Kulam)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://temple.jobes24x7.com/api/uploads/$dImage',
                                  width: 24, height: 24, fit: BoxFit.cover,
                                  errorBuilder: (c,e,s) => const Icon(Icons.person, size: 24),
                                ),
                              ),
                            if (dImage != null) const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dTamil ?? '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('($dEng)', style: const TextStyle(color: Colors.green, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vTamil ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('தற்போதைய: $tharpothaiya', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('சொந்தம்: $nativePlace', style: const TextStyle(color: Colors.blue, fontSize: 11)),
                        Text('இப்போது: $currentPlace', style: const TextStyle(color: Colors.blue, fontSize: 11)),
                      ],
                    )),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$generation-ஆம் தலைமுறை', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        Text('(${generation}th Generation)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unmarried', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Text('(திருமணமாகாதவர்)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteSubmission(submission['id']),
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

  @override
  void dispose() {
    _currentVagaiyaraController.dispose();
    super.dispose();
  }
}
