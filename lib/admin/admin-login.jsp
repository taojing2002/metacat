<%@ page language="java" %> 
<%@ page import="edu.ucsb.nceas.metacat.util.OrganizationUtil,edu.ucsb.nceas.metacat.properties.PropertyService" %>
<% 
/**
 *  '$RCSfile$'
 *    Copyright: 2008 Regents of the University of California and the
 *               National Center for Ecological Analysis and Synthesis
 *  For Details: http://www.nceas.ucsb.edu/
 *
 *   '$Author$'
 *     '$Date$'
 * '$Revision$'
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
%>

<% 
	Vector<String> adminList = (Vector<String>)request.getAttribute("adminList");;
%>

<html>
<head>

<title>Database Install/Upgrade Utility</title>
<%@ include file="./head-section.jsp"%>

</head>
<body>
<%@ include file="./header-section.jsp"%>
	
<div class="document">
	<h2>Administrator Login</h2>
	
	<p>Account login page.</p>
	
	<%@ include file="./page-message-section.jsp"%>
	
	<form name="loginform" method="post" action="<%= request.getContextPath() %>/admin"
		target="_top" onsubmit="return validateAndSubmitForm(this);" id="loginform">
	
	<table class="admin-login">
		<tr>
			<td><h4>Username</h4></td>
			<td>
				<select class="username-input" name="username">
	<%
				for(String adminName : adminList) {
	%>
					<option><%= adminName %></option>
	<%
		}
	%>
			    
			  </select>
			</td>
		</tr>
		<tr>
		    <td></td>
		    <td class="textinput-description">[Fully qualified administrator username]</td>
		</tr>
		<tr>
			<td><h4>Password</h4></td>
			<td><input class="login-input" name="password" type="password" maxlength="50" value=""></td>
		</tr>
		<tr>
		    <td></td>
		    <td class="textinput-description">[Administrator password]</td>
		</tr>
	</table>
	
	<div class="buttons-wrapper">
		<input class="button" input type="submit" name="loginAction" value="Login" class="button_login"></td>
		<input class="button" type="button" value="Cancel" onClick="forward('<%= request.getContextPath() %>')"> 
		<input type="hidden" name="configureType" value="login"/>
		<input type="hidden" name="processForm" value="true"/>
	</div>
	</form>
</div>
</body>
</html>
