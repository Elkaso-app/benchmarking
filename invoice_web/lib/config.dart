/// API Configuration
class AppConfig {
  // API Base URL - automatically detects environment
  // For production, set API_URL environment variable during build
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8001',
  );
  
  // API Endpoints
  static const String processEndpoint = '/api/process';
  static const String batchProcessEndpoint = '/api/process/batch';
  static const String benchmarkEndpoint = '/api/benchmark';
  static const String listInvoicesEndpoint = '/api/invoices/list';
  static const String listOutputsEndpoint = '/api/outputs/list';
  static const String analyzeCostsEndpoint = '/api/analyze_costs';
  static const String contactRequestEndpoint = '/api/contact_request';
  
  // App Info
  static const String appName = 'Kaso Invoice Analyzer';
  static const String appVersion = '1.0.0';
  
  // Check if running in production
  static bool get isProduction => !apiBaseUrl.contains('localhost');
}
