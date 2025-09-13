# Changelog - Bista Utang App

## Version 3.0.0 - Complete Offline-First App with Export & Sync

### 🐛 Bug Fixes
- **Fixed compilation errors** - Resolved Consumer widget scope issues
- **Fixed theme provider access** - Proper Consumer widget wrapping for theme access
- **Fixed analytics calculation** - Local analytics calculation instead of Supabase dependency

### 🚀 Major Features
- **Offline-First Architecture** - App works completely offline with local SQLite storage
- **Automatic Synchronization** - Seamless sync between local and Supabase when online
- **Export Functionality** - CSV and PDF export with professional formatting
- **Database Resilience** - Continues working even when Supabase is paused/unavailable

### 🎨 UI/UX Improvements
- **Fixed Dark Mode Fonts** - All text now visible in dark mode with proper contrast
- **Theme-Aware Components** - All screens now properly respond to theme changes
- **Enhanced Visual Hierarchy** - Better text contrast and readability
- **Modern Export UI** - Professional export dialogs with success/error feedback

### 🔧 Technical Improvements
- **Local Database Service** - SQLite integration for offline data storage
- **Sync Service** - Intelligent synchronization with conflict resolution
- **Export Service** - Professional CSV/PDF generation with charts and summaries
- **Connectivity Monitoring** - Automatic online/offline detection and handling
- **Queue Management** - Failed operations queued for retry when online

### 📱 App Features
- **Offline Support** - Full functionality without internet connection
- **Data Export** - Export debts to CSV or PDF with detailed formatting
- **Automatic Backup** - Data automatically backed up to Supabase when online
- **Sync Status** - Visual indicators for sync status and connectivity
- **Professional Reports** - PDF exports include summaries, charts, and formatting

### 🛠️ Infrastructure
- **Supabase Integration** - Complete setup guide and database schema
- **Edge Functions** - Ready for email notifications (optional)
- **Database Schema** - Optimized tables with proper indexing
- **Security** - Row Level Security configuration and best practices

## Version 2.1.0 - Bug Fixes & UI Improvements

### 🐛 Bug Fixes
- **Fixed debt creation error** - Added proper ID generation to prevent null constraint violations
- **Fixed compilation errors** - Resolved all null safety and method definition issues
- **Fixed dark mode contrast** - Improved text visibility in dark mode
- **Fixed syntax errors** - Corrected missing closing braces in Consumer widgets
- **Fixed widget structure** - Properly closed Consumer widgets to prevent method scope issues
- **Fixed method scope errors** - Corrected Consumer widget closure in home screen

### 🎨 UI/UX Improvements
- **Moved theme toggle** - Theme switcher now accessible from dashboard top bar
- **Enhanced dark mode** - Better contrast ratios and text visibility
- **Improved card design** - Theme-aware colors and better visual hierarchy
- **Better accessibility** - Improved color contrast for all text elements

### 🚀 Technical Improvements
- **Better error handling** - More robust debt creation with proper ID generation
- **Theme-aware components** - All widgets now properly respond to theme changes
- **Improved user experience** - Theme toggle easily accessible from main screen

## Version 2.0.0 - Supabase-Only Backend & Modern Design

### 🔄 Major Changes
- **Removed SQLite dependency** - App now uses only Supabase for data storage
- **Simplified architecture** - Single backend solution for better reliability
- **Enhanced error handling** - Better null safety and error management

### 🎨 Design Improvements
- **Modern color palette** - Updated to contemporary blue/purple gradient scheme
- **Enhanced card design** - Rounded corners (20px), better shadows, gradient backgrounds
- **Improved button styling** - Larger padding, better elevation, modern shadows
- **Better visual hierarchy** - Improved spacing and typography

### 🚀 Technical Improvements
- **Supabase-only backend** - Removed local SQLite database
- **Better null safety** - Fixed all compilation errors
- **Simplified data flow** - Direct Supabase integration
- **Improved performance** - Faster data operations

## Version 1.1.0 - Modern UI & Bug Fixes

### 🐛 Bug Fixes
- **Fixed SQLite database error** for web/desktop platforms by implementing platform-aware database initialization
- **Fixed UI overflow errors** in the add debt screen by restructuring the layout
- **Resolved layout issues** with proper responsive design

### 🎨 UI/UX Improvements
- **Added modern color scheme** with professional indigo/purple/cyan palette
- **Implemented dark mode support** with automatic theme switching
- **Enhanced visual design** with better shadows, spacing, and typography
- **Added theme toggle** in settings screen
- **Improved responsive layout** for different screen sizes

### 🔧 Technical Improvements
- **Added ThemeProvider** for centralized theme management
- **Implemented platform detection** for database compatibility
- **Enhanced error handling** for better user experience
- **Added proper state management** for theme switching

### 🚀 New Features
- **Dark/Light mode toggle** with persistent settings
- **Modern color palette** with Material Design 3
- **Enhanced visual feedback** with better animations
- **Improved accessibility** with better contrast ratios

### 📱 Supabase Integration
- **Configured Supabase client** with your API credentials
- **Created comprehensive setup guide** (SUPABASE_SETUP.md)
- **Prepared for email notifications** and data synchronization
- **Added database schema** for debt management

### 🎯 Color Scheme
- **Primary**: Indigo (#6366F1) - Modern, professional
- **Secondary**: Purple (#8B5CF6) - Creative, engaging  
- **Accent**: Cyan (#06B6D4) - Fresh, modern
- **Success**: Emerald (#10B981) - Positive, trustworthy
- **Warning**: Amber (#F59E0B) - Attention-grabbing
- **Error**: Red (#EF4444) - Clear, urgent

### 🌙 Dark Mode Features
- **Automatic system detection** or manual toggle
- **Persistent theme preference** across app sessions
- **Optimized contrast ratios** for better readability
- **Consistent design language** in both themes

### 📋 Next Steps for Supabase Setup
1. **Create database table** using the SQL schema in SUPABASE_SETUP.md
2. **Set up Row Level Security** for data protection
3. **Configure email notifications** using Edge Functions
4. **Test data synchronization** between local and cloud storage

### 🔄 Migration Notes
- **No breaking changes** - existing data preserved
- **Theme preferences** automatically migrated
- **Database structure** remains compatible
- **All existing features** continue to work

---

## Version 1.0.0 - Initial Release

### ✨ Core Features
- Debt management with CRUD operations
- Local SQLite storage
- Modern UI with Material Design
- Search and filter functionality
- Analytics dashboard
- Onboarding screens
- Settings and configuration

### 📱 Platform Support
- Android
- iOS  
- Web
- Windows
- macOS
- Linux

### 🛠️ Technology Stack
- Flutter 3.5.4+
- Provider state management
- SQLite local storage
- Google Fonts typography
- Material Design 3
