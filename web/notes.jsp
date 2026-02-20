<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.*" %>
<%@ page import="com.workflowx.dao.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String theme = currentUser.getThemePreference() != null ? currentUser.getThemePreference() : "LIGHT";

NoteDAO noteDAO = new NoteDAO();
List<Note> notes = noteDAO.getUserNotes(currentUser.getUserId());

String navProfilePic = null;
String pic = currentUser.getProfilePicture();
if (pic != null && !pic.isEmpty() && !pic.equals("default.jpg")) {
    navProfilePic = pic;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Notes</title>

<style>
body, html { margin:0; padding:0; font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif; background:#f0f0f5; color:#222; }
body.dark-mode { background:#1e1e2f; color:white; }

/* NAVBAR */
.navbar { position:sticky; top:0; height:60px; display:flex; align-items:center; justify-content:space-between; padding:0 15px; background:linear-gradient(135deg,#667eea,#764ba2); z-index:10; }
.dark-mode .navbar { background:linear-gradient(135deg,#232526,#414345); }
.navbar h1 { color:white; }
.navbar .dashboard-btn{ color:white; text-decoration:none; padding:8px 15px; background:rgba(255,255,255,0.2); border-radius:5px; font-weight:500; }
.profile-pic-btn {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: rgba(255,255,255,0.15);
    border: 1px solid white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    text-decoration: none;
    transition: all 0.3s;
    overflow: hidden;
    padding: 0;
    margin: 0;
}

.profile-pic-btn:hover {
    background: rgba(255,255,255,0.3);
    transform: scale(1.2);
}

.profile-pic-btn img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 50%;
}

.profile-icon-svg {
    width: 12px;
    height: 12px;
    fill: white;
}

        /* MINI ICON TOGGLE */
        .mini-toggle {
            width: 60px;
            height: 28px;
            background: #ddd;
            border-radius: 20px;
            padding: 3px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .mini-slider {
            width: 100%;
            height: 100%;
            border-radius: 20px;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 6px;
            font-size: 12px;
        }

        .mini-slider::before {
            content: "";
            position: absolute;
            width: 22px;
            height: 22px;
            background: #667eea;
            border-radius: 50%;
            left: 3px;
            transition: all 0.3s ease;
        }

        .mini-slider.active::before {
            left: 35px;
            background: #2b2b3d;
        }

        .mini-slider span {
            z-index: 1;
            }

        /* Dark mode adjustments */
        .dark-mode .mini-toggle {
            background: #444;
        }
/* NOTES CONTAINER */
.notes-container { padding:15px; min-height:100vh; }
.note { background:white; border-radius:20px; padding:15px; margin-bottom:15px; box-shadow:0 5px 15px rgba(0,0,0,0.1); transition:0.2s; }
.note:hover { transform:translateY(-2px); }
.dark-mode .note { background:#2b2b3d; }
.note.pinned { border-left:4px solid #007aff; }
.note-title { font-weight:bold; font-size:1.1em; margin-bottom:8px; border:none; background:transparent; width:100%; }
.note-content { margin-bottom:8px; white-space:pre-wrap; }
.note-date { font-size:0.75em; color:#888; }
.note-actions { display:flex; gap:8px; margin-top:10px; }

/* BUTTONS */
button { border:none; border-radius:12px; padding:8px 14px; cursor:pointer; font-weight:600; color:white; }
.edit-btn { background:#28a745; }
.delete-btn { background:#dc3545; }
.pin-btn { background:#6f42c1; }
.primary-btn { background:#007aff; }
.secondary-btn { background:#6c757d; }

/* ADD NOTE */
.add-note-btn { position:fixed; bottom:20px; right:20px; width:60px; height:60px; border-radius:50%; font-size:36px; background:#007aff; color:white; cursor:pointer; box-shadow:0 4px 12px rgba(0,0,0,0.2); }

/* EDITOR */
.rich-editor { min-height:100px; padding:10px; border:1px solid #ccc; border-radius:8px; background:white; color:#222; }
.dark-mode .rich-editor { background:#1e1e2f; color:white; border-color:#555; }
.rich-editor:focus { outline:none; }

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
    .editor-toolbar {
    display: flex;
    gap: 6px;
    margin-bottom: 8px;
}

.editor-toolbar button {
    padding: 4px 8px;
    border-radius: 6px;
    font-size: 12px;
    background: #007aff;
    color: white;
    border: none;
    cursor: pointer;
}

.dark-mode .editor-toolbar button {
    background: #444;
}
</style>
</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="navbar">
    <h1>Notes</h1>
    <div style="display:flex; align-items:center; gap:15px;">
        <form action="ThemeServlet" method="post">
            <div class="mini-toggle" onclick="this.closest('form').submit();">
                <div class="mini-slider <%= theme.equals("DARK") ? "active" : "" %>">
                     <span class="icon-left">☀</span>
            <span class="icon-right">🌙</span>
                </div>
            </div>
            <input type="hidden" name="currentTheme" value="<%= theme %>">
        </form>

        <% if (navProfilePic != null) { %>
            <a href="profile.jsp" class="profile-pic-btn"><img src="uploads/profiles/<%= navProfilePic %>" alt="Profile"></a>
        <% } else { %>
            <a href="profile.jsp" class="profile-pic-btn">
                <svg class="profile-icon-svg" viewBox="0 0 24 24" width="20" height="20">
                    <path fill="white" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                </svg>
            </a>
        <% } %>

        <a href="<%= currentUser.isEmployer() ? "employerDashboard.jsp" : "employeeDashboard.jsp" %>" class="dashboard-btn">← Dashboard</a>
    </div>
</div>

<div class="notes-container">

    <!-- Add Note Form -->
    <div id="addNoteForm" class="note" style="display:none;">
        <form action="ManageNoteServlet" method="post">
            <input type="hidden" name="action" value="create">
            <input type="text" name="noteTitle" placeholder="Title (optional)"  style="width:100%;padding:8px;border-radius:8px;border:1px solid #ccc;margin-bottom:10px;">
             <div class="editor-toolbar">
    <button type="button" onclick="format('bold')"><b>B</b></button>
    <button type="button" onclick="format('italic')"><i>I</i></button>
    <button type="button" onclick="format('underline')"><u>U</u></button>
    <button type="button" onclick="format('insertUnorderedList')">• List</button>
    <button type="button" onclick="format('insertOrderedList')">1. List</button>
    <button type="button" onclick="insertChecklist()">☑ Checklist</button>
</div>
            <div contenteditable="true" class="rich-editor"></div>
            <input type="hidden" name="noteContent">
            <label style="display:flex;align-items:center;margin-top:10px;">
                <input type="checkbox" name="isPinned" style="margin-right:8px;">📌 Pin this note
            </label>
            <br><br>
            <button type="submit" class="primary-btn">Add Note</button>
            <button type="button" onclick="toggleAddNoteForm()" class="secondary-btn">Cancel</button>
        </form>
    </div>

<%
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy hh:mm a");
if(notes!=null){
    for(Note note: notes){
%>
<div class="note <%= note.isPinned() ? "pinned" : "" %>">
<form action="ManageNoteServlet" method="post">
    <input type="hidden" name="noteId" value="<%= note.getNoteId() %>">
    <input type="text" name="noteTitle" value="<%= note.getTitle() %>" class="note-title" readonly>
    <div class="editor-toolbar" style="display:none;">
    <button type="button" onclick="format('bold')"><b>B</b></button>
    <button type="button" onclick="format('italic')"><i>I</i></button>
    <button type="button" onclick="format('underline')"><u>U</u></button>
    <button type="button" onclick="format('insertUnorderedList')">• List</button>
    <button type="button" onclick="format('insertOrderedList')">1. List</button>
    <button type="button" onclick="insertChecklist()">☑ Checklist</button>
</div>

<div class="rich-editor" contenteditable="false"><%= note.getContent() %></div>
    <input type="hidden" name="noteContent">
    <div class="note-date"><%= dateFormat.format(note.getCreatedAt()) %></div>
    <div class="note-actions">
        <button type="button" class="edit-btn" onclick="enableEdit(this)">Edit</button>
        <button type="submit" name="action" value="togglePin" class="pin-btn"><%= note.isPinned()?"Unpin":"Pin" %></button>
        <button type="submit" name="action" value="delete" class="delete-btn">Delete</button>
    </div>
</form>
</div>
<% } } %>
</div>

<button class="add-note-btn" onclick="toggleAddNoteForm()">+</button>

<script>
function toggleAddNoteForm(){
    const form=document.getElementById("addNoteForm");
    form.style.display=form.style.display==="none"?"block":"none";
}

document.querySelectorAll("#addNoteForm form").forEach(form=>{
    form.addEventListener("submit",function(){
        const editor=form.querySelector(".rich-editor");
        const hidden=form.querySelector("input[name='noteContent']");
        if(editor && hidden){ hidden.value=editor.innerHTML; }
    });
});

function enableEdit(button){
    const note=button.closest(".note");
    const form=note.querySelector("form");
    const title=form.querySelector("input[name='noteTitle']");
    const editor=form.querySelector(".rich-editor");
    const hidden=form.querySelector("input[name='noteContent']");
    const toolbar = note.querySelector(".editor-toolbar");
    if (toolbar) toolbar.style.display = "flex";
    title.removeAttribute("readonly");
    title.style.border="1px solid #ccc"; 
    title.style.background="white";
    editor.setAttribute("contenteditable","true"); 
    editor.focus();

    button.innerText="Save"; 
    button.classList.remove("edit-btn"); 
    button.classList.add("primary-btn");
    button.onclick=function(){
    hidden.value=editor.innerHTML;

    // create action field dynamically
    let actionInput = form.querySelector("input[name='action']");
    if (!actionInput) {
        actionInput = document.createElement("input");
        actionInput.type = "hidden";
        actionInput.name = "action";
        form.appendChild(actionInput);
    }
    actionInput.value = "update";

    form.submit();
};
}
function format(command) {
    document.execCommand(command, false, null);
}

function insertChecklist() {
    const selection = window.getSelection();
    if (!selection.rangeCount) return;

    const range = selection.getRangeAt(0);
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";

    const space = document.createTextNode(" ");

    range.insertNode(space);
    range.insertNode(checkbox);

    range.setStartAfter(space);
    selection.removeAllRanges();
    selection.addRange(range);
}
</script>

</body>
</html>
