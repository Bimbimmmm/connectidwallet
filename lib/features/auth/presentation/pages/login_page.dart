import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Simulasi proses login (tidak memanggil OAuth)
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF284074),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + 2 * _backgroundController.value,
                        -1 + 2 * _backgroundController.value),
                    end: Alignment(1 - 2 * _backgroundController.value,
                        1 - 2 * _backgroundController.value),
                    colors: const [
                      Color(0xFF284074),
                      Color(0xFF3A5298),
                      Color(0xFF1E325C),
                      Color(0xFF284074),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating orbs
          ..._buildFloatingOrbs(size),

          // Main content
          SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Glass card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo (fallback jika asset tidak ada)
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
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/BLPID.png',
                                        width: 60,
                                        height: 60,
                                        errorBuilder: (context, error, stack) {
                                          return const Icon(
                                            Icons.fingerprint,
                                            size: 50,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .scale(
                                    delay:
                                    const Duration(milliseconds: 300),
                                    duration:
                                    const Duration(milliseconds: 600),
                                    curve: Curves.elasticOut,
                                  )
                                      .shimmer(
                                    delay: const Duration(seconds: 1),
                                    duration: const Duration(seconds: 2),
                                    color: Colors.white.withOpacity(0.3),
                                  ),

                                  const SizedBox(height: 32),

                                  // Welcome text
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [Colors.white, Color(0xFFE0E0E0)],
                                        ).createShader(bounds),
                                    child: const Text(
                                      'Selamat Datang di',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                    delay:
                                    const Duration(milliseconds: 500),
                                    duration:
                                    const Duration(milliseconds: 800),
                                  )
                                      .slideY(
                                    begin: 0.3,
                                    end: 0,
                                    delay:
                                    const Duration(milliseconds: 500),
                                  ),

                                  const SizedBox(height: 8),

                                  // App name
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.9),
                                        const Color(0xFFB8D4F0),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'CONNECTIDWALLET',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                        height: 1.2,
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                    delay:
                                    const Duration(milliseconds: 700),
                                    duration:
                                    const Duration(milliseconds: 800),
                                  )
                                      .slideY(
                                    begin: 0.3,
                                    end: 0,
                                    delay:
                                    const Duration(milliseconds: 700),
                                  ),

                                  const SizedBox(height: 48),

                                  // Button "Login" (dummy) — gambar proporsional memenuhi tombol
                                  GestureDetector(
                                    onTap: _isLoading ? null : _handleLogin,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: 50,
                                      width: 150,
                                      //width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _isLoading
                                              ? [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]
                                              : [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.25),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF284074).withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [

                                              SizedBox.expand(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                    'assets/images/login.png',
                                                    filterQuality: FilterQuality.high,
                                                    errorBuilder: (c, e, s) => const SizedBox(), // fallback silent
                                                  ),
                                                ),
                                              ),


                                              if (_isLoading)
                                                Container(color: Colors.white.withOpacity(0.15)),


                                              if (_isLoading)
                                                const Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor:
                                                      AlwaysStoppedAnimation<Color>(Color(0xFF284074)),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                    delay:
                                    const Duration(milliseconds: 900),
                                    duration:
                                    const Duration(milliseconds: 800),
                                  )
                                      .slideY(
                                    begin: 0.5,
                                    end: 0,
                                    delay:
                                    const Duration(milliseconds: 900),
                                  ),

                                  const SizedBox(height: 24),

                                  // Security badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_user,
                                            size: 16,
                                            color:
                                            Colors.white.withOpacity(0.9)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Powered By BLPID - BSSN',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                            Colors.white.withOpacity(0.9),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                    delay: const Duration(
                                        milliseconds: 1100),
                                    duration:
                                    const Duration(milliseconds: 800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                          duration: const Duration(milliseconds: 1000),
                        )
                            .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),

                // Bottom logos (opsional)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chipLogo('assets/images/BLPID.png', Icons.security),
                      const SizedBox(width: 16),
                      Container(
                        height: 32,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 16),
                      _chipLogo('assets/images/bssn_logo.png',
                          Icons.verified_user),
                    ],
                  )
                      .animate()
                      .fadeIn(
                    delay: const Duration(milliseconds: 1300),
                    duration: const Duration(milliseconds: 800),
                  )
                      .slideY(
                    begin: 1,
                    end: 0,
                    delay: const Duration(milliseconds: 1300),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipLogo(String asset, IconData fallback) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Image.asset(
        asset,
        height: 32,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            fallback,
            size: 32,
            color: Colors.white.withOpacity(0.6),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(Size size) {
    return [
      AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Positioned(
            top: size.height * 0.1 + (30 * _floatingController.value),
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Positioned(
            bottom: size.height * 0.2 - (30 * _floatingController.value),
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B7FBB).withOpacity(0.2),
                    const Color(0xFF5B7FBB).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Positioned(
            top: size.height * 0.4 + (20 * _floatingController.value),
            right: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white54, Colors.transparent],
                ),
              ),
            ),
          );
        },
      ),
      ...List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Positioned(
              top: size.height * (0.2 + index * 0.15) +
                  (15 *
                      _floatingController.value *
                      (index.isEven ? 1 : -1)),
              left: size.width * (0.1 + index * 0.2),
              child: Container(
                width: 30 + (index * 10),
                height: 30 + (index * 10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white38, Colors.transparent],
                  ),
                ),
              ),
            );
          },
        );
      }),
    ];
  }
}
