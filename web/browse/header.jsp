<%@ page import="java.io.*"%>



<html lang="en">
<head>

<meta http-equiv="refresh" content="60">

<link rel="stylesheet" type="text/css"
	href="/cfmap/browse/theme/table.css" media="all">
<script type="text/javascript" src="/cfmap/browse/theme/table.js"></script>

<style type="text/css">
body {
	background-color: #fff;
	margin: 10px;
	font-family: Lucida Grande, Verdana, Sans-serif;
	font-size: 14px;
	color: #4F5155;
}

a {
	color: #003399;
	background-color: transparent;
	font-weight: normal;
}

h1 {
	color: #444;
	background-color: transparent;
	font-size: 16px;
	font-weight: bold;
	margin: 0px 0 2px 0;
	padding: 5px 0 6px 0;
}

h3 {
	color: #777;
	background-color: transparent;
	font-size: 12px;
	font-weight: bold;
}

h4 {
	color: #777;
	background-color: transparent;
	font-size: 11px;
	font-weight: bold;
	margin-bottom: 3px;
}

/*
code {
 font-family: Monaco, Verdana, Sans-serif;
 font-size: 12px;
 background-color: #f9f9f9;
 border: 1px solid #D0D0D0;
 color: #002166;
 display: block;
 margin: 14px 0 14px 0;
 padding: 12px 10px 12px 10px;
}
*/
box,pre {
	background-color: #f9f9f9;
	border: 1px solid #D0D0D0;
	color: #002166;
	display: block;
	padding: 12px 10px 12px 10px;
	overflow: hidden;
}

boxfooter {
	height: 5px;
	width: 100%;
	text-align: center;
	background: blue;
}

.hints {
	background-color: #f9f9f9;
	border: 1px solid #D0D0D0;
	color: #002166;
	display: block;
	margin: 0px 0 14px 0;
	padding: 12px 10px 12px 10px;
}

td {
	font-size: 10px;
	padding-left: 0px;
	padding-right: 0px;
	padding-top: 0px;
	padding-bottom: 0px;
	text-align: left;
}

th {
	font-size: 10px;
	text-align: left;
}

.dnsrecords ul {
	list-style-type: none;
	margin: 0;
	padding: 0;
}

.dnsrecords ul li {
	position: relative;
	display: inline;
	float: left;
	background-color: #F3F3F3;
}

.zebratable {
	border: 1px solid #cccccc;
}

.zebraTable tr {
	background-color: #dddddd;
	color: #000;
	font-size: 13px;
}

.zebraTable .rowEven {
	background: #eeeeee;
	color: #000;
	font-size: 12px;
	vertical-align: top;
}

.zebraTable .rowOdd {
	background: #Ffffff;
	color: #000;
	font-size: 12px;
	vertical-align: top;
}

//----------------------------------------------
.toggler {
	color: #222;
	margin: 0;
	padding: 2px 5px;
	background: #eee;
	border-bottom: 1px solid #ddd;
	border-right: 1px solid #ddd;
	border-top: 1px solid #f5f5f5;
	border-left: 1px solid #f5f5f5;
	font-size: 11px;
	font-weight: normal;
	font-family: 'Andale Mono', sans-serif;
}

.element {
	
}

.element p {
	margin: 0;
	padding: 4px;
}

.float-right {
	padding: 10px 20px;
	float: right;
}

blockquote {
	text-style: italic;
	padding: 5px 0 5px 30px;
}

.menulink {
	text-decoration: none;
	text-transform: uppercase;
	margin-left: 20px;
	color: black;
	font-family: "Helvetica Neue", Helvetica, Arial, Sans-serif;
	font-weight: bold;
	font-size: 1.1em;
}

.menubox a:hover {
	border-top: 4px solid #114477;
}

.menulinkselected {
	border-top: 4px solid #114477;
	text-decoration: none;
	text-transform: uppercase;
	margin-left: 20px;
	color: darkgreen;
	font-family: "Helvetica Neue", Helvetica, Arial, Sans-serif;
	font-weight: bold;
	font-size: 1.1em;
}

.hidebox {
	background: #F9F9F9;
	color: darkgreen;
	border: 4px solid lightblue;
	padding: 5px;
	font-size: 0.8em;
}

.img {
	border: 0px;
}
//-------------------------------------------------
</style>

<script src="/cfmap/browse/theme/mootools.js" type="text/javascript"></script>
<script src="/cfmap/browse/theme/cookies.js" type="text/javascript"></script>

</head>
<body>
<center>
<table>
	<tr>
		<td><a href='/cfmap/browse/searchform.jsp'>Search</a></td>
		<td>[<a href='/cfmap/browse/view.jsp?z=dev&f=html'>All</a></td>
		<td>,<a href='/cfmap/browse/realtime.jsp'>Logs</a></td>
		<td>,<a href='/cfmap/browse/view.jsp?z=dev&f=html&status=broken'>Broken</a>]</td>
		<td></td>
	</tr>
	<tr>
		<td>
		<%
			try {
				String command = "hostname";
				Process proc = Runtime.getRuntime().exec(command);
				BufferedReader buf = new BufferedReader(new InputStreamReader(proc.getInputStream()));
				String s = null;
				String hostname = "";
				while ((s = buf.readLine()) != null) {
					hostname = hostname + s;
				}
				out.println("<i style='padding-left:20px;font-size:0.8em;'>[Served by : " + hostname + "]</i>");
			} catch (Exception e) {

			}
		%>
		</td>
	</tr>
</table>
