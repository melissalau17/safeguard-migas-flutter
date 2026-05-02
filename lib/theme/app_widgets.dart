import 'package:flutter/material.dart';
import 'app_colors.dart';

// ── Status Badge ──────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const StatusBadge({super.key, required this.label, required this.bg, required this.fg});

  factory StatusBadge.red(String label) =>
      StatusBadge(label: label, bg: AppColors.badgeRedBg, fg: AppColors.red);
  factory StatusBadge.yellow(String label) =>
      StatusBadge(label: label, bg: AppColors.badgeYellowBg, fg: AppColors.yellow);
  factory StatusBadge.green(String label) =>
      StatusBadge(label: label, bg: AppColors.badgeGreenBg, fg: AppColors.green);
  factory StatusBadge.blue(String label) =>
      StatusBadge(label: label, bg: AppColors.badgeBlueBg, fg: AppColors.blue);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}

// ── App Card ──────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.borderColor, this.backgroundColor, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: Border.all(color: borderColor ?? AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

// ── Progress Bar Row ──────────────────────────────────────
class BarRow extends StatelessWidget {
  final String label;
  final double fraction;
  final Color barColor;
  const BarRow({super.key, required this.label, required this.fraction, required this.barColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String initials;
  final Color bg;
  final Color fg;
  final double size;
  const UserAvatar({super.key, required this.initials, required this.bg, required this.fg, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(color: fg, fontSize: size * 0.35, fontWeight: FontWeight.w500)),
    );
  }
}

// ── Section Label ─────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.6, fontWeight: FontWeight.w500));
  }
}

// ── Toggle Switch (static, visual only) ──────────────────
class ToggleOn extends StatelessWidget {
  final bool on;
  const ToggleOn({super.key, this.on = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 20,
      decoration: BoxDecoration(
        color: on ? AppColors.green : AppColors.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Align(
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16, height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: on ? Colors.white : AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────
class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool showDot;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blueDark : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ]),
        if (showDot) Positioned(
          top: -2, right: -4,
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.navBg, width: 1.5),
            ),
          ),
        ),
      ]),
    );
  }
}