import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'gemini_csv_service.dart';
import 'excel_analysis_service.dart';

/// Service to generate charts from CSV/Excel data
class ChartGenerationService {
  final GeminiCsvService _csvService = GeminiCsvService();
  final ExcelAnalysisService _excelService = ExcelAnalysisService();
  
  /// Auto-detect best chart type based on data
  ChartType detectBestChartType({
    required List<dynamic> xValues,
    required List<double> yValues,
  }) {
    if (xValues.isEmpty || yValues.isEmpty) {
      return ChartType.bar;
    }
    
    // If x values are numeric and continuous, use line chart
    if (xValues.every((x) => x is num || double.tryParse(x.toString()) != null)) {
      return ChartType.line;
    }
    
    // If few categories (< 8), use pie chart
    if (xValues.toSet().length < 8) {
      return ChartType.pie;
    }
    
    // Default to bar chart
    return ChartType.bar;
  }
  
  /// Generate line chart data from CSV
  Future<LineChartData?> generateLineChart({
    required String fileId,
    required String xColumn,
    required String yColumn,
    Color? lineColor,
    bool showDots = true,
  }) async {
    try {
      final chartData = await _csvService.getChartData(
        fileId: fileId,
        xColumn: xColumn,
        yColumn: yColumn,
      );
      
      if (chartData == null) return null;
      
      final data = chartData['data'] as List<Map<String, dynamic>>;
      final spots = <FlSpot>[];
      
      for (int i = 0; i < data.length; i++) {
        final yValue = data[i]['y'] as double;
        spots.add(FlSpot(i.toDouble(), yValue));
      }
      
      return LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor ?? Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              color: (lineColor ?? Colors.blue).withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
            axisNameWidget: Text(yColumn),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Text(
                    data[index]['x'].toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: Text(xColumn),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      );
    } catch (e) {
      print('Error generating line chart: $e');
      return null;
    }
  }
  
