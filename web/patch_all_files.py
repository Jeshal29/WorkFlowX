#!/usr/bin/env python3
"""
WorkFlowX Mobile Responsive CSS Patcher
Run this script from your project's web directory to add mobile CSS to all JSP files.

Usage:
  python patch_all_files.py

Or for a single file:
  python patch_all_files.py tasks.jsp
"""

import os
import sys

MOBILE_CSS = """
    /* ===== MOBILE RESPONSIVE ===== */
    @media (max-width: 768px) {

        /* Navbar */
        .navbar, .header {
            padding: 10px 15px;
            flex-wrap: wrap;
            gap: 8px;
        }
        .navbar h1, .navbar h2, .header h2 {
            font-size: 16px;
        }
        .navbar > div[style] {
            gap: 8px !important;
            flex-wrap: wrap;
        }
        .navbar .user-info > span {
            display: none;
        }
        .navbar .dashboard-btn, .header .dashboard-btn {
            padding: 6px 10px;
            font-size: 12px;
        }

        /* Container */
        .container {
            margin: 10px auto;
            padding: 0 10px;
            width: 95% !important;
        }

        /* Welcome / Page Header */
        .welcome, .page-header, .section-header {
            padding: 15px;
        }
        .welcome h2, .page-header h1, .page-header h2 {
            font-size: 18px;
        }

        /* Dashboard cards */
        .card { padding: 15px; }
        .card-icon { font-size: 36px; }
        .card h3 { font-size: 15px; }

        /* Tables - make scrollable on mobile */
        .table-container {
            overflow-x: auto;
            width: 100%;
        }
        table {
            min-width: 600px;
        }

        /* Forms */
        .form-group input,
        .form-group select,
        .form-group textarea,
        .remarks-input {
            font-size: 16px;
        }

        /* Buttons - stack vertically */
        .action-form {
            flex-direction: column;
        }
        .btn-group {
            flex-direction: column;
        }

        /* Grid layouts */
        .dashboard-grid,
        .cards-grid,
        .reports-grid,
        .stats-row,
        .stats-grid,
        .stats-container,
        .grid {
            grid-template-columns: 1fr !important;
        }

        /* Stats */
        .stats { padding: 15px; }

        /* Messages / Chat layout */
        .main-container {
            flex-direction: column;
            height: auto;
        }
        .left, .right {
            width: 100% !important;
        }
        .left {
            max-height: 250px;
            overflow-y: auto;
        }
        .right {
            min-height: 400px;
        }

        /* Task grid */
        .task-grid {
            grid-template-columns: 1fr !important;
        }
        .task-header {
            flex-direction: column;
            gap: 8px;
        }
        .task-meta {
            flex-direction: column;
            gap: 5px;
        }

        /* Leave details */
        .leave-details {
            grid-template-columns: 1fr 1fr !important;
        }
        .leave-header {
            flex-direction: column;
            gap: 10px;
        }

        /* Profile */
        .profile-body { padding: 20px; }
        .form-grid {
            grid-template-columns: 1fr !important;
        }
        .info-row {
            flex-direction: column;
            gap: 4px;
        }

        /* Performance cards */
        .performance-card {
            flex-direction: column;
            align-items: flex-start;
            gap: 15px;
        }
        .stats-row {
            flex-wrap: wrap;
        }

        /* Report cards */
        .report-card { padding: 20px; }
        .report-card .icon { font-size: 36px; }

        /* Tabs */
        .tabs, .filter-tabs {
            flex-wrap: wrap;
        }
        .tab, .filter-tabs a {
            font-size: 13px;
            padding: 8px 12px;
        }

        /* Notes */
        .add-note-btn {
            width: 50px;
            height: 50px;
            font-size: 28px;
        }

        /* Assign task form */
        .form-container {
            padding: 20px;
        }

        /* Violator rows */
        .violator-row {
            flex-direction: column;
            align-items: flex-start;
            gap: 8px;
        }

        /* Charts */
        .chart-bar {
            flex-direction: column;
            align-items: flex-start;
        }
        .chart-label { min-width: unset; }
        .chart-bar-wrapper { width: 100%; }

        /* Messages page send box */
        .send-box { flex-wrap: wrap; }
        .send-box input[type=text] { width: 100%; }
        .send-box input[type=file] { width: 100%; }
    }

    @media (max-width: 480px) {
        .navbar h1, .navbar h2, .header h2 {
            font-size: 14px;
        }
        .stat-card .number {
            font-size: 28px;
        }
        .leave-details {
            grid-template-columns: 1fr !important;
        }
    }
"""

# All JSP files that need mobile CSS
JSP_FILES = [
    "login.jsp",
    "register.jsp",
    "employeeDashboard.jsp",
    "employerDashboard.jsp",
    "adminDashboard.jsp",
    "tasks.jsp",
    "assignTask.jsp",
    "leaves.jsp",
    "approveLeaves.jsp",
    "messages.jsp",
    "allMessages.jsp",
    "notes.jsp",
    "profile.jsp",
    "changePassword.jsp",
    "employees.jsp",
    "manageEmployers.jsp",
    "reports.jsp",
    "globalReports.jsp",
    "reportUsers.jsp",
    "reportBadWords.jsp",
    "reportMessages.jsp",
    "reportLeaves.jsp",
    "reportTasks.jsp",
    "reportPerformance.jsp",
    "reportOverview.jsp",
    "reportUserDetail.jsp",
]

def patch_file(filepath):
    """Add mobile CSS to a JSP file before the last </style> tag"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already patched
    if '/* ===== MOBILE RESPONSIVE =====' in content:
        print(f"  SKIPPED (already patched): {filepath}")
        return False
    
    last_style = content.rfind('</style>')
    if last_style == -1:
        print(f"  WARNING: No </style> found in {filepath}")
        return False
    
    updated = content[:last_style] + MOBILE_CSS + '\n</style>' + content[last_style+8:]
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(updated)
    
    print(f"  ✓ Patched: {filepath}")
    return True

def main():
    if len(sys.argv) > 1:
        # Patch specific file(s)
        files = sys.argv[1:]
    else:
        # Patch all known JSP files in current directory
        files = [f for f in JSP_FILES if os.path.exists(f)]
        
        if not files:
            print("No JSP files found in current directory.")
            print("Make sure to run this script from your web directory (e.g., C:/your-project/web/)")
            return
    
    print(f"Patching {len(files)} file(s)...")
    patched = 0
    for f in files:
        if os.path.exists(f):
            if patch_file(f):
                patched += 1
        else:
            print(f"  NOT FOUND: {f}")
    
    print(f"\n✅ Done! Patched {patched} file(s).")
    print("Next steps:")
    print("  1. Clean and Build in NetBeans")
    print("  2. git add . && git commit -m 'Added mobile responsive CSS to all pages'")
    print("  3. git push origin main")

if __name__ == '__main__':
    main()
