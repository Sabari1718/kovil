import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kulatheivam/core/network/api_client.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';
import '../data/kovil_api_repository.dart';

class ThakavalContent extends StatefulWidget {
  const ThakavalContent({super.key});

  @override
  State<ThakavalContent> createState() => _ThakavalContentState();
}

class _ThakavalContentState extends State<ThakavalContent> {
  // Amenities states
  final Map<String, bool> _amenities = {
    'தண்ணீர் வசதி (Water)': true,
    'குடிநீர் வசதி (Drinking)': true,
    'குளியலறை (Bathroom)': true,
    'கழிப்பறை (Toilet)': true,
    'தங்கும் விடுதி (Stay)': true,
    'மின்வசதி (Power)': true,
    'வெந்நீர் (Hot Water)': true,
    'குளிர்சாதன (AC)': true,
    'திருமண மண்டபம் (Hall)': true,
  };

  final Map<String, IconData> _amenityIcons = {
    'தண்ணீர் வசதி (Water)': Icons.water_drop_outlined,
    'குடிநீர் வசதி (Drinking)': Icons.waves_outlined,
    'குளியலறை (Bathroom)': Icons.shower_outlined,
    'கழிப்பறை (Toilet)': Icons.wash_outlined,
    'தங்கும் விடுதி (Stay)': Icons.home_outlined,
    'மின்வசதி (Power)': Icons.power_settings_new_outlined,
    'வெந்நீர் (Hot Water)': Icons.thermostat_outlined,
    'குளிர்சாதன (AC)': Icons.ac_unit_outlined,
    'திருமண மண்டபம் (Hall)': Icons.grid_view_outlined,
  };

  final _hallDescCtrl = TextEditingController();
  final _poojariPhoneCtrl = TextEditingController();

  File? _hallPhoto;
  String? _existingImageUrl;
  bool _isLoading = false;
  int? _takavalId;
  final _apiRepository = KovilApiRepository(ApiClient());

  @override
  void initState() {
    super.initState();
    _fetchTakavalData();
  }

  Future<void> _fetchTakavalData() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getTakaval();
    if (data != null) {
      setState(() {
        _takavalId = data['id'];
        _amenities['தண்ணீர் வசதி (Water)'] = data['water_facility'] == 'true';
        _amenities['குடிநீர் வசதி (Drinking)'] =
            data['drinking_water'] == 'true';
        _amenities['குளியலறை (Bathroom)'] = data['bathroom'] == 'true';
        _amenities['கழிப்பறை (Toilet)'] = data['toilet'] == 'true';
        _amenities['தங்கும் விடுதி (Stay)'] = data['accommodation'] == 'true';
        _amenities['மின்வசதி (Power)'] = data['power_backup'] == 'true';
        _amenities['வெந்நீர் (Hot Water)'] = data['hot_water'] == 'true';
        _amenities['குளிர்சாதன (AC)'] = data['ac_facility'] == 'true';
        _amenities['திருமண மண்டபம் (Hall)'] = data['marriage_hall'] == 'true';

        _hallDescCtrl.text = data['mandapam_description']?.toString() ?? '';
        _poojariPhoneCtrl.text = data['poojari_contact']?.toString() ?? '';

        if (data['mandapam_image'] != null &&
            data['mandapam_image'].toString().isNotEmpty) {
          _existingImageUrl =
              '${ApiClient.baseUrl.replaceAll('/api', '')}/uploads/${data['mandapam_image']}';
          if (!data['mandapam_image'].toString().startsWith('/uploads')) {
            _existingImageUrl =
                '${ApiClient.baseUrl.replaceAll('/api', '')}/uploads/${data['mandapam_image']}';
          }
        }
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _hallPhoto = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _hallPhoto = null;
    });
  }

  void _resetAll() {
    setState(() {
      for (var k in _amenities.keys) {
        _amenities[k] = false;
      }
      _hallDescCtrl.clear();
      _poojariPhoneCtrl.clear();
      _hallPhoto = null;
      _existingImageUrl = null;
    });
  }

