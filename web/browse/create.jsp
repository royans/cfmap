<html lang="en">
<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.PrintWriter"%>
<body>
<%
	System.out.println("REQUEST : " + request.getRequestURI() + "&" + request.getQueryString());

	try {
		Cfmap t = Cfmap.getInstance();
		String z = "unset";

		HashMap<String, String> map = new HashMap<String, String>();
		String ParameterNames = "";
		for (Enumeration<String> e = request.getParameterNames(); e.hasMoreElements();) {
			ParameterNames = (String) e.nextElement();
			if ((!ParameterNames.equals("c")) && (!ParameterNames.equals("submit"))
					&& (!ParameterNames.equals("z"))) {
				if (ParameterNames.equals("version")) {
					map.put(ParameterNames, request.getParameter(ParameterNames));
				} else {
					if (!request.getParameter(ParameterNames).equals("unset")) {
						map.put(ParameterNames, request.getParameter(ParameterNames));
					}
				}
			}
		}

		if (!map.containsKey("checked")) {
			long timestamp = System.currentTimeMillis() / 1000;
			map.put("checked", new Long(timestamp).toString());
		}
		if (map.containsKey("clustername") && !map.containsKey("zonename")) {
			String[] c = map.get("clustername").split("_");
			if (c.length == 3) {
				map.put("zonename", c[1]);
			}
		}

		String ipaddr = request.getRemoteAddr();
		map.put("ip", ipaddr);

		if ((map.containsKey("host") && map.containsKey("port") && map.containsKey("appname"))
				|| (map.containsKey("key"))) {
			out.println(t.insertandinvert(ipaddr, z, map));
		} else {
			out.println("Host/port/appname not specified");
		}
	} catch (Exception e) {
		out.println("<pre>");
		PrintWriter pw = response.getWriter();
		e.printStackTrace(pw);
		out.println("</pre>");
		response.setStatus(500);
	}
%>
</body>

</html>

