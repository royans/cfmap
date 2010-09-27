
<%@page import="org.json.JSONArray"%><%@ page
	import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.sql.Timestamp"%>

<jsp:include page="/browse/header.jsp" />

<box>
<%
	String c = "";
	String keyspace = "";
	String columnfamily = "";
	String key = "";
	String hostport = null;
	String hostport_param = "";

	if ((request.getParameter("c") != null)) {
		c = request.getParameter("c");
	}
	if ((request.getParameter("key") != null)) {
		key = request.getParameter("key");
	}
	if ((request.getParameter("hostport") != null)) {
		hostport = request.getParameter("hostport");
		hostport_param = "&hostport=" + hostport;
	}
	if ((request.getParameter("keyspace") != null)) {
		keyspace = request.getParameter("keyspace");
	}
	if ((request.getParameter("columnfamily") != null)) {
		columnfamily = request.getParameter("columnfamily");
	}

	if (c.equals("listkeyspaces")) {
		try {
			Cfmap t = Cfmap.getInstance();
			ArrayList<String> result = t.browseGetKeySpaces(hostport);
			Iterator<String> i = result.iterator();
			out.println("<table>");
			while (i.hasNext()) {
				String keyspace_name = i.next();
				out.println("<tr><td><a href=?c=listcolumnfamily&keyspace=" + keyspace_name + hostport_param
						+ ">" + keyspace_name + "</a></td></tr>");
			}
			out.println("</table>");
		} catch (Exception e) {
			response.setStatus(500);
			e.printStackTrace();
		}
	}

	if (c.equals("listcolumnfamily")) {
		try {
			Cfmap t = Cfmap.getInstance();
			Map<String, Map<String, String>> result = t.browseGetColumnFamilies(hostport, keyspace);
			Iterator<String> i = result.keySet().iterator();
			out.println("<table>");
			while (i.hasNext()) {
				String _columnfamily = i.next();
				out.println("<tr><td><a href=?c=listrows&keyspace=" + keyspace + "&columnfamily="
						+ _columnfamily + hostport_param + ">" + _columnfamily + "</a></td></tr>");
			}
		} catch (Exception e) {
			response.setStatus(500);
			e.printStackTrace();
		}
	}

	if (c.equals("listrows")) {
		try {
			Cfmap t = Cfmap.getInstance();
			HashMap<String, HashMap<String, String>> rows = t.browseGetRows(hostport, keyspace, columnfamily);
			if (rows != null) {
				Iterator<String> rows_iterator = rows.keySet().iterator();
				out.println("<table>");
				while (rows_iterator.hasNext()) {
					String _key = rows_iterator.next();
					out.println("<tr><td>" + _key + " == </td><td>");
					HashMap<String, String> map = rows.get(_key);
					if (map != null) {
						Iterator<String> columnkeys_iterator = map.keySet().iterator();
						while (columnkeys_iterator.hasNext()) {
							String columnkey = columnkeys_iterator.next();
							out.println(columnkey);
							out.println(" -=- ");
							String columnvar = map.get(columnkey);
							out.println(columnvar);
						}
					}

					out.println("</td></tr>");
				}
			} else {
				out.println("result was null");
			}
		} catch (Exception e) {
			response.setStatus(500);
			e.printStackTrace();
		}
	}
%>
</box>
<jsp:include page="/browse/footer.jsp" />

