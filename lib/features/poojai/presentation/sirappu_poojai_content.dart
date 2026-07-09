import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../data/poojai_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class SirappuPookaiContent extends StatefulWidget {
  final Map<String, dynamic>? editPoojai;
  const SirappuPookaiContent({super.key, this.editPoojai});

  @override
  State<SirappuPookaiContent> createState() => _SirappuPookaiContentState();
}

class _SirappuPookaiContentState extends State<SirappuPookaiContent> {
  final ScrollController _scrollController = ScrollController();
  // Radio buttons
  String _repeatType = 'எல்லாவொரு முறையும்';
  String _nithiyaMarrum = 'மாற்றும் இல்லை';
  String _scope = 'அனைத்து தெய்வங்கள்';

  // Deity dropdown
  String _selectedDeity = 'Select தெய்வங்கள் (Deity Selection)';

  // Checkboxes - Transport
  bool _vaganam = false;
  bool _therailKamanthu = false;
  bool _ther = false;

  // Checkboxes - Rituals
  bool _abhishekam = false;
  bool _theertham = false;
  bool _alangaram = false;
  bool _naivedyam = false;
  bool _aradhanai = false;
  bool _parayanam = false;
  bool _vinnappam = false;

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _viseshaNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _purappaaduTimeController =
      TextEditingController();
  final TextEditingController _vazhibaattuController = TextEditingController();
  final TextEditingController _palaangalController = TextEditingController();
  final TextEditingController _venduthalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _ottumotthaController = TextEditingController();

  // Day dropdown
  String _selectedDay = 'Select கிழமை (Day)';

  final List<String> _deities = [
    'Select தெய்வங்கள் (Deity Selection)',
    'அனைத்து தெய்வங்கள்',
    'மூலவர் மட்டும்',
    'உடனாற்றாய் அம்பாள்',
    'தக்ஷிணாமூர்த்தி',
    'சண்டிகேஸ்வரர்',
    'கால பைரவர்',
    'நவ நாயகர்கள்',
  ];

  final List<String> _days = [
    'Select கிழமை (Day)',
    'திங்கட்கிழமை',
    'செவ்வாய்கிழமை',
    'புதன்கிழமை',
    'வியாழக்கிழமை',
    'வெள்ளிக்கிழமை',
    'சனிக்கிழமை',
    'ஞாயிற்றுக்கிழமை',
  ];