  /// Generate bar chart data from CSV
  Future<BarChartData?> generateBarChart({
    required String fileId,
    required String xColumn,
    required String yColumn,
    Color? barColor,
    int maxBars = 20,
  }) async {
    try {
      final chartData = await _csvService.getChartData(
        fileId: fileId,
        xColumn: xColumn,
        yColumn: yColumn,
        maxPoints: maxBars,
      );
      
      if (chartData == null) return null;
      
      final data = chartData['data'] as List<Map<String, dynamic>>;
      final barGroups = <BarChartGroupData>[];
      
      for (int i = 0; i < data.length; i++) {
        final yValue = data[i]['y'] as double;
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: yValue,
                color: barColor ?? Colors.blue,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
      }
      
      return BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
            axisNameWidget: Text(yColumn),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index]['x'].toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(xColumn),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      );
    } catch (e) {
      print('Error generating bar chart: $e');
      return null;
    }
  }
  
  /// Generate pie chart data from CSV
  Future<List<PieChartSectionData>?> generatePieChart({
    required String fileId,
    required String labelColumn,
    required String valueColumn,
    int maxSlices = 8,
  }) async {
    try {
      final chartData = await _csvService.getChartData(
        fileId: fileId,
        xColumn: labelColumn,
        yColumn: valueColumn,
        maxPoints: maxSlices,
      );
      
      if (chartData == null) return null;
      
      final data = chartData['data'] as List<Map<String, dynamic>>;
      final sections = <PieChartSectionData>[];
      
      // Calculate total for percentages
      final total = data.fold<double>(
        0,
        (sum, item) => sum + (item['y'] as double),
      );
      
      // Generate colors
      final colors = _generateColors(data.length);
      
      for (int i = 0; i < data.length; i++) {
        final value = data[i]['y'] as double;
        final percentage = (value / total * 100).toStringAsFixed(1);
        
        sections.add(
          PieChartSectionData(
            value: value,
            title: '$percentage%',
            color: colors[i],
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      
      return sections;
    } catch (e) {
      print('Error generating pie chart: $e');
      return null;
    }
  }
  
  /// Generate scatter chart data
  Future<ScatterChartData?> generateScatterChart({
    required String fileId,
    required String xColumn,
    required String yColumn,
    Color? dotColor,
    double dotSize = 8,
  }) async {
    try {
      final chartData = await _csvService.getChartData(
        fileId: fileId,
        xColumn: xColumn,
        yColumn: yColumn,
      );
      
      if (chartData == null) return null;
      
      final data = chartData['data'] as List<Map<String, dynamic>>;
      final spots = <ScatterSpot>[];
      
      for (int i = 0; i < data.length; i++) {
        final xValue = double.tryParse(data[i]['x'].toString()) ?? i.toDouble();
        final yValue = data[i]['y'] as double;
        spots.add(ScatterSpot(xValue, yValue));
      }
      
      return ScatterChartData(
        scatterSpots: spots.map((spot) => 
          ScatterSpot(
            spot.x,
            spot.y,
            dotPainter: FlDotCirclePainter(
              color: dotColor ?? Colors.blue,
              radius: dotSize,
            ),
          )
        ).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
            axisNameWidget: Text(yColumn),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
            axisNameWidget: Text(xColumn),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      );
    } catch (e) {
      print('Error generating scatter chart: $e');
      return null;
    }
  }
  
  /// Generate multi-line chart (for comparing multiple columns)
  Future<LineChartData?> generateMultiLineChart({
    required String fileId,
    required String xColumn,
    required List<String> yColumns,
    List<Color>? colors,
  }) async {
    try {
      final lineBars = <LineChartBarData>[];
      final generatedColors = colors ?? _generateColors(yColumns.length);
      
      for (int i = 0; i < yColumns.length; i++) {
        final chartData = await _csvService.getChartData(
          fileId: fileId,
          xColumn: xColumn,
          yColumn: yColumns[i],
        );
        
        if (chartData != null) {
          final data = chartData['data'] as List<Map<String, dynamic>>;
          final spots = <FlSpot>[];
          
          for (int j = 0; j < data.length; j++) {
            final yValue = data[j]['y'] as double;
            spots.add(FlSpot(j.toDouble(), yValue));
          }
          
          lineBars.add(
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: generatedColors[i],
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          );
        }
      }
      
      return LineChartData(
        lineBarsData: lineBars,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
            axisNameWidget: Text(xColumn),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      );
    } catch (e) {
      print('Error generating multi-line chart: $e');
      return null;
    }
  }
  
  /// Generate colors for chart elements
  List<Color> _generateColors(int count) {
    final colors = <Color>[];
    final hueStep = 360 / count;
    
    for (int i = 0; i < count; i++) {
      final hue = (i * hueStep) % 360;
      colors.add(HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor());
    }
    
    return colors;
  }
  
  /// Get suggested chart types for data
  Future<List<ChartSuggestion>> getSuggestedCharts({
    required String fileId,
    String? fileType,
  }) async {
    try {
      final suggestions = <ChartSuggestion>[];
      
      // This would analyze the data structure and suggest appropriate charts
      // For now, returning common suggestions
      suggestions.add(ChartSuggestion(
        type: ChartType.line,
        title: 'Line Chart',
        description: 'Show trends over time',
        confidence: 0.9,
      ));
      
      suggestions.add(ChartSuggestion(
        type: ChartType.bar,
        title: 'Bar Chart',
        description: 'Compare values across categories',
        confidence: 0.85,
      ));
      
      suggestions.add(ChartSuggestion(
        type: ChartType.pie,
        title: 'Pie Chart',
        description: 'Show proportions and percentages',
        confidence: 0.75,
      ));
      
      return suggestions;
    } catch (e) {
      print('Error getting chart suggestions: $e');
      return [];
    }
  }
}

/// Chart type enum
enum ChartType {
  line,
  bar,
  pie,
  scatter,
  multiLine,
}

/// Chart suggestion model
class ChartSuggestion {
  final ChartType type;
  final String title;
  final String description;
  final double confidence; // 0.0 to 1.0
  
  ChartSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
  });
}
