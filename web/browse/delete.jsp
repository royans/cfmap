<html lang="en">
<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>

<body>
<%
	try {
		Cfmap t = Cfmap.getInstance();

//		Cfmap t = new Cfmap();
//		t.init();

		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			String ipaddr = request.getRemoteAddr();

			if (request.getParameter("key") != null) {

				ArrayList<String> hosts = new ArrayList<String>();
				hosts.add(request.getParameter("key"));
				
				t.delHosts(ipaddr,zone, hosts);
				out.println("deleted " + request.getParameter("key"));
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
		response.setStatus(500);
	}
%>
</body>

</html>
