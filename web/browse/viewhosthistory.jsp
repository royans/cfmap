<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.sql.Timestamp"%>

<%
	String c = "";
	if ((request.getParameter("c") != null)) {
		c = request.getParameter("c");
	}
	try {
		Cfmap t = Cfmap.getInstance();

		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			if ((request.getParameter("key") != null)) {
				String ipaddr = request.getRemoteAddr();
				HashMap<String, String> map = t.getProperties(request.getRemoteAddr(), zone, "forward", request
						.getParameter("key"));
				HashMap<String, HashMap> result = t.getChanges(ipaddr, zone, request.getParameter("key"));
				Iterator<String> i = result.keySet().iterator();
				t.clearOldHistory(request.getRemoteAddr(), zone, "history", 300, request.getParameter("key"),
						3600 );

				while (i.hasNext()) {
					String key = i.next();
					if (key.startsWith(c)) {
						HashMap sm = result.get(key);
						Iterator<byte[]> ii = sm.keySet().iterator();
						while (ii.hasNext()) {
							byte[] rowkey = ii.next();
							java.util.UUID uuid_ = t.toUUID(rowkey);
							Date d = new Date();
							d.setTime(1000 * ((uuid_.timestamp() / 10000000) - 12219292800L));
							out.println(d.toLocaleString() + " -- " + sm.get(rowkey) + " --- " + key + "<br/>");
						}
					}
				}
			}
		}
	} catch (Exception e) {
		response.setStatus(500);
		e.printStackTrace();
	}
%>
