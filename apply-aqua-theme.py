import os
import re

html_files = [f for f in os.listdir('.') if f.endswith('.html')]

# Aqua colors
new_primary = '#00e5ff'
new_primary_rgb = '0, 229, 255'

for f in html_files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()

    # 1. Update CSS Variables (keeping the name --green to avoid breaking existing styles)
    # They might be defined as --green: #10b981; or --green:#00C896; etc.
    content = re.sub(r'--green:\s*#[0-9a-fA-F]+;', f'--green: {new_primary};', content)
    content = re.sub(r'--green-dim:\s*rgba\([^)]+\);', f'--green-dim: rgba({new_primary_rgb}, 0.1);', content)
    content = re.sub(r'--green-mid:\s*rgba\([^)]+\);', f'--green-mid: rgba({new_primary_rgb}, 0.3);', content)

    # 2. Update inline SVG strokes/fills and other hardcoded colors
    content = re.sub(r'#00C896', new_primary, content, flags=re.IGNORECASE)
    content = re.sub(r'#10b981', new_primary, content, flags=re.IGNORECASE)
    content = re.sub(r'#00e6ae', '#00c3d9', content, flags=re.IGNORECASE) # btn-submit:hover background

    # 3. Handle rgba(0, 200, 150, ...) replacements to aqua rgb (0, 229, 255)
    content = re.sub(r'rgba\(\s*0\s*,\s*200\s*,\s*150\s*,', f'rgba({new_primary_rgb},', content)
    # Handle rgba(16, 185, 129, ...) replacements to aqua rgb
    content = re.sub(r'rgba\(\s*16\s*,\s*185\s*,\s*129\s*,', f'rgba({new_primary_rgb},', content)

    # 4. Enhance contrast by making background slightly deeper
    # If the user wants better contrast, we could darken the background or tweak borders
    content = re.sub(r'--bg:\s*#09090b;', '--bg: #050507;', content)
    content = re.sub(r'--surface:\s*#121214;', '--surface: #0a0a0c;', content)
    content = re.sub(r'--surface2:\s*#18181b;', '--surface2: #0f0f13;', content)

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
    print(f'Updated {f}')
