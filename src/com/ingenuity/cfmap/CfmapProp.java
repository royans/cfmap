package com.ingenuity.cfmap;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;

public class CfmapProp {
	private HashMap<String, String> properties;
	private ArrayList<String> blacklist = new ArrayList<String>();
	private String zone = "";
	private String key = "";

	public CfmapProp(String zone, String key, HashMap<String, String> properties) {
		this.zone = zone;
		this.key = key;
		this.properties = properties;
	}

	public String toRelativeDate(String date, int warning, int fail, boolean format) {
		String result = date;
		try {
			long i = (Calendar.getInstance().getTime().getTime() - Long.parseLong(date) * 1000) / 1000;

			if (i > 60) {
				if ((i > 24 * 3600)) {
					result = Math.round((i / (24 * 3600))) + "d";
				} else {
					if (i > 3600) {
						result = (Math.round(i / (3600))) + "h";
					} else {
						if (i > 60) {
							result = (Math.round(i / (60))) + "m";
						}
					}
				}
			} else {
				result = Math.round(i) + "s";
			}

			if (format) {
				boolean modified = false;
				if (fail > -1) {
					if (i > fail) {
						result = "<span style='background:red;color:white;font-weight:bold;'> " + result + "</span>";
						modified = true;
					}
				}
				if (!modified) {
					if (warning > -1) {
						if (i > warning) {
							result = "<span style='color:tomato;font-weight:bold;'>" + result + "</span>";
						}
					}
				}
			}

		} catch (Exception e) {
		}
		return result;
	}

	public String prop(String property) {
		return prop(property, true);
	}

	public String prop(String property, boolean format) {
		if (properties.containsKey(property)) {

			if ((property.equals("deployed_date") || property.equals("checked"))) {
				if (property.equals("deployed_date")) {
					return toRelativeDate(properties.get(property), 8640000, 25920000, format);
				} else {
					if (property.equals("checked")) {
						return toRelativeDate(properties.get(property), 1000, 3600, format);
					}
				}
			}

			cols_present.add(property);
			return properties.get(property);
		} else {
			return "-";
		}
	}

	public String fromArrayToGraphiteTarget(ArrayList<String> input,String parent,String child) {
		String result = "";
		for (int i = 0; i < input.size(); i++) {
			result = result+"&target="+parent+"." + input.get(i)+"."+child;
		}
		return result;
	}

	public String fromArrayToString(ArrayList<String> input, String property, String url) {
		String result = "";
		for (int i = 0; i < input.size(); i++) {
			String j = "<a style='text-decoration:none;' href='" + url + "&" + property + "=" + input.get(i) + "' >"
					+ input.get(i) + "</a>";
			if (i > 0) {
				result = result + ", " + j;
			} else {
				result = j;
			}
		}
		return result;
	}

	public ArrayList<String> cols_present = new ArrayList<String>();

	public String toHtmlTableRow(String[] cols, String url) {
		String status = prop("status");
		if (status.equals("broken")) {
			status = "<font style='color:red;font-weight:bold;'>X</font>";
		}

		if (status.equals("running")) {
			status = "<font style='color:green;font-weight:bold;'>running</font>";
		}

		if (status.equals("deployed")) {
			status = "<font style='color:gray;font-size:0.7em;'>deployed</font>";
		}

		if (status.equals("stopped")) {
			status = "<font style='color:gray;font-size:0.6em;'>stopped</font>";
		}

		if (status.equals("started")) {
			status = "<font style='color:lightgreen;font-size:0.6em;'>started</font>";
		}
		String result = "";
		if ((cols != null) && (cols.length > 0)) {
			result = result + "<tr>";
			for (int i = 0; i < cols.length; i++) {
				String[] s = cols[i].split(":");
				String col = s[0];
				String colname = "";
				if (s.length > 1) {
					colname = s[1];
				}
				boolean found = false;
				if (col.equals("del")) {
					result = result + "<td><a href='/cfmap/browse/deletereally.jsp?key=" + key + "&z=" + zone
							+ "'>x</a>" + "</td>";
					found = true;
				}
				if (col.equals("key")) {
					result = result + "<td> <a href='/cfmap/browse/viewrecord.jsp?key=" + key + "&z=" + zone + "'>"
							+ prop("host", false) + ":" + prop("port", false) + "</a></td>";
					found = true;
				}
				if (col.contains("stats_")) {
					result = result + "<td>" + prop(col) + "</td>";
					found = true;
				}
				if (col.equals("checked")) {
					if ((prop("status") != null) && (!prop("status").equals("deployed"))) {
						result = result + "<td> <a href='" + url + "&" + col + "=" + prop(col, false) + "'>"
								+ prop(col, true) + "</a></td>";
					} else {
						result = result + "<td> " + prop(col, false) + "</td>";
					}
					found = true;
				}

				if (!found) {
					if ((prop(col) != null) && (prop(col).length() > 0)) {
						result = result + "<td><a href='" + url + "&" + col + "=" + prop(col, false) + "'>" + prop(col)
								+ "</a></td>";

					} else {
						result = result + "<td>-</td>";
					}
				}
			}
			result = result + "</tr>";
		} else {
			result = "<tr><td><a href='/cfmap/browse/deletereally.jsp?key=" + key + "&z=" + zone + "'>x</a>"
					+ "</td><td>" + prop("deployed_date") + "</td><td> <a href='/cfmap/browse/viewrecord.jsp?key="
					+ key + "&z=" + zone + "'>" + prop("host") + ":" + prop("port") + "</a></td> <td> <a href='" + url
					+ "&host=" + prop("host", false) + "'>" + prop("host") + "</a></td><td>" + status
					+ "</td><td><a href='" + url + "&appname=" + prop("appname", false) + "'>" + prop("appname")
					+ "</a></td><td >" + prop("checked") + "</td><td><a href='" + url + "&zonename="
					+ prop("zonename", false) + "'>" + prop("zonename") + "</a></td><td><a href='" + url
					+ "&appnamedir=" + prop("appnamedir", false) + "'>" + prop("appnamedir") + "</a></td><td><a href='"
					+ url + "&clustername=" + prop("clustername", false) + "'>" + prop("clustername") + "</a></td><td>"
					+ prop("stats_host_ps-count") + "</td><td><center>" + prop("stats_host_netstat-est")
					+ "</center></td><td>" + prop("stats_host_load-avg") + "</td><td><center>"
					+ prop("stats_host_freemem") + "</center></td><td>" + prop("stats_host_iowait")
					+ "</td><td style='padding-left:10px;padding-right:10px;'> <a href='" + url + "&version="
					+ prop("version") + "'>" + prop("version") + "</a></td><td><a href='"
					+ prop("url").replace("'", "") + "'>" + prop("url").replace("'", "") + "</a>" + "</td>" + "</tr> ";
		}
		return result;
	}

	public String toShell() {
		Iterator<String> i = properties.keySet().iterator();
		String result = "";
		while (i.hasNext()) {
			String propkey = i.next();
			result = result + key + ":" + propkey + "=" + properties.get(propkey) + "\n";
		}
		return result;
	}

}

