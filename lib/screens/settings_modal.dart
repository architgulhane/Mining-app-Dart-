import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _apiKeyController = TextEditingController();
  String _selectedModel = 'GPT-4 Turbo';
  double _temperature = 0.5;
  bool _ragEnabled = true;
  double _topK = 5;
  double _chunkSize = 512;
  double _chunkOverlap = 50;
  
  final List<Map<String, dynamic>> _uploadedFiles = [
    {
      'name': 'machine_data.csv',
      'size': '2.4 MB',
      'rows': '15,234',
      'indexed': true,
    },
    {
      'name': 'production_logs.pdf',
      'size': '5.8 MB',
      'rows': 'N/A',
      'indexed': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF4F46E5),
              tabs: const [
                Tab(text: 'API & Models'),
                Tab(text: 'Data'),
                Tab(text: 'RAG'),
              ],
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildApiTab(),
                  _buildDataTab(),
                  _buildRagTab(),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save & Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OpenAI API Key',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'sk-...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Model Selection',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedModel,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            items: const [
              DropdownMenuItem(value: 'GPT-4 Turbo', child: Text('GPT-4 Turbo')),
              DropdownMenuItem(value: 'GPT-4', child: Text('GPT-4')),
              DropdownMenuItem(value: 'GPT-3.5 Turbo', child: Text('GPT-3.5 Turbo')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedModel = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Temperature',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Focused', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              Expanded(
                child: Slider(
                  value: _temperature,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: _temperature.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _temperature = value;
                    });
                  },
                ),
              ),
              const Text('Creative', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Documents',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _uploadFile,
            onHover: (hovering) {},
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF9FAFB),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Drag and drop files or click to browse',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Supports: CSV, PDF, DOCX, TXT',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Uploaded Files',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          ..._uploadedFiles.map((file) => _FileListItem(
                file: file,
                onDelete: () {
                  setState(() {
                    _uploadedFiles.remove(file);
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildRagTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Enable RAG',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Switch(
                value: _ragEnabled,
                onChanged: (value) {
                  setState(() {
                    _ragEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Top K Results',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _topK,
            min: 1,
            max: 20,
            divisions: 19,
            label: _topK.round().toString(),
            onChanged: _ragEnabled
                ? (value) {
                    setState(() {
                      _topK = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 24),
          const Text(
            'Chunk Size',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _chunkSize,
            min: 128,
            max: 2048,
            divisions: 15,
            label: _chunkSize.round().toString(),
            onChanged: _ragEnabled
                ? (value) {
                    setState(() {
                      _chunkSize = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 24),
          const Text(
            'Chunk Overlap',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _chunkOverlap,
            min: 0,
            max: 200,
            divisions: 20,
            label: _chunkOverlap.round().toString(),
            onChanged: _ragEnabled
                ? (value) {
                    setState(() {
                      _chunkOverlap = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _ragEnabled ? _reindexFiles : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Reindex All Files'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile() async {
    try {
      // Pick file with specific extensions
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf', 'docx', 'doc', 'txt'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          // Get file information
          final fileName = file.name;
          final filePath = file.path;
          final fileSize = file.size;
          
          if (filePath != null) {
            // Show loading indicator
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploading $fileName...'),
                duration: const Duration(seconds: 2),
              ),
            );

            // Calculate file size in MB or KB
            String formattedSize;
            if (fileSize >= 1024 * 1024) {
              formattedSize = '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
            } else if (fileSize >= 1024) {
              formattedSize = '${(fileSize / 1024).toStringAsFixed(1)} KB';
            } else {
              formattedSize = '$fileSize B';
            }

            // Get file extension
            final extension = path.extension(fileName).toLowerCase();
            
            // Count rows for CSV files
            String rows = 'N/A';
            if (extension == '.csv') {
              try {
                final file = File(filePath);
                final lines = await file.readAsLines();
                rows = '${lines.length - 1}'; // Subtract header row
              } catch (e) {
                // Error counting rows - silently fail
                debugPrint('Error counting rows: $e');
              }
            }

            // Add to uploaded files list
            setState(() {
              _uploadedFiles.add({
                'name': fileName,
                'size': formattedSize,
                'rows': rows,
                'indexed': false,
                'path': filePath,
              });
            });

            // Simulate indexing process
            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                final fileIndex = _uploadedFiles.indexWhere((f) => f['path'] == filePath);
                if (fileIndex != -1) {
                  _uploadedFiles[fileIndex]['indexed'] = true;
                }
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$fileName indexed successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reindexFiles() {
    if (_uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No files to reindex'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Set all files to not indexed
    setState(() {
      for (var file in _uploadedFiles) {
        file['indexed'] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reindexing files...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate reindexing
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        for (var file in _uploadedFiles) {
          file['indexed'] = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All files reindexed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _saveSettings() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }
}

class _FileListItem extends StatelessWidget {
  final Map<String, dynamic> file;
  final VoidCallback onDelete;
  
  const _FileListItem({
    required this.file,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Color(0xFF6B7280), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${file['size']} • ${file['rows']} rows',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (file['indexed'])
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 4),
                Text(
                  'Indexed',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: const Color(0xFFEF4444),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
