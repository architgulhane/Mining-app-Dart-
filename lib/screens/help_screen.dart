import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About & Help',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CogniSarthi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mining Operations Co-Pilot',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // About Section
            const _SectionTitle(title: 'About'),
            const SizedBox(height: 12),
            const Text(
              'CogniSarthi is an AI-powered mining operations co-pilot that helps you analyze and optimize your mining operations through natural language queries. Get instant insights on OEE, downtime, production metrics, and more.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            
            // SDGs Section
            const _SectionTitle(title: 'Contributing to Sustainable Development'),
            const SizedBox(height: 12),
            const Text(
              'This project aligns with the United Nations Sustainable Development Goals:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            _SDGCard(
              number: '9',
              title: 'Industry, Innovation and Infrastructure',
              description: 'Promoting sustainable industrialization and fostering innovation in mining operations.',
              color: const Color(0xFFFD6925),
            ),
            const SizedBox(height: 12),
            _SDGCard(
              number: '12',
              title: 'Responsible Consumption and Production',
              description: 'Optimizing resource use and reducing waste through data-driven insights.',
              color: const Color(0xFFBF8B2E),
            ),
            const SizedBox(height: 12),
            _SDGCard(
              number: '13',
              title: 'Climate Action',
              description: 'Reducing carbon footprint through improved operational efficiency.',
              color: const Color(0xFF3F7E44),
            ),
            const SizedBox(height: 32),
            
            // Features Section
            const _SectionTitle(title: 'Key Features'),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.chat_bubble_outline,
              title: 'Natural Language Queries',
              description: 'Ask questions in plain English and get instant answers',
            ),
            const _FeatureItem(
              icon: Icons.analytics_outlined,
              title: 'Real-time Analytics',
              description: 'View OEE, downtime, and production metrics',
            ),
            const _FeatureItem(
              icon: Icons.history,
              title: 'Query History',
              description: 'Access and export your previous analyses',
            ),
            const _FeatureItem(
              icon: Icons.dataset_outlined,
              title: 'Dataset Explorer',
              description: 'Browse and filter your raw operational data',
            ),
            const _FeatureItem(
              icon: Icons.settings_outlined,
              title: 'Customizable RAG',
              description: 'Configure retrieval-augmented generation parameters',
            ),
            const SizedBox(height: 32),
            
            // Documentation Link
            const _SectionTitle(title: 'Documentation'),
            const SizedBox(height: 12),
            _LinkCard(
              icon: Icons.book_outlined,
              title: 'User Guide',
              subtitle: 'Learn how to use all features',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _LinkCard(
              icon: Icons.code,
              title: 'API Documentation',
              subtitle: 'Technical reference for developers',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            
            // Contact Section
            const _SectionTitle(title: 'Contact & Feedback'),
            const SizedBox(height: 12),
            _LinkCard(
              icon: Icons.email_outlined,
              title: 'Send Feedback',
              subtitle: 'feedback@cognisarthi.com',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _LinkCard(
              icon: Icons.bug_report_outlined,
              title: 'Report an Issue',
              subtitle: 'Help us improve the app',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            
            // UI/UX Component Breakdown (Expandable)
            ExpansionTile(
              title: const Text(
                'UI/UX Component Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              subtitle: const Text(
                'Developer reference',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page Structure:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Splash Screen - Onboarding'),
                      Text('• Home Screen - Main chat interface'),
                      Text('• History Screen - Query history'),
                      Text('• Analytics Screen - Quick shortcuts'),
                      Text('• Dataset Explorer - Raw data view'),
                      Text('• Settings Modal - Configuration'),
                      Text('• Help Screen - This screen'),
                      SizedBox(height: 16),
                      Text(
                        'Key Components:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Sidebar (New Chat, History List, Footer)'),
                      Text('• Header Icons (Settings, Refresh, Help)'),
                      Text('• Welcome View (Prompts Grid)'),
                      Text('• Chat View (Messages, Tables, Charts)'),
                      Text('• Chat Input Bar (Text, Voice, Send)'),
                      Text('• Quick Prompts Grid (10 suggestions)'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Footer
            const Center(
              child: Text(
                '© 2024 CogniSarthi. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _SDGCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Color color;
  
  const _SDGCard({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _LinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4F46E5)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
        onTap: onTap,
      ),
    );
  }
}
