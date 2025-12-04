import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../config.dart';
import '../models/invoice_data.dart';

/// API Service for communicating with the backend
class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Process a single invoice file
  Future<ProcessingResult> processSingleInvoice(PlatformFile file) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.processEndpoint}');
      final request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ProcessingResult.fromJson(json);
      } else {
        throw Exception('Failed to process invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error processing invoice: $e');
    }
  }

  /// Process multiple invoice files
  Future<BenchmarkResult> processBatchInvoices(List<PlatformFile> files) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.batchProcessEndpoint}');
      final request = http.MultipartRequest('POST', uri);

      // Add all files
      for (var file in files) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return BenchmarkResult.fromJson(json);
      } else {
        throw Exception('Failed to process batch: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error processing batch: $e');
    }
  }

  /// Run benchmark on server invoices
  Future<BenchmarkResult> runBenchmark({int? limit}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl${AppConfig.benchmarkEndpoint}${limit != null ? '?limit=$limit' : ''}',
      );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return BenchmarkResult.fromJson(json['benchmark']);
      } else {
        throw Exception('Failed to run benchmark: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error running benchmark: $e');
    }
  }

  /// List invoices available on server
  Future<List<String>> listInvoices() async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.listInvoicesEndpoint}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return List<String>.from(json['files'] ?? []);
      } else {
        throw Exception('Failed to list invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing invoices: $e');
    }
  }

  /// Get download URL for a file
  String getDownloadUrl(String fileType, String filename) {
    return '$baseUrl${AppConfig.downloadEndpoint}/$fileType/$filename';
  }

  /// Check if backend is healthy
  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}



