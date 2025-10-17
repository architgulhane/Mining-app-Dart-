/// Model class for CSV file analysis results from Gemini
class CsvAnalysis {
  final String summary;
  final int rowCount;
  final int columnCount;
  final List<String> columns;
  final List<String> insights;
  final String statistics;
  final Map<String, String> dataTypes;
  final List<String> recommendations;

  CsvAnalysis({
    required this.summary,
    required this.rowCount,
    required this.columnCount,
    required this.columns,
    required this.insights,
    required this.statistics,
    required this.dataTypes,
    required this.recommendations,
  });

  factory CsvAnalysis.fromJson(Map<String, dynamic> json) {
    return CsvAnalysis(
      summary: json['summary'] ?? 'No summary available',
      rowCount: json['rowCount'] ?? 0,
      columnCount: json['columnCount'] ?? 0,
      columns: List<String>.from(json['columns'] ?? []),
      insights: List<String>.from(json['insights'] ?? []),
      statistics: json['statistics']?['description'] ?? 'No statistics available',
      dataTypes: Map<String, String>.from(json['dataTypes'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'rowCount': rowCount,
      'columnCount': columnCount,
      'columns': columns,
      'insights': insights,
      'statistics': statistics,
      'dataTypes': dataTypes,
      'recommendations': recommendations,
    };
  }

  @override
  String toString() {
    return '''
CSV Analysis:
Summary: $summary
Rows: $rowCount | Columns: $columnCount
Insights: ${insights.join(', ')}
Statistics: $statistics
''';
  }
}

/// Extended UploadedFile model with CSV analysis
class UploadedFileWithAnalysis {
  final String name;
  final String size;
  final String path;
  final DateTime uploadedAt;
  final CsvAnalysis? analysis;

  UploadedFileWithAnalysis({
    required this.name,
    required this.size,
    required this.path,
    required this.uploadedAt,
    this.analysis,
  });

  bool get isCsv => name.toLowerCase().endsWith('.csv');
  bool get hasAnalysis => analysis != null;

  String get displayInfo {
    if (hasAnalysis && analysis != null) {
      return '${analysis!.rowCount} rows × ${analysis!.columnCount} columns';
    }
    return size;
  }
}
