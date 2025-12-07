# 🔔 Slack Integration - Contact Request Feature

## ✅ Feature Implemented

### Overview
When users click "Contact Suppliers Now", they can submit their contact information (email/phone), and the system will send the request along with the full items list to a Slack webhook.

---

## 🎯 User Flow

### 1. User Clicks Button
- On the blurred suppliers section
- Button: **"Contact Suppliers Now"**

### 2. Contact Form Popup
- **Fields**:
  - 📧 Email Address (optional)
  - 📱 Phone Number (optional)
  - ⚠️ At least one is required
- **Submit Button**: "Submit Request"
- **Info**: "We'll send you supplier options within 24 hours"

### 3. Data Submission
**Frontend → Backend → Slack**

**Frontend sends to backend**:
```json
{
  "email": "user@example.com",
  "phone": "+971 50 123 4567",
  "items": [...full items list...],
  "timestamp": "2025-12-08T00:10:00Z"
}
```

**Backend processes and sends to Slack**:
- Formats message with contact info
- Includes items summary (first 10 items)
- Attaches full JSON data
- Sends to Slack webhook

### 4. Success Message
- ✅ Green checkmark icon
- "Request Submitted!"
- "Kaso team will contact you within 24 hours"

---

## 🔧 Technical Implementation

### Frontend Changes

#### File: `invoice_web/lib/widgets/blurred_suppliers_list.dart`

**New Features**:
1. **Contact Form Dialog**
   - Email input field
   - Phone input field
   - Form validation
   - Loading state during submission

2. **API Integration**
   - Sends POST request to `/api/contact_request`
   - Includes items list from parent widget
   - Handles success/error responses

3. **Success/Error Modals**
   - Success: Green checkmark with confirmation
   - Error: Alert dialog with error message

**Key Changes**:
```dart
// Widget now accepts items list
class BlurredSuppliersList extends StatefulWidget {
  final List<dynamic>? itemsList;
  
  const BlurredSuppliersList({
    super.key,
    this.itemsList,
  });
}

// Sends data to backend
Future<void> _submitContactInfo(BuildContext context, String email, String phone) async {
  final data = {
    'email': email,
    'phone': phone,
    'items': widget.itemsList ?? [],
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  final response = await http.post(
    Uri.parse('http://localhost:8001/api/contact_request'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
}
```

#### File: `invoice_web/lib/pages/upload_page.dart`

**Updated**:
```dart
// Pass items list to widget
BlurredSuppliersList(itemsList: _masterList),
```

---

### Backend Changes

#### File: `api.py`

**New Endpoint**: `/api/contact_request`

```python
@app.post("/api/contact_request")
async def submit_contact_request(request: Request):
    """Submit contact request and send to Slack webhook."""
    data = await request.json()
    email = data.get('email', '')
    phone = data.get('phone', '')
    items = data.get('items', [])
    timestamp = data.get('timestamp', datetime.now().isoformat())
    
    # Slack webhook URL
    slack_webhook_url = "https://hooks.slack.com/services/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"
    
    # Format and send to Slack
    slack_message = {
        "text": "🔔 New Supplier Contact Request",
        "blocks": [...],
        "attachments": [...]
    }
    
    response = requests.post(slack_webhook_url, json=slack_message)
```

**Features**:
- Receives contact info and items from frontend
- Formats Slack message with rich formatting
- Includes contact information
- Shows items summary (first 10 items)
- Attaches full JSON data
- Returns success/error response

#### File: `requirements.txt`

**Added**:
```
requests>=2.31.0
```

---

## 📨 Slack Message Format

### Message Structure

**Header**:
```
🔔 New Supplier Contact Request
```

**Contact Information Section**:
```
Contact Information:
📧 Email: user@example.com
📱 Phone: +971 50 123 4567

Time:
2025-12-08T00:10:00Z
```

**Items Summary Section**:
```
📦 Items Summary (25 items):
1. Tomatoes - 50.0 kg (AED 45.00 - 48.50)
2. Onions - 30.0 kg (AED 35.00 - 38.00)
3. Potatoes - 75.0 kg (AED 25.00 - 28.00)
... (first 10 items)
... and 15 more items
```

