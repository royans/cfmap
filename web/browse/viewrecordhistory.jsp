<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.sql.Timestamp"%>

<%
	String format = "html";
	ArrayList<String> properties = null;
	HashMap<String, TreeMap<Long, String>> allProperties = new HashMap<String, TreeMap<Long, String>>();

	if ((request.getParameter("f") != null)) {
		format = request.getParameter("f");
	}

	if ((request.getParameter("properties") != null)) {
		properties = new ArrayList<String>();
		String[] _properties = request.getParameter("properties").split(",");
		for (int i = 0; i < _properties.length; i++) {
			properties.add(_properties[i]);
		}
	}

	if (format.equals("html")) {
%>
<jsp:include page="/browse/header.jsp" />
<%
	}
	try {
		Cfmap t = Cfmap.getInstance();
		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			if ((request.getParameter("key") != null)) {
				String ipaddr = request.getRemoteAddr();
				HashMap<String, String> map = t.getProperties(request.getRemoteAddr(), zone, "forward", request
						.getParameter("key"));
				HashMap<String, HashMap> result = null;
				try {
					result = t.getChanges(ipaddr, zone, request.getParameter("key"));
				} catch (Exception e) {
					e.printStackTrace();
				}
				Iterator<String> i = result.keySet().iterator();
				if (format.equals("html")) {
					out.println("<table style='width:500px;'>");
					out
							.println("<tr><td style='font-weight:bold;font-size:1em;background:#feeeef;border-top:1px dotted black'><table style='width:100%;'><tr><td style='text-align:left;font-weight:bold;'>"
									+ map.get("host")
									+ "</td><td style='text-align:center;font-weight:bold;'>"
									+ map.get("port")
									+ "</td><td style='text-align:right;font-weight:bold;'>"
									+ map.get("appname") + "</td></tr></table></td></tr>");
				}
				Date d = new Date();
				long top_d = 0;
				long bottom_d = 0;
				String output = "";
				String temp_output = "";
				int counter = 0;
				while (i.hasNext()) {
					String key = i.next();
					if (((!key.startsWith("stats_")) || (request.getParameter("key").startsWith("stats_")))
							&& ((properties == null) || (properties.contains(key)))) {
						HashMap sm = result.get(key);
						Iterator<byte[]> ii = sm.keySet().iterator();
						if (format.equals("html")) {
							out
									.print("<tr><td style='text-align:left;font-size:0.8em;font-weight:bold;color:darkgreen;border-top:1px dotted gray;background:#eeeeee;'>"
											+ key + "</td></tr><tr><td><table>\n");
						}
						TreeMap<Long, String> viewlog = new TreeMap<Long, String>();
						TreeMap<Long, String> propertylist = new TreeMap<Long, String>();
						while (ii.hasNext()) {
							byte[] rowkey = ii.next();
							java.util.UUID uuid_ = t.toUUID(rowkey);
							d.setTime(1000 * ((uuid_.timestamp() / 10000000) - 12219292800L));
							counter++;
							if (format.equals("html")) {

								temp_output = "<tr><td style='text-align:left;font-size:0.7em;width:50%;color:#bbbbbb;'>"
										+ d.toLocaleString()
										+ "</td><td style='text-align:left;font-size:0.7em;font-weight:bold;'> "
										+ sm.get(rowkey) + "</td></tr>";
							}
							long d_long = d.getTime();
							viewlog.put(new Long(d_long), temp_output);
							temp_output = "";
							propertylist.put(new Long(d_long), (String) sm.get(rowkey));
						}

						Iterator<Long> k = viewlog.keySet().iterator();
						while (k.hasNext()) {
							Long timeKey = k.next();
							output = (viewlog.get(timeKey)) + output;
						}
						allProperties.put(key, propertylist);

						out.println(output);
						if (format.equals("html")) {
							out.println("</table></td></tr>");
						}
						output = "";
					}
				}
				if (format.equals("html")) {
					out.println("</table>");
				}

				if (format.equals("j")) {
					JSONObject jsonObj = new JSONObject(allProperties);
					out.println(jsonObj.toString());
				}
				if (format.equals("stats")) {
					TreeMap<Long, String> info = allProperties.get("info");
					Iterator<Long> ii = info.keySet().iterator();
					while (ii.hasNext()) {
						Long time = ii.next();
						String s = info.get(time);
						JSONObject jsonObj = new JSONObject(s);
						if (jsonObj.has("clustername") && jsonObj.get("clustername").equals("stats")) {
							out.println(jsonObj.get("info"));
						}
					}
				}

			}
		}
	} catch (Exception e) {
		response.setStatus(500);
		e.printStackTrace();
	}

	if (format.equals("html")) {
%>
<jsp:include page="/browse/footer.jsp" />
<%
	}
%>


