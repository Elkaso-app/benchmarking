# Invoice Benchmarking Tool - Flutter Web Frontend

A beautiful, modern Flutter web application for processing and benchmarking invoice extraction using AI.

## Features

✨ **Upload & Process Invoices**
- Drag and drop PDF invoices
- Process single or multiple files
- Real-time processing status
- View extracted data immediately

📊 **Run Benchmarks**
- Process all invoices from server directory
- Configurable processing limits
- Detailed performance metrics
- Success rate tracking

📈 **Results & Analytics**
- View all extracted invoice data
- Download CSV exports
- Processing time statistics
- Success/failure tracking

🎨 **Modern UI**
- Material Design 3
- Responsive layout
- Real-time backend status
- Intuitive navigation

## Prerequisites

1. **Flutter SDK** (3.10.1 or higher)
   - Install from: https://flutter.dev/docs/get-started/install

2. **Backend Server Running**
   - The FastAPI backend must be running on `http://localhost:8000`
   - See backend README for setup instructions

## Quick Start

### 1. Install Dependencies

```bash
cd invoice_web
flutter pub get
```

### 2. Start Backend Server

In a separate terminal, start the Python backend:

```bash
cd ..
python api.py
```

Backend should be running at: http://localhost:8000

### 3. Run Flutter Web App

```bash
flutter run -d chrome
```

Or for hot reload in development:

```bash
flutter run -d web-server --web-port 8080
```

The app will open in your browser at: http://localhost:8080

## Project Structure

```
invoice_web/
├── lib/
│   ├── config.dart                    # API configuration
│   ├── main.dart                      # App entry point
│   │
│   ├── models/
│   │   └── invoice_data.dart          # Data models
│   │
│   ├── services/
│   │   └── api_service.dart           # API client
│   │
│   ├── pages/
│   │   ├── home_page.dart             # Main page with navigation
│   │   ├── upload_page.dart           # Upload & process page
│   │   └── benchmark_page.dart        # Benchmark page
│   │
│   └── widgets/
│       └── invoice_result_card.dart   # Result display widget
│
├── pubspec.yaml                       # Dependencies
└── README.md                          # This file
```

## Configuration

Edit `lib/config.dart` to change the backend URL:

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000';
}
```

## Usage Guide

### Upload & Process Invoices

1. Click **"Upload Invoices"** tab in the bottom navigation
2. Click **"Choose Files"** button
3. Select one or more PDF invoice files
4. Click **"Process Invoices"**
5. View results and download CSV exports

### Run Benchmark

1. Click **"Run Benchmark"** tab
2. Select processing limit (or process all)
3. Click **"Run Benchmark"**
4. View detailed results and statistics
5. Download CSV and JSON reports

## Features in Detail

### Backend Status Indicator

The app shows real-time connection status to the backend:
- 🟢 **Green**: Backend is connected and healthy
- 🔴 **Red**: Backend is offline or unreachable

Click the refresh icon to retry connection.

### Processing Results

For each processed invoice, you can view:
- ✅ Success/failure status
- ⏱️ Processing time
- 📄 Invoice metadata (number, date, vendor, customer)
- 📋 All line items with quantities and prices
- 💰 Totals (subtotal, tax, total amount)

### CSV Exports

Two types of CSV files are generated:

1. **Items CSV**: All line items from all invoices
2. **Summary CSV**: Processing summary and invoice totals

## Building for Production

### Build Web App

```bash
flutter build web --release
```

Output will be in `build/web/` directory.

### Deploy

You can deploy the built web app to any static hosting service:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages
- AWS S3 + CloudFront

Example with Firebase:

```bash
firebase deploy
```

## Troubleshooting

### "Backend Server Not Running"

**Problem**: App shows backend offline message

**Solution**:
1. Make sure Python backend is running: `python api.py`
2. Check backend URL in `lib/config.dart`
3. Check backend is accessible at http://localhost:8000/health

### CORS Errors

**Problem**: Browser shows CORS errors in console

**Solution**:
The backend already has CORS enabled for all origins. If issues persist:
1. Check backend CORS middleware in `api.py`
2. Try accessing backend from same domain

### File Upload Not Working

**Problem**: Files don't upload or process

**Solution**:
1. Ensure files are PDFs (other formats not supported)
2. Check file size (backend has 10MB limit by default)
3. Check browser console for errors

### Slow Processing

**Problem**: Invoice processing takes too long

**Solution**:
1. This is normal - LLM processing takes 2-5 seconds per invoice
2. Use the limit option to process fewer invoices for testing
3. Check your OpenAI/Anthropic API rate limits

## Development

### Hot Reload

Flutter supports hot reload for rapid development:

```bash
flutter run -d chrome
```

Then press `r` to hot reload or `R` to hot restart.

### Debug Mode

Run in debug mode to see detailed logs:

```bash
flutter run -d chrome --verbose
```

### Code Generation

If you add new models or serialization, run:

```bash
flutter pub run build_runner build
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `http` | ^1.2.0 | HTTP client for API calls |
| `file_picker` | ^8.0.0 | File selection dialog |
| `provider` | ^6.1.1 | State management |
| `intl` | ^0.19.0 | Internationalization & formatting |
| `url_launcher` | ^6.2.3 | Open download links |

## API Integration

The app communicates with the backend via REST API:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/process` | POST | Process single invoice |
| `/api/process/batch` | POST | Process multiple invoices |
| `/api/benchmark` | POST | Run benchmark |
| `/api/invoices/list` | GET | List available invoices |
| `/api/download/{type}/{file}` | GET | Download CSV/JSON |
| `/health` | GET | Backend health check |

See `lib/services/api_service.dart` for implementation details.

## Browser Support

Tested and working on:
- ✅ Chrome/Chromium (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge

## Performance

- Initial load: < 2 seconds
- File upload: Instant (local processing)
- Invoice processing: 2-5 seconds per invoice (depends on LLM API)
- UI response: < 100ms

## Future Enhancements

Planned features:
- [ ] Drag & drop file upload
- [ ] Real-time processing progress with WebSockets
- [ ] Invoice preview before processing
- [ ] Batch comparison and analytics
- [ ] Export to Excel format
- [ ] Dark mode theme
- [ ] Mobile responsive design
- [ ] Authentication and user accounts

## License

MIT License

## Support

For issues or questions:
1. Check backend logs: `python api.py`
2. Check browser console for errors
3. Review API documentation: http://localhost:8000/docs

## Screenshots

### Upload Page
Upload and process invoice PDFs with immediate results.

### Benchmark Page
Run comprehensive benchmarks with detailed statistics.

### Results Display
View extracted invoice data in a clean, organized format.

---

Built with ❤️ using Flutter and FastAPI
