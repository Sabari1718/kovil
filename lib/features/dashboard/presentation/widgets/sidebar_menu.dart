import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class SidebarMenu extends ConsumerWidget {
  final bool isMobile;
  final String activeScreen;
  final Set<String> expandedItems;
  final Function(String) onScreenSelected;
  final Function(String, bool) onItemExpanded;

  final String userName;
  final String userEmail;

  const SidebarMenu({
    super.key,
    required this.isMobile,
    required this.activeScreen,
    required this.expandedItems,
    required this.onScreenSelected,
    required this.onItemExpanded,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Container(
      width: isMobile ? MediaQuery.of(context).size.width : 260,
      color: const Color(0xFF1E2336), // Dark blue sidebar color
      child: Column(
        children: [
          // Logo Area
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  'KOVIL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.indigo.shade300,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isMobile) ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildActiveListTile(
                  'Home',
                  Icons.home,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'Dashboard',
                  Icons.dashboard,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'கோவில் சேர்க்க',
                  Icons.add_home_work,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'தெய்வங்கள்',
                  Icons.self_improvement,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'கோவில்',
                  Icons.temple_hindu_outlined,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'பூஜைகள்',
                  Icons.spa,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'திருவிழாக்கள்',
                  Icons.festival_outlined,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'பிரார்த்தனை',
                  Icons.clean_hands,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'பக்தர்கள்',
                  Icons.people_outline,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'குலம்',
                  Icons.groups,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'நிர்வாகம்',
                  Icons.admin_panel_settings,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'முகவரி',
                  Icons.location_on,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                _buildActiveListTile(
                  'தகவல்',
                  Icons.info_outline,
                  activeScreen,
                  onScreenSelected,
                  lang,
                ),
                const Divider(color: Colors.white24, height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language, color: Colors.white70, size: 20),
                          const SizedBox(width: 16),
                          Text(
                            lang == 'ta' ? 'மொழி' : 'Language',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: lang,
                          dropdownColor: const Color(0xFF2A2D3E),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: const [
                            DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(languageProvider.notifier).setLanguage(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // User Profile Block
          if (isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigoAccent,
                      radius: 20,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hoverColor: Colors.white10,
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                AppTranslations.translate('Logout', lang),
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    String title,
    IconData icon,
    List<String> children,
    String activeScreen,
    Set<String> expandedItems,
    Function(String) onScreenSelected,
    Function(String, bool) onItemExpanded,
    String lang,
  ) {
    bool isExpanded = expandedItems.contains(title);
    bool isChildActive = children.contains(activeScreen);

    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) => onItemExpanded(title, expanded),
        leading: Icon(
          icon,
          color: isChildActive ? Colors.white : Colors.white54,
        ),
        title: Text(
          AppTranslations.translate(title, lang),
          style: TextStyle(
            color: isChildActive ? Colors.white : Colors.white54,
            fontWeight: isChildActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        collapsedIconColor: isChildActive ? Colors.white : Colors.white54,
        iconColor: Colors.white,
        backgroundColor: isChildActive
            ? const Color(0xFF524EE1).withOpacity(0.1)
            : Colors.transparent,
        collapsedBackgroundColor: isChildActive
            ? const Color(0xFF524EE1)
            : Colors.transparent,
        childrenPadding: const EdgeInsets.only(left: 54, bottom: 8),
        children: children.map((child) {
          bool isActive = activeScreen == child;
          return ListTile(
            title: Text(
              AppTranslations.translate(child, lang),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: isActive
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            onTap: () => onScreenSelected(child),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveListTile(
    String title,
    IconData icon,
    String activeScreen,
    Function(String) onScreenSelected,
    String lang,
  ) {
    bool isActive = activeScreen == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isActive ? const Color(0xFF524EE1) : Colors.transparent,
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white54),
        title: Text(
          AppTranslations.translate(title, lang),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onScreenSelected(title),
      ),
    );
  }
}
