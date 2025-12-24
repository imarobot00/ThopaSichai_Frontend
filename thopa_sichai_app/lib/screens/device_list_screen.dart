import 'package:flutter/material.dart';
import 'device_details_screen.dart';
import 'add_device_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

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
        title: const Text(
          'My Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF7DC2FF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddDeviceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDeviceCard(
            context,
            'Backyard Garden',
            'SDRP-X-1A2B3C',
            'Active • Zone 1',
            true,
            Icons.grass_outlined,
          ),
          const SizedBox(height: 12),
          _buildDeviceCard(
            context,
            'Front Lawn Sprinkler',
            'SDRP-X-4D5E6F',
            'Idle • Zone 2',
            false,
            Icons.water_drop_outlined,
          ),
          const SizedBox(height: 12),
          _buildDeviceCard(
            context,
            'Flower Bed',
            'SDRP-X-7G8H9I',
            'Scheduled • Zone 3',
            false,
            Icons.local_florist_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    String name,
    String deviceId,
    String status,
    bool isActive,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceDetailsScreen(
              deviceName: name,
              deviceId: deviceId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF212529),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF82E0AA) : Colors.white54,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deviceId,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
