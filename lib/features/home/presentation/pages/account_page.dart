// lib/features/home/account_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // BLPID Logo Background
          Positioned(
            top: -50,
            right: -100,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/blpid_logo.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(context),

                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Card
                        _buildProfileCard(),
                        const SizedBox(height: 24),

                        // Settings Options
                        _buildSettingsSection(context),
                        const SizedBox(height: 100),
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

  Widget _buildAppBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
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
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.8),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Handle edit profile
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'MW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(delay: const Duration(milliseconds: 100)),

              const SizedBox(height: 16),

              // Name
              const Text(
                'Muhammad Wibisono',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200)),

              const SizedBox(height: 4),

              // Email
              Text(
                'wibisono@example.com',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 300)),

              const SizedBox(height: 16),

              // Verified Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Verified Account',
                      style: TextStyle(
                        color: Colors.greenAccent.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 400))
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final settings = [
      {'icon': Icons.person_outline, 'title': 'Personal Information', 'subtitle': 'Manage your profile'},
      {'icon': Icons.security, 'title': 'Security', 'subtitle': 'Password & authentication'},
      {'icon': Icons.privacy_tip_outlined, 'title': 'Privacy', 'subtitle': 'Data & permissions'},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'subtitle': 'Alert preferences'},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'subtitle': 'Get assistance'},
      {'icon': Icons.info_outline, 'title': 'About', 'subtitle': 'App information'},
      {'icon': Icons.logout, 'title': 'Logout', 'subtitle': 'Sign out of account', 'isLogout': true},
    ];

    return Column(
      children: settings.asMap().entries.map((entry) {
        final index = entry.key;
        final setting = entry.value;
        final isLogout = setting['isLogout'] == true;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isLogout) {
              // Handle logout
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isLogout
                      ? Colors.redAccent.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLogout
                    ? Colors.redAccent.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLogout
                            ? Colors.redAccent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        setting['icon'] as IconData,
                        color: isLogout
                            ? Colors.redAccent
                            : Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            setting['title'] as String,
                            style: TextStyle(
                              color: isLogout ? Colors.redAccent : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            setting['subtitle'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }
}