# Supabase Setup Guide for Bista Utang

This guide will help you set up Supabase for the Bista Utang debt management app with offline support and automatic synchronization.

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `bista-utang`
   - **Database Password**: Choose a strong password
   - **Region**: Select the closest region to your users
6. Click "Create new project"
7. Wait for the project to be created (usually takes 1-2 minutes)

## 2. Database Setup

### 2.1 Create the Debts Table

1. Go to the **SQL Editor** in your Supabase dashboard
2. Click "New Query"
3. Run the following SQL to create the debts table:

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
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  due_date TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL DEFAULT 'active',
  user_id TEXT NOT NULL,
  last_modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_debts_user_id ON debts(user_id);
CREATE INDEX idx_debts_status ON debts(status);
CREATE INDEX idx_debts_created_at ON debts(created_at);
CREATE INDEX idx_debts_synced_at ON debts(synced_at);
```

### 2.2 Set Up Row Level Security (RLS)

Since we're not using authentication, we'll disable RLS for simplicity:

```sql
-- Disable RLS for the debts table
ALTER TABLE debts DISABLE ROW LEVEL SECURITY;
```

### 2.3 Create Email Notifications Function

Create a function to send email notifications when debts are created or updated:

```sql
-- Create function to send debt notifications
CREATE OR REPLACE FUNCTION send_debt_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- This will be handled by Edge Functions
  -- For now, we'll just log the event
  INSERT INTO debt_notifications (debt_id, action, created_at)
  VALUES (NEW.id, TG_OP, NOW());
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create notifications log table
CREATE TABLE debt_notifications (
  id SERIAL PRIMARY KEY,
  debt_id TEXT NOT NULL,
  action TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create trigger for debt notifications
CREATE TRIGGER debt_notification_trigger
  AFTER INSERT OR UPDATE ON debts
  FOR EACH ROW
  EXECUTE FUNCTION send_debt_notification();
```

## 3. API Configuration

### 3.1 Get Your Project Credentials

1. Go to **Settings** → **API** in your Supabase dashboard
2. Copy the following values:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Anon/Public Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 3.2 Update Your Flutter App

Update the credentials in `lib/services/supabase_service.dart`:

```dart
class SupabaseService {
  static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
  // ... rest of the code
}
```

## 4. Email Notifications Setup (Optional)

### 4.1 Create Edge Function for Email Notifications

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Initialize Supabase in your project:
   ```bash
   supabase init
   ```

3. Create an Edge Function:
   ```bash
   supabase functions new send-debt-notification
   ```

4. Add the following code to `supabase/functions/send-debt-notification/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { debtData, action } = await req.json()
    
    // Here you would integrate with your email service
    // For example, using Resend, SendGrid, or similar
    
    return new Response(
      JSON.stringify({ success: true }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})
```

5. Deploy the function:
   ```bash
   supabase functions deploy send-debt-notification
   ```

## 5. Offline Support Architecture

The app is designed with the following offline-first architecture:

### 5.1 Local Storage (SQLite)
- All debt data is stored locally on the device
- App works completely offline
- Fast read/write operations

### 5.2 Automatic Synchronization
- When online, changes are synced to Supabase
- Failed operations are queued for retry
- Periodic sync every 5 minutes when online

### 5.3 Conflict Resolution
- Last write wins (simple approach)
- Local changes take precedence
- Supabase acts as backup/cloud storage

## 6. Database Pausing and Resumption

### 6.1 Handling Supabase Downtime
- App continues to work with local data
- All operations are queued locally
- Automatic retry when Supabase comes back online

### 6.2 Monitoring Sync Status
The app tracks:
- Online/offline status
- Pending sync operations
- Last successful sync time

## 7. Testing Your Setup

### 7.1 Test Database Connection
1. Run your Flutter app
2. Try adding a debt
3. Check the Supabase dashboard to see if the data appears

### 7.2 Test Offline Functionality
1. Turn off your internet connection
2. Add/edit/delete debts
3. Turn internet back on
4. Verify data syncs to Supabase

### 7.3 Test Export Functionality
1. Add some test debts
2. Go to Analytics screen
3. Tap "Export Data"
4. Try both CSV and PDF exports

## 8. Production Considerations

### 8.1 Security
- Consider enabling RLS if you add authentication later
- Use environment variables for API keys
- Implement proper error handling

### 8.2 Performance
- Monitor database performance
- Consider adding more indexes if needed
- Implement pagination for large datasets

### 8.3 Backup
- Enable automatic backups in Supabase
- Consider implementing data export/import features
- Regular testing of restore procedures

## 9. Troubleshooting

### Common Issues:

1. **Connection Errors**
   - Check your API URL and key
   - Verify Supabase project is not paused
   - Check internet connectivity

2. **Sync Issues**
   - Check sync queue in local database
   - Verify Supabase table structure
   - Check for data type mismatches

3. **Export Issues**
   - Ensure proper file permissions
   - Check available storage space
   - Verify PDF/CSV libraries are properly installed

## 10. Next Steps

1. Set up monitoring and alerts
2. Implement user authentication (optional)
3. Add more advanced analytics
4. Consider implementing real-time updates
5. Add data validation and sanitization

This setup provides a robust, offline-first debt management system with cloud backup and synchronization capabilities.
