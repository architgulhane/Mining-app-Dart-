import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Secure manager for API keys with encryption and rotation
class SecureKeyManager {
  static final SecureKeyManager _instance = SecureKeyManager._internal();
  factory SecureKeyManager() => _instance;
  SecureKeyManager._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  static const String _geminiKeyName = 'gemini_api_key';
  static const String _openaiKeyName = 'openai_api_key';
  static const String _keyMetadataPrefix = 'key_metadata_';
  static const String _keyRotationHistoryKey = 'key_rotation_history';
  
  /// Store Gemini API key securely
  Future<void> setGeminiKey(String apiKey) async {
    await _setKey(_geminiKeyName, apiKey, 'Google Gemini');
  }
  
  /// Get Gemini API key
  Future<String?> getGeminiKey() async {
    return await _getKey(_geminiKeyName);
  }
  
  /// Store OpenAI API key securely
  Future<void> setOpenAIKey(String apiKey) async {
    await _setKey(_openaiKeyName, apiKey, 'OpenAI');
  }
  
  /// Get OpenAI API key
  Future<String?> getOpenAIKey() async {
    return await _getKey(_openaiKeyName);
  }
  
  /// Check if Gemini key exists and is valid
  Future<bool> hasValidGeminiKey() async {
    final key = await getGeminiKey();
    return key != null && key.isNotEmpty && _isValidGeminiKeyFormat(key);
  }
  
  /// Check if OpenAI key exists and is valid
  Future<bool> hasValidOpenAIKey() async {
    final key = await getOpenAIKey();
    return key != null && key.isNotEmpty && _isValidOpenAIKeyFormat(key);
  }
  
  /// Validate Gemini API key format
  bool _isValidGeminiKeyFormat(String key) {
    // Gemini keys start with AIzaSy and are 39 characters long
    return key.startsWith('AIzaSy') && key.length == 39;
  }
  
  /// Validate OpenAI API key format
  bool _isValidOpenAIKeyFormat(String key) {
    // OpenAI keys start with sk- and are typically 48+ characters
    return key.startsWith('sk-') && key.length >= 20;
  }
  
  /// Delete all stored API keys
  Future<void> deleteAllKeys() async {
    await _secureStorage.delete(key: _geminiKeyName);
    await _secureStorage.delete(key: _openaiKeyName);
    
    // Clear metadata
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyMetadataPrefix$_geminiKeyName');
    await prefs.remove('$_keyMetadataPrefix$_openaiKeyName');
  }
  
  /// Rotate an API key (store old key in history)
  Future<void> rotateKey(String keyName, String newKey) async {
    // Get old key
    final oldKey = await _getKey(keyName);
    
    if (oldKey != null) {
      // Add to rotation history
      await _addToRotationHistory(keyName, oldKey);
    }
    
    // Set new key
    String provider = 'Unknown';
    if (keyName == _geminiKeyName) provider = 'Google Gemini';
    if (keyName == _openaiKeyName) provider = 'OpenAI';
    
    await _setKey(keyName, newKey, provider);
  }
  
