<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%
	try {
		HashMap<String, String> find = new HashMap<String, String>();
		find.put("appname", "cfmap");
		Cfmap t = Cfmap.getInstance();
		HashMap<String, HashMap<String, String>> hostsProperties = t.getHostsProperties("127.0.0.1", "dev",
				find);
		if (hostsProperties.size() < 1) {
			response.setStatus(500);
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
%>
