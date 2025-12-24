import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class SoilMoistureScreen extends StatefulWidget {
  const SoilMoistureScreen({super.key});

  @override
  State<SoilMoistureScreen> createState() => _SoilMoistureScreenState();
}

class _SoilMoistureScreenState extends State<SoilMoistureScreen> {
  List<dynamic> _moistureData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedPeriod = '24H';

  @override
  void initState() {
    super.initState();
    _fetchMoistureData();
  }

  Future<void> _fetchMoistureData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/soil-moisture/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _moistureData = data['data']['records'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  double get _currentReading {
    if (_moistureData.isEmpty) return 0;
    try {
      return double.parse(_moistureData.first['value'].toString());
    } catch (e) {
      return 0;
    }
  }

  double get _highValue {
    if (_moistureData.isEmpty) return 0;
    double max = 0;
    for (var item in _moistureData) {
      try {
        double val = double.parse(item['value'].toString());
        if (val > max) max = val;
      } catch (e) {}
    }
    return max;
  }

  double get _lowValue {
    if (_moistureData.isEmpty) return 0;
    double min = 100;
    for (var item in _moistureData) {
      try {
        double val = double.parse(item['value'].toString());
        if (val < min) min = val;
      } catch (e) {}
    }
    return min;
  }

  List<FlSpot> _getChartData() {
    if (_moistureData.isEmpty) return [];
    List<FlSpot> spots = [];
    for (int i = 0; i < _moistureData.length; i++) {
      try {
        double value = double.parse(_moistureData[i]['value'].toString());
        spots.add(FlSpot(i.toDouble(), value));
      } catch (e) {}
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212529),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Soil Moisture',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMoistureData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _moistureData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No soil moisture data yet',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Reading
                          const Text(
                            'Current Reading',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentReading.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Chart
                          Container(
                            height: 200,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF212529),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 20,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade800,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: false,
                                ),
                                borderData: FlBorderData(show: false),
                                minY: 0,
                                maxY: 100,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getChartData(),
                                    isCurved: true,
                                    color: const Color(0xFF4FC3F7),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: const Color(0xFF4FC3F7),
                                          strokeWidth: 0,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Time Period Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _periodButton('24H'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _periodButton('7D'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _periodButton('30D'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _periodButton('All Time'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Statistics
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  'High',
                                  '${_highValue.toInt()}%',
                                  Icons.arrow_upward,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _statCard(
                                  'Low',
                                  '${_lowValue.toInt()}%',
                                  Icons.arrow_downward,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _periodButton(String period) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF212529),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            period,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: label == 'High' ? Colors.blue : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
