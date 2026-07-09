import 'package:flutter/material.dart';
import 'package:kulatheivam/core/network/api_client.dart';
import '../data/kovil_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class AddressContent extends StatefulWidget {
  const AddressContent({super.key});

  @override
  State<AddressContent> createState() => _AddressContentState();
}

class _AddressContentState extends State<AddressContent> {
  // Location Details
  final _doorNoCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _longCtrl = TextEditingController();

  // Service Contacts
  final _poojaPhoneCtrl = TextEditingController();
  final _poojaEmailCtrl = TextEditingController();
  final _nerthikadanPhoneCtrl = TextEditingController();
  final _nerthikadanEmailCtrl = TextEditingController();

  final _annathanamPhoneCtrl = TextEditingController();
  final _nankodaiPhoneCtrl = TextEditingController();
  final _committeePhoneCtrl = TextEditingController();

  final _kadhuKuthuPhoneCtrl = TextEditingController();
  final _mudiPhoneCtrl = TextEditingController();
  final _committeeEmailCtrl = TextEditingController();

  bool _isLoading = false;
  int? _addressId;
  final _apiRepository = KovilApiRepository(ApiClient());

  @override
  void initState() {
    super.initState();
    _fetchAddressData();
  }

  Future<void> _fetchAddressData() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getTempleAddressContact();
    if (data != null) {
      setState(() {
        _addressId = data['id'];
        _doorNoCtrl.text = data['door_number']?.toString() ?? '';
        _buildingCtrl.text = data['building_name']?.toString() ?? '';
        _streetCtrl.text = data['street_name']?.toString() ?? '';
        _landmarkCtrl.text = data['landmark']?.toString() ?? '';
        _areaCtrl.text = data['area_name']?.toString() ?? '';
        _pincodeCtrl.text = data['pincode']?.toString() ?? '';
        _countryCtrl.text = data['country']?.toString() ?? '';
        _latCtrl.text = data['latitude']?.toString() ?? '';
        _longCtrl.text = data['longitude']?.toString() ?? '';

        _poojaPhoneCtrl.text = data['pooja_phone']?.toString() ?? '';
        _poojaEmailCtrl.text = data['pooja_email']?.toString() ?? '';
        _nerthikadanPhoneCtrl.text =
            data['nerthikadan_phone']?.toString() ?? '';
        _nerthikadanEmailCtrl.text =
            data['nerthikadan_email']?.toString() ?? '';
        _annathanamPhoneCtrl.text = data['annadhanam_phone']?.toString() ?? '';
        _nankodaiPhoneCtrl.text = data['donation_phone']?.toString() ?? '';
        _committeePhoneCtrl.text =
            data['bhakthar_group_phone']?.toString() ?? '';
        _kadhuKuthuPhoneCtrl.text = data['kadhukuthu_phone']?.toString() ?? '';
        _mudiPhoneCtrl.text = data['mudithalai_phone']?.toString() ?? '';
        _committeeEmailCtrl.text =
            data['bhakthar_group_email']?.toString() ?? '';
      });
    }
    setState(() => _isLoading = false);
  }

  void _resetAll() {
    setState(() {
      _doorNoCtrl.clear();
      _buildingCtrl.clear();
      _streetCtrl.clear();
      _landmarkCtrl.clear();
      _areaCtrl.clear();
      _pincodeCtrl.clear();
      _countryCtrl.clear();
      _latCtrl.clear();
      _longCtrl.clear();
      _poojaPhoneCtrl.clear();
      _poojaEmailCtrl.clear();
      _nerthikadanPhoneCtrl.clear();
      _nerthikadanEmailCtrl.clear();
      _annathanamPhoneCtrl.clear();
      _nankodaiPhoneCtrl.clear();
      _committeePhoneCtrl.clear();
      _kadhuKuthuPhoneCtrl.clear();
      _mudiPhoneCtrl.clear();
      _committeeEmailCtrl.clear();
    });
  }

  @override
  void dispose() {
    _doorNoCtrl.dispose();
    _buildingCtrl.dispose();
    _streetCtrl.dispose();
    _landmarkCtrl.dispose();
    _areaCtrl.dispose();
    _pincodeCtrl.dispose();
    _countryCtrl.dispose();
    _latCtrl.dispose();
    _longCtrl.dispose();
    _poojaPhoneCtrl.dispose();
    _poojaEmailCtrl.dispose();
    _nerthikadanPhoneCtrl.dispose();
    _nerthikadanEmailCtrl.dispose();
    _annathanamPhoneCtrl.dispose();
    _nankodaiPhoneCtrl.dispose();
    _committeePhoneCtrl.dispose();
    _kadhuKuthuPhoneCtrl.dispose();
    _mudiPhoneCtrl.dispose();
    _committeeEmailCtrl.dispose();
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
          _locationCard(),
          const SizedBox(height: 24),
          _contactsCard(),
          const SizedBox(height: 24),
          // Actions at the bottom
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _resetBtn(_resetAll),
                _saveBtn('Save Changes', () async {
                  if (_addressId == null) return;
                  setState(() => _isLoading = true);
                  final data = {
                    'door_number': _doorNoCtrl.text,
                    'building_name': _buildingCtrl.text,
                    'street_name': _streetCtrl.text,
                    'landmark': _landmarkCtrl.text,
                    'area_name': _areaCtrl.text,
                    'pincode': _pincodeCtrl.text,
                    'country': _countryCtrl.text,
                    'latitude': _latCtrl.text,
                    'longitude': _longCtrl.text,
                    'pooja_phone': _poojaPhoneCtrl.text,
                    'pooja_email': _poojaEmailCtrl.text,
                    'nerthikadan_phone': _nerthikadanPhoneCtrl.text,
                    'nerthikadan_email': _nerthikadanEmailCtrl.text,
                    'annadhanam_phone': _annathanamPhoneCtrl.text,
                    'donation_phone': _nankodaiPhoneCtrl.text,
                    'kadhukuthu_phone': _kadhuKuthuPhoneCtrl.text,
                    'mudithalai_phone': _mudiPhoneCtrl.text,
                    'bhakthar_group_phone': _committeePhoneCtrl.text,
                    'bhakthar_group_email': _committeeEmailCtrl.text,
                  };
                  final success = await _apiRepository
                      .updateTempleAddressContact(_addressId!, data);
                  setState(() => _isLoading = false);
                  if (success) {
                    CustomDeleteDialog.showSuccess(
                      context,
                      title: 'வெற்றிகரமாக சேமிக்கப்பட்டது!',
                      message: 'Saved Successfully!',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('பிழை ஏற்பட்டது!'),
                        backgroundColor: Colors.red,
                      ),
                    );
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
          Icons.location_on_outlined,
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
              'முகவரி மற்றும் தொடர்பு (Address & Contact)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              'கோவிலின் இருப்பிட விவரங்கள் மற்றும் அனைத்து சேவைத் தொடர்பு எண்களையும் நிர்வகிக்கவும்.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );

  // ── Location Details Card ─────────────────────────────────────────────────────
  Widget _locationCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecor(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.home_outlined, color: Colors.indigo.shade600, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'இருப்பிட விவரங்கள் (Location Details)',
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
        _threeCol(
          _textField(
            'கதவு எண்',
            '',
            _doorNoCtrl,
            Icons.door_front_door_outlined,
          ),
          _textField('கட்டிடம்', '', _buildingCtrl, Icons.home_work_outlined),
          _textField('தெரு பெயர்', '', _streetCtrl, Icons.add_road),
        ),
        const SizedBox(height: 16),
        _threeCol(
          _textField('அடையாளம்', '', _landmarkCtrl, Icons.flag_outlined),
          _textField('பகுதி', '', _areaCtrl, Icons.location_city_outlined),
          _textField(
            'அஞ்சல் குறியீடு',
            '',
            _pincodeCtrl,
            Icons.mark_as_unread_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _threeCol(
          _textField('நாடு (Country)', '', _countryCtrl, Icons.public),
          _textField('அட்சரேகை (Lat)', '', _latCtrl, Icons.explore_outlined),
          _textField(
            'தீர்க்கரேகை (Long)',
            '',
            _longCtrl,
            Icons.explore_outlined,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.my_location, size: 14),
            label: const Text('Get Current GPS'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.indigo.shade600,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Service Contacts Card ─────────────────────────────────────────────────────
  Widget _contactsCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecor(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.contact_phone_outlined,
              color: Colors.teal.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'சேவைத் தொடர்பு எண்கள் (Service Contacts)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Subcategory 1
        Text(
          'பூஜை மற்றும் நிவர்த்தி',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _twoCol(
          _textField(
            'பூஜை தொலைபேசி',
            '',
            _poojaPhoneCtrl,
            Icons.phone_outlined,
          ),
          _textField(
            'பூஜை மின்னஞ்சல்',
            '',
            _poojaEmailCtrl,
            Icons.alternate_email,
          ),
        ),
        const SizedBox(height: 16),
        _twoCol(
          _textField(
            'நேர்த்திக்கடன் தொலைபேசி',
            '',
            _nerthikadanPhoneCtrl,
            Icons.phone_outlined,
          ),
          _textField(
            'நேர்த்திக்கடன் மின்னஞ்சல்',
            '',
            _nerthikadanEmailCtrl,
            Icons.alternate_email,
          ),
        ),
        const SizedBox(height: 24),

        // Subcategory 2
        Text(
          'பிற சேவைகள்',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _threeCol(
          _textField(
            'அன்னதானம் தொலைபேசி',
            '',
            _annathanamPhoneCtrl,
            Icons.favorite_border,
          ),
          _textField(
            'நன்கொடை தொலைபேசி',
            '',
            _nankodaiPhoneCtrl,
            Icons.currency_rupee_outlined,
          ),
          _textField(
            'பக்தர்கள் குழு தொலைபேசி',
            '',
            _committeePhoneCtrl,
            Icons.timeline,
          ),
        ),
        const SizedBox(height: 16),
        _threeCol(
          _textField(
            'காதுகுத்து தொலைபேசி',
            '',
            _kadhuKuthuPhoneCtrl,
            Icons.info_outline,
          ),
          _textField(
            'தலைமுடி தொலைபேசி',
            '',
            _mudiPhoneCtrl,
            Icons.info_outline,
          ),
          _textField(
            'பக்தர்கள் குழு மின்னஞ்சல்',
            '',
            _committeeEmailCtrl,
            Icons.alternate_email,
          ),
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

  Widget _threeCol(Widget a, Widget b, Widget c) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 700) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            a,
            const SizedBox(height: 14),
            b,
            const SizedBox(height: 14),
            c,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 14),
          Expanded(child: b),
          const SizedBox(width: 14),
          Expanded(child: c),
        ],
      );
    },
  );

  Widget _twoCol(Widget a, Widget b) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 500) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [a, const SizedBox(height: 14), b],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 14),
          Expanded(child: b),
        ],
      );
    },
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

  Widget _saveBtn(String label, VoidCallback cb) => ElevatedButton.icon(
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
