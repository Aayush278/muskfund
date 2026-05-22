import os
import re

files = ['terms.html', 'privacy.html', 'disclaimer.html']

body_mesh = """        body {
            background: var(--bg);
            color: var(--white);
            font-family: var(--font-body);
            min-height: 100vh;
            overflow-x: hidden;
            line-height: 1.7;
            position: relative;
        }

        /* Ambient Mesh Background */
        body::before {
            content: '';
            position: fixed;
            top: -10%;
            left: -10%;
            width: 50%;
            height: 50%;
            background: radial-gradient(circle, rgba(16, 185, 129, 0.05) 0%, transparent 60%);
            border-radius: 50%;
            z-index: -1;
            filter: blur(80px);
            animation: float 15s ease-in-out infinite alternate;
        }

        body::after {
            content: '';
            position: fixed;
            bottom: -10%;
            right: -10%;
            width: 60%;
            height: 60%;
            background: radial-gradient(circle, rgba(245, 158, 11, 0.03) 0%, rgba(16, 185, 129, 0.02) 40%, transparent 70%);
            border-radius: 50%;
            z-index: -1;
            filter: blur(100px);
            animation: float 20s ease-in-out infinite alternate-reverse;
        }

        @keyframes float {
            0% { transform: translate(0, 0) scale(1); }
            50% { transform: translate(5%, 5%) scale(1.1); }
            100% { transform: translate(-5%, 8%) scale(0.95); }
        }"""

hero_title_gradient = """        .hero-title {
            font-family: var(--font-display);
            font-size: clamp(48px, 7vw, 80px);
            letter-spacing: -1px;
            font-weight: 700;
            line-height: 1.1;
            margin-bottom: 16px;
            background: linear-gradient(135deg, #ffffff 0%, #a1a1aa 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: inline-block;
            filter: drop-shadow(0 2px 10px rgba(255,255,255,0.1));
        }"""

glass_boxes = """        .highlight-box {
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(16, 185, 129, 0.03));
            backdrop-filter: blur(10px);
            border: 1px solid rgba(16, 185, 129, 0.2);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 32px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2), inset 0 1px 0 rgba(255, 255, 255, 0.05);
        }

        .highlight-box p {
            font-size: 15px;
            color: rgba(255, 255, 255, 0.9);
            line-height: 1.7;
            margin: 0
        }

        .highlight-box strong {
            color: var(--green)
        }

        .warning-box {
            background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(245, 158, 11, 0.03));
            backdrop-filter: blur(10px);
            border: 1px solid rgba(245, 158, 11, 0.2);
            border-left: 4px solid var(--gold);
            border-radius: 8px 16px 16px 8px;
            padding: 24px;
            margin-bottom: 32px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
        }"""

toc_glass = """        .toc {
            background: linear-gradient(180deg, rgba(24, 24, 27, 0.6) 0%, rgba(9, 9, 11, 0.8) 100%);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.05);
            padding: 32px;
            margin-bottom: 48px;
        }"""

for f in files:
    if not os.path.exists(f):
        continue
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Replace body
    content = re.sub(
        r'\s*body\s*\{[^}]*\}',
        '\n' + body_mesh,
        content
    )
    
    # Replace hero-title
    content = re.sub(
        r'\s*\.hero-title\s*\{[^}]*\}',
        '\n' + hero_title_gradient,
        content
    )
    
    # Replace highlight-box and warning-box
    content = re.sub(
        r'\s*\.highlight-box\s*\{.*?(?=\.warning-box-title)',
        '\n' + glass_boxes + '\n\n        ',
        content,
        flags=re.DOTALL
    )
    
    # Replace TOC
    content = re.sub(
        r'\s*\.toc\s*\{[^}]*\}',
        '\n' + toc_glass,
        content
    )

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
    print(f'Upgraded {f}')
