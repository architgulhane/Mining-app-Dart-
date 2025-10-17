import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service for securely storing uploaded files locally with metadata tracking
class FileStorageService {
  static const String _filesMetadataKey = 'stored_files_metadata';
  static const int _maxStorageSizeBytes = 100 * 1024 * 1024; // 100MB limit
  
  /// Get the application documents directory for storing files
  Future<Directory> _getStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final storageDir = Directory('${appDir.path}/cognisarthi_files');
    
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    
    return storageDir;
  }
  
  /// Save a file locally and return its metadata
  /// 
  /// [fileBytes] - The file content as bytes
  /// [fileName] - Original file name
  /// [fileType] - Type of file (csv, pdf, xlsx, etc.)
  /// [description] - Optional description
  Future<StoredFileMetadata> saveFile({
    required Uint8List fileBytes,
    required String fileName,
    required String fileType,
    String? description,
  }) async {
    try {
      // Check storage quota
      await _enforceStorageQuota();
      
      final storageDir = await _getStorageDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedFileName = _sanitizeFileName(fileName);
      final storedFileName = '${timestamp}_$sanitizedFileName';
      final filePath = '${storageDir.path}/$storedFileName';
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      // Calculate file hash for integrity checking
      final fileHash = _calculateHash(fileBytes);
      
      // Create metadata
      final metadata = StoredFileMetadata(
        id: timestamp.toString(),
        originalFileName: fileName,
        storedFileName: storedFileName,
        filePath: filePath,
        fileType: fileType,
        fileSize: fileBytes.length,
        fileHash: fileHash,
        uploadedAt: DateTime.now(),
        description: description,
      );
      
      // Save metadata
      await _saveMetadata(metadata);
      
      return metadata;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }
  
  /// Retrieve a stored file's content
  Future<Uint8List> getFileContent(String fileId) async {
    final metadata = await getFileMetadata(fileId);
    if (metadata == null) {
      throw Exception('File not found');
    }
    
    final file = File(metadata.filePath);
    if (!await file.exists()) {
      throw Exception('File physically not found on disk');
    }
    
    final bytes = await file.readAsBytes();
    
    // Verify file integrity
    final currentHash = _calculateHash(bytes);
    if (currentHash != metadata.fileHash) {
      throw Exception('File integrity check failed - file may be corrupted');
    }
    
    return bytes;
  }
  
  /// Get metadata for a specific file
  Future<StoredFileMetadata?> getFileMetadata(String fileId) async {
    final allMetadata = await getAllFilesMetadata();
    return allMetadata.firstWhere(
      (m) => m.id == fileId,
      orElse: () => throw Exception('File not found'),
    );
  }
  
  /// Get all stored files metadata
  Future<List<StoredFileMetadata>> getAllFilesMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final metadataJson = prefs.getStringList(_filesMetadataKey) ?? [];
    
    return metadataJson
        .map((json) => StoredFileMetadata.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt)); // Most recent first
  }
  
  /// Delete a stored file
  Future<void> deleteFile(String fileId) async {
    final metadata = await getFileMetadata(fileId);
    if (metadata == null) return;
    
    // Delete physical file
    final file = File(metadata.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    
    // Remove metadata
    await _removeMetadata(fileId);
  }
  
  /// Delete all stored files
  Future<void> clearAllFiles() async {
    final allMetadata = await getAllFilesMetadata();
    
    for (final metadata in allMetadata) {
      final file = File(metadata.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_filesMetadataKey);
  }
  
  /// Get total storage used
  Future<int> getTotalStorageUsed() async {
    final allMetadata = await getAllFilesMetadata();
    return allMetadata.fold<int>(0, (sum, metadata) => sum + metadata.fileSize);
  }
  
  /// Check if storage quota is exceeded
  Future<bool> isStorageQuotaExceeded() async {
    final used = await getTotalStorageUsed();
    return used >= _maxStorageSizeBytes;
  }
  
  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    final allMetadata = await getAllFilesMetadata();
    final totalSize = await getTotalStorageUsed();
    
    final fileTypeCount = <String, int>{};
    final fileTypeSizes = <String, int>{};
    
    for (final metadata in allMetadata) {
      fileTypeCount[metadata.fileType] = (fileTypeCount[metadata.fileType] ?? 0) + 1;
      fileTypeSizes[metadata.fileType] = (fileTypeSizes[metadata.fileType] ?? 0) + metadata.fileSize;
    }
    
    return StorageStats(
      totalFiles: allMetadata.length,
      totalSizeBytes: totalSize,
      maxSizeBytes: _maxStorageSizeBytes,
      usagePercentage: (totalSize / _maxStorageSizeBytes * 100).clamp(0, 100),
      fileTypeCount: fileTypeCount,
      fileTypeSizes: fileTypeSizes,
    );
  }
  
  /// Delete old files if storage quota is exceeded
  Future<void> _enforceStorageQuota() async {
    final allMetadata = await getAllFilesMetadata();
    final totalSize = await getTotalStorageUsed();
    
    if (totalSize >= _maxStorageSizeBytes) {
      // Delete oldest files until we have 20% free space
      final targetSize = (_maxStorageSizeBytes * 0.8).toInt();
      var currentSize = totalSize;
      
      // Sort by oldest first
      final sorted = List<StoredFileMetadata>.from(allMetadata)
        ..sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
      
      for (final metadata in sorted) {
        if (currentSize <= targetSize) break;
        
        await deleteFile(metadata.id);
        currentSize -= metadata.fileSize;
      }
    }
  }
  
  /// Save file metadata
  Future<void> _saveMetadata(StoredFileMetadata metadata) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getStringList(_filesMetadataKey) ?? [];
    
    existingJson.add(jsonEncode(metadata.toJson()));
    await prefs.setStringList(_filesMetadataKey, existingJson);
  }
  
  /// Remove file metadata
  Future<void> _removeMetadata(String fileId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getStringList(_filesMetadataKey) ?? [];
    
    final filtered = existingJson.where((json) {
      final data = jsonDecode(json);
      return data['id'] != fileId;
    }).toList();
    
    await prefs.setStringList(_filesMetadataKey, filtered);
  }
  
  /// Sanitize file name to prevent path traversal attacks
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_')
        .replaceAll('..', '_');
  }
  
  /// Calculate SHA-256 hash of file content for integrity checking
  String _calculateHash(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }
  
  /// Clean up orphaned files (files on disk without metadata)
  Future<void> cleanupOrphanedFiles() async {
    final storageDir = await _getStorageDirectory();
    final allMetadata = await getAllFilesMetadata();
    final metadataFiles = allMetadata.map((m) => m.storedFileName).toSet();
    
    final filesOnDisk = storageDir.listSync();
    for (final entity in filesOnDisk) {
      if (entity is File) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        if (!metadataFiles.contains(fileName)) {
          await entity.delete();
        }
      }
    }
  }
}

