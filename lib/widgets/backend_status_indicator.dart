import 'package:flutter/material.dart';

/// Widget to display backend connection status
class BackendStatusIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isUsingBackend;
  final VoidCallback? onTap;

  const BackendStatusIndicator({
    Key? key,
    required this.isConnected,
    required this.isUsingBackend,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBackgroundColor(),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getIndicatorColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIndicatorColor() {
    if (!isConnected) return Colors.red;
    return isUsingBackend ? Colors.green : Colors.orange;
  }

  Color _getBackgroundColor() {
    if (!isConnected) return Colors.red;
    return isUsingBackend ? Colors.green : Colors.orange;
  }

  Color _getTextColor() {
    if (!isConnected) return Colors.red;
    return isUsingBackend ? Colors.green : Colors.orange;
  }

  String _getStatusText() {
    if (!isConnected) return 'Backend Offline';
    return isUsingBackend ? 'Backend API' : 'Gemini Direct';
  }
}

/// Detailed backend status dialog
class BackendStatusDialog extends StatelessWidget {
  final bool isConnected;
  final bool isUsingBackend;
  final VoidCallback? onToggleBackend;
  final VoidCallback? onRefreshStatus;

  const BackendStatusDialog({
    Key? key,
    required this.isConnected,
    required this.isUsingBackend,
    this.onToggleBackend,
    this.onRefreshStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Backend Connection Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow(
            'Backend Server',
            isConnected ? 'Connected' : 'Disconnected',
            isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            'Current Mode',
            isUsingBackend ? 'Backend API' : 'Direct Gemini API',
            isUsingBackend ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildFeatureList(),
        ],
      ),
      actions: [
        if (onRefreshStatus != null)
          TextButton.icon(
            onPressed: () {
              onRefreshStatus!();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        if (isConnected && onToggleBackend != null)
          TextButton.icon(
            onPressed: () {
              onToggleBackend!();
              Navigator.of(context).pop();
            },
            icon: Icon(isUsingBackend ? Icons.cloud_off : Icons.cloud),
            label: Text(isUsingBackend ? 'Use Gemini Direct' : 'Use Backend'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _buildFeatureItem(
          'Database Persistence',
          isUsingBackend,
        ),
        _buildFeatureItem(
          'OEE Analytics',
          isUsingBackend,
        ),
        _buildFeatureItem(
          'Mining-specific Insights',
          isUsingBackend,
        ),
        _buildFeatureItem(
          'Session Management',
          isUsingBackend,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              fontSize: 13,
              color: enabled ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