  @override
  void dispose() {
    _hallDescCtrl.dispose();
    _poojariPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 24),
          _amenitiesCard(),
          const SizedBox(height: 24),
          _hallPoojariCard(),
          const SizedBox(height: 24),
          // Actions at the bottom
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _resetBtn(_resetAll),
                _updateBtn('Update Information', () async {
                  if (_takavalId == null) return;
                  setState(() => _isLoading = true);

                  final data = {
                    'water_facility': _amenities['தண்ணீர் வசதி (Water)']
                        .toString(),
                    'drinking_water': _amenities['குடிநீர் வசதி (Drinking)']
                        .toString(),
                    'bathroom': _amenities['குளியலறை (Bathroom)'].toString(),
                    'toilet': _amenities['கழிப்பறை (Toilet)'].toString(),
                    'accommodation': _amenities['தங்கும் விடுதி (Stay)']
                        .toString(),
                    'power_backup': _amenities['மின்வசதி (Power)'].toString(),
                    'hot_water': _amenities['வெந்நீர் (Hot Water)'].toString(),
                    'ac_facility': _amenities['குளிர்சாதன (AC)'].toString(),
                    'marriage_hall': _amenities['திருமண மண்டபம் (Hall)']
                        .toString(),
                    'mandapam_description': _hallDescCtrl.text,
                    'poojari_contact': _poojariPhoneCtrl.text,
                  };

                  XFile? xFile;
                  if (_hallPhoto != null) {
                    xFile = XFile(_hallPhoto!.path);
                  }

                  final success = await _apiRepository.updateTakaval(
                    _takavalId!,
                    data,
                    imageFile: xFile,
                  );
                  setState(() => _isLoading = false);

                  if (success) {
                    if (mounted) {
                      CustomDeleteDialog.showSuccess(
                        context,
                        title: 'வெற்றிகரமாக சேமிக்கப்பட்டது!',
                        message: 'தகவல்கள் வெற்றிகரமாக புதுப்பிக்கப்பட்டன.',
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('பிழை ஏற்பட்டது!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _header() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.info_outline,
          color: Colors.indigo.shade600,
          size: 22,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'தகவல் மற்றும் வசதிகள் (Temple Facilities)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              'பக்தர்களுக்கான வசதிகள் மற்றும் மண்டப விவரங்களை நிர்வகிக்கவும்.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );

  // ── Amenities Card ────────────────────────────────────────────────────────────
  Widget _amenitiesCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecor(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_box_outlined,
              color: Colors.indigo.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'கிடைக்கக்கூடிய வசதிகள் (Amenities)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _amenities.keys.map((key) {
            final isSelected = _amenities[key] ?? false;
            return GestureDetector(
              onTap: () => setState(() => _amenities[key] = !isSelected),
              child: Container(
                width: 250,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.indigo.shade50.withOpacity(0.3)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.indigo.shade300
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected
                          ? Colors.indigo.shade600
                          : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _amenityIcons[key],
                      color: isSelected
                          ? Colors.indigo.shade600
                          : Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.indigo.shade900
                              : Colors.grey.shade800,
                        ),
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
  );

  // ── Hall & Poojari Card ───────────────────────────────────────────────────────
  Widget _hallPoojariCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecor(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_size_select_actual_outlined,
              color: Colors.indigo.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'மண்டபம் மற்றும் பூசாரி (Hall & Poojari)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (ctx, bc) {
            final isWide = bc.maxWidth > 600;
            final descField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('மண்டபம் விளக்கம்'),
                const SizedBox(height: 6),
                TextField(
                  controller: _hallDescCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'மண்டபம் விளக்கம்...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                      borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            );

            final photoField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('மண்டபம் புகைப்படம்'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _hallPhoto == null ? _pickImage : null,
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _hallPhoto != null
                            ? Image.file(
                                _hallPhoto!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : _existingImageUrl != null
                            ? Image.network(
                                _existingImageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Preview',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      if (_hallPhoto != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red.shade100,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );

            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: descField),
                      const SizedBox(width: 24),
                      Expanded(child: photoField),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      descField,
                      const SizedBox(height: 16),
                      photoField,
                    ],
                  );
          },
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (ctx, bc) {
            return SizedBox(
              width: bc.maxWidth > 600
                  ? (bc.maxWidth / 2) - 12
                  : double.infinity,
              child: _textField(
                'பூசாரி தொடர்பு எண்',
                '',
                _poojariPhoneCtrl,
                Icons.phone_outlined,
              ),
            );
          },
        ),
      ],
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────────
  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF374151),
    ),
  );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
    prefixIcon: Icon(icon, size: 14, color: Colors.grey.shade400),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      borderSide: const BorderSide(color: Color(0xFF6B4EE1)),
    ),
    filled: true,
    fillColor: Colors.white,
  );

  Widget _textField(
    String label,
    String hint,
    TextEditingController ctrl,
    IconData icon,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      TextField(controller: ctrl, decoration: _inputDeco(hint, icon)),
    ],
  );

  Widget _resetBtn(VoidCallback cb) => OutlinedButton.icon(
    onPressed: cb,
    icon: Icon(Icons.restart_alt, size: 15, color: Colors.grey.shade700),
    label: Text('Reset All', style: TextStyle(color: Colors.grey.shade700)),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _updateBtn(String label, VoidCallback cb) => ElevatedButton.icon(
    onPressed: cb,
    icon: const Icon(Icons.save_outlined, size: 15),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6B4EE1),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  );
}