**JSON Attachment**:
```json
{
  "description": "Tomatoes",
  "total_quantity": 50.0,
  "unit": "kg",
  "price_min": 45.00,
  "price_max": 48.50,
  "occurrences": 5
}
```

---

## 🔐 Security & Configuration

### Slack Webhook URL
**Hardcoded in backend**: `api.py`

```python
slack_webhook_url = "https://hooks.slack.com/services/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"
```

**To Update**:
1. Get new webhook URL from Slack
2. Update `slack_webhook_url` in `api.py`
3. Restart backend server

### Data Flow Security
✅ **Frontend → Backend → Slack**
- Frontend never directly contacts Slack
- Backend validates and formats data
- Slack webhook is server-side only

---

## 🧪 Testing

### Test the Feature

1. **Start Servers**:
```bash
# Backend
cd /Users/issam/Desktop/elkaso/Backend/ai/benchmarking
source venv/bin/activate
python3 api.py

# Frontend
cd invoice_web
flutter run -d chrome --web-port 3000
```

2. **Upload Invoices**:
- Go to http://localhost:3000
- Upload 5-10 PDF invoices
- Click "Process Invoices"
- Wait for processing to complete

3. **Test Contact Form**:
- Scroll to "Blurred Suppliers" section
- Click **"Contact Suppliers Now"**
- Enter email: `test@example.com`
- Enter phone: `+971 50 123 4567`
- Click **"Submit Request"**

4. **Verify**:
- ✅ Success message appears
- ✅ Check Slack channel for message
- ✅ Message includes contact info
- ✅ Message includes items summary
- ✅ JSON attachment has full data

### Test Cases

#### ✅ Valid Submissions
- Email only
- Phone only
- Both email and phone

#### ✅ Validation
- Empty form (should show error)
- Invalid email format (should show error)
- Valid submission (should succeed)

#### ✅ Backend
- Endpoint responds with 200
- Slack receives formatted message
- Full items JSON is included

---

## 📊 Data Sent to Slack

### Contact Information
- Email address (if provided)
- Phone number (if provided)
- Timestamp of request

### Items Data
Each item includes:
- `description`: Item name
- `total_quantity`: Total quantity across invoices
- `unit`: Unit of measurement (kg, pcs, etc.)
- `price_min`: Lowest price seen
- `price_max`: Highest price seen
- `occurrences`: Number of times item appears

### Example Item
```json
{
  "description": "Fresh Tomatoes",
  "total_quantity": 125.5,
  "unit": "kg",
  "price_min": 42.00,
  "price_max": 48.50,
  "occurrences": 8
}
```

---

## 🎯 Benefits

### For Users
- ✅ Easy to submit contact request
- ✅ No need to manually send data
- ✅ Confirmation of submission
- ✅ Clear timeline (24 hours)

### For Kaso Team
- ✅ Automatic notifications in Slack
- ✅ Full context (contact + items)
- ✅ Structured data for analysis
- ✅ Easy to respond to requests

### For System
- ✅ Centralized data flow
- ✅ Secure (backend-only webhook)
- ✅ Formatted for readability
- ✅ JSON for automation

---

## 🚀 Status

### ✅ Completed
- [x] Contact form UI
- [x] Form validation
- [x] Frontend API integration
- [x] Backend endpoint
- [x] Slack webhook integration
- [x] Success/error handling
- [x] Items list passing
- [x] Message formatting
- [x] JSON attachment

### 🎊 Ready to Use!

**Both servers running**:
- Backend: http://localhost:8001
- Frontend: http://localhost:3000

**Test now**: Upload invoices and try the contact form!

---

## 📝 Files Modified

### Frontend
1. `invoice_web/lib/widgets/blurred_suppliers_list.dart` - Contact form & API call
2. `invoice_web/lib/pages/upload_page.dart` - Pass items list

### Backend
1. `api.py` - New `/api/contact_request` endpoint
2. `requirements.txt` - Added `requests` library

### Documentation
1. `SLACK_INTEGRATION.md` - This file

---

**Built with ❤️ - Slack integration ready!** 🚀

