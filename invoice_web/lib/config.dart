/// API Configuration
class AppConfig {
  // API Base URL - change this if your backend is on a different host/port
  static const String apiBaseUrl = 'http://localhost:8001';
  
  // API Endpoints
  static const String processEndpoint = '/api/process';
  static const String batchProcessEndpoint = '/api/process/batch';
  static const String benchmarkEndpoint = '/api/benchmark';
  static const String listInvoicesEndpoint = '/api/invoices/list';
  static const String listOutputsEndpoint = '/api/outputs/list';
  static const String downloadEndpoint = '/api/download';
  
  // App Info
  static const String appName = 'Invoice Benchmarking Tool';
  static const String appVersion = '1.0.0';
}


