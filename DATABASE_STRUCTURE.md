# Database Structure

This document describes the organization of SQL database files.

## SQL Files Location

All SQL files are maintained in the root directory:
- Database setup files: `*_database_setup.sql`
- Migration files: `*.sql`
- Utility scripts: `*.sql`

## Files

### Setup Scripts
- `MUSKFUND_MASTER_DATABASE_SETUP.sql` - Master database initialization
- `MUSKFUND_FINAL_BACKUP.sql` - Database backup
- `database_setup.sql` - Alternative setup script
- `final_database_setup.sql` - Final setup configuration

### Authorization & Security
- `apply_rls.sql` - Row Level Security policies
- `bypass_auth.sql` - Authentication bypass utilities
- `fix_rls.sql` - RLS fixes
- `fix_rls_v2.sql` - RLS v2 fixes

### Features
- `create_investor.sql` - Create investor functionality
- `update_db.sql` - Database updates
- `update_db_features.sql` - Feature updates
- `setup_avatars.sql` - Avatar setup
- `add_avatar.sql` - Add avatar functionality

## Migration Path

When executing migrations, follow this order:
1. Run master database setup
2. Apply RLS policies
3. Create investor accounts
4. Set up avatars
5. Run final setup
