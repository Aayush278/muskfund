import os
import re

newFonts = '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Outfit:wght@500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />'

# Get all html files except the ones we've already done perfectly
files = [f for f in os.listdir('.') if f.endswith('.html') and f not in ('dashboard.html', 'profile.html')]

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()

    # 1. Replace Google Fonts link
    content = re.sub(r'<link[^>]*href=["\']https:\/\/fonts\.googleapis\.com\/css2\?family=Bebas\+Neue[^>]*>', newFonts, content)

    # 2. Replace CSS root variables dynamically
    content = re.sub(r'--bg:\s*#[0-9a-fA-F]+;', '--bg: #09090b;', content)
    content = re.sub(r'--surface:\s*#[0-9a-fA-F]+;', '--surface: #121214;', content)
    content = re.sub(r'--surface2:\s*#[0-9a-fA-F]+;', '--surface2: #18181b;', content)
    content = re.sub(r'--border:\s*#[0-9a-fA-F]+;', '--border: #27272a;', content)
    content = re.sub(r'--green:\s*#[0-9a-fA-F]+;', '--green: #10b981;', content)
    content = re.sub(r'--green-dim:\s*rgba\([^\)]+\);', '--green-dim: rgba(16, 185, 129, 0.1);', content)
    content = re.sub(r'--green-mid:\s*rgba\([^\)]+\);', '--green-mid: rgba(16, 185, 129, 0.3);', content)
    content = re.sub(r'--gold:\s*#[0-9a-fA-F]+;', '--gold: #f59e0b;', content)
    content = re.sub(r'--red:\s*#[0-9a-fA-F]+;', '--red: #ef4444;', content)
    content = re.sub(r'--red-dim:\s*rgba\([^\)]+\);', '--red-dim: rgba(239, 68, 68, 0.1);', content)
    content = re.sub(r'--white:\s*#[0-9a-fA-F]+;', '--white: #ffffff;', content)
    content = re.sub(r'--grey:\s*#[0-9a-fA-F]+;', '--grey: #a1a1aa;', content)
    content = re.sub(r'--grey2:\s*#[0-9a-fA-F]+;', '--grey2: #71717a;', content)

    # Add font variables if they don't exist, or replace them
    if '--font-display' in content:
        content = re.sub(r'--font-display:[^;]+;', "--font-display: 'Outfit', sans-serif;", content)
        content = re.sub(r'--font-body:[^;]+;', "--font-body: 'Inter', sans-serif;", content)
        content = re.sub(r'--font-mono:[^;]+;', "--font-mono: 'JetBrains Mono', monospace;", content)
    else:
        # inject font variables into root
        content = re.sub(r':root\s*{', ":root {\n            --font-display: 'Outfit', sans-serif;\n            --font-body: 'Inter', sans-serif;\n            --font-mono: 'JetBrains Mono', monospace;", content)

    # Replace explicit font families in CSS
    content = re.sub(r'font-family:\s*[\'"]?Bebas Neue[\'"]?[^;]+;', "font-family: var(--font-display);", content)
    content = re.sub(r'font-family:\s*[\'"]?DM Sans[\'"]?[^;]+;', "font-family: var(--font-body);", content)
    content = re.sub(r'font-family:\s*[\'"]?DM Mono[\'"]?[^;]+;', "font-family: var(--font-mono);", content)

    # Replace card backgrounds with linear gradients for glassmorphism
    def replace_card(m):
        return f"background: linear-gradient(180deg, var(--surface) 0%, var(--bg) 100%);\n            border: 1px solid var(--border);\n            border-radius: {m.group(1)};\n            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);"
    
    content = re.sub(r'background:\s*var\(--surface\);\s*border:\s*1px\s*solid\s*var\(--border\);\s*border-radius:\s*(16px|14px|12px|10px);', replace_card, content)

    # Specifically for nav logo icon (gradient background)
    content = re.sub(
        r'background:\s*var\(--green-dim\);\s*border:\s*1px\s*solid\s*var\(--green-mid\);\s*display:\s*flex;\s*align-items:\s*center;\s*justify-content:\s*center;',
        'background: linear-gradient(135deg, var(--green-mid), var(--green-dim));\n            border: 1px solid var(--green-mid);\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            box-shadow: 0 0 20px rgba(16, 185, 129, 0.15);',
        content
    )

    # Font weight adjustments for titles (from Bebas Neue 400 to Outfit 600/700)
    def fix_topbar(m):
        return m.group(0).replace('letter-spacing: 2px;', 'font-weight: 700; letter-spacing: 1px;')
    
    content = re.sub(r'\.topbar-title\s*{[^}]+}', fix_topbar, content)
    content = re.sub(r'\.nav-logo-text\s*{[^}]+}', fix_topbar, content)
    content = re.sub(r'\.sidebar-logo-text\s*{[^}]+}', fix_topbar, content)

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
    print(f'Updated {f}')