  final PoojaiApiRepository _apiRepository = PoojaiApiRepository(ApiClient());
  bool _isLoading = false;
  int? _editingId;

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchPoojais();
    if (widget.editPoojai != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _editPoojai(widget.editPoojai!);
      });
    }
  }

  Future<void> _fetchPoojais() async {
    setState(() => _isLoading = true);
    final data = await _apiRepository.getSpecialPoojais();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _repeatType = 'எல்லாவொரு முறையும்';
      _nithiyaMarrum = 'மாற்றும் இல்லை';
      _scope = 'அனைத்து தெய்வங்கள்';
      _selectedDeity = 'Select தெய்வங்கள் (Deity Selection)';
      _selectedDay = 'Select கிழமை (Day)';
      _vaganam = false;
      _therailKamanthu = false;
      _ther = false;
      _abhishekam = false;
      _theertham = false;
      _alangaram = false;
      _naivedyam = false;
      _aradhanai = false;
      _parayanam = false;
      _vinnappam = false;
      _titleController.clear();
      _viseshaNameController.clear();
      _dateController.clear();
      _timeController.clear();
      _dayController.clear();
      _purappaaduTimeController.clear();
      _vazhibaattuController.clear();
      _palaangalController.clear();
      _venduthalController.clear();
      _notesController.clear();
      _ottumotthaController.clear();
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null)
      setState(
        () => _dateController.text =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      );
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) {
      final formattedTime =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
      setState(() => ctrl.text = formattedTime);
    }
  }

  String _mapRepeatType(String val) {
    if (val.contains('ஒருமுறை')) return 'one_time';
    return 'every_time';
  }

  String _unmapRepeatType(String val) {
    if (val == 'one_time') return 'ஒருமுறை மட்டும்';
    return 'எல்லாவொரு முறையும்';
  }

  String _mapRitualChange(String val) {
    if (val.contains('மாற்றும் உண்டு')) return 'change';
    return 'no_change';
  }

  String _unmapRitualChange(String val) {
    if (val == 'change') return 'மாற்றும் உண்டு';
    return 'மாற்றும் இல்லை';
  }

  String _mapScope(String val) {
    if (val.contains('அனைத்து')) return 'all';
    if (val == 'மூலவர் மட்டும்') return 'moolavar';
    if (val.contains('உரிய')) return 'moolavar_special';
    if (val.contains('சிறப்பு')) return 'special_pooja_deity';
    return 'all';
  }

  String _unmapScope(String val) {
    if (val == 'all') return 'அனைத்து தெய்வங்கள்';
    if (val == 'moolavar') return 'மூலவர் மட்டும்';
    if (val == 'moolavar_special') return 'மூலவர், சிறப்பு உரிய தெய்வங்கள்';
    if (val == 'special_pooja_deity') return 'சிறப்பு பூஜை தெய்வங்கள் மட்டும்';
    return 'அனைத்து தெய்வங்கள்';
  }

  Future<void> _savePoojai() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('தயவுசெய்து பூஜையின் தலைப்பை உள்ளிடவும்')),
      );
      return;
    }

    setState(() => _isLoading = true);

    List<String> transportList = [];
    if (_vaganam) transportList.add('வாகனம்');
    if (_therailKamanthu) transportList.add('தோளில் சுமந்து செல்வது');
    if (_ther) transportList.add('தேர்');

    List<String> ritualList = [];
    if (_abhishekam) ritualList.add('அபிஷேகம்');
    if (_theertham) ritualList.add('தீர்த்தம்');
    if (_alangaram) ritualList.add('அலங்காரம்');
    if (_naivedyam) ritualList.add('நைவேத்தியம்');
    if (_aradhanai) ritualList.add('ஆராதனை');
    if (_parayanam) ritualList.add('பாராயணம்');
    if (_vinnappam) ritualList.add('விண்ணப்பம்');

    final data = {
      'repeat_type': _mapRepeatType(_repeatType),
      'ritual_change': _mapRitualChange(_nithiyaMarrum),
      'deity_selection': _mapScope(_scope),
      'deity_id': _selectedDeity == 'Select தெய்வங்கள் (Deity Selection)'
          ? 'all'
          : _selectedDeity,
      'title': _titleController.text,
      'special_day_name': _viseshaNameController.text,
      'date': _dateController.text,
      'time': _timeController.text,
      'day': _selectedDay == 'Select கிழமை (Day)' ? '' : _selectedDay,
      'departure_time': _purappaaduTimeController.text,
      'transport': transportList.join(','),
      'worship_method': _vazhibaattuController.text,
      'benefits': _palaangalController.text,
      'prayers': _venduthalController.text,
      'notes': _notesController.text,
      'overall_note': _ottumotthaController.text,
      'ritual_types': ritualList.join(','),
      'status': 'active',
      'temple_id': 1,
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateSpecialPoojai(_editingId!, data);
    } else {
      success = await _apiRepository.addSpecialPoojai(data);
    }

    setState(() => _isLoading = false);

    if (success) {
      CustomDeleteDialog.showSuccess(context, title: 'வெற்றி', message: 'விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது');
      _clearForm();
      _fetchPoojais();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save record')));
    }
  }

  void _editPoojai(Map<String, dynamic> poojai) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    setState(() {
      _editingId = int.tryParse(poojai['id']?.toString() ?? '');

      _repeatType = _unmapRepeatType(poojai['repeat_type']?.toString() ?? '');
      _nithiyaMarrum = _unmapRitualChange(
        poojai['ritual_change']?.toString() ?? '',
      );
      _scope = _unmapScope(poojai['deity_selection']?.toString() ?? '');

      String deityId = poojai['deity_id']?.toString() ?? '';
      _selectedDeity = _deities.contains(deityId)
          ? deityId
          : (deityId == 'all'
                ? 'அனைத்து தெய்வங்கள்'
                : 'Select தெய்வங்கள் (Deity Selection)');

      _selectedDay = _days.contains(poojai['day'])
          ? poojai['day']
          : 'Select கிழமை (Day)';

      _titleController.text = poojai['title']?.toString() ?? '';
      _viseshaNameController.text =
          poojai['special_day_name']?.toString() ?? '';

      if (poojai['date'] != null) {
        try {
          DateTime dt = DateTime.parse(poojai['date'].toString());
          _dateController.text =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        } catch (_) {
          _dateController.text = poojai['date']?.toString() ?? '';
        }
      } else {
        _dateController.text = '';
      }

      _timeController.text = poojai['time']?.toString() ?? '';
      _purappaaduTimeController.text =
          poojai['departure_time']?.toString() ?? '';
      _vazhibaattuController.text = poojai['worship_method']?.toString() ?? '';
      _palaangalController.text = poojai['benefits']?.toString() ?? '';
      _venduthalController.text = poojai['prayers']?.toString() ?? '';
      _notesController.text = poojai['notes']?.toString() ?? '';
      _ottumotthaController.text = poojai['overall_note']?.toString() ?? '';

      String transport = poojai['transport']?.toString() ?? '';
      _vaganam = transport.contains('வாகனம்');
      _therailKamanthu =
          transport.contains('தோளில் சுமந்து செல்வது') ||
          transport.contains('தேரில் கமந்து செல்வது');
      _ther =
          transport.contains('தேர்') &&
          !transport.contains(
            'தேரில்',
          ); // simple workaround for 'தேர்' vs 'தேரில்'

      String rituals = poojai['ritual_types']?.toString() ?? '';
      _abhishekam = rituals.contains('அபிஷேகம்');
      _theertham = rituals.contains('தீர்த்தம்');
      _alangaram = rituals.contains('அலங்காரம்');
      _naivedyam = rituals.contains('நைவேத்தியம்');
      _aradhanai = rituals.contains('ஆராதனை');
      _parayanam = rituals.contains('பாராயணம்');
      _vinnappam = rituals.contains('விண்ணப்பம்');
    });
  }

  Future<void> _deletePoojai(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      setState(() => _isLoading = true);
      final success = await _apiRepository.deleteSpecialPoojai(id);
      setState(() => _isLoading = false);
      if (success) {
        await CustomDeleteDialog.showDeleted(context);
        _fetchPoojais();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete record'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _viseshaNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _dayController.dispose();
    _purappaaduTimeController.dispose();
    _vazhibaattuController.dispose();
    _palaangalController.dispose();
    _venduthalController.dispose();
    _notesController.dispose();
    _ottumotthaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildFormCard(),
              const SizedBox(height: 28),
              _buildListCard(),
            ],
          ),
        ),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bolt, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'சிறப்பு பூஜைகள் (Special Poojas)',
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
        'விசேஷ திருநாள்கள் மற்றும் விசேஷ காலங்களுக்கான சிறப்பு பூஜைகளை இங்கே நிர்வகிக்கலாம்.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    ],
  );

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.blue.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'புதிய சிறப்பு பூஜை படிவு (Add New Special Pooja)',
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
          const SizedBox(height: 24),

          // Row 1: Repeat Type | Nithiya Marrum | Deity
          _threeRow(
            _radioGroup(
              'நிகழ்வு முறை (Repeat Type)',
              _repeatType,
              ['எல்லாவொரு முறையும்', 'ஒதுவொரு மட்டும்'],
              (v) => setState(() => _repeatType = v!),
            ),
            _radioGroup(
              'நித்திய பூஜை மாற்றும்',
              _nithiyaMarrum,
              ['மாற்றும் உண்டு', 'மாற்றும் இல்லை'],
              (v) => setState(() => _nithiyaMarrum = v!),
            ),
            _dropdown(
              'தெய்வங்கள் (Deity Selection)',
              _selectedDeity,
              _deities,
              Icons.person_outline,
              (v) => setState(() => _selectedDeity = v!),
            ),
          ),
          const SizedBox(height: 20),

          // Scope row — full width radio group
          _scopeRow(),
          const SizedBox(height: 20),

          // Row 2: Title | Visesha Name | Date
          _threeRow(
            _textField(
              'பூஜையின் தலைப்பு (Title)',
              '+ பூஜையின் பெயர்',
              _titleController,
              Icons.add,
            ),
            _textField(
              'விசேஷ தினத்தின் பெயர்',
              'தினத்தின் பெயர்',
              _viseshaNameController,
              Icons.event_outlined,
            ),
            _dateField('பூஜை தேதி (Date)', _dateController),
          ),
          const SizedBox(height: 16),

          // Row 3: Time | Day | Purappadu Time
          _threeRow(
            _timeField('பூஜை நேரம் (Time)', _timeController),
            _dayDropdown(),
            _timeField('புறப்பாடு நேரம்', _purappaaduTimeController),
          ),
          const SizedBox(height: 20),

          // Transport section
          _transportSection(),
          const SizedBox(height: 20),

          // Row 4: Vazhibaattu | Palangal | Venduthal
          _threeRow(
            _textField(
              'வழிபாட்டு முறை',
              'வழிபாட்டு முறை',
              _vazhibaattuController,
              Icons.auto_fix_high_outlined,
            ),
            _textField(
              'பூஜையின் பலன்கள்',
              'பலன்கள்',
              _palaangalController,
              Icons.favorite_border,
            ),
            _textField(
              'வேண்டுதல்கள்',
              'வேண்டுதல்கள்',
              _venduthalController,
              Icons.description_outlined,
            ),
          ),
          const SizedBox(height: 16),

          // Row 5: Notes | Ottumottha (2 of 3)
          _threeRow(
            _textField(
              'பூஜை குறிப்பு',
              'குறிப்புகள்',
              _notesController,
              Icons.description_outlined,
            ),
            _textField(
              'ஒட்டுமொத்த குறிப்பு',
              'கூடுதல் தகவல்கள்',
              _ottumotthaController,
              Icons.description_outlined,
            ),
            const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // Ritual checkboxes
          _ritualsSection(),
          const SizedBox(height: 32),

          // Buttons
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 14,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _clearForm,
                icon: Icon(
                  Icons.clear_all,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                label: Text(
                  'Clear Form',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
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
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePoojai,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(
                  _editingId == null
                      ? 'Save Special Pooja'
                      : 'Update Special Pooja',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecor(),
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
                        'சிறப்பு பூஜைகள் பட்டியல் (Special Pooja List)',
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
              TextButton.icon(
                onPressed: _fetchPoojais,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.indigo),
                label: const Text(
                  'Refresh',
                  style: TextStyle(color: Colors.indigo, fontSize: 12),
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
                columnSpacing: 20,
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
                      'தலைப்பு & விசேஷ திரணம்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'தேதி & நேரம்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'தெய்வம்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'முறை',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'நிலை',
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
                rows: _records
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              r['id']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    r['title']?.toString() ?? '-',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    r['special_day_name']?.toString() ?? '-',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  r['date']?.toString().split('T').first ?? '-',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  r['time']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              r['deity_id']?.toString() ?? '-',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text(
                              _unmapRepeatType(
                                r['repeat_type']?.toString() ?? '-',
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (r['status']?.toString().toLowerCase() ==
                                        'active')
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                r['status']?.toString() ?? '-',
                                style: TextStyle(
                                  color:
                                      (r['status']?.toString().toLowerCase() ==
                                          'active')
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.grey.shade600,
                                      size: 15,
                                    ),
                                    onPressed: () => _editPoojai(r),
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 15,
                                    ),
                                    onPressed: () {
                                      _scrollController.jumpTo(0);
                                      final id = int.tryParse(
                                        r['id']?.toString() ?? '',
                                      );
                                      if (id != null) _deletePoojai(id);
                                    },
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                  ),
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

  // ─── Sub-widgets ────────────────────────────────────────────────────────

  Widget _scopeRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'தேர்வு செய்த தெய்வங்கள் எல்லை (Scope)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children:
                [
                      'அனைத்து தெய்வங்கள்',
                      'மூலவர் மட்டும்',
                      'மூலவர், சிறப்பு கரிய தெய்வங்கள்',
                      'சிறப்பு பூஜை தெய்வங்கள் மட்டும்',
                    ]
                    .map(
                      (s) => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: s,
                              groupValue: _scope,
                              onChanged: (v) => setState(() => _scope = v!),
                              activeColor: const Color(0xFF3B82F6),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Flexible(
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _transportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'போக்குவரத்து / ஊர்வலம் (Transport)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 20,
            children: [
              _checkboxItem(
                'வாகனம்',
                _vaganam,
                (v) => setState(() => _vaganam = v!),
              ),
              _checkboxItem(
                'தேரில் கமந்து செல்வது',
                _therailKamanthu,
                (v) => setState(() => _therailKamanthu = v!),
              ),
              _checkboxItem('தேர்', _ther, (v) => setState(() => _ther = v!)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ritualsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'வழிபாடு சடங்குகள் (Rituals)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _checkboxItem(
                'அபிஷேகம்',
                _abhishekam,
                (v) => setState(() => _abhishekam = v!),
              ),
              _checkboxItem(
                'தீர்த்தம்',
                _theertham,
                (v) => setState(() => _theertham = v!),
              ),
              _checkboxItem(
                'அலங்காரம்',
                _alangaram,
                (v) => setState(() => _alangaram = v!),
              ),
              _checkboxItem(
                'நைவேத்தியம்',
                _naivedyam,
                (v) => setState(() => _naivedyam = v!),
              ),
              _checkboxItem(
                'ஆராதனை',
                _aradhanai,
                (v) => setState(() => _aradhanai = v!),
              ),
              _checkboxItem(
                'பாராயணம்',
                _parayanam,
                (v) => setState(() => _parayanam = v!),
              ),
              _checkboxItem(
                'விண்ணப்பம்',
                _vinnappam,
                (v) => setState(() => _vinnappam = v!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _radioGroup(
    String label,
    String groupValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 0,
          runSpacing: 4,
          children: options
              .map(
                (s) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: s,
                      groupValue: groupValue,
                      onChanged: onChanged,
                      activeColor: const Color(0xFF3B82F6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Flexible(
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _dayDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'கிழமை (Day)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 15,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                    items: _days
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDay = v!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────
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

  Widget _threeRow(Widget a, Widget b, Widget c) => LayoutBuilder(
    builder: (ctx, bc) {
      if (bc.maxWidth < 750)
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

  Widget _textField(
    String label,
    String hint,
    TextEditingController ctrl,
    IconData icon,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      TextField(controller: ctrl, decoration: _inputDecoration(hint, icon)),
    ],
  );

  Widget _dateField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        readOnly: true,
        onTap: _pickDate,
        decoration: _inputDecoration(
          'dd mm yyyy',
          Icons.calendar_today_outlined,
        ),
      ),
    ],
  );

  Widget _timeField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _pickTime(ctrl),
        decoration: InputDecoration(
          hintText: '-- :',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Icon(
            Icons.access_time_outlined,
            size: 15,
            color: Colors.grey.shade400,
          ),
          suffixIcon: Icon(
            Icons.access_time,
            size: 15,
            color: Colors.grey.shade400,
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
            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ],
  );

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  items: items
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        prefixIcon: Icon(icon, size: 15, color: Colors.grey.shade400),
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        filled: true,
        fillColor: Colors.white,
      );

  Widget _checkboxItem(String label, bool value, Function(bool?) onChanged) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
          ),
        ],
      );
}
