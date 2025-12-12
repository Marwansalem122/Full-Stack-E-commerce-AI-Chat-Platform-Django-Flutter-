import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:stylish_admin/core/theme/theme.dart';
import 'package:stylish_admin/core/utils/responsive_helper.dart';
import 'package:stylish_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stylish_admin/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  final String? errorMessage;
  const LoginPage({super.key, this.errorMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  final _particleSystem = ParticleSystem();

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.errorMessage!,
              style: AppTheme.bodyMedium().copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.negative,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTheme.bodyMedium().copyWith(color: Colors.white),
                ),
                backgroundColor: AppTheme.negative,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // animated background
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _particleSystem.createPainter(
                    _backgroundController.value,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryDark.withAlpha((0.9 * 255).round()),
                          AppTheme.primaryMedium.withAlpha((0.7 * 255).round()),
                          AppTheme.primaryLight.withAlpha((0.5 * 255).round()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            ..._buildDecorativeElements(),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isMobile(context)
                        ? AppTheme.spacingMedium
                        : 0,
                  ),
                  child: GlassmorphicContainer(
                    width: ResponsiveHelper.isMobile(context)
                        ? double.infinity
                        : 450,
                    height: 600,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.bottomCenter,
                    border: 2,
                    linearGradient: LinearGradient(
                      colors: [
                        AppTheme.textPrimary.withAlpha((0.1 * 255).round()),
                        AppTheme.textPrimary.withAlpha((0.05 * 255).round()),
                      ],
                      stops: const [0.1, 1],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        AppTheme.textPrimary.withAlpha((0.5 * 255).round()),
                        AppTheme.textPrimary.withAlpha((0.1 * 255).round()),
                      ],
                      stops: const [0.1, 1],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingLarge),
                      child: const LoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeElements() {
    return [
      // Top left Decorative circle
      Positioned(
        top: -100,
        left: -100,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.accentBlue.withAlpha((0.3 * 255).round()),
                AppTheme.accentPurple.withAlpha((0.3 * 255).round()),
              ],
            ),
          ),
        ),
      ),
      // Bottom right Decorative circle
      Positioned(
        bottom: -150,
        right: -150,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.accentGreen.withAlpha((0.3 * 255).round()),
                AppTheme.accentOrange.withAlpha((0.3 * 255).round()),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class ParticleSystem {
  final List<Particle> _particles = List.generate(100, (index) => Particle());
  CustomPainter createPainter(double progress) {
    return _ParticlePainter(_particles, progress);
  }
}

class Particle {
  late double x;
  late double y;
  late double radius;
  late Color color;
  final double speed;
  Particle() : speed = Random().nextDouble() * 0.5 + 0.1 {
    reset();
  }

  void reset() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    radius = random.nextDouble() * 3 + 1;
    color = Color.fromRGBO(
      random.nextInt(100) + 100,
      random.nextInt(100) + 100,
      random.nextInt(200) + 50,
      random.nextDouble() * 0.3 + 0.1,
    );
  }

  void update(double progress) {
    x += (sin(progress * 2 * pi + x * 10) * 0.001 * speed);
    y += (sin(progress * 2 * pi + x * 10) * 0.001 * speed);

    // Wrap around
    x = x % 1;
    y = y % 1;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  _ParticlePainter(this.particles, this.progress) {
    for (var particle in particles) {
      particle.update(progress);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
