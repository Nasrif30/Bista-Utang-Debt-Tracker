# Supabase Setup Guide for Bista Utang

This guide will help you set up Supabase for your debt management app to enable email notifications and data synchronization.

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `bista-utang` (or your preferred name)
   - **Database Password**: Create a strong password
   - **Region**: Choose the closest region to your users
6. Click "Create new project"

## 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project-id.supabase.co`)
   - **Anon/Public Key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

3. Update your Flutter app:
   - Open `lib/services/supabase_service.dart`
   - Replace the placeholder values with your actual credentials:
   ```dart
   static const String supabaseUrl = 'https://your-project-id.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key-here';
   ```

## 3. Create Database Tables

1. In your Supabase dashboard, go to **Table Editor**
2. Click "Create a new table"
3. Create the `debts` table with the following structure:

```sql
CREATE TABLE debts (
  id TEXT PRIMARY KEY,
  debtor_name TEXT NOT NULL,
  debtor_email TEXT,
  debtor_phone TEXT,
  debtor_notes TEXT,
  facebook_profile TEXT,
  amount REAL NOT NULL,
  currency TEXT DEFAULT 'USD',
  created_at TEXT NOT NULL,
  due_date TEXT,
  status TEXT DEFAULT 'active',
  user_id TEXT DEFAULT 'default_user'
);
```

4. Click "Save" to create the table

## 4. Set Up Row Level Security (RLS)

1. In the Table Editor, click on your `debts` table
2. Go to the **RLS** tab
3. Enable Row Level Security
4. Create a policy to allow all operations (for now):

```sql
-- Allow all operations for all users (you can restrict this later)
CREATE POLICY "Allow all operations" ON debts
FOR ALL USING (true);
```

## 5. Set Up Email Notifications (Optional)

### Option A: Using Supabase Edge Functions

1. Go to **Edge Functions** in your Supabase dashboard
2. Create a new function called `send-debt-notification`
3. Use this template:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { debtorEmail, debtorName, amount, currency, notes } = await req.json()
  
  const emailBody = `
    Hello ${debtorName},
    
    This is a reminder about your debt of ${currency} ${amount}.
    
    ${notes ? `Notes: ${notes}` : ''}
    
    Please contact us to arrange payment.
    
    Best regards,
    Bista Utang App
  `
  
  // You'll need to configure email service (Resend, SendGrid, etc.)
  // This is a placeholder - implement your email service
  
  return new Response(
    JSON.stringify({ success: true, message: "Email sent" }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

### Option B: Using External Email Service

You can integrate with services like:
- **Resend** (recommended for developers)
- **SendGrid**
- **Mailgun**
- **Amazon SES**

## 6. Configure Email Service (Resend Example)

1. Sign up at [resend.com](https://resend.com)
2. Get your API key
3. Update your Edge Function to use Resend:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { debtorEmail, debtorName, amount, currency, notes } = await req.json()
  
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'noreply@yourdomain.com',
      to: [debtorEmail],
      subject: `Debt Reminder - ${currency} ${amount}`,
      html: `
        <h2>Debt Reminder</h2>
        <p>Hello ${debtorName},</p>
        <p>This is a reminder about your debt of <strong>${currency} ${amount}</strong>.</p>
        ${notes ? `<p><strong>Notes:</strong> ${notes}</p>` : ''}
        <p>Please contact us to arrange payment.</p>
        <p>Best regards,<br>Bista Utang App</p>
      `,
    }),
  })
  
  return new Response(
    JSON.stringify({ success: true, message: "Email sent" }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

## 7. Test Your Setup

1. Run your Flutter app: `flutter run`
2. Try adding a debt with an email address
3. Check if the data appears in your Supabase dashboard
4. Test the email notification (if implemented)

## 8. Security Considerations

### For Production:

1. **Enable RLS properly**:
```sql
-- More secure policy example
CREATE POLICY "Users can only see their own debts" ON debts
FOR ALL USING (user_id = auth.uid());
```

2. **Use environment variables** for sensitive data
3. **Set up proper authentication** if needed
4. **Configure CORS** for web deployment
5. **Set up database backups**

## 9. Environment Variables

For production, use environment variables:

```dart
// In your Flutter app
static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

## 10. Troubleshooting

### Common Issues:

1. **CORS errors**: Configure CORS in Supabase dashboard
2. **RLS blocking requests**: Check your RLS policies
3. **Email not sending**: Verify your email service configuration
4. **Database connection issues**: Check your credentials and network

### Useful Commands:

```bash
# Check Supabase status
supabase status

# Generate types for your database
supabase gen types typescript --local > types/supabase.ts
```

## Next Steps

1. **Implement email notifications** using the Edge Function
2. **Add user authentication** if needed
3. **Set up data backup** and recovery
4. **Configure monitoring** and alerts
5. **Deploy to production** with proper security

## Support

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Edge Functions Documentation](https://supabase.com/docs/guides/functions)

---

**Note**: This setup provides a basic configuration. For production use, implement proper security measures, authentication, and monitoring.
