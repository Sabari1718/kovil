import 'package:flutter/material.dart';
import '../../kulam/presentation/kula_deivam_worship_content.dart';
import '../../kulam/presentation/samugam_manage_content.dart';
import '../../kulam/presentation/subcommunity_manage_content.dart';
import '../../kulam/presentation/kulam_manage_content.dart';
import '../../kulam/presentation/kula_deivam_mapping_content.dart';
import '../../kulam/presentation/vagaiyara_manage_content.dart';
import '../../kulam/presentation/ancestors_manage_content.dart';
import '../../kovil/presentation/temple_manage_content.dart';
import '../../kovil/presentation/temple_list_content.dart';
import '../../kovil/presentation/temple_history_content.dart';
import '../../kovil/presentation/temple_extra_details_content.dart';
import '../../kovil/presentation/temple_tabs_content.dart';
import '../../deities/presentation/mulavar_content.dart';
import '../../deities/presentation/add_deities_content.dart';
import '../../deities/presentation/parivara_deities_content.dart';
import '../../deities/presentation/pigara_deities_content.dart';
import '../../deities/presentation/upa_deities_content.dart';
import '../../deities/presentation/kaval_deities_content.dart';
import '../../deities/presentation/bali_deities_content.dart';
import '../../deities/presentation/kovil_deities_content.dart';
import '../../poojai/presentation/poojai_content.dart';
import '../../poojai/presentation/nithiya_poojai_content.dart';
import '../../poojai/presentation/kizhama_poojai_content.dart';
import '../../poojai/presentation/sirappu_poojai_content.dart';
import '../../piraarthanai/presentation/kurai_niverthi_content.dart';
import '../../paktharkal/presentation/nertthi_kadan_content.dart';
import '../../paktharkal/presentation/kulam_makkal_content.dart';
import '../../paktharkal/presentation/samugam_saathi_content.dart';
import '../../paktharkal/presentation/kattali_tharar_content.dart';
import '../../thiruvizha/presentation/thiruvizha_content.dart';
import '../../thiruvizha/presentation/visesham_content.dart';
import '../../nirvagam/presentation/tharma_kartta_content.dart';
import '../../nirvagam/presentation/nan_kodaiyalar_content.dart';
import '../../nirvagam/presentation/ara_nilayat_thurai_content.dart';
import '../../nirvagam/presentation/porul_athara_content.dart';
import '../../nirvagam/presentation/anna_thanam_content.dart';
import '../../nirvagam/presentation/paktharkal_kuzhu_content.dart';
import '../../kovil/presentation/address_content.dart';
import '../../kovil/presentation/thakaval_content.dart';
import '../../deities/presentation/deities_tabs_content.dart';
import '../../poojai/presentation/poojas_tabs_content.dart';
import '../../thiruvizha/presentation/festivals_tabs_content.dart';
import '../../paktharkal/presentation/devotees_tabs_content.dart';
import '../../kulam/presentation/kulam_tabs_content.dart';
import '../../nirvagam/presentation/admin_tabs_content.dart';
import 'widgets/sidebar_menu.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/localization/app_translations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String userName;
  final String userEmail;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final List<String> subItems;
  final String? assetPath;
  
  _CategoryItem(this.title, this.icon, {this.subItems = const [], this.assetPath});
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Set<String> _expandedItems = {};
  final List<String> _navigationStack = [];
  String _activeScreen = 'Home';
  Map<String, dynamic>? _screenArguments;

  void _navigateTo(String screen, {Map<String, dynamic>? arguments}) {
    setState(() {
      if (_activeScreen != screen) {
        _navigationStack.add(_activeScreen);
        _activeScreen = screen;
      }
      if (arguments != null) {
        _screenArguments = arguments;
      }
    });
  }

  void _goBack() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _activeScreen = _navigationStack.removeLast();
        _screenArguments = null;
      });
    }
  }

  final List<_CategoryItem> _dashboardCategories = [
    _CategoryItem('கோவில் சேர்க்க', Icons.add_home_work, assetPath: 'assets/images/icon_add_temple.png'),
    _CategoryItem('தெய்வங்கள்', Icons.self_improvement, assetPath: 'assets/images/icon_deities.png'),
    _CategoryItem('கோவில்', Icons.temple_hindu_outlined, assetPath: 'assets/images/icon_temple.png'),
    _CategoryItem('பூஜைகள்', Icons.spa, assetPath: 'assets/images/icon_pooja.png'),
    _CategoryItem('திருவிழாக்கள்', Icons.festival_outlined, assetPath: 'assets/images/icon_festival.png'),
    _CategoryItem('பிரார்த்தனை', Icons.clean_hands, assetPath: 'assets/images/icon_prayer.png'),
    _CategoryItem('பக்தர்கள்', Icons.people_outline, assetPath: 'assets/images/icon_devotees.png'),
    _CategoryItem('குலம்', Icons.groups, assetPath: 'assets/images/icon_kulam.png'),
    _CategoryItem('நிர்வாகம்', Icons.admin_panel_settings, assetPath: 'assets/images/icon_admin.png'),
    _CategoryItem('முகவரி', Icons.location_on, assetPath: 'assets/images/icon_address.png'),
    _CategoryItem('தகவல்', Icons.info_outline, assetPath: 'assets/images/icon_info.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return PopScope(
      canPop: _navigationStack.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA), // Light background color
        appBar: isDesktop ? null : _buildAppBar(isDesktop),
        drawer: isDesktop ? null : _buildSidebar(context, isMobile: true),
        body: Row(
          children: [
            if (isDesktop) _buildSidebar(context, isMobile: false),
            Expanded(
              child: Column(
                children: [
                  if (isDesktop) _buildAppBar(isDesktop),
                  Expanded(child: _getActiveScreenContent(isDesktop)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActiveScreenContent(bool isDesktop) {
    switch (_activeScreen) {
      case 'குலதெய்வம் வழிபாடு':
        return KulaDeivamWorshipContent(
          onScreenSelected: (screen) {
            _navigateTo(screen);
          },
        );
      case 'சமூகம்':
        return const SamugamManageContent();
      case 'உட்பிரிவு':
        return const SubCommunityManageContent();
      case 'குலம்':
        return const KulamTabsContent();
      case 'குல தெய்வம்':
        return const KulaDeivamMappingContent();
      case 'வகைரா':
        return const VagaiyaraManageContent();
      case 'முன்னோர்களைச் சேர்க்க':
        return const AncestorsManageContent();
      case 'கோவில் சேர்க்க':
        return TempleManageContent(
          onScreenSelected: (screen, {arguments}) {
            _navigateTo(screen, arguments: arguments);
          },
        );
      case 'கோவில்':
        return TempleTabsContent(
          onScreenSelected: (screen, {arguments}) {
            _navigateTo(screen, arguments: arguments);
          },
          screenArguments: _screenArguments,
        );
      case 'கோவில் பட்டியல்':
        return TempleListContent(
          onScreenSelected: (screen) {
            _navigateTo(screen);
          },
        );
      case 'வரலாறு':
        return const TempleHistoryContent();
      case 'தெய்வங்கள்':
        return DeitiesTabsContent(
          onScreenSelected: (screen, {arguments}) {
            _navigateTo(screen, arguments: arguments);
          },
          screenArguments: _screenArguments,
        );
      case 'மூலவர்':
        return const MulavarContent();
      case 'தெய்வங்கள் சேர்க்க':
        return AddDeitiesContent(
          onScreenSelected: (screen, {arguments}) {
            _navigateTo(screen, arguments: arguments);
          },
        );
      case 'கோவில் தெய்வங்கள் சேர்க்க':
        return KovilDeitiesContent(editDeity: _screenArguments?['editDeity']);
      case 'பரிவார தெய்வங்கள்':
        return ParivaraDeitiesContent(
          editDeity: _screenArguments?['editDeity'],
        );
      case 'பிகரா தெய்வங்கள்':
        return PigaraDeitiesContent(editDeity: _screenArguments?['editDeity']);
      case 'உப தெய்வங்கள்':
        return UpaDeitiesContent(editDeity: _screenArguments?['editDeity']);
      case 'காவல் தெய்வங்கள்':
        return KavalDeitiesContent(editDeity: _screenArguments?['editDeity']);
      case 'பாலி தெய்வங்கள்':
        return BaliDeitiesContent(editDeity: _screenArguments?['editDeity']);
      case 'பூஜைகள்':
        return PoojasTabsContent(
          onScreenSelected: (screen, {arguments}) {
            _navigateTo(screen, arguments: arguments);
          },
          screenArguments: _screenArguments,
        );
      case 'நித்திய பூஜை':
        return NithiyaPookaiContent(editPoojai: _screenArguments?['editPoojai']);
      case 'கிழமை பூஜை':
        return KizhamaPookaiContent(editPoojai: _screenArguments?['editPoojai']);
      case 'சிறப்பு பூஜை':
        return SirappuPookaiContent(editPoojai: _screenArguments?['editPoojai']);
      case 'குறை நிவர்த்தி':
        return const KuraiNivarthiContent();
      case 'பக்தர்கள்':
        return const DevoteesTabsContent();
      case 'நேர்த்தி கடன்':
        return const NertthiKadanContent();
      case 'குலம் மக்கள்':
        return const KulamMakkalContent();
      case 'சமூகம் மற்றும் சாதி':
        return const SamugamSaathiContent();
      case 'கட்டளை தாரர்கள்':
        return const KattaliTharalContent();
      case 'திருவிழாக்கள்':
        return const FestivalsTabsContent();
      case 'விசேஷங்கள்':
        return const ViseshamContent();
      case 'நிர்வாகம்':
        return const AdminTabsContent();
      case 'தர்மகர்த்தா':
        return const TharmaKartthaContent();
      case 'நன்கொடையாளர் / தொண்டர்':
        return const NanKodaiyalarContent();
      case 'அறநிலையத்துறை':
        return const AraNilayatThuraiContent();
      case 'பொருளாதார்':
        return const PorulAtharaContent();
      case 'அன்ன தானம்':
        return const AnnaThanamContent();
      case 'பக்தர்கள் குழு':
        return const PaktharkalKuzhuContent();
      case 'முகவரி':
        return const AddressContent();
      case 'தகவல்':
        return const ThakavalContent();
      case 'Dashboard':
        return _buildDashboardStats(isDesktop);
      case 'Home':
        return _buildPremiumDashboardGrid(isDesktop);
      default:
        return _buildPremiumDashboardGrid(isDesktop);
    }
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0, // Prevents color change on scroll
      iconTheme: const IconThemeData(color: Colors.black87, size: 28),
      title: null, // Removed temple title
      leading: _navigationStack.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
            )
          : null, // Uses default Drawer hamburger menu
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.dark_mode_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        if (isDesktop) ...[
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                widget.userEmail,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Colors.indigoAccent,
            child: Text(
              widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, {bool isMobile = false}) {
    return SidebarMenu(
      isMobile: isMobile,
      userName: widget.userName,
      userEmail: widget.userEmail,
      activeScreen: _activeScreen,
      expandedItems: _expandedItems,
      onScreenSelected: (screen) {
        _navigateTo(screen);
        if (isMobile) Navigator.pop(context);
      },
      onItemExpanded: (title, expanded) {
        setState(() {
          if (expanded) {
            _expandedItems.add(title);
          } else {
            _expandedItems.remove(title);
          }
        });
      },
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4EE1), Color(0xFFA259FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Live Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome back, ${widget.userName}! 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Here's what's happening with your temple management system today.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBannerStat('124', 'TEMPLES'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildBannerStat('1.2k', 'USERS'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildBannerStat('99.9%', 'UPTIME'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDashboardGrid(bool isDesktop) {
    final lang = ref.watch(languageProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.translate('முதன்மை சேவைகள்', lang),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = isDesktop ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.2 : 1.0,
                ),
                itemCount: _dashboardCategories.length,
                itemBuilder: (context, index) {
                  final category = _dashboardCategories[index];
                  return _buildCategoryCard(category, lang, index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryItem category, String lang, int index) {
    final List<Color> cardColors = [
      const Color(0xFFFEE2E2), // Light Red
      const Color(0xFFFEF3C7), // Light Yellow
      const Color(0xFFD1FAE5), // Light Green
      const Color(0xFFDBEAFE), // Light Blue
      const Color(0xFFE0E7FF), // Light Indigo
      const Color(0xFFF3E8FF), // Light Purple
      const Color(0xFFFCE7F3), // Light Pink
      const Color(0xFFFFEDD5), // Light Orange
      const Color(0xFFCCFBF1), // Light Teal
      const Color(0xFFF4F4F5), // Light Zinc
      const Color(0xFFE2E8F0), // Light Slate
    ];
    final color = cardColors[index % cardColors.length];

    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (category.subItems.isEmpty) {
            _navigateTo(category.title);
          } else {
             _showSubCategoryDialog(category, lang);
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: SizedBox(
                width: double.infinity,
                child: category.assetPath != null
                    ? Image.asset(
                        category.assetPath!,
                        fit: BoxFit.cover,
                        color: color,
                        colorBlendMode: BlendMode.darken,
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(category.icon, size: 32, color: Colors.black87),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppTranslations.translate(category.title, lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category.subItems.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${category.subItems.length} Options',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubCategoryDialog(_CategoryItem category, String lang) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    Widget buildList() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: Colors.indigo),
              const SizedBox(width: 12),
              Text(
                AppTranslations.translate(category.title, lang),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isDesktop) const Spacer(),
              if (isDesktop)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: category.subItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subItem = category.subItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.grey.shade50,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_right_alt, color: Colors.indigo),
                  ),
                  title: Text(
                    AppTranslations.translate(subItem, lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateTo(subItem);
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24),
              child: buildList(),
            ),
          );
        }
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(child: buildList()),
          );
        }
      );
    }
  }

  Widget _buildDashboardStats(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(),
          const SizedBox(height: 24),
          _buildStatsCards(isDesktop),
          const SizedBox(height: 24),
          _buildBottomRow(isDesktop),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 1);
        double childAspectRatio = isDesktop ? 1.5 : 2.0;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              Icons.temple_hindu,
              Colors.indigo,
              '124',
              'Total Temples',
              '+4 this month',
              Colors.indigo,
            ),
            _buildStatCard(
              Icons.people,
              Colors.purple,
              '1,240',
              'Registered Users',
              '+12% increase',
              Colors.purple,
            ),
            _buildStatCard(
              Icons.calendar_today,
              Colors.orange,
              '45',
              'Daily Poojas',
              'Active now',
              Colors.orange,
            ),
            _buildStatCard(
              Icons.show_chart,
              Colors.teal,
              '99.9%',
              'System Health',
              'Stable',
              Colors.teal,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color iconColor,
    String value,
    String title,
    String trend,
    Color trendColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Icon(Icons.trending_up, color: trendColor, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                trend,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(bool isDesktop) {
    final sessionWidget = Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Active login details',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildSessionRow(
              Icons.person_outline,
              'User ID / Email',
              widget.userEmail,
            ),
            const Divider(),
            _buildSessionRow(Icons.shield_outlined, 'Role', 'Administrator'),
            const Divider(),
            _buildSessionRow(Icons.access_time, 'Login Time', 'Today, 9:48 AM'),
            const Divider(),
            _buildSessionRow(
              Icons.check_circle_outline,
              'Status',
              'Authenticated',
              valueColor: Colors.green,
            ),
          ],
        ),
      ),
    );

    final activityWidget = Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Latest system events',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildActivityItem(
              Icons.temple_hindu,
              'New Temple Added',
              'Sri Ranganathaswamy Temple',
              '2 mins ago',
              Colors.indigo,
            ),
            _buildActivityItem(
              Icons.calendar_today,
              'Pooja Scheduled',
              'Evening Deeparadhana',
              '15 mins ago',
              Colors.orange,
            ),
            _buildActivityItem(
              Icons.security,
              'System Update',
              'Backup completed',
              '1 hour ago',
              Colors.teal,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('View All Activity'),
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [sessionWidget, const SizedBox(width: 24), activityWidget],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [sessionWidget],
          ), // Wrap in Row to use Expanded properly
          const SizedBox(height: 24),
          Row(children: [activityWidget]),
        ],
      );
    }
  }

  Widget _buildSessionRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 20),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 10,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
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
}
