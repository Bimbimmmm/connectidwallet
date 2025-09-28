// lib/features/home/menu/presentation/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/services/keycloak_session_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final KeycloakSessionService _sessionService = KeycloakSessionService();

  List<LoginEvent> _loginHistory = [];
  bool _isLoading = false;

  // Dummy data untuk Identity Usage (tetap menggunakan dummy)
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
    {
      'date': '20 Nov 2024, 11:20',
      'identity': 'KTP Digital',
      'issuer': 'Dukcapil',
      'verifier': 'Tokopedia',
      'status': 'failed',
      'purpose': 'Seller Verification',
      'type': 'verification',
    },
    {
      'date': '19 Nov 2024, 09:30',
      'identity': 'Sertifikat Vaksin',
      'issuer': 'Kemenkes',
      'verifier': 'Traveloka',
      'status': 'success',
      'purpose': 'Travel Requirement',
      'type': 'verification',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLoginHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLoginHistory() async {
    setState(() => _isLoading = true);
    try {
      // Coba mendapatkan events dari Keycloak
      final events = await _sessionService.getMyEvents(max: 50);
      if (!mounted) return;

      setState(() {
        _loginHistory = events;
        _isLoading = false;
      });

      // Show info jika menggunakan mock/fallback data
      if (events.isNotEmpty && events.first.id.startsWith('evt-sess-')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Menampilkan history dari session data'),
            backgroundColor: Colors.orange.withOpacity(0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      debugPrint('Error loading login history: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat riwayat login: ${e.toString()}'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF284074),
      body: Stack(
        children: [
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

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
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
                onTap: () {
                  HapticFeedback.lightImpact();
                  _loadLoginHistory(); // Refresh login history
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
                    Icons.refresh_rounded,
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

                Text(
                  item['identity'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildInfoChip('Issuer', item['issuer'], Icons.business_rounded),
                    const SizedBox(width: 12),
                    _buildInfoChip('Verifier', item['verifier'], Icons.verified_user_rounded),
                  ],
                ),
                const SizedBox(height: 8),

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

  Widget _buildAppLoginTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_loginHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat login',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat login aplikasi akan muncul di sini',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLoginHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _loginHistory.length,
      itemBuilder: (context, index) =>
          _buildLoginHistoryItem(_loginHistory[index], index),
    );
  }

  Widget _buildLoginHistoryItem(LoginEvent event, int index) {
    final bool isSuccess = event.isSuccess;

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
                      event.eventTimeFormatted,
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
                        event.statusText,
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

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isSuccess ? Colors.greenAccent : Colors.redAccent).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isSuccess ? Colors.greenAccent : Colors.redAccent).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getAppIcon(event.clientId),
                        color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login to ${event.clientName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Event: ${event.type}',
                            style: TextStyle(
                              color: Colors.blueAccent.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (event.ipAddress != null) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        'IP: ${event.ipAddress}',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                if (event.error != null) ...[
                  Row(
                    children: [
                      Icon(Icons.error_outline, size: 14, color: Colors.redAccent.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Error: ${event.error}',
                          style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      _formatEventDate(event.eventTime),
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),

                if (event.details != null && event.details!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...event.details!.entries.take(3).map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
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

  String _formatEventDate(DateTime eventTime) {
    final now = DateTime.now();
    final difference = now.difference(eventTime);

    if (difference.inDays == 0) {
      // Today
      return '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // This week
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[eventTime.weekday - 1]} ${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Older
      return '${eventTime.day}/${eventTime.month}/${eventTime.year}';
    }
  }

  IconData _getAppIcon(String clientId) {
    switch (clientId.toLowerCase()) {
      case 'wallet-id':
        return Icons.account_balance_wallet_rounded;
      case 'tokopedia-client':
        return Icons.shopping_bag_rounded;
      case 'gojek-client':
        return Icons.motorcycle_rounded;
      case 'shopee-client':
        return Icons.shopping_cart_rounded;
      case 'bca-client':
      case 'bank-bca':
        return Icons.account_balance_rounded;
      case 'garuda-indonesia':
        return Icons.flight_rounded;
      case 'traveloka':
        return Icons.travel_explore_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

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