  /// Get key rotation history
  Future<List<KeyRotationRecord>> getRotationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_keyRotationHistoryKey) ?? [];
    
    return historyJson
        .map((json) => KeyRotationRecord.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.rotatedAt.compareTo(a.rotatedAt));
  }
  
  /// Get metadata for a key
  Future<KeyMetadata?> getKeyMetadata(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final metadataJson = prefs.getString('$_keyMetadataPrefix$keyName');
    
    if (metadataJson == null) return null;
    
    return KeyMetadata.fromJson(jsonDecode(metadataJson));
  }
  
  /// Get all key metadata
  Future<Map<String, KeyMetadata>> getAllKeyMetadata() async {
    final geminiMeta = await getKeyMetadata(_geminiKeyName);
    final openaiMeta = await getKeyMetadata(_openaiKeyName);
    
    final result = <String, KeyMetadata>{};
    if (geminiMeta != null) result['gemini'] = geminiMeta;
    if (openaiMeta != null) result['openai'] = openaiMeta;
    
    return result;
  }
  
  /// Store a key securely with metadata
  Future<void> _setKey(String keyName, String apiKey, String provider) async {
    await _secureStorage.write(key: keyName, value: apiKey);
    
    // Store metadata (non-sensitive)
    final metadata = KeyMetadata(
      keyName: keyName,
      provider: provider,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      keyLength: apiKey.length,
      keyPrefix: apiKey.substring(0, 6.coerceAtMost(apiKey.length)),
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_keyMetadataPrefix$keyName',
      jsonEncode(metadata.toJson()),
    );
  }
  
  /// Retrieve a key securely
  Future<String?> _getKey(String keyName) async {
    final key = await _secureStorage.read(key: keyName);
    
    if (key != null) {
      // Update last used timestamp
      await _updateLastUsed(keyName);
    }
    
    return key;
  }
  
  /// Update last used timestamp for a key
  Future<void> _updateLastUsed(String keyName) async {
    final metadata = await getKeyMetadata(keyName);
    if (metadata != null) {
      final updated = KeyMetadata(
        keyName: metadata.keyName,
        provider: metadata.provider,
        createdAt: metadata.createdAt,
        lastUsedAt: DateTime.now(),
        keyLength: metadata.keyLength,
        keyPrefix: metadata.keyPrefix,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_keyMetadataPrefix$keyName',
        jsonEncode(updated.toJson()),
      );
    }
  }
  
  /// Add key to rotation history
  Future<void> _addToRotationHistory(String keyName, String oldKey) async {
    final record = KeyRotationRecord(
      keyName: keyName,
      oldKeyPrefix: oldKey.substring(0, 6.coerceAtMost(oldKey.length)),
      rotatedAt: DateTime.now(),
      reason: 'Manual rotation',
    );
    
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_keyRotationHistoryKey) ?? [];
    
    historyJson.add(jsonEncode(record.toJson()));
    
    // Keep only last 10 records
    if (historyJson.length > 10) {
      historyJson.removeAt(0);
    }
    
    await prefs.setStringList(_keyRotationHistoryKey, historyJson);
  }
  
  /// Export keys (for backup - USE WITH CAUTION)
  Future<Map<String, String>> exportKeys() async {
    final geminiKey = await getGeminiKey();
    final openaiKey = await getOpenAIKey();
    
    final result = <String, String>{};
    if (geminiKey != null) result['gemini'] = geminiKey;
    if (openaiKey != null) result['openai'] = openaiKey;
    
    return result;
  }
  
  /// Import keys (for restore)
  Future<void> importKeys(Map<String, String> keys) async {
    if (keys.containsKey('gemini')) {
      await setGeminiKey(keys['gemini']!);
    }
    if (keys.containsKey('openai')) {
      await setOpenAIKey(keys['openai']!);
    }
  }
}

/// Metadata about an API key (non-sensitive)
class KeyMetadata {
  final String keyName;
  final String provider;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final int keyLength;
  final String keyPrefix;
  
  KeyMetadata({
    required this.keyName,
    required this.provider,
    required this.createdAt,
    required this.lastUsedAt,
    required this.keyLength,
    required this.keyPrefix,
  });
  
  Map<String, dynamic> toJson() => {
    'keyName': keyName,
    'provider': provider,
    'createdAt': createdAt.toIso8601String(),
    'lastUsedAt': lastUsedAt.toIso8601String(),
    'keyLength': keyLength,
    'keyPrefix': keyPrefix,
  };
  
  factory KeyMetadata.fromJson(Map<String, dynamic> json) => KeyMetadata(
    keyName: json['keyName'],
    provider: json['provider'],
    createdAt: DateTime.parse(json['createdAt']),
    lastUsedAt: DateTime.parse(json['lastUsedAt']),
    keyLength: json['keyLength'],
    keyPrefix: json['keyPrefix'],
  );
  
  String get maskedKey => '$keyPrefix${"*" * (keyLength - 6)}';
}

/// Record of key rotation
class KeyRotationRecord {
  final String keyName;
  final String oldKeyPrefix;
  final DateTime rotatedAt;
  final String reason;
  
  KeyRotationRecord({
    required this.keyName,
    required this.oldKeyPrefix,
    required this.rotatedAt,
    required this.reason,
  });
  
  Map<String, dynamic> toJson() => {
    'keyName': keyName,
    'oldKeyPrefix': oldKeyPrefix,
    'rotatedAt': rotatedAt.toIso8601String(),
    'reason': reason,
  };
  
  factory KeyRotationRecord.fromJson(Map<String, dynamic> json) => KeyRotationRecord(
    keyName: json['keyName'],
    oldKeyPrefix: json['oldKeyPrefix'],
    rotatedAt: DateTime.parse(json['rotatedAt']),
    reason: json['reason'],
  );
}

extension IntExtension on int {
  int coerceAtMost(int maximum) {
    return this > maximum ? maximum : this;
  }
}
