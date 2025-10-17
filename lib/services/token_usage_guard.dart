import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to track, limit, and manage API token usage and costs
class TokenUsageGuard {
  static final TokenUsageGuard _instance = TokenUsageGuard._internal();
  factory TokenUsageGuard() => _instance;
  TokenUsageGuard._internal();
  
  static const String _usageHistoryKey = 'token_usage_history';
  static const String _dailyLimitKey = 'token_daily_limit';
  static const String _warningThresholdKey = 'token_warning_threshold';
  
  // Default limits
  static const int _defaultDailyLimit = 100000; // 100k tokens per day
  static const double _defaultWarningThreshold = 0.8; // 80%
  
  // Pricing per 1M tokens (in USD) - Gemini 1.5 Flash
  static const double _inputTokenCost = 0.075; // $0.075 per 1M input tokens
  static const double _outputTokenCost = 0.30; // $0.30 per 1M output tokens
  
  /// Estimate token count for text (rough approximation)
  int estimateTokenCount(String text) {
    // Rough estimation: 1 token ≈ 4 characters for English
    // More accurate would be using tiktoken library
    return (text.length / 4).ceil();
  }
  
  /// Record API usage
  Future<void> recordUsage({
    required String provider,
    required int inputTokens,
    required int outputTokens,
    required String operation,
    String? fileId,
  }) async {
    final usage = TokenUsage(
      provider: provider,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      totalTokens: inputTokens + outputTokens,
      operation: operation,
      timestamp: DateTime.now(),
      fileId: fileId,
      costUsd: _calculateCost(inputTokens, outputTokens),
    );
    
    await _saveUsage(usage);
  }
  
  /// Check if daily limit is reached
  Future<bool> isDailyLimitReached() async {
    final today = await getTodayUsage();
    final limit = await getDailyLimit();
    return today.totalTokens >= limit;
  }
  
  /// Check if warning threshold is reached
  Future<bool> isWarningThresholdReached() async {
    final today = await getTodayUsage();
    final limit = await getDailyLimit();
    final threshold = await getWarningThreshold();
    return today.totalTokens >= (limit * threshold);
  }
  
  /// Get percentage of daily limit used
  Future<double> getDailyUsagePercentage() async {
    final today = await getTodayUsage();
    final limit = await getDailyLimit();
    return (today.totalTokens / limit * 100).clamp(0, 100);
  }
  
  /// Get today's usage summary
  Future<UsageSummary> getTodayUsage() async {
    final history = await getUsageHistory(days: 1);
    return _summarizeUsage(history);
  }
  
  /// Get usage for specific date range
  Future<List<TokenUsage>> getUsageHistory({int days = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_usageHistoryKey) ?? [];
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return historyJson
        .map((json) => TokenUsage.fromJson(jsonDecode(json)))
        .where((usage) => usage.timestamp.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Get usage summary for a date range
  Future<UsageSummary> getUsageSummary({int days = 7}) async {
    final history = await getUsageHistory(days: days);
    return _summarizeUsage(history);
  }
  
  /// Get daily limit
  Future<int> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyLimitKey) ?? _defaultDailyLimit;
  }
  
