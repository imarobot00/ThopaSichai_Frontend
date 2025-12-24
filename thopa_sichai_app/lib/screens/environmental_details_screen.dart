import 'package:flutter/material.dart';

class EnvironmentalDetailsScreen extends StatefulWidget {
  final String sensorType;
  final String currentValue;
  final IconData icon;

  const EnvironmentalDetailsScreen({
    super.key,
    required this.sensorType,
    required this.currentValue,
    required this.icon,
  });

  @override
  State<EnvironmentalDetailsScreen> createState() =>
      _EnvironmentalDetailsScreenState();
}

class _EnvironmentalDetailsScreenState
    extends State<EnvironmentalDetailsScreen> {
  String _selectedRange = '24H';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.sensorType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Reading
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Reading',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.currentValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Graph
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: LineGraphPainter(),
                child: Container(),
              ),
            ),
            const SizedBox(height: 24),

            // Time Range Selector
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildRangeButton('24H'),
                  _buildRangeButton('7D'),
                  _buildRangeButton('30D'),
                  _buildRangeButton('All Time'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Column(
              children: [
                _buildStatCard('High', '72%', Icons.arrow_upward),
                const SizedBox(height: 12),
                _buildStatCard('Low', '58%', Icons.arrow_downward),
                const SizedBox(height: 12),
                _buildStatCard('Average', '65%', Icons.show_chart),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeButton(String range) {
    final isSelected = _selectedRange == range;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRange = range;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF82E0AA)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            range,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7DC2FF), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class LineGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7DC2FF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = const Color(0xFF444746)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Sample data points for the graph
    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw dots at data points
    final dotPaint = Paint()
      ..color = const Color(0xFF7DC2FF)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
