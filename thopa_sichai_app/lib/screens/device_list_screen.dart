import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.16.112:8000/api/soil-moisture/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = data['data']['records'] as List;
        
        // Group by nodeid to get unique devices
        final Map<String, Map<String, dynamic>> deviceMap = {};
        for (var record in records) {
          final nodeid = record['nodeid'];
          if (!deviceMap.containsKey(nodeid)) {
            deviceMap[nodeid] = {
              'nodeid': nodeid,
              'lastValue': record['value'],
              'lastUpdate': record['timestamp'],
              'ipAddress': record['ip_address'],
            };
          }
        }
        
        setState(() {
          _devices = deviceMap.values.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load devices';
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
          'Sensor Nodes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF7DC2FF)),
            onPressed: _fetchDevices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, style: const TextStyle(color: Colors.white)),
                      ElevatedButton(
                        onPressed: _fetchDevices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _devices.isEmpty
                  ? const Center(
                      child: Text(
                        'No sensors found',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        return _buildDeviceCard(context, _devices[index]);
                      },
                    ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, Map<String, dynamic> device) {
    final nodeid = device['nodeid'] ?? 'Unknown';
    final lastValue = device['lastValue'] ?? 0;
    final ipAddress = device['ipAddress'] ?? 'N/A';
    final isActive = lastValue > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to device details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? const Color(0xFF82E0AA).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sensors,
                    color: isActive ? const Color(0xFF82E0AA) : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nodeid,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Moisture: ${lastValue.toInt()}% • $ipAddress',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? const Color(0xFF82E0AA).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Idle',
                    style: TextStyle(
                      color: isActive ? const Color(0xFF82E0AA) : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
