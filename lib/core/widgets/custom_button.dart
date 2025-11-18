import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

enum ButtonVariant { primary, secondary, outlined, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool fullWidth;
  final Color? customColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.fullWidth = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading;

    Widget buttonChild = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: _getTextColor(context),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: _getTextColor(context),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: _getTextStyle(context),
        ),
      ],
    );

    final buttonStyle = _getButtonStyle(context);

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: variant == ButtonVariant.outlined
          ? OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: buttonChild,
      )
          : variant == ButtonVariant.text
          ? TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final foregroundColor = _getTextColor(context);
    final side = _getBorderSide(context);
    final overlayColor = _getOverlayColor(context);

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      overlayColor: WidgetStateProperty.all(overlayColor),
      side: WidgetStateProperty.all(side),
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (customColor != null) return customColor!;

    if (!isDisabled && !isLoading) {
      switch (variant) {
        case ButtonVariant.primary:
          return Theme.of(context).colorScheme.primary;
        case ButtonVariant.secondary:
          return Theme.of(context).colorScheme.secondary;
        case ButtonVariant.danger:
          return AppColors.error;
        case ButtonVariant.outlined:
        case ButtonVariant.text:
          return Colors.transparent;
      }
    }
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.12);
  }

  Color _getTextColor(BuildContext context) {
    if (customColor != null && variant == ButtonVariant.primary) {
      return Colors.white;
    }

    if (!isDisabled && !isLoading) {
      switch (variant) {
        case ButtonVariant.primary:
          return Theme.of(context).colorScheme.onPrimary;
        case ButtonVariant.secondary:
          return Theme.of(context).colorScheme.onSecondary;
        case ButtonVariant.danger:
          return AppColors.white;
        case ButtonVariant.outlined:
          return Theme.of(context).colorScheme.primary;
        case ButtonVariant.text:
          return Theme.of(context).colorScheme.primary;
      }
    }
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = TextStyles.buttonMedium;

    if (!isDisabled && !isLoading) {
      return baseStyle.copyWith(
        color: _getTextColor(context),
      );
    }

    return baseStyle.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
    );
  }

  BorderSide? _getBorderSide(BuildContext context) {
    if (variant == ButtonVariant.outlined && !isDisabled && !isLoading) {
      return BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1,
      );
    }
    if (variant == ButtonVariant.danger && !isDisabled && !isLoading) {
      return BorderSide(
        color: AppColors.error,
        width: 1,
      );
    }
    return null;
  }

  Color _getOverlayColor(BuildContext context) {
    if (!isDisabled && !isLoading) {
      final baseColor = _getTextColor(context);
      return baseColor.withOpacity(0.1);
    }
    return Colors.transparent;
  }
}

// Convenience button variants
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
      fullWidth: fullWidth,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final bool fullWidth;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
      fullWidth: fullWidth,
    );
  }
}

// Renamed to avoid conflict with Flutter's OutlinedButton
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final bool fullWidth;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
      fullWidth: fullWidth,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final bool fullWidth;

  const DangerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.danger,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
      fullWidth: fullWidth,
    );
  }
}
