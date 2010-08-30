
<%@page import="com.google.gson.JsonArray"%><%@ page
	import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%
	try {
		
		Cfmap t = Cfmap.getInstance();

	//	Cfmap t = new Cfmap();
	//	t.init();

		HashMap<String, String> find = new HashMap<String, String>();

		for (Enumeration<String> e = request.getParameterNames(); e.hasMoreElements();) {
			String ParameterNames = (String) e.nextElement();
			if (!ParameterNames.equals("c") && !(ParameterNames.equals("submit"))
					&& !ParameterNames.equals("format") && !(ParameterNames.equals("z"))
					&& (!request.getParameter(ParameterNames).equals(""))) {
				find.put(ParameterNames, request.getParameter(ParameterNames));
			}
		}

		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			String ipaddr = request.getRemoteAddr();

			if (find.size() == 0) {
				find.put("all", "all");
			}

			Iterator<String> hosts = t.getHosts(ipaddr, zone, find).iterator();

			HashMap<String, HashMap<String, String>> allhosts = new HashMap<String, HashMap<String, String>>();

			while (hosts.hasNext()) {
				String host = hosts.next();
				HashMap<String, String> properties = t.getProperties(ipaddr, zone, "forward", host);
				allhosts.put(host, properties);
				JSONObject jsonObj = new JSONObject(properties);
			}
			JSONObject jsonObj = new JSONObject(allhosts);
			out.println(jsonObj.toString());
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
%>
