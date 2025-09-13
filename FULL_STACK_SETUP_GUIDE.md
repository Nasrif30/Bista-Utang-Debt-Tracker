# 🚀 Full Stack Debt Management App - Complete Setup Guide

## 📋 Overview
This is a complete full-stack Flutter debt management application with:
- **Frontend**: Flutter (Mobile + Web)
- **Backend**: Supabase (Database + Functions + Auth)
- **Features**: Offline-first, Dark mode, Export (CSV/PDF), Real-time sync

## 🛠️ Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Supabase account
- Git

## 📱 App Features
✅ **Debt Management**: Add, edit, delete debts  
✅ **Debtor Information**: Name, email, phone, notes, Facebook link  
✅ **Status Tracking**: Active, Settled, Overdue  
✅ **Dark/Light Mode**: Modern UI with theme switching  
✅ **Offline Support**: Works without internet  
✅ **Export**: CSV and PDF export  
✅ **Analytics**: Debt statistics and insights  
✅ **Onboarding**: User-friendly introduction  
✅ **Real-time Sync**: Automatic data synchronization  

## 🔧 Setup Instructions

### 1. Clone and Setup Flutter Project
```bash
# Clone the project
git clone <your-repo-url>
cd bista_utang

# Install dependencies
flutter pub get

# Run the app (for web debugging)
flutter run -d chrome

# Run on mobile device
flutter run -d <device-id>
```

### 2. Supabase Backend Setup

#### Step 1: Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your Project URL and API Key

#### Step 2: Database Setup
Run this SQL in your Supabase SQL Editor:

```sql
-- Create debts table
CREATE TABLE debts (
  id TEXT PRIMARY KEY,
  debtor_name TEXT NOT NULL,
  debtor_email TEXT,
  debtor_phone TEXT,
  debtor_notes TEXT,
  facebook_profile TEXT,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  due_date TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL DEFAULT 'active',
  user_id TEXT NOT NULL DEFAULT 'default_user',
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_debts_user_id ON debts(user_id);
CREATE INDEX idx_debts_status ON debts(status);
CREATE INDEX idx_debts_created_at ON debts(created_at);

-- Enable Row Level Security
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;

-- Create policies (allow all operations for default_user)
CREATE POLICY "Allow all operations for default_user" ON debts
  FOR ALL USING (user_id = 'default_user');
```

#### Step 3: Configure Flutter App
Update `lib/services/supabase_service.dart`:

```dart
class SupabaseService {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  // ... rest of the code
}
```

### 3. Email Notifications Setup (Optional)

#### Step 1: Create Edge Function
Create a new Edge Function in Supabase:

```typescript
// supabase/functions/send-debt-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { debtorEmail, debtorName, amount, currency } = await req.json()
  
  const emailBody = `
    Hello ${debtorName},
    
    This is a reminder about your debt of ${currency} ${amount}.
    
    Please contact us to arrange payment.
    
    Best regards,
    Bista Utang Team
  `
  
  // Send email using Supabase's email service
  // Implementation depends on your email provider
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  })
})
```

#### Step 2: Deploy Function
```bash
supabase functions deploy send-debt-notification
```

### 4. Mobile App Configuration

#### Android Setup
1. Open `android/app/build.gradle`
2. Ensure minimum SDK version is 21+
3. Add permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS Setup
1. Open `ios/Runner.xcworkspace` in Xcode
2. Set minimum deployment target to iOS 11.0+
3. Add permissions in `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library for sharing exports</string>
```

### 5. Build and Deploy

#### Web Deployment
```bash
# Build for web
flutter build web

# Deploy to any static hosting (Netlify, Vercel, etc.)
```

#### Android APK
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS App
```bash
# Build for iOS
flutter build ios --release
```

## 🔧 Troubleshooting

### Common Issues

#### 1. SQLite Error on Web
**Problem**: "databaseFactory not initialized"  
**Solution**: The app uses in-memory database for web debugging. This is normal.

#### 2. Dark Mode Fonts Not Visible
**Problem**: Text invisible in dark mode  
**Solution**: Ensure proper theme colors are set in `ThemeProvider`.

#### 3. Export Not Working
**Problem**: PDF/CSV export fails  
**Solution**: 
- For web: Uses browser download
- For mobile: Requires file system permissions

#### 4. Supabase Connection Issues
**Problem**: Cannot connect to Supabase  
**Solution**: 
- Check URL and API key
- Verify RLS policies
- Check network connectivity

### Debug Mode
```bash
# Run with debug info
flutter run --debug

# Check logs
flutter logs
```

## 📊 App Architecture

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── debt.dart            # Debt data model
├── providers/
│   ├── debt_provider.dart   # State management
│   └── theme_provider.dart  # Theme management
├── screens/
│   ├── onboarding/          # Onboarding flow
│   ├── home/               # Dashboard
│   ├── add_debt/           # Add/Edit debt
│   ├── analytics/          # Statistics
│   └── settings/           # App settings
├── services/
│   ├── supabase_service.dart    # Backend API
│   ├── local_database_service.dart # Local storage
│   ├── sync_service.dart        # Data synchronization
│   ├── export_service.dart      # Export functionality
│   └── device_service.dart      # Device utilities
└── widgets/
    ├── debt_card.dart       # Debt display widget
    ├── custom_text_field.dart # Input widget
    └── search_bar_widget.dart # Search functionality
```

## 🚀 Production Deployment

### 1. Environment Configuration
Create environment-specific configs:
- Development: Use local Supabase instance
- Production: Use production Supabase project

### 2. Security Considerations
- Enable RLS policies in Supabase
- Use environment variables for sensitive data
- Implement proper error handling
- Add input validation

### 3. Performance Optimization
- Implement pagination for large datasets
- Use lazy loading for images
- Optimize database queries
- Cache frequently accessed data

### 4. Monitoring
- Set up error tracking (Sentry, Crashlytics)
- Monitor app performance
- Track user analytics
- Set up database monitoring

## 📱 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing Checklist
- [ ] Add new debt
- [ ] Edit existing debt
- [ ] Delete debt
- [ ] Switch between light/dark mode
- [ ] Export to CSV
- [ ] Export to PDF
- [ ] Offline functionality
- [ ] Data synchronization
- [ ] Search and filter
- [ ] Analytics display

## 🎯 Next Steps

### Potential Enhancements
1. **Push Notifications**: Remind users about due dates
2. **Multi-language Support**: Internationalization
3. **Advanced Analytics**: Charts and graphs
4. **Backup/Restore**: Cloud backup functionality
5. **User Authentication**: Multi-user support
6. **Payment Tracking**: Record partial payments
7. **Recurring Debts**: Set up recurring debt reminders

### Scaling Considerations
- Database optimization for large datasets
- Implement caching strategies
- Add API rate limiting
- Consider microservices architecture
- Implement proper logging and monitoring

## 📞 Support

If you encounter any issues:
1. Check this guide first
2. Review the error logs
3. Check Supabase dashboard
4. Verify Flutter/Dart versions
5. Test on different devices

## 🎉 Congratulations!

You now have a fully functional full-stack debt management application! The app includes:
- Modern, responsive UI
- Offline-first architecture
- Real-time data synchronization
- Export capabilities
- Dark/light mode support
- Comprehensive analytics

Happy coding! 🚀