/// Metadata for a stored file
class StoredFileMetadata {
  final String id;
  final String originalFileName;
  final String storedFileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String fileHash;
  final DateTime uploadedAt;
  final String? description;
  final DateTime? lastAccessedAt;
  final Map<String, dynamic>? analysisCache;
  
  StoredFileMetadata({
    required this.id,
    required this.originalFileName,
    required this.storedFileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.fileHash,
    required this.uploadedAt,
    this.description,
    this.lastAccessedAt,
    this.analysisCache,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'originalFileName': originalFileName,
    'storedFileName': storedFileName,
    'filePath': filePath,
    'fileType': fileType,
    'fileSize': fileSize,
    'fileHash': fileHash,
    'uploadedAt': uploadedAt.toIso8601String(),
    'description': description,
    'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    'analysisCache': analysisCache,
  };
  
  factory StoredFileMetadata.fromJson(Map<String, dynamic> json) => StoredFileMetadata(
    id: json['id'],
    originalFileName: json['originalFileName'],
    storedFileName: json['storedFileName'],
    filePath: json['filePath'],
    fileType: json['fileType'],
    fileSize: json['fileSize'],
    fileHash: json['fileHash'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
    description: json['description'],
    lastAccessedAt: json['lastAccessedAt'] != null 
        ? DateTime.parse(json['lastAccessedAt']) 
        : null,
    analysisCache: json['analysisCache'],
  );
  
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Storage statistics
class StorageStats {
  final int totalFiles;
  final int totalSizeBytes;
  final int maxSizeBytes;
  final double usagePercentage;
  final Map<String, int> fileTypeCount;
  final Map<String, int> fileTypeSizes;
  
  StorageStats({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.maxSizeBytes,
    required this.usagePercentage,
    required this.fileTypeCount,
    required this.fileTypeSizes,
  });
  
  String get totalSizeFormatted {
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  String get maxSizeFormatted {
    return '${(maxSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}
