// lib/features/home/menu/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Map<String, dynamic>> _identityUsageHistory = [
    {
      'date': '22 Nov 2024, 14:30',
      'identity': 'KTP Digital',
      'issuer': 'Dukcapil',
      'verifier': 'Bank BCA',
      'status': 'success',
      'purpose': 'Account Verification',
      'type': 'verification',
    },
    {
      'date': '22 Nov 2024, 10:15',
      'identity': 'SIM Digital',
      'issuer': 'Korlantas',
      'verifier': 'Gojek',
      'status': 'success',
      'purpose': 'Driver Registration',
      'type': 'verification',
    },
    {
      'date': '21 Nov 2024, 16:45',
      'identity': 'Passport Digital',
      'issuer': 'Imigrasi',
      'verifier': 'Garuda Indonesia',
      'status': 'success',
      'purpose': 'Flight Check-in',
      'type': 'verification',
    },
  ];

  final List<Map<String, dynamic>> _appLoginHistory = [
    {
      'date': '22 Nov 2024, 14:28',
      'appName': 'Bank BCA',
      'idpUsed': 'Privy',
      'status': 'success',
      'device': 'Chrome on Windows',
      'location': 'Jakarta, Indonesia',
      'type': 'login',
    },
    {
      'date': '22 Nov 2024, 10:10',
      'appName': 'Gojek',
      'idpUsed': 'BSrE',
      'status': 'success',
      'device': 'Mobile App - Android',
      'location': 'Bandung, Indonesia',
      'type': 'login',
    },
    {
      'date': '21 Nov 2024, 16:40',
      'appName': 'Garuda Indonesia',
      'idpUsed': 'BKN',
      'status': 'success',
      'device': 'Safari on iPhone',
      'location': 'Jakarta, Indonesia',
      'type': 'login',
    },
    {
      'date': '20 Nov 2024, 09:00',
      'appName': 'Tokopedia',
      'idpUsed': 'BLPID',
      'status': 'failed',
      'device': 'Firefox on Mac',
      'location': 'Surabaya, Indonesia',
      'type': 'login',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF284074),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF284074),
                  const Color(0xFF3A5298).withOpacity(0.8),
                  const Color(0xFF1E325C),
                ],
              ),
            ),
          ),

          // Logo watermark
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
                errorBuilder: (context, error, stack) => Container(
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

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),

                // Tab bar
                _buildTabBar(),

                // Tab contents
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIdentityUsageTab(),
                      _buildAppLoginTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====== AppBar ======
  Widget _buildAppBar() {
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
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
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
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.8)],
                  ).createShader(bounds),
                  child: const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
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
                    Icons.filter_list_rounded,
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

  // ====== Tabs ======
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            tabs: const [
              Tab(text: 'Identity Usage'),
              Tab(text: 'App Logins'),
            ],
          ),
        ),
      ),
    );
  }

  // ====== Identity Usage Tab ======
  Widget _buildIdentityUsageTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _identityUsageHistory.length,
      itemBuilder: (context, index) =>
          _buildIdentityHistoryItem(_identityUsageHistory[index], index),
    );
  }

  Widget _buildIdentityHistoryItem(Map<String, dynamic> item, int index) {
    final bool isSuccess = item['status'] == 'success';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // date + status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isSuccess
                            ? Colors.greenAccent
                            : Colors.redAccent)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (isSuccess
                              ? Colors.greenAccent
                              : Colors.redAccent)
                              .withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        isSuccess ? 'Success' : 'Failed',
                        style: TextStyle(
                          color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // identity title
                Text(
                  item['identity'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // issuer + verifier chips
                Row(
                  children: [
                    _buildInfoChip('Issuer', item['issuer'], Icons.business_rounded),
                    const SizedBox(width: 12),
                    _buildInfoChip('Verifier', item['verifier'], Icons.verified_user_rounded),
                  ],
                ),
                const SizedBox(height: 8),

                // purpose
                Text(
                  item['purpose'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
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
  }

  // ====== App Logins Tab ======
  Widget _buildAppLoginTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _appLoginHistory.length,
      itemBuilder: (context, index) =>
          _buildLoginHistoryItem(_appLoginHistory[index], index),
    );
  }

  Widget _buildLoginHistoryItem(Map<String, dynamic> item, int index) {
    final bool isSuccess = item['status'] == 'success';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // date + status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isSuccess
                            ? Colors.greenAccent
                            : Colors.redAccent)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (isSuccess
                              ? Colors.greenAccent
                              : Colors.redAccent)
                              .withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        isSuccess ? 'Success' : 'Failed',
                        style: TextStyle(
                          color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // title
                Text(
                  'Login to ${item['appName']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.fingerprint, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'via ${item['idpUsed']}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.devices, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      item['device'],
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      item['location'],
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
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
  }

  // ====== Shared small widgets ======
  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                  ),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
