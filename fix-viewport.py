import os
import re

files = [f for f in os.listdir('.') if f.endswith('.html') and f != 'admin-dashboard.html']

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Replace simple viewport tags with the locked one
    content = re.sub(
        r'<meta\s+name="viewport"\s+content="width=device-width,\s*initial-scale=1.0"\s*/?>',
        '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />',
        content
    )

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
    print(f'Updated viewport in {f}')
