import os
import re

html_files = [f for f in os.listdir('.') if f.endswith('.html')]

for f in html_files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()

    # Enhance to a deep midnight blue/slate for ultra-premium look
    content = re.sub(r'--bg:\s*#050507;', '--bg: #030712;', content)
    content = re.sub(r'--surface:\s*#0a0a0c;', '--surface: #0f172a;', content)
    content = re.sub(r'--surface2:\s*#0f0f13;', '--surface2: #1e293b;', content)
    content = re.sub(r'--border:\s*#27272a;', '--border: #334155;', content)
    
    # Optional: ensure text colors contrast nicely on the slate
    content = re.sub(r'--grey:\s*#a1a1aa;', '--grey: #94a3b8;', content)
    content = re.sub(r'--grey2:\s*#71717a;', '--grey2: #64748b;', content)

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
    print(f'Enhanced {f}')
