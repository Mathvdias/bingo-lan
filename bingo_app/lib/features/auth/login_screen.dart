import 'dart:io';
import 'package:bingo_app/features/auth/auth_view_model.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Column(
                    children: [
                      // Logo placeholder - you can add your logo here
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.casino,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bingo Lucca',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jogue bingo com amigos e família',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Error message
                  if (viewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Google Sign-In Button
                  _SignInButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final success = await viewModel.signInWithGoogle();
                            if (success && context.mounted) {
                              context.go('/lobby');
                            }
                          },
                    icon:
                        'assets/images/google_logo.png', // You'll need to add this
                    label: 'Continuar com Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    isLoading: viewModel.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Apple Sign-In Button (iOS only)
                  if (Platform.isIOS)
                    _SignInButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final success = await viewModel.signInWithApple();
                              if (success && context.mounted) {
                                context.go('/lobby');
                              }
                            },
                      icon:
                          'assets/images/apple_logo.png', // You'll need to add this
                      label: 'Continuar com Apple',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      isLoading: viewModel.isLoading,
                    ),

                  const SizedBox(height: 32),

                  // Terms and Privacy
                  Text(
                    'Ao continuar, você concorda com nossos\nTermos de Uso e Política de Privacidade',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;

  const _SignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: backgroundColor == Colors.white
                ? Colors.grey.shade300
                : Colors.transparent,
          ),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon would go here - for now using text
                Icon(
                  backgroundColor == Colors.white
                      ? Icons.g_mobiledata
                      : Icons.apple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
