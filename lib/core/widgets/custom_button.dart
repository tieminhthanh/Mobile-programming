import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outlined, danger, ghost }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _ButtonConfig.fromVariant(variant, context);
    final sizeConfig = _ButtonSizeConfig.fromSize(size);

    final child = isLoading
        ? SizedBox(
            width: sizeConfig.iconSize,
            height: sizeConfig.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: config.foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: sizeConfig.iconSize, color: config.foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: sizeConfig.fontSize,
                  fontWeight: FontWeight.w600,
                  color: config.foreground,
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 6),
                Icon(suffixIcon, size: sizeConfig.iconSize, color: config.foreground),
              ],
            ],
          );

    final button = variant == ButtonVariant.outlined || variant == ButtonVariant.ghost
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: config.foreground,
              side: variant == ButtonVariant.outlined
                  ? BorderSide(color: config.border ?? config.foreground)
                  : BorderSide.none,
              backgroundColor: config.background,
              minimumSize: Size(0, sizeConfig.height),
              padding: sizeConfig.padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: config.background,
              foregroundColor: config.foreground,
              disabledBackgroundColor: config.background?.withOpacity(0.6),
              minimumSize: Size(0, sizeConfig.height),
              padding: sizeConfig.padding,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: child,
          );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class _ButtonConfig {
  final Color? background;
  final Color foreground;
  final Color? border;

  const _ButtonConfig({
    this.background,
    required this.foreground,
    this.border,
  });

  factory _ButtonConfig.fromVariant(ButtonVariant variant, BuildContext context) {
    const primary = Color(0xFF09F6AB);
    const primaryDark = Color(0xFF07C98B);
    const onPrimary = Color(0xFF0F172A);
    const textPrimary = Color(0xFF0F172A);
    const borderColor = Color(0xFFE2E8F0);
    const errorColor = Color(0xFFB91C1C);
    const errorBg = Color(0xFFFEE2E2);

    switch (variant) {
      case ButtonVariant.primary:
        return const _ButtonConfig(background: primary, foreground: onPrimary);
      case ButtonVariant.secondary:
        return const _ButtonConfig(background: primaryDark, foreground: onPrimary);
      case ButtonVariant.outlined:
        return const _ButtonConfig(
          background: Colors.transparent,
          foreground: textPrimary,
          border: borderColor,
        );
      case ButtonVariant.danger:
        return const _ButtonConfig(background: errorBg, foreground: errorColor);
      case ButtonVariant.ghost:
        return const _ButtonConfig(
          background: Colors.transparent,
          foreground: textPrimary,
        );
    }
  }
}

class _ButtonSizeConfig {
  final double height;
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;

  const _ButtonSizeConfig({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.padding,
  });

  factory _ButtonSizeConfig.fromSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const _ButtonSizeConfig(
          height: 36,
          fontSize: 13,
          iconSize: 14,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        );
      case ButtonSize.medium:
        return const _ButtonSizeConfig(
          height: 48,
          fontSize: 15,
          iconSize: 16,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        );
      case ButtonSize.large:
        return const _ButtonSizeConfig(
          height: 56,
          fontSize: 16,
          iconSize: 18,
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        );
    }
  }
}