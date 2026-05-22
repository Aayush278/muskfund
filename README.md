# MUSKFUND 📊

A modern, professional private portfolio management platform built with a sleek dark-themed UI. MUSKFUND provides a secure investor portal for accessing and managing private investment portfolios.

> "I made this took like a week this is my first project after becoming a loser .....but making and completing projects makes me happy yk"

## 🌟 Features

- **Responsive Design** - Fully responsive across desktop, tablet, and mobile devices
- **Secure Authentication** - Investor login system powered by Supabase
- **Professional UI** - Modern dark theme with cyan/green accent colors and smooth animations
- **Password Reset** - Secure password recovery functionality
- **Account Suspension Handling** - Built-in account status management
- **Role-Based Access** - Support for different user roles (investor/admin)
- **Modern Stack** - HTML5, CSS3, JavaScript with Supabase backend

## 🚀 Getting Started

### Prerequisites
- A modern web browser (Chrome, Firefox, Safari, Edge)
- Supabase account (for backend authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Aayush278/muskfund.git
   cd muskfund
   ```

2. **Configure Supabase**
   - Create a `supabase.js` file in the root directory
   - Add your Supabase project credentials:
   ```javascript
   import { createClient } from '@supabase/supabase-js'
   
   const SUPABASE_URL = 'your_supabase_url'
   const SUPABASE_KEY = 'your_supabase_key'
   
   export const db = createClient(SUPABASE_URL, SUPABASE_KEY)
   ```

3. **Open in browser**
   - Open `index.html` in your web browser or serve using a local server
   ```bash
   # Using Python
   python -m http.server 8000
   
   # Using Node.js (with http-server)
   npx http-server
   ```

## 📁 File Structure

```
muskfund/
├── index.html              # Landing page
├── home.html               # Investor login page
├── dashboard.html          # Investor dashboard (protected)
├── admin-dashboard.html    # Admin dashboard (protected)
├── supabase.js            # Supabase configuration & helper functions
├── terms.html             # Terms of Service
├── privacy.html           # Privacy Policy
└── README.md              # This file
```

## 🔐 Authentication Flow

1. **Landing Page** (`index.html`) - Welcome and introduction
2. **Login Page** (`home.html`) - Investor authentication
   - Requires: Full Name + Aadhaar/Investor ID
   - Password recovery via email
3. **Dashboard** - Role-based redirect:
   - Admin → `admin-dashboard.html`
   - Investor → `dashboard.html`

## 🎨 Design System

### Colors
- **Primary Background**: `#030712` (Deep Navy)
- **Surface**: `#0f172a` (Slate)
- **Accent**: `#00e5ff` (Cyan)
- **Gold**: `#f59e0b` (Warning/Secondary)
- **Red**: `#ef4444` (Error)

### Fonts
- **Display**: Outfit (700, 600, 500)
- **Body**: Inter (600, 500, 400)
- **Mono**: JetBrains Mono (600, 500, 400)

### Key Features
- Glassmorphism effects with backdrop blur
- Smooth animations and transitions
- Gradient accents and glowing effects
- Responsive grid layouts

## 📱 Responsive Breakpoints

- **Desktop**: 1024px and above
- **Tablet**: 768px to 1023px
- **Mobile**: Below 768px
- **Small Mobile**: Below 480px

## 🔧 Configuration

### Environment Variables (in supabase.js)
```javascript
SUPABASE_URL         // Your Supabase project URL
SUPABASE_KEY         // Your Supabase anon public key
```

### Backend Functions Required
The application expects these Supabase RPC functions:
- `get_investor_email(p_name, p_secret)` - Retrieve investor email for authentication
- Database table: `profiles` with fields: `id`, `role`, `is_active`

## 🐛 Known Issues & TODO

- [ ] Separate inline CSS into external stylesheet
- [ ] Modularize JavaScript into separate files
- [ ] Improve accessibility (ARIA labels, keyboard navigation)
- [ ] Add unit tests
- [ ] Implement rate limiting on login attempts
- [ ] Add email verification on signup
- [ ] Create admin panel for investor management
- [ ] Fix investor login page linking (logo should link to index.html)

## 🔒 Security Considerations

- ✅ Uses Supabase Auth for secure password handling
- ✅ Environment-based configuration ready
- ⚠️ Consider implementing CSRF protection
- ⚠️ Add rate limiting on authentication endpoints
- ⚠️ Validate all user inputs on backend
- ⚠️ Use HTTPS in production

## 💡 Usage Tips

### Login Credentials
- **Full Name**: Your registered investor name
- **Password**: Last 6 digits of Aadhaar OR custom investor ID (e.g., MFH-001)

### Password Reset
1. Click "Forgot Password?" on login page
2. Enter your registered email
3. Check inbox for reset link
4. Create new password

### WhatsApp Support
Click "Contact us on WhatsApp" link on login page for quick support.

## 📦 Dependencies

- **Supabase JS Client** - Backend authentication and database
- **Google Fonts** - Outfit, Inter, JetBrains Mono
- **CDN**: jsDelivr (Supabase library)

## 🎯 Performance Metrics

- **Lighthouse Score**: Mobile ~85, Desktop ~92 (can be improved with CSS extraction)
- **Page Load**: ~1-2 seconds (depends on network)
- **Animation Performance**: Smooth 60 FPS on modern browsers
- **Language Composition**: HTML 93.5%, PLpgSQL 3.8%, Python 1.7%, JavaScript 1%

## 🤝 Contributing

This is a personal project, but feedback and suggestions are welcome! Feel free to:
- Report bugs
- Suggest improvements
- Share ideas for new features

## 📄 License

This project is private. All rights reserved.

## 👨‍💻 Author

**Aayush278**

## 🙏 Acknowledgments

- Supabase for authentication backend
- Google Fonts for typography
- Inspired by modern SaaS design patterns

---

**Last Updated**: May 2026

For support, contact via [WhatsApp](https://wa.me/919771534777)
