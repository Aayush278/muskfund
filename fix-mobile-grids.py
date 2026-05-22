import os
import re

style_block = """
    <!-- Mobile Performance Optimizations & Grid Fixes -->
    <style>
        @media (max-width: 768px) {
            body::before, body::after { display: none !important; animation: none !important; }
            .pcard:hover, .stat-card:hover, .card:hover, .pcard-icon, .stat-card-icon { transform: none !important; box-shadow: none !important; }
            .btn-primary, .hero-visual::before, .hero-visual::after, .pulse-indicator { animation: none !important; }
            html { scroll-behavior: auto !important; }
        }
        @media (max-width: 480px) {
            /* Force all multi-column grids to 1 column on very small phones to prevent overflow */
            .stats-grid, .cards-grid, .actions-grid, .two-col-grid, .form-row, .stats-row, .skeleton-stat-row { 
                grid-template-columns: 1fr !important; 
            }
            .data-table-wrap, .txn-table-wrap, .table-wrap {
                overflow-x: auto !important;
                -webkit-overflow-scrolling: touch !important;
            }
        }
    </style>
</head>"""

files = [f for f in os.listdir('.') if f.endswith('.html')]

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Remove the old block first to avoid duplicates
    content = re.sub(r'\s*<!-- Mobile Performance Optimizations -->.*?<\/style>\s*<\/head>', '\n</head>', content, flags=re.DOTALL)
    
    # Inject the new block
    if "Mobile Performance Optimizations & Grid Fixes" not in content:
        content = content.replace("</head>", style_block)
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Fixed mobile grids & animations in {f}")
