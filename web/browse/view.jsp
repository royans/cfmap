<%@ page import="com.ingenuity.cfmap.*"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%
	String format = "j";
	if ((request.getParameter("f") != null) && (request.getParameter("f").equals("html"))) {
		format = "html";
	}
	if ((request.getParameter("f") != null) && (request.getParameter("f").equals("s"))) {
		format = "s"; // shell
	}
	if ((request.getParameter("f") != null) && (request.getParameter("f").equals("img"))) {
		format = "img"; // shell
	}
	String[] cols;
	if (request.getParameter("cols") != null) {
		cols = request.getParameter("cols").split(",");
	} else {
		cols = new String[0];
	}
	//	out.println(cols.length);
	if (format.equals("html")) {
%>
<jsp:include page="/browse/header.jsp" />

<script src="/cfmap/browse/jquery/jquery.min.js"></script>

<table style='width: 100%;'>
	<tr>
		<td style='text-align: right; padding-right: 20px;'>
		<div style='width: 90%;' id='slickbox'>slick</div>
		</td>
		<td style="width: 100px;"><a href='#'
			OnClick='javascript:$("#slickbox").toggle("slow");'>Preferences</a></td>

	</tr>
</table>
<%
	//<a href='javascript:$("#preferences").toggle("slow");'>Preferences</a>
	}
	try {
		Cfmap t = Cfmap.getInstance();
		HashMap<String, String> find = new HashMap<String, String>();
		for (Enumeration<String> e = request.getParameterNames(); e.hasMoreElements();) {
			String ParameterNames = (String) e.nextElement();
			if (!ParameterNames.equals("c") && !(ParameterNames.equals("submit"))
					&& !ParameterNames.equals("f") && !(ParameterNames.equals("z"))
					&& !(ParameterNames.equals("cols")) && (!request.getParameter(ParameterNames).equals(""))) {
				find.put(ParameterNames, request.getParameter(ParameterNames));
			}
		}
		ArrayList<String> clusterlist = new ArrayList<String>();
		ArrayList<String> serverlist = new ArrayList<String>();
		ArrayList<String> apps = new ArrayList<String>();
		int count_services = 0;
		String _clustername = "";
		String _host = "";
		String _appname = "";
		String _zonename = "";
		float _host_load_max = 0;
		float _host_load_total = 0;
		float _host_load = 0;

		if ((request.getParameter("z") != null)) {
			String zone = request.getParameter("z");
			String ipaddr = request.getRemoteAddr();
			if (find.size() == 0) {
				find.put("type", "app");
			}
			ArrayList<String> cols_present=new ArrayList<String>();
			HashMap<String, HashMap<String, String>> hostsProperties = t.getHostsProperties(ipaddr, zone, find);
			if (format.equals("html")) {
				Iterator<String> hosts = hostsProperties.keySet().iterator();
				SortedMap<Long, String> properties_output = new TreeMap<Long, String>();
				Long dateNow = System.currentTimeMillis();
				Random rand = new Random();
				while (hosts.hasNext()) {
					String host = hosts.next();
					HashMap<String, String> properties = hostsProperties.get(host);
					try {
						_clustername = properties.get("clustername");
						_host = properties.get("host");
						_appname = properties.get("appname");
						_zonename = properties.get("zonename");
						if (properties.containsKey("stats_host_load-avg")){
  						 _host_load = Float.parseFloat(properties.get("stats_host_load-avg"));
						}
						if (!clusterlist.contains(_clustername)) {
							clusterlist.add(_clustername);
						}
						if (!serverlist.contains(_host)) {
							serverlist.add(_host);
							_host_load_total = _host_load_total + _host_load;
						}
						if (!apps.contains(_appname)) {
							apps.add(_appname);
						}

					} catch (Exception e) {
						e.printStackTrace();
					}

					CfmapProp p = new CfmapProp(zone, host, properties);

					Long deployed_date = null;
					try {
						deployed_date = new Long(properties.get("deployed_date"));
					} catch (Exception e) {
						deployed_date = new Long(0);
					}
					if (deployed_date == null) {
						deployed_date = System.currentTimeMillis();
					}
					try {
						Long key = deployed_date;
						while (properties_output.containsKey(deployed_date)) {
							deployed_date++;
						}
						properties_output.put(deployed_date, p.toHtmlTableRow(cols, request.getRequestURI()
								.toString()
								+ "?" + request.getQueryString().toString()));
						cols_present.addAll(p.cols_present);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				Iterator<Long> i = properties_output.keySet().iterator();
				String s = "";
				while (i.hasNext()) {
					s = properties_output.get(i.next()) + s;
				}

				out.println("<table id='view_table'>");
				if (cols.length > 0) {
					for (int j = 0; j < cols.length; j++) {

						String[] ss = cols[j].split(":");
						String col = ss[0];
						String colname = "";
						if (ss.length > 1) {
							colname = ss[1];
						}
						if ((cols_present.contains(ss[0]) == true)||(ss[0].equals("key"))) {
							if (ss.length > 1) {
								out.println("<th>" + colname + "</th>");
							} else {
								out.println("<th>" + col + "</th>");
							}
						}else{							
							out.println("<th>" + col + "</th>");
						}
					}
					out.println("</tr>");
				} else {
					out
							.println("<tr><th>Del</th><th title='deployed_date'>Dep</th><th title='key'>Host:Port</th><th title='host'>Host</th><th>status</th><th>app</th><th>heartbeat</th><th>zone</th><th>appnamedir</th><th>cluster</th><th>ps</th><th>netstat</th><th>load</th><th>freemem</th><th>iowait</th><th title='version'>Version</th><th>url</th></tr>");
				}
				out.println(s);
				out.println("<tr><td colspan=20>");
				{
					CfmapProp p = new CfmapProp(zone, null, null);
					out
							.println("<table style='width:100%;border-top:1px dotted gray;padding-top:10px;margin-top:10px;'>");
					out.println("<tr><td style='font-weight:bold;width:300px;'>Clusters ("
							+ clusterlist.size()
							+ ") </td><td>"
							+ p.fromArrayToString(clusterlist, "clustername", request.getRequestURI() + "?"
									+ request.getQueryString()) + "</td></tr>");
					out.println("<tr><td style='font-weight:bold;width:300px;'>Hosts ("
							+ serverlist.size()
							+ ") - "
							+ _host_load_total
							/ serverlist.size()
							+ " load average </td><td>"
							+ p.fromArrayToString(serverlist, "host", request.getRequestURI() + "?"
									+ request.getQueryString()) + "</td></tr>");
					out.println("<tr><td style='font-weight:bold;width:300px;'>Apps ("
							+ apps.size()
							+ ")</td><td>"
							+ p.fromArrayToString(apps, "appname", request.getRequestURI() + "?"
									+ request.getQueryString()) + "</td></tr>");
					out.println("</table>");
				}
				out.println("</td></tr>");
				out.println("</table>");
			}
			if (format.equals("img")) {
				String status = "failed";
				int total = 0;
				int failed = 0;
				Iterator<String> i = hostsProperties.keySet().iterator();
				while (i.hasNext()) {
					String k = i.next();
					HashMap<String, String> map = hostsProperties.get(k);
					if (map.containsKey("status")) {
						total++;
						if (map.get("status").equals("broken")) {
							failed++;
						}
						if (map.containsKey("checked")) {
							long delta = (Calendar.getInstance().getTime().getTime() - Long.parseLong(map
									.get("checked")) * 1000) / 1000;
							if (delta > 1800) {
								failed++;
							}
						}
					}
				}
				if (total == 0 ){
					out.println("not found");
					response.sendRedirect("/cfmap/browse/theme/exclamation.png");					
				}
				if ((total / 2) < failed) {
					out.println("failed");
					response.sendRedirect("/cfmap/browse/theme/cancel.png");
				} else {
					if (failed > 0) {
						out.println("warning");
						response.sendRedirect("/cfmap/browse/theme/error.png");
					} else {
						out.println("ok");
						response.sendRedirect("/cfmap/browse/theme/tick.png");
					}
				}
			}
			if (format.equals("j")) {
				JSONObject jsonObj = new JSONObject(hostsProperties);
				out.println(jsonObj.toString());
			}
			if (format.equals("s")) {
				Iterator<String> hosts = hostsProperties.keySet().iterator();
				while (hosts.hasNext()) {
					String host = hosts.next();
					HashMap<String, String> properties = hostsProperties.get(host);
					CfmapProp p = new CfmapProp(zone, host, properties);
					out.println(p.toShell());
				}
			}
		} else {
			if (format.equals("html")) {
				out.println("<a href='?z=dev&f=html'>show info</a><br/>");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
		out.println("Exception :" + e.toString());
		response.setStatus(500);
	}
	if (format.equals("html")) {
%>
<jsp:include page="/browse/footer.jsp" />
<%
	}
%>

