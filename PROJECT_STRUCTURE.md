# MUSKFUND Project Structure

## Overview

This project has been reorganized to separate concerns and improve maintainability.

## Directory Structure

```
muskfund/
├── html/                    # HTML files (all web pages)
│   ├── index.html          # Landing page
│   ├── dashboard.html      # User dashboard
│   ├── admin-dashboard.html
│   ├── admin-login.html
│   └── ...                 # Other HTML pages
│
├── js/                     # JavaScript files
│   ├── supabase.js        # Supabase client & helpers
│   ├── update-theme.js    # Theme management
│   └── ...                # Other JavaScript files
│
├── css/                    # CSS stylesheets
│   └── (To be populated)   # Individual CSS files
│
├── images/                 # Image assets
│   └── IMG_0017.PNG
│
├── database/              # Database files
│   └── *.sql              # SQL setup & migration scripts
│
├── python/                # Python utility scripts
│   ├── apply-aqua-theme.py
│   ├── disable-animations.py
│   ├── enhance-colors.py
│   ├── fix-mobile-grids.py
│   ├── fix-viewport.py
│   ├── update-theme.py
│   └── upgrade-legal.py
│
└── docs/                  # Documentation
    ├── DATABASE_STRUCTURE.md
    ├── PROJECT_STRUCTURE.md
    └── README.md
```

## File Organization

### HTML Pages
All `.html` files should be in the `html/` directory.
- Update script references to use relative paths: `../js/filename.js`
- Update link references for navigation: Use relative paths or build URLs

### JavaScript Files
All `.js` files should be in the `js/` directory.
- `supabase.js` - Core database client
- `update-theme.js` - Theme switching functionality

### SQL Files
Keep in `database/` or root directory (for deployment compatibility).

### Asset Files
Images and media in `images/` directory.

## Deployment Notes

### For Vercel/Static Hosting
1. Ensure HTML files reference correct JS paths
2. Build process may need adjustment for file references
3. Database scripts stay in root or separate directory

### For Node.js Backend
1. Move `database/` files to backend directory
2. Reference with absolute paths
3. Implement database migration runner

## Next Steps

1. ✅ Create directory structure
2. ⬜ Move HTML files to `html/` directory
3. ⬜ Move JS files to `js/` directory
4. ⬜ Create `css/` files and organize styles
5. ⬜ Move images to `images/` directory
6. ⬜ Update all file references in HTML
7. ⬜ Test deployment
8. ⬜ Update CI/CD pipelines if applicable
