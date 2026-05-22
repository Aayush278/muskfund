const fs = require('fs');
const path = require('path');

const newFonts = `<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Outfit:wght@500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />`;

const files = fs.readdirSync(__dirname).filter(f => f.endsWith('.html') && f !== 'dashboard.html' && f !== 'profile.html');

for (const file of files) {
    const filePath = path.join(__dirname, file);
    let content = fs.readFileSync(filePath, 'utf-8');

    // 1. Replace Google Fonts link
    content = content.replace(/<link[^>]*href=["']https:\/\/fonts\.googleapis\.com\/css2\?family=Bebas\+Neue[^>]*>/, newFonts);

    // 2. Replace CSS root variables dynamically
    content = content.replace(/--bg:\s*#[0-9a-fA-F]+;/, '--bg: #09090b;');
    content = content.replace(/--surface:\s*#[0-9a-fA-F]+;/, '--surface: #121214;');
    content = content.replace(/--surface2:\s*#[0-9a-fA-F]+;/, '--surface2: #18181b;');
    content = content.replace(/--border:\s*#[0-9a-fA-F]+;/, '--border: #27272a;');
    content = content.replace(/--green:\s*#[0-9a-fA-F]+;/, '--green: #10b981;');
    content = content.replace(/--green-dim:\s*rgba\([^\)]+\);/, '--green-dim: rgba(16, 185, 129, 0.1);');
    content = content.replace(/--green-mid:\s*rgba\([^\)]+\);/, '--green-mid: rgba(16, 185, 129, 0.3);');
    content = content.replace(/--gold:\s*#[0-9a-fA-F]+;/, '--gold: #f59e0b;');
    content = content.replace(/--red:\s*#[0-9a-fA-F]+;/, '--red: #ef4444;');
    content = content.replace(/--red-dim:\s*rgba\([^\)]+\);/, '--red-dim: rgba(239, 68, 68, 0.1);');
    content = content.replace(/--white:\s*#[0-9a-fA-F]+;/, '--white: #ffffff;');
    content = content.replace(/--grey:\s*#[0-9a-fA-F]+;/, '--grey: #a1a1aa;');
    content = content.replace(/--grey2:\s*#[0-9a-fA-F]+;/, '--grey2: #71717a;');
    
    // Add font variables if they don't exist, or replace them
    if(content.includes('--font-display')) {
        content = content.replace(/--font-display:[^;]+;/, "--font-display: 'Outfit', sans-serif;");
        content = content.replace(/--font-body:[^;]+;/, "--font-body: 'Inter', sans-serif;");
        content = content.replace(/--font-mono:[^;]+;/, "--font-mono: 'JetBrains Mono', monospace;");
    } else {
        // inject font variables into root
        content = content.replace(/:root\s*{/, ":root {\n            --font-display: 'Outfit', sans-serif;\n            --font-body: 'Inter', sans-serif;\n            --font-mono: 'JetBrains Mono', monospace;");
    }

    // Replace explicit font families in CSS
    content = content.replace(/font-family:\s*['\"]*Bebas Neue['\"]*[^;]+;/g, "font-family: var(--font-display);");
    content = content.replace(/font-family:\s*['\"]*DM Sans['\"]*[^;]+;/g, "font-family: var(--font-body);");
    content = content.replace(/font-family:\s*['\"]*DM Mono['\"]*[^;]+;/g, "font-family: var(--font-mono);");

    // Replace card backgrounds with linear gradients for glassmorphism
    content = content.replace(/background:\s*var\(--surface\);\s*border:\s*1px\s*solid\s*var\(--border\);\s*border-radius:\s*(16px|14px|12px|10px);/g, (match, p1) => {
        return `background: linear-gradient(180deg, var(--surface) 0%, var(--bg) 100%);\n            border: 1px solid var(--border);\n            border-radius: ${p1};\n            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);`;
    });
    
    // Specifically for nav logo icon (gradient background)
    content = content.replace(/background:\s*var\(--green-dim\);\s*border:\s*1px\s*solid\s*var\(--green-mid\);\s*display:\s*flex;\s*align-items:\s*center;\s*justify-content:\s*center;/g, 
        `background: linear-gradient(135deg, var(--green-mid), var(--green-dim));\n            border: 1px solid var(--green-mid);\n            display: flex;\n            align-items: center;\n            justify-content: center;`
    );

    // Font weight adjustments for titles
    content = content.replace(/\.topbar-title\s*{[^}]+}/g, match => match.replace(/letter-spacing:\s*2px;/, 'font-weight: 700; letter-spacing: 1px;'));
    content = content.replace(/\.nav-logo-text\s*{[^}]+}/g, match => match.replace(/letter-spacing:\s*2px;/, 'font-weight: 700; letter-spacing: 1px;'));
    content = content.replace(/\.sidebar-logo-text\s*{[^}]+}/g, match => match.replace(/letter-spacing:\s*2px;/, 'font-weight: 700; letter-spacing: 1px;'));

    fs.writeFileSync(filePath, content, 'utf-8');
    console.log(`Updated ${file}`);
}