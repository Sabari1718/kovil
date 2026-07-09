import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../data/poojai_api_repository.dart';
import 'package:kulatheivam/core/widgets/custom_delete_dialog.dart';

class KizhamaPookaiContent extends StatefulWidget {
  final Map<String, dynamic>? editPoojai;
  const KizhamaPookaiContent({super.key, this.editPoojai});

  @override
  State<KizhamaPookaiContent> createState() => _KizhamaPookaiContentState();
}

class _KizhamaPookaiContentState extends State<KizhamaPookaiContent> {
  final ScrollController _scrollController = ScrollController();
  // Dropdowns
  String _selectedDay = 'Select கிழமை (Day)';
  String _selectedFrequency = 'Select கால் பூஜை (Pooja Frequency)';
  String _selectedPoojaName = 'Select பூஜா பெயர் (Pooja Name)';
  String _selectedSession = 'Select நாள் நேரம் (Session)';

  // Text controllers
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _abhishekamController = TextEditingController();
  final TextEditingController _theerthamController = TextEditingController();
  final TextEditingController _alangaramController = TextEditingController();
  final TextEditingController _naivedyamController = TextEditingController();
  final TextEditingController _aradhanaiController = TextEditingController();
  final TextEditingController _parayanamController = TextEditingController();
  final TextEditingController _extraAlangaramController =
      TextEditingController();
  final TextEditingController _extraSandanamController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Checkboxes
  bool _deepaAradhanai = false;
  bool _archanai = false;
  bool _prasadam = false;
  bool _annadhanam = false;

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

  final List<String> _frequencies = [
    'Select கால் பூஜை (Pooja Frequency)',
    'ஒரு கால பூஜை',
    'இரண்டு கால பூஜை',
    'மூன்று கால பூஜை',
    'நான்கு கால பூஜை',
    'ஐந்து கால பூஜை',
    'ஆறு கால பூஜை',
  ];

  final List<String> _poojaNames = [
    'Select பூஜா பெயர் (Pooja Name)',
    'உஷோ கலாம்',
    'காலை சந்தி',
    'உச்சி கலாம்',
    'சாயரட்சை',
    'அர்த்த ஜாமம்',
  ];

  final List<String> _sessions = [
    'Select நாள் நேரம் (Session)',
    'காலை (Morning)',
    'பிற்பகல் (Afternoon)',
    'சாயங்காலம் (Evening)',
    'இரவு (Night)',
  ];

  final PoojaiApiRepository _apiRepository = PoojaiApiRepository(ApiClient());
  bool _isLoading = false;
  int? _editingId;

