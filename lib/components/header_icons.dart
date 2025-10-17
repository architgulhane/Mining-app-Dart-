import 'package:flutter/material.dart';

class HeaderIcons extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onRefreshTap;
  final VoidCallback? onHelpTap;
  
  const HeaderIcons({
    super.key,
    this.onSettingsTap,
    this.onRefreshTap,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _HeaderIconButton(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onTap: onRefreshTap,
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.help_outline,
            tooltip: 'Help',
            onTap: onHelpTap,
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
