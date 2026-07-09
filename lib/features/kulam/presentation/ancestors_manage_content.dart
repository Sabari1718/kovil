import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kulatheivam/core/network/api_client.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import 'dart:io';

class AncestorsManageContent extends StatefulWidget {
  const AncestorsManageContent({Key? key}) : super(key: key);

  @override
  _AncestorsManageContentState createState() => _AncestorsManageContentState();
}

class _AncestorsManageContentState extends State<AncestorsManageContent> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearFromController = TextEditingController();
  final TextEditingController _yearToController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedGender = 'male'; 
  String? _selectedGeneration;
  XFile? _selectedImage;
  bool _isLoading = false;
  List<dynamic> _ancestors = [];
  
  String? _selectedAncestorId;

  final List<Map<String, String>> _generations = [
    {'id': '1', 'name': '1-ஆம் தலைமுறை (1st Gen)'},
    {'id': '2', 'name': '2-ஆம் தலைமுறை (2nd Gen)'},
    {'id': '3', 'name': '3-ஆம் தலைமுறை (3rd Gen)'},
    {'id': '4', 'name': '4-ஆம் தலைமுறை (4th Gen)'},
    {'id': '5', 'name': '5-ஆம் தலைமுறை (5th Gen)'},
    {'id': '6', 'name': '6-ஆம் தலைமுறை (6th Gen)'},
    {'id': '7', 'name': '7-ஆம் தலைமுறை (7th Gen)'},
    {'id': '8', 'name': '8-ஆம் தலைமுறை (8th Gen)'},
    {'id': '9', 'name': '9-ஆம் தலைமுறை (9th Gen)'},
    {'id': '10', 'name': '10-ஆம் தலைமுறை + (10th Gen+)'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAncestors();
  }

  Future<void> _fetchAncestors() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/ancestors');
      final dataObj = response['data'] ?? {};
      if (dataObj['code'] == 200) {
        setState(() {
          _ancestors = dataObj['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching ancestors: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _yearFromController.clear();
    _yearToController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedGender = 'male';
      _selectedGeneration = null;
      _selectedImage = null;
      _selectedAncestorId = null;
    });
  }

  void _onAncestorSelected(String? id) {
    setState(() {
      _selectedAncestorId = id;
    });
    
    if (id == null) {
      _resetForm();
      return;
    }

    final ancestor = _ancestors.firstWhere((element) => element['id'].toString() == id, orElse: () => null);
    if (ancestor != null) {
      _nameController.text = ancestor['name']?.toString() ?? '';
      _yearFromController.text = ancestor['year_from']?.toString() ?? '';
      _yearToController.text = ancestor['year_to']?.toString() ?? '';
      _descriptionController.text = ancestor['description']?.toString() ?? '';
      
      setState(() {
        _selectedGender = ancestor['gender'] == 'female' ? 'female' : 'male';
        final gen = ancestor['generation']?.toString() ?? '1';
        _selectedGeneration = _generations.any((e) => e['id'] == gen) ? gen : '1';
        _selectedImage = null; 
      });
    }
  }

  Future<void> _saveAncestor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> payload = {
        'name': _nameController.text,
        'gender': _selectedGender,
        'generation': _selectedGeneration,
        'year_from': int.tryParse(_yearFromController.text),
        'year_to': int.tryParse(_yearToController.text),
        'description': _descriptionController.text,
        'temple_details_id': null,
      };

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        String extension = _selectedImage!.path.split('.').last;
        payload['photo_path'] = 'data:image/$extension;base64,$base64Image';
      }

      Map<String, dynamic> response;
      if (_selectedAncestorId != null) {
        response = await _apiClient.put('/ancestor/update/$_selectedAncestorId', payload);
      } else {
        response = await _apiClient.post('/ancestor/create', payload);
      }

      final dataObj = response['data'] ?? {};
      if (dataObj['code'] == 200 || dataObj['code'] == 201) {
        CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
        _resetForm();
        _fetchAncestors();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('பிழை: ${dataObj['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('பிழை: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAncestor() async {
    if (_selectedAncestorId == null) return;
    
    final confirmed = await CustomDeleteDialog.showConfirmation(context);

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final response = await _apiClient.delete('/ancestor/delete/$_selectedAncestorId');
        final dataObj = response['data'] ?? {};
        if (dataObj['code'] == 200) {
          CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
          _resetForm();
          _fetchAncestors();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('பிழை: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
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
          Row(
            children: [
              Icon(Icons.people_outline, color: Colors.blue.shade800, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'முன்னோர்கள் மேலாண்மை (Ancestors Management)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'கோவிலின் மூதாதையர்கள் மற்றும் முன்னோர்களின் விபரங்களை இங்கே நிர்வகிக்கவும்.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Main Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Dropdown Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ஏற்கனவே உள்ள முன்னோரைத் தேர்ந்தெடுத்து திருத்த அல்லது நீக்க (Select to Edit/Delete Ancestor)',
                        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedAncestorId,
                            hint: const Text('-- புதிய முன்னோர் சேர்க்கவும் (Add New Ancestor) --'),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('-- புதிய முன்னோர் சேர்க்கவும் (Add New Ancestor) --'),
                              ),
                              ..._ancestors.map((e) => DropdownMenuItem<String>(
                                value: e['id'].toString(),
                                child: Text(e['name']?.toString() ?? 'Unknown'),
                              )),
                            ],
                            onChanged: _onAncestorSelected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Divider(color: Colors.grey.shade200, height: 1),
                
                // Form Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bookmark_border, color: Colors.indigo.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedAncestorId == null 
                                  ? 'புதிய முன்னோர் சேர்த்தல் (Add New Ancestor)' 
                                  : 'முன்னோர் விவரங்களை திருத்த (Edit Ancestor)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return Column(
                                children: [
                                  _buildTextFieldWithIcon('முன்னோர் பெயர் (Ancestor Name) *', 'எ.கா: சிவராமகிருஷ்ண மு', Icons.person_outline, _nameController),
                                  const SizedBox(height: 16),
                                  _buildGenerationDropdown(),
                                  const SizedBox(height: 16),
                                  _buildGenderDropdown(),
                                  const SizedBox(height: 16),
                                  _buildTextFieldWithIcon('ஆண்டு தொடக்கம் (Year From)', 'எ.கா: 1890', Icons.calendar_today_outlined, _yearFromController, isNumber: true),
                                  const SizedBox(height: 16),
                                  _buildTextFieldWithIcon('ஆண்டு முடிவு (Year To)', 'எ.கா: 1970', Icons.calendar_today_outlined, _yearToController, isNumber: true),
                                  const SizedBox(height: 16),
                                  _buildPhotoUpload(),
                                ],
                              );
                            }
                            
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildTextFieldWithIcon('முன்னோர் பெயர் (Ancestor Name) *', 'எ.கா: சிவராமகிருஷ்ண மு', Icons.person_outline, _nameController)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildGenerationDropdown()),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildGenderDropdown()),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: _buildTextFieldWithIcon('ஆண்டு தொடக்கம் (Year From)', 'எ.கா: 1890', Icons.calendar_today_outlined, _yearFromController, isNumber: true)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextFieldWithIcon('ஆண்டு முடிவு (Year To)', 'எ.கா: 1970', Icons.calendar_today_outlined, _yearToController, isNumber: true)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildPhotoUpload()),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        const Text('விவரம் / வரலாறு (Description)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'முன்னோர் பற்றிய விபரங்களை உள்ளிடவும்...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: Icon(Icons.auto_awesome, color: Colors.grey.shade400, size: 20),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            if (_selectedAncestorId != null)
                              OutlinedButton.icon(
                                onPressed: _deleteAncestor,
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: const Text('நீக்க (Delete)', style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            OutlinedButton.icon(
                              onPressed: _resetForm,
                              icon: Icon(Icons.refresh, color: Colors.grey.shade600, size: 18),
                              label: Text('ரத்து (Cancel)', style: TextStyle(color: Colors.grey.shade700)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveAncestor,
                              icon: _isLoading 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                : const Icon(Icons.save_outlined, size: 18),
                              label: Text(_selectedAncestorId != null ? 'புதுப்பிக்க (Update)' : 'முன்னோரைச் சேர் (Save)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1), // Indigo color matching screenshot
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithIcon(String label, String hint, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'இதை நிரப்பவும்';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenerationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('தலைமுறை (Select Generation)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedGeneration,
              hint: const Text('-- தேர்ந்தெடுக்கவும் --'),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              items: _generations.map((e) => DropdownMenuItem(
                value: e['id'], 
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e['name']!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGeneration = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('பாலினம் (Gender)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedGender,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              items: [
                DropdownMenuItem(value: 'male', child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    const Text('ஆண் (Male)'),
                  ],
                )),
                DropdownMenuItem(value: 'female', child: Row(
                  children: [
                    Icon(Icons.person_3_outlined, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    const Text('பெண் (Female)'),
                  ],
                )),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedGender = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('புகைப்படம் (Photo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedImage?.name ?? 'புகைப்படம் பதிவேற்றவும்',
                    style: TextStyle(color: _selectedImage == null ? Colors.grey.shade400 : Colors.black87, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
