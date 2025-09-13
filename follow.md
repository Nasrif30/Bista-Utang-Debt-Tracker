Create a modern Flutter app for monitoring debts with Supabase as the backend, without login authentication.

Core Features:

Onboarding Splash Screen:

Sliding intro (3–4 slides) with animations explaining how the app works.

Show only on first launch, then skip.

Debt Management:

Add debts with flexible amounts (min. 1 USD or 1 PHP).

Enter full debtor info: name, email (for notifications), notes, and Facebook profile link.

Mark debts as “Active” or “Settled.”

Update or delete debts anytime.

Notifications to Debtors:

When a debt is created or updated, the debtor receives an email notification with details (amount, due date, notes, etc.).

Supabase Functions handle sending emails.

Option to send reminder notifications manually from the app (like “Send Reminder” button).

For local reminders (if user wants to remind themselves), use Flutter local notifications to alert the user about unpaid debts.

Storage & Sync (No Login):

Debts stored locally (Hive or SQLite) for offline-first access.

App generates a unique device ID to separate data per user.

Supabase syncs in the background for sending email notifications and backups.

UI/UX:

Clean, modern design with fast loading dashboard.

Rounded cards for each debt entry with status indicators (red = active, green = settled).

Bottom tabs: Home, Add Debt, Analytics, Settings.

Search and filter debts by name, date, or amount.

Analytics & Extras:

Show total debt, active debts, and settled debts.

Copy Facebook profile link easily.

Export debts as CSV or PDF.

Backend (Supabase):

Database stores debtor details and status.

Supabase Functions send email notifications automatically to debtors.

Option to schedule reminder emails (e.g., daily, weekly, custom).

⚡ So with this setup:

Debtor gets email notifications/reminders from Supabase.

User gets local notifications to remind them of debts.