  /// Set daily limit
  Future<void> setDailyLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyLimitKey, limit);
  }
  
  /// Get warning threshold (0.0 - 1.0)
  Future<double> getWarningThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_warningThresholdKey) ?? _defaultWarningThreshold;
  }
  
  /// Set warning threshold
  Future<void> setWarningThreshold(double threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_warningThresholdKey, threshold);
  }
  
  /// Get usage stats by provider
  Future<Map<String, UsageSummary>> getUsageByProvider({int days = 7}) async {
    final history = await getUsageHistory(days: days);
    final byProvider = <String, List<TokenUsage>>{};
    
    for (final usage in history) {
      byProvider.putIfAbsent(usage.provider, () => []).add(usage);
    }
    
    return byProvider.map((provider, usages) => 
      MapEntry(provider, _summarizeUsage(usages))
    );
  }
  
  /// Get usage stats by operation type
  Future<Map<String, UsageSummary>> getUsageByOperation({int days = 7}) async {
    final history = await getUsageHistory(days: days);
    final byOperation = <String, List<TokenUsage>>{};
    
    for (final usage in history) {
      byOperation.putIfAbsent(usage.operation, () => []).add(usage);
    }
    
    return byOperation.map((operation, usages) => 
      MapEntry(operation, _summarizeUsage(usages))
    );
  }
  
  /// Clear old usage records (keep last 30 days)
  Future<void> cleanupOldRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_usageHistoryKey) ?? [];
    
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    
    final filtered = historyJson.where((json) {
      final usage = TokenUsage.fromJson(jsonDecode(json));
      return usage.timestamp.isAfter(cutoffDate);
    }).toList();
    
    await prefs.setStringList(_usageHistoryKey, filtered);
  }
  
  /// Export usage data as CSV
  Future<String> exportUsageAsCsv({int days = 30}) async {
    final history = await getUsageHistory(days: days);
    
    final csv = StringBuffer();
    csv.writeln('Timestamp,Provider,Operation,Input Tokens,Output Tokens,Total Tokens,Cost (USD),File ID');
    
    for (final usage in history) {
      csv.writeln(
        '${usage.timestamp.toIso8601String()},'
        '${usage.provider},'
        '${usage.operation},'
        '${usage.inputTokens},'
        '${usage.outputTokens},'
        '${usage.totalTokens},'
        '${usage.costUsd.toStringAsFixed(6)},'
        '${usage.fileId ?? ""}'
      );
    }
    
    return csv.toString();
  }
  
  /// Reset all usage data
  Future<void> resetUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usageHistoryKey);
  }
  
  /// Check if operation is allowed based on limits
  Future<OperationCheck> checkOperationAllowed({
    required int estimatedTokens,
  }) async {
    final todayUsage = await getTodayUsage();
    final limit = await getDailyLimit();
    final remaining = limit - todayUsage.totalTokens;
    
    if (remaining <= 0) {
      return OperationCheck(
        allowed: false,
        reason: 'Daily token limit reached',
        remainingTokens: 0,
        estimatedCost: 0,
      );
    }
    
    if (estimatedTokens > remaining) {
      return OperationCheck(
        allowed: false,
        reason: 'Operation would exceed daily limit',
        remainingTokens: remaining,
        estimatedCost: _calculateCost(estimatedTokens, 0),
      );
    }
    
    return OperationCheck(
      allowed: true,
      reason: 'Operation allowed',
      remainingTokens: remaining - estimatedTokens,
      estimatedCost: _calculateCost(estimatedTokens, estimatedTokens ~/ 2),
    );
  }
  
  /// Calculate cost for token usage
  double _calculateCost(int inputTokens, int outputTokens) {
    final inputCost = (inputTokens / 1000000) * _inputTokenCost;
    final outputCost = (outputTokens / 1000000) * _outputTokenCost;
    return inputCost + outputCost;
  }
  
  /// Save usage record
  Future<void> _saveUsage(TokenUsage usage) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_usageHistoryKey) ?? [];
    
    historyJson.add(jsonEncode(usage.toJson()));
    
    // Keep only last 1000 records to prevent storage bloat
    if (historyJson.length > 1000) {
      historyJson.removeAt(0);
    }
    
    await prefs.setStringList(_usageHistoryKey, historyJson);
    
    // Auto-cleanup old records periodically
    if (historyJson.length % 100 == 0) {
      await cleanupOldRecords();
    }
  }
  
  /// Summarize usage from records
  UsageSummary _summarizeUsage(List<TokenUsage> usages) {
    if (usages.isEmpty) {
      return UsageSummary(
        totalTokens: 0,
        inputTokens: 0,
        outputTokens: 0,
        totalCost: 0,
        requestCount: 0,
      );
    }
    
    return UsageSummary(
      totalTokens: usages.fold(0, (sum, u) => sum + u.totalTokens),
      inputTokens: usages.fold(0, (sum, u) => sum + u.inputTokens),
      outputTokens: usages.fold(0, (sum, u) => sum + u.outputTokens),
      totalCost: usages.fold(0.0, (sum, u) => sum + u.costUsd),
      requestCount: usages.length,
    );
  }
}

/// Single token usage record
class TokenUsage {
  final String provider;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final String operation;
  final DateTime timestamp;
  final String? fileId;
  final double costUsd;
  
  TokenUsage({
    required this.provider,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.operation,
    required this.timestamp,
    this.fileId,
    required this.costUsd,
  });
  
  Map<String, dynamic> toJson() => {
    'provider': provider,
    'inputTokens': inputTokens,
    'outputTokens': outputTokens,
    'totalTokens': totalTokens,
    'operation': operation,
    'timestamp': timestamp.toIso8601String(),
    'fileId': fileId,
    'costUsd': costUsd,
  };
  
  factory TokenUsage.fromJson(Map<String, dynamic> json) => TokenUsage(
    provider: json['provider'],
    inputTokens: json['inputTokens'],
    outputTokens: json['outputTokens'],
    totalTokens: json['totalTokens'],
    operation: json['operation'],
    timestamp: DateTime.parse(json['timestamp']),
    fileId: json['fileId'],
    costUsd: json['costUsd'],
  );
}

/// Usage summary
class UsageSummary {
  final int totalTokens;
  final int inputTokens;
  final int outputTokens;
  final double totalCost;
  final int requestCount;
  
  UsageSummary({
    required this.totalTokens,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalCost,
    required this.requestCount,
  });
  
  String get totalCostFormatted => '\$${totalCost.toStringAsFixed(4)}';
  
  String get tokensFormatted {
    if (totalTokens < 1000) return '$totalTokens';
    if (totalTokens < 1000000) return '${(totalTokens / 1000).toStringAsFixed(1)}K';
    return '${(totalTokens / 1000000).toStringAsFixed(2)}M';
  }
}

/// Result of operation check
class OperationCheck {
  final bool allowed;
  final String reason;
  final int remainingTokens;
  final double estimatedCost;
  
  OperationCheck({
    required this.allowed,
    required this.reason,
    required this.remainingTokens,
    required this.estimatedCost,
  });
  
  String get estimatedCostFormatted => '\$${estimatedCost.toStringAsFixed(4)}';
}
