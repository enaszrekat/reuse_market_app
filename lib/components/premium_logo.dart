import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium Logo Component
/// Clean, luxury branding for graduation project
/// Uses actual logo image from assets
class PremiumLogo extends StatelessWidget {
  final double? height;
  final bool showSubtitle;
  final bool compact;

  const PremiumLogo({
    super.key,
    this.height,
    this.showSubtitle = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactLogo();
    }
    return _buildFullLogo();
  }

  Widget _buildFullLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Image - Display exactly as provided
        Image.asset(
          'assets/logo.png',
          height: height ?? 120,
          fit: BoxFit.contain,
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            'by Enas & Amera',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
              color: AppTheme.primaryGreen.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLogo() {
    return Image.asset(
      'assets/logo.png',
      height: height ?? 40,
      fit: BoxFit.contain,
    );
  }
}

/// Premium Logo with Icon Variant
/// Uses actual logo image from assets
class PremiumLogoWithIcon extends StatelessWidget {
  final double? height;
  final bool showSubtitle;

  const PremiumLogoWithIcon({
    super.key,
    this.height,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Image - Display exactly as provided
        Image.asset(
          'assets/logo.png',
          height: height ?? 140,
          fit: BoxFit.contain,
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            'by Enas & Amera',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
              color: AppTheme.primaryGreen.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Premium Brand Badge (for small spaces)
class PremiumBrandBadge extends StatelessWidget {
  final double size;

  const PremiumBrandBadge({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            const Color(0xFF50E5B7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'RM',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
