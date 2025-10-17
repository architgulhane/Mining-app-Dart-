import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E7EB).withOpacity(0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'View and edit your profile',
                    showAvatar: true,
                    onTap: () {},
                  ),
                  Divider(height: 1, color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.star,
                    title: 'Subscription',
                    subtitle: 'Manage your subscription',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.storage,
                    title: 'Data Sources',
                    subtitle: 'Manage data source connections',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Configure notification preferences',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.contrast,
                    title: 'Appearance',
                    subtitle: 'Customize app appearance',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Support Section
            _buildSectionHeader('Support'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.help_center,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.alternate_email,
                    title: 'Contact Us',
                    subtitle: 'Contact us for assistance',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.feedback,
                    title: 'Feedback',
                    subtitle: 'Provide feedback',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showAvatar = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon or Avatar
              if (showAvatar)
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(28),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDZwnBLjNQAYpm-kyXUokDFsH2FuqWsXLoTxSkRSX8_BpfSbBEJOCZQaeaPDCdhEk7IzL0pMRvZ5U2hC56o8xjh44V-xrHL1f_W6I_WcYQlcwRDP1Wt4Rznuuzj5Vi6rpx4Nc9DXkipj55nXsXF1JlQTtR9PkU2EiXCGN7MZPLqL3vM2WmpyEIlMF87PuyDqD-oMEqAS6HHW6AqId8MGaHrsPC_sGIODnLR2GTa6GPYTIS_GrZKeaR9ku-R6iFz4eiOAvf2zZSrwDcg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1193D4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1193D4),
                    size: 24,
                  ),
                ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
