import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../services/api_service.dart';
import '../services/font_size_provider.dart';
import 'upload_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isBackendHealthy = false;
  bool _isCheckingHealth = true;
  int _selectedIndex = 0;
  int? _hoveredIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Breakpoint for mobile/desktop
  static const double mobileBreakpoint = 768;

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    setState(() => _isCheckingHealth = true);
    final apiService = context.read<ApiService>();
    final isHealthy = await apiService.healthCheck();
    setState(() {
      _isBackendHealthy = isHealthy;
      _isCheckingHealth = false;
    });
  }

  void _onNavigationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(onNavigateToUpload: () => _onNavigationTapped(1));
      case 1:
        return const UploadPage();
      default:
        return DashboardPage(onNavigateToUpload: () => _onNavigationTapped(1));
    }
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: !_isBackendHealthy && !_isCheckingHealth
          ? _buildBackendOfflineWidget()
          : Column(
              children: [
                _buildTopNavigationBar(),
                Expanded(child: _getSelectedPage()),
              ],
            ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF08012D),
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/kaso_logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            // Navigation items
            _buildDrawerNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              index: 0,
            ),
            _buildDrawerNavItem(
              icon: Icons.upload_file_rounded,
              label: 'Upload',
              index: 1,
            ),
            const Spacer(),
            // Font size controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFontSizeControls(),
            ),
            const Divider(color: Colors.white24),
            // Backend status
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMobileBackendStatus(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        _onNavigationTapped(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMobileBackendStatus() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _isBackendHealthy
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _isBackendHealthy ? 'Backend Connected' : 'Backend Offline',
          style: TextStyle(
            color: _isBackendHealthy
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(
            Icons.refresh_rounded,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: _checkBackendHealth,
        ),
      ],
    );
  }

  Widget _buildTopNavigationBar() {
    final isMobile = _isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF08012D), // Navy blue
        border: Border(bottom: BorderSide(color: Color(0xFF08012D), width: 1)),
      ),
      child: Container(
        height: isMobile ? 60 : 70,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
        child: Row(
          children: [
            // Mobile: Hamburger menu
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            // Kaso Logo
            Image.asset(
              'assets/kaso_logo.png',
              height: isMobile ? 26 : 32,
              fit: BoxFit.contain,
            ),
            // Desktop: Navigation Items
            if (!isMobile) ...[
              const SizedBox(width: 48),
              _buildTopNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              const SizedBox(width: 8),
              _buildTopNavItem(
                icon: Icons.upload_file_rounded,
                label: 'Upload',
                index: 1,
              ),
            ],
            const Spacer(),
            // Desktop: Font Size Controls
            if (!isMobile) ...[
              _buildFontSizeControls(),
              const SizedBox(width: 16),
            ],
            // Backend status indicator (simplified on mobile)
            if (isMobile)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isBackendHealthy
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isBackendHealthy
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isBackendHealthy
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isBackendHealthy
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isBackendHealthy ? 'Connected' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isBackendHealthy
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            // Desktop only: refresh and profile
            if (!isMobile) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: _checkBackendHealth,
                tooltip: 'Refresh connection',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // User profile
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: Icon(
                        Icons.person_rounded,
                        color: const Color(0xFF08012D),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => _onNavigationTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.15)
                : isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE53E51),
                      width: 2,
                    ),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeControls() {
    final fontSizeProvider = context.watch<FontSizeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Font size icon
          Icon(
            Icons.text_fields_rounded,
            color: Colors.white.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 8),
          // Decrease button
          _buildFontSizeButton(
            icon: Icons.remove,
            onPressed: fontSizeProvider.fontScale > FontSizeProvider.small
                ? () => fontSizeProvider.decrease()
                : null,
            tooltip: 'Decrease font size',
          ),
          // Current size indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              fontSizeProvider.currentSizeLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Increase button
          _buildFontSizeButton(
            icon: Icons.add,
            onPressed: fontSizeProvider.fontScale < FontSizeProvider.extraLarge
                ? () => fontSizeProvider.increase()
                : null,
            tooltip: 'Increase font size',
          ),
          const SizedBox(width: 4),
          // Reset button
          _buildFontSizeButton(
            icon: Icons.restart_alt_rounded,
            onPressed: fontSizeProvider.fontScale != FontSizeProvider.medium
                ? () => fontSizeProvider.reset()
                : null,
            tooltip: 'Reset font size',
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: onPressed != null
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: onPressed != null
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBackendOfflineWidget() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Backend Server Not Running',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Please start the backend server to use this application.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To start the backend:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Open terminal'),
                    const Text('2. Navigate to project directory'),
                    const Text('3. Run: python api.py'),
                    const SizedBox(height: 8),
                    Text(
                      'Expected URL: ${AppConfig.apiBaseUrl}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkBackendHealth,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
