<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>

<jsp:include page="/browse/header.jsp" />

<%
	try {
		Cfmap t = Cfmap.getInstance();
	//	Cfmap t = new Cfmap();
	//	t.init();
		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			if ((request.getParameter("key") != null)) {
				HashMap<String, String> map = t.getProperties(request.getRemoteAddr(), zone, "forward", request
						.getParameter("key"));
				Iterator<String> properties = map.keySet().iterator();
				out.println("<table>");
				while (properties.hasNext()) {
					String propertyname = properties.next();
					if (!propertyname.equals("all")) {
						out
								.println("<tr><td style='font-weight:bold;align:left;text-align:left;border-bottom:1px dashed #ededed;'>"
										+ (propertyname)
										+ "</td><td style='align:left;text-align:left;border-bottom:1px dashed #ededed;'>"
										+ map.get(propertyname) + "</td ></tr> ");
					}
				}
				out.println("</table>");
				out.println("<a href='/cfmap/browse/viewrecordhistory.jsp?key="+request.getParameter("key")+"&z="+zone+"'>History</a>");
			}
		}
	} catch (Exception e) {
		response.setStatus(500);
		e.printStackTrace();
	}
	
%>
<jsp:include page="/browse/footer.jsp" />
