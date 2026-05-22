import os

style_block = """
    <!-- Mobile Performance Optimizations -->
    <style>
        @media (max-width: 768px) {
            /* Completely remove heavy ambient mesh backgrounds on phones for performance */
            body::before, body::after {
                display: none !important;
                animation: none !important;
            }
            /* Disable hover lift transformations on cards */
            .pcard:hover, .stat-card:hover, .card:hover, .pcard-icon, .stat-card-icon {
                transform: none !important;
                box-shadow: none !important;
            }
            /* Stop infinite background animations like glows and pulses */
            .btn-primary, .hero-visual::before, .hero-visual::after, .pulse-indicator {
                animation: none !important;
            }
            /* Disable smooth scroll on mobile to avoid jank */
            html {
                scroll-behavior: auto !important;
            }
        }
    </style>
</head>"""

files = [f for f in os.listdir('.') if f.endswith('.html')]

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    if "<!-- Mobile Performance Optimizations -->" not in content:
        content = content.replace("</head>", style_block)
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Disabled mobile animations in {f}")