  // Mock data
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
    final data = await _apiRepository.getKilamaiPoojais();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedDay = 'Select கிழமை (Day)';
      _selectedFrequency = 'Select கால் பூஜை (Pooja Frequency)';
      _selectedPoojaName = 'Select பூஜா பெயர் (Pooja Name)';
      _selectedSession = 'Select நாள் நேரம் (Session)';
      _timeController.clear();
      _abhishekamController.clear();
      _theerthamController.clear();
      _alangaramController.clear();
      _naivedyamController.clear();
      _aradhanaiController.clear();
      _parayanamController.clear();
      _extraAlangaramController.clear();
      _extraSandanamController.clear();
      _notesController.clear();
      _deepaAradhanai = false;
      _archanai = false;
      _prasadam = false;
      _annadhanam = false;
    });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) {
      final formattedTime =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
      setState(() => _timeController.text = formattedTime);
    }
  }

  Future<void> _savePoojai() async {
    if (_selectedDay.contains('Select') ||
        _selectedFrequency.contains('Select') ||
        _selectedPoojaName.contains('Select')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'தயவுசெய்து கிழமை, கால பூஜை மற்றும் பூஜா பெயர் தேர்ந்தெடுக்கவும்',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    List<String> vagaiList = [];
    if (_deepaAradhanai) vagaiList.add('தீப ஆராதனை');
    if (_archanai) vagaiList.add('அர்ச்சனை');
    if (_prasadam) vagaiList.add('பிரசாதம்');
    if (_annadhanam) vagaiList.add('அன்னதானம்');

    final data = {
      'day': _selectedDay,
      'pooja_time': _selectedFrequency,
      'pooja_name': _selectedPoojaName,
      'session': _selectedSession == 'Select நாள் நேரம் (Session)'
          ? ''
          : _selectedSession,
      'time': _timeController.text,
      'abhishekam': _abhishekamController.text,
      'theertham': _theerthamController.text,
      'alangaram': _alangaramController.text,
      'naivedyam': _naivedyamController.text,
      'aradhanai': _aradhanaiController.text,
      'parayanam': _parayanamController.text,
      'extra_alangaram': _extraAlangaramController.text,
      'extra_sandanam': _extraSandanamController.text,
      'pooja_notes': _notesController.text,
      'pooja_vagai': vagaiList.join(','),
      'deity_type': 'mulavar',
      'pooja_type': 'week',
      'status': 'active',
      'temple_id': 1,
      'details': '',
      'maha_deep_aradhanai': '',
    };

    bool success;
    if (_editingId != null) {
      success = await _apiRepository.updateKilamaiPoojai(_editingId!, data);
    } else {
      success = await _apiRepository.addKilamaiPoojai(data);
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
      _selectedDay = _days.contains(poojai['day'])
          ? poojai['day']
          : 'Select கிழமை (Day)';
      _selectedFrequency = _frequencies.contains(poojai['pooja_time'])
          ? poojai['pooja_time']
          : 'Select கால் பூஜை (Pooja Frequency)';
      _selectedPoojaName = _poojaNames.contains(poojai['pooja_name'])
          ? poojai['pooja_name']
          : 'Select பூஜா பெயர் (Pooja Name)';
      _selectedSession = _sessions.contains(poojai['session'])
          ? poojai['session']
          : 'Select நாள் நேரம் (Session)';

      _timeController.text = poojai['time']?.toString() ?? '';
      _abhishekamController.text = poojai['abhishekam']?.toString() ?? '';
      _theerthamController.text = poojai['theertham']?.toString() ?? '';
      _alangaramController.text = poojai['alangaram']?.toString() ?? '';
      _naivedyamController.text = poojai['naivedyam']?.toString() ?? '';
      _aradhanaiController.text = poojai['aradhanai']?.toString() ?? '';
      _parayanamController.text = poojai['parayanam']?.toString() ?? '';
      _extraAlangaramController.text =
          poojai['extra_alangaram']?.toString() ?? '';
      _extraSandanamController.text =
          poojai['extra_sandanam']?.toString() ?? '';
      _notesController.text = poojai['pooja_notes']?.toString() ?? '';

      String vagai = poojai['pooja_vagai']?.toString() ?? '';
      _deepaAradhanai = vagai.contains('தீப ஆராதனை');
      _archanai = vagai.contains('அர்ச்சனை');
      _prasadam = vagai.contains('பிரசாதம்');
      _annadhanam = vagai.contains('அன்னதானம்');
    });
  }

  Future<void> _deletePoojai(int id) async {
    final confirm = await CustomDeleteDialog.showConfirmation(context);
    if (confirm) {
      setState(() => _isLoading = true);
      final success = await _apiRepository.deleteKilamaiPoojai(id);
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
    _timeController.dispose();
    _abhishekamController.dispose();
    _theerthamController.dispose();
    _alangaramController.dispose();
    _naivedyamController.dispose();
    _aradhanaiController.dispose();
    _parayanamController.dispose();
    _extraAlangaramController.dispose();
    _extraSandanamController.dispose();
    _notesController.dispose();
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_view_week,
                color: Colors.blue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'கிழமை பூஜைகள் (Weekly Poojas)',
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
          'கோவிலின் வாராந்திர சிறப்பு பூஜைகள் மற்றும் கிழமை நேரங்களை இங்கே நிர்வகிக்கலாம்.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

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
                  'புதிய பூஜை படிவு (Add New Ritual)',
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

          // Row 1: Day, Frequency, PoojaName
          _threeRow(
            _dropdown(
              'கிழமை (Day)',
              _selectedDay,
              _days,
              Icons.calendar_month_outlined,
              (v) => setState(() => _selectedDay = v!),
            ),
            _dropdown(
              'கால பூஜை (Pooja Frequency)',
              _selectedFrequency,
              _frequencies,
              Icons.loop_outlined,
              (v) => setState(() => _selectedFrequency = v!),
            ),
            _dropdown(
              'பூஜா பெயர் (Pooja Name)',
              _selectedPoojaName,
              _poojaNames,
              Icons.surround_sound_outlined,
              (v) => setState(() => _selectedPoojaName = v!),
            ),
          ),
          const SizedBox(height: 16),

          // Row 2: Session, Time, Abhishekam
          _threeRow(
            _dropdown(
              'நாள் நேரம் (Session)',
              _selectedSession,
              _sessions,
              Icons.wb_sunny_outlined,
              (v) => setState(() => _selectedSession = v!),
            ),
            _timeField('நேரம் (Exact Time)', _timeController),
            _textField(
              'அபிஷேகம் (Abhishekam)',
              'ex: பஞ்ச மரிஷேகம்...',
              _abhishekamController,
              Icons.water_drop_outlined,
            ),
          ),
          const SizedBox(height: 16),

          // Row 3: Theertham, Alangaram, Naivedyam
          _threeRow(
            _textField(
              'தீர்த்தம் (Theertham)',
              'ex: சனை தீர்த்தம்...',
              _theerthamController,
              Icons.local_drink_outlined,
            ),
            _textField(
              'அலங்காரம் (Alangaram)',
              'அலங்கார விவரங்கள்...',
              _alangaramController,
              Icons.auto_fix_high_outlined,
            ),
            _textField(
              'நைவேத்தியம் (Naivedyam)',
              'நைவேத்திய விவரங்கள்...',
              _naivedyamController,
              Icons.fastfood_outlined,
            ),
          ),
          const SizedBox(height: 16),

          // Row 4: Aradhanai, Parayanam, Extra Alangaram
          _threeRow(
            _textField(
              'ஆராதனை (Aradhanai)',
              '+ ஆராதனை...',
              _aradhanaiController,
              Icons.add,
            ),
            _textField(
              'பாராயணம் (Parayanam)',
              'பாராயணம்...',
              _parayanamController,
              Icons.menu_book_outlined,
            ),
            _textField(
              'Extra Alangaram',
              '+ கூடுதல் அலங்காரம்...',
              _extraAlangaramController,
              Icons.add,
            ),
          ),
          const SizedBox(height: 16),

          // Row 5: Extra Sandanam + Notes
          _threeRow(
            _textField(
              'Extra Sandanam',
              '+ கூடுதல் சந்தனம்...',
              _extraSandanamController,
              Icons.add,
            ),
            _textField(
              'பூஜை குறிப்பு',
              'பூஜை பற்றிய குறிப்புகள்...',
              _notesController,
              Icons.description_outlined,
            ),
            const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Pooja Types checkboxes
          const Text(
            'பூஜை வகைகள் (Pooja Types)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 24,
            children: [
              _checkboxItem(
                'தீப ஆராதனை',
                _deepaAradhanai,
                (v) => setState(() => _deepaAradhanai = v!),
              ),
              _checkboxItem(
                'அர்ச்சனை',
                _archanai,
                (v) => setState(() => _archanai = v!),
              ),
              _checkboxItem(
                'பிரசாதம்',
                _prasadam,
                (v) => setState(() => _prasadam = v!),
              ),
              _checkboxItem(
                'அன்னதானம்',
                _annadhanam,
                (v) => setState(() => _annadhanam = v!),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Buttons
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 14,
            runSpacing: 14,
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
                  _editingId == null ? 'Save Ritual' : 'Update Ritual',
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
                        'கிழமை பூஜைகள் பட்டியல் (Ritual List)',
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
                columnSpacing: 24,
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
                      'கிழமை',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'காலம் & பெயர்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'நாள் நேரம்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'நேரம்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'அபிஷேகம்',
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
                            Text(
                              r['day']?.toString() ?? '-',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  r['pooja_time']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  r['pooja_name']?.toString() ?? '-',
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
                              r['session']?.toString() ?? '-',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r['time']?.toString() ?? '-',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              r['abhishekam']?.toString() ?? '-',
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

  // ─── Helpers ─────────────────────────────────────────────────────
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
      if (bc.maxWidth < 750) {
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

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
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
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12),
                            ),
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
  }

  Widget _textField(
    String label,
    String hint,
    TextEditingController ctrl,
    IconData icon,
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
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }

  Widget _timeField(String label, TextEditingController ctrl) {
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
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          readOnly: true,
          onTap: _pickTime,
          decoration: InputDecoration(
            hintText: '-- : --',
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
  }

  Widget _checkboxItem(String label, bool value, Function(bool?) onChanged) {
    return Row(
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
          style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}
