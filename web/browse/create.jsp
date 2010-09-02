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

		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			HashMap<String, String> map = new HashMap<String, String>();

			String ParameterNames = "";
			for (Enumeration<String> e = request.getParameterNames(); e.hasMoreElements();) {
				ParameterNames = (String) e.nextElement();
				if ((!ParameterNames.equals("c")) && (!ParameterNames.equals("submit"))) {
					if (ParameterNames.equals("version")) {
						String v_ = request.getParameter(ParameterNames) + ".0.0.0.0.0";
						String[] vs = null;
						vs = v_.split("\\.");
						map.put(ParameterNames, vs[0] + "." + vs[1] + "." + vs[2] + "." + vs[3]);
						map.put("version_x", vs[0] + "." + vs[1] + "." + vs[2]);
						map.put("version_x_x", vs[0] + "." + vs[1]);
						map.put("version_x_x_x", vs[0]);
					} else {
						if (!(ParameterNames.equals("z") && (zone.equals("unset")))) {
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

			if (map.containsKey("host") && map.containsKey("port") && map.containsKey("appname")) {
				out.println(t.insertandinvert(ipaddr, zone, map));
			} else {
				out.println("Host/port/appname not specified");
			}
		} else {
			out.println("Zone not specified");
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

