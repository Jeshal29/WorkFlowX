<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, com.workflowx.util.DatabaseConnection" %>
<%
Connection conn = DatabaseConnection.getConnection();
String sql = "SELECT a.*, u1.username AS admin_name, u2.username AS target_name " +
             "FROM admin_actions a " +
             "LEFT JOIN users u1 ON a.admin_id = u1.user_id " +
             "LEFT JOIN users u2 ON a.target_user_id = u2.user_id " +
             "ORDER BY a.created_at DESC";

PreparedStatement ps = conn.prepareStatement(sql);
ResultSet rs = ps.executeQuery();
%>

<html>
<head>
<title>Audit Logs</title>
<style>
table { width:100%; border-collapse:collapse; }
th, td { padding:12px; border-bottom:1px solid #ddd; }
th { background:#667eea; color:white; }
tr:hover { background:#f5f5f5; }
</style>
</head>
<body>

<h2>🔐 Audit Logs</h2>

<table>
<tr>
<th>Admin</th>
<th>Action</th>
<th>Target User</th>
<th>Details</th>
<th>IP Address</th>
<th>Date</th>
</tr>

<%
while(rs.next()){
%>
<tr>
<td><%= rs.getString("admin_name") %></td>
<td><%= rs.getString("action_type") %></td>
<td><%= rs.getString("target_name") != null ? rs.getString("target_name") : "-" %></td>
<td><%= rs.getString("action_details") %></td>
<td><%= rs.getString("ip_address") %></td>
<td><%= rs.getTimestamp("created_at") %></td>
</tr>
<%
}
%>

</table>

</body>
</html>
