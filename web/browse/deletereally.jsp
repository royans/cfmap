<html lang="en">
<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>

<body>
<%
	try {
		Cfmap t = Cfmap.getInstance();

	//	Cfmap t = new Cfmap();
	//	t.init();

		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			String ipaddr = request.getRemoteAddr();

			if (request.getParameter("key") != null) {
				
				out.println("Do you really want to delete ? Click <a href='/cfmap/browse/delete.jsp?key="+request.getParameter("key")+"&z="+request.getParameter("z")+"'>here</a> if you do.");
						
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
		response.setStatus(500);
	}
%>
</body>

</html>
