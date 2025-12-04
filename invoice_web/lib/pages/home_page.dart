import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../services/api_service.dart';
import 'upload_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBackendHealthy = false;
  bool _isCheckingHealth = true;

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    setState(() => _isCheckingHealth = true);
    final apiService = context.read<ApiService>();
    final isHealthy = await apiService.healthCheck();
    setState(() {
      _isBackendHealthy = isHealthy;
      _isCheckingHealth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, size: 28),
            const SizedBox(width: 12),
            const Text(
              AppConfig.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Backend status indicator
            _isCheckingHealth
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    children: [
                      Icon(
                        _isBackendHealthy ? Icons.check_circle : Icons.error,
                        color: _isBackendHealthy ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isBackendHealthy ? 'Connected' : 'Backend Offline',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isBackendHealthy ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _checkBackendHealth,
                        tooltip: 'Refresh connection',
                      ),
                    ],
                  ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !_isBackendHealthy && !_isCheckingHealth
          ? _buildBackendOfflineWidget()
          : const UploadPage(),
    );
  }

  Widget _buildBackendOfflineWidget() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Backend Server Not Running',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please start the backend server to use this application.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To start the backend:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Open terminal'),
                    const Text('2. Navigate to project directory'),
                    const Text('3. Run: python api.py'),
                    const SizedBox(height: 8),
                    Text(
                      'Expected URL: ${AppConfig.apiBaseUrl}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkBackendHealth,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


