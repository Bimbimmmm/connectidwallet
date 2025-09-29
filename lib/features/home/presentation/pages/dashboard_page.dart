// lib/features/home/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

import '../../menu/presentation/pages/linked_idp_page.dart';
import '../../menu/presentation/pages/active_session_page.dart';
import '../../menu/presentation/pages/history_page.dart';
import '../../menu/presentation/pages/id_vault_page.dart';
import '../../../../core/services/connectidn_auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late final AnimationController _cardController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _cardsController = ScrollController();
  final ConnectIDNAuthService _authService = ConnectIDNAuthService();

  String _userName = 'User'; // Default name
  String? _firstName;
  String? _lastName;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          if (user.name != null && user.name!.isNotEmpty) {
            _userName = user.name!;
          } else {
            _userName = user.preferredUsername ?? user.email ?? 'User';
          }
        });
      }

      final userInfo = await _authService.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _firstName = userInfo['given_name'] ?? userInfo['firstName'];
          _lastName = userInfo['family_name'] ?? userInfo['lastName'];

          if (_firstName != null || _lastName != null) {
            _userName = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
          } else if (userInfo['name'] != null) {
            _userName = userInfo['name'];
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _scrollController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  void _handleCallCenter() => HapticFeedback.lightImpact();
  void _handleSettings() => HapticFeedback.lightImpact();

  // ============================================
  // TAMBAHAN: HANDLER LOGOUT
  // ============================================
  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildLogoutDialog(),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        // Call logout service
        final success = await _authService.logout();

        if (mounted) {
          if (success) {
            // Navigate to login page and clear all previous routes
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
            );

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Logged out successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else {
            // Show error message but still navigate to login
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Logout completed (with errors)'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildLogoutDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E325C),
              Color(0xFF284074),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to logout from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ============================================
  // END TAMBAHAN LOGOUT
  // ============================================

  void _navigateToMenu(int index) {
    HapticFeedback.lightImpact();

    Widget? targetPage;
    switch (index) {
      case 0:
        targetPage = const LinkedIDPPage();
        break;
      case 1:
        targetPage = const ActiveSessionPage();
        break;
      case 2:
        targetPage = const HistoryPage();
        break;
      case 3:
        targetPage = const IDVaultPage();
        break;
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => targetPage!,
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -100,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/BLPID.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          _buildWelcomeSection(),

                          const SizedBox(height: 24),

                          _buildCardsSection(),

                          const SizedBox(height: 32),

                          _buildMainMenuSection(),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================
          // TAMBAHAN: LOADING OVERLAY SAAT LOGOUT
          // ============================================
          if (_isLoggingOut)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          // ============================================
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container
          (
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo/Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.8)],
                ).createShader(bounds),
                child: const Text(
                  'CONNECTIDWALLET',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),

              Row(
                children: [
                  _buildAppBarIcon(Icons.headset_mic_rounded, _handleCallCenter),
                  const SizedBox(width: 8),
                  _buildAppBarIcon(Icons.settings_rounded, _handleSettings),
                  const SizedBox(width: 8),
                  _buildAppBarIcon(Icons.logout_rounded, _handleLogout),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.9)),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello,',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 500))
            .slideX(begin: -0.2, end: 0),

        const SizedBox(height: 4),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFB8D4F0)],
          ).createShader(bounds),
          child: Text(
            _userName, // Gunakan nama dinamis
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 200))
            .slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Credentials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _cardsController, // ⬅️ controller khusus (horizontal)
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildCredentialCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialCard(int index) {
    final cardTypes = ['KTP Digital', 'SIM Digital', 'Passport Digital'];
    final issuers = ['Dukcapil', 'Korlantas', 'Imigrasi'];
    final holders = ['Bima Satria Yudha Mohammad', 'Bima Satria Yudha Mohammad', 'Bima Satria Yudha Mohammad'];
    final dates = ['Verified: 20 Jan 2024', 'Verified: 15 Feb 2024', 'Verified: 10 Mar 2024'];

    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: AnimatedBuilder(
        animation: _cardController,
        builder: (context, child) {
          return Container(
            width: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cardTypes[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              issuers[index],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holders[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified, size: 16, color: Colors.greenAccent.withOpacity(0.9)),
                                  const SizedBox(width: 4),
                                  Text(
                                    dates[index],
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildCardAction(Icons.qr_code_2_rounded),
                                  const SizedBox(width: 8),
                                  _buildCardAction(Icons.edit_rounded),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
        .slideX(begin: 0.5, end: 0);
  }

  Widget _buildCardAction(IconData icon) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.9)),
      ),
    );
  }

  Widget _buildMainMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Menu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMenuItem(
              icon: Icons.link_rounded,
              title: 'Linked IDP',
              subtitle: 'Identity Providers',
              index: 0,
            ),
            _buildMenuItem(
              icon: Icons.devices_rounded,
              title: 'Active Session',
              subtitle: 'Manage devices',
              index: 1,
            ),
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'History',
              subtitle: 'Activity logs',
              index: 2,
            ),
            _buildMenuItem(
              icon: Icons.shield_rounded,
              title: 'ID Vault',
              subtitle: 'Secure storage',
              index: 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _navigateToMenu(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.white.withOpacity(0.9)),
                  const SizedBox(height: 8),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}