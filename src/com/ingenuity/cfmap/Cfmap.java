package com.ingenuity.cfmap;

import java.math.BigInteger;
import java.net.InetAddress;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.cassandra.thrift.*;
import me.prettyprint.cassandra.service.CassandraClient;
import me.prettyprint.cassandra.service.CassandraClientPool;
import me.prettyprint.cassandra.service.CassandraClientPoolFactory;
import me.prettyprint.cassandra.service.Keyspace;
import me.prettyprint.cassandra.service.PoolExhaustedException;
import org.apache.cassandra.thrift.Column;
import org.apache.cassandra.thrift.ColumnPath;
import org.apache.cassandra.thrift.NotFoundException;
import org.apache.cassandra.thrift.UnavailableException;
import org.perf4j.LoggingStopWatch;
import org.perf4j.StopWatch;

import com.google.gson.Gson;

public class Cfmap {

	private static Cfmap ref = null;
	private ArrayList<String> hostlist;
	private int port = 9160;

	public Cfmap() {
	}

	public static synchronized Cfmap getInstance() throws IllegalStateException, PoolExhaustedException, Exception {
		if (ref == null) {
			ref = new Cfmap();
			ref.init();
		}
		return ref;
	}

	private ArrayList<String> fromStringArray(String hosts[]) {
		ArrayList<String> result = new ArrayList<String>();
		for (int i = 0; i < hosts.length; i++) {
			result.add(hosts[i]);
		}
		return result;
	}

	private synchronized void init() throws IllegalStateException, PoolExhaustedException, Exception {
		System.out.println("initializing..");
		hostlist = new ArrayList<String>();
		this.port = 9160;
		if ((Messages.getString("com.ingenuity.cfmap.hosts") != null)
				&& (Messages.getString("com.ingenuity.cfmap.hosts").length() > 0)) {
			hostlist = fromStringArray(Messages.getString("com.ingenuity.cfmap.hosts").split(","));
		} else {
			try {
				InetAddress addr = InetAddress.getLocalHost();
				hostlist.add(addr.getHostName());
			} catch (Exception e) {
			}
		}
		if (hostlist.size() == 0) {
			hostlist.add("127.0.0.1");
		}
		System.out.println("Host set : " + hostlist.get(0));
		if ((Messages.getString("com.ingenuity.cfmap.port") != null)
				&& (Messages.getString("com.ingenuity.cfmap.port").length() > 0)) {
			Integer port_ = Integer.getInteger(Messages.getString("com.ingenuity.cfmap.port"));
			if (port_ != null) {
				port = port_.intValue();
			}
		}
		System.out.println("Port set : " + port);
		initCassandra();
	}

	static String[] cassandraHostList = null;
	static String[] workingCassandraHostList = null;

	private synchronized void updatehostlist(CassandraClient client, long time) {
		String host = null;
		if ((1 == 2) && (client != null)) {
			host = client.getIp() + ":" + client.getPort();
			System.out.println("Updatehostlist " + host + "  " + time);

			if (time > 2000) {
				System.out.println("Removing node " + host);
				String[] newHostList = new String[cassandraHostList.length];
				int j = 0;
				for (int i = 0; i < workingCassandraHostList.length; i++) {
					if ((workingCassandraHostList[i] != null) && (!workingCassandraHostList[i].equals(host))) {
						newHostList[j++] = workingCassandraHostList[i];
					}
				}
				workingCassandraHostList = newHostList;
			}
			if (workingCassandraHostList == null || workingCassandraHostList.length == 0) {
				if (workingCassandraHostList == null) {
					workingCassandraHostList = new String[cassandraHostList.length];
				}
				workingCassandraHostList = cassandraHostList;
			}
		}
	}

	// private synchronized CassandraClient
	// poolBorrowClient_(CassandraClientPool pool) throws Exception {
	// CassandraClient client;
	// client = pool.borrowClient(workingCassandraHostList);
	// return client;
	// }

	private void initCassandra() throws IllegalStateException, PoolExhaustedException, Exception {
		cassandraHostList = new String[10];
		for (int i = 0; i < hostlist.size(); i++) {
			InetAddress addr = InetAddress.getByName(hostlist.get(i));
			cassandraHostList[i] = addr.toString().split("/")[1] + ":" + port;
			// cassandraHostList[i] = hostlist.get(i) + ":" + port;
			System.out.println(i + "----" + cassandraHostList[i]);
		}
		workingCassandraHostList = cassandraHostList;
	}

	/*
	 * protected void dumpEverything_1() throws Exception { CassandraClientPool
	 * pool = CassandraClientPoolFactory.INSTANCE.get(); StopWatch stopWatch =
	 * new LoggingStopWatch("TimeToGetClient"); CassandraClient client =
	 * pool.borrowClient(workingCassandraHostList); stopWatch.stop(); try {
	 * updatehostlist(client, stopWatch.getElapsedTime());
	 * 
	 * List<String> keyspaces = client.getKeyspaces(); Iterator<String>
	 * keyspace_iterator = keyspaces.iterator(); Keyspace keyspace; while
	 * (keyspace_iterator.hasNext()) { String keyspace_name =
	 * keyspace_iterator.next(); keyspace = client.getKeyspace(keyspace_name,
	 * ConsistencyLevel.ONE); } } catch (Exception e) {
	 * 
	 * } finally { pool.releaseClient(client); } }
	 */
	protected ArrayList<String> getAllReverseRowsFor(String zonename, String rowkey) throws Exception {
		ArrayList<String> rowkeys;
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		// String zonename=getZoneName("",z);
		try {
			pool = CassandraClientPoolFactory.INSTANCE.get();
			if (pool == null) {
				System.out.println(" pool is null...");
			}
			if (cassandraHostList == null) {
				System.out.println(" cassandraHostList is null...");
			}

			StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient1");
			try {
				client = pool.borrowClient(workingCassandraHostList);

				System.out.println(client.getIp());
			} catch (NullPointerException e) {
				workingCassandraHostList = cassandraHostList;
			}

			stopWatch.stop();
			updatehostlist(client, stopWatch.getElapsedTime());

			stopWatch = new LoggingStopWatch("TimeToGetClient2");
			if (client != null) {
				System.out.println(zonename);
				keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);
			} else {
				System.out.println("Client is null... 1");
			}
			stopWatch.stop();

			SlicePredicate predicate = new SlicePredicate();
			predicate
					.setSlice_range(new SliceRange().setStart("".getBytes()).setFinish("".getBytes()).setCount(100000));
			ColumnParent parent = new ColumnParent();
			parent.setColumn_family("reverse");
			rowkeys = new ArrayList<String>();

			stopWatch = new LoggingStopWatch("TimeToGetClient3");
			List<Column> results = keyspace.getSlice(rowkey, parent, predicate);
			stopWatch.stop();
			for (Column result : results) {
				Column column = result;
				rowkeys.add(new String(column.name, "UTF-8"));
			}
			client = keyspace.getClient();
		} finally {
			if ((pool != null) && (client != null)) {
				pool.releaseClient(client);
			}
		}
		return rowkeys;
	}

	/**
	 * @param zonename
	 *            The zone of data to look at
	 * @param rowkey
	 *            The rowkey is the specific to the service on a particular
	 *            host/port
	 * @param newProperties
	 *            New set of properties to apply
	 * @param oldPropertylist
	 *            Old set of properties. Used to figure out what updates need to
	 *            be applied
	 * @param replace
	 * @throws Exception
	 */
	protected void updateHost(String zonename, String rowkey, HashMap<String, String> newProperties,
			HashMap<String, String> oldPropertylist, boolean replace) throws Exception {
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		ArrayList<String> cleanuptables = new ArrayList<String>();
		// System.out.println("rkt: inserting 4 ");
		try {
			pool = CassandraClientPoolFactory.INSTANCE.get();

			StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient");
			try {
				client = pool.borrowClient(workingCassandraHostList);
			} catch (NullPointerException e) {
				workingCassandraHostList = cassandraHostList;
			}
			stopWatch.stop();
			updatehostlist(client, stopWatch.getElapsedTime());

			keyspace = client.getKeyspace(zonename, ConsistencyLevel.ZERO);
			ArrayList<String> properties_keys = new ArrayList<String>();
			Iterator<String> j = newProperties.keySet().iterator();
			while (j.hasNext()) {
				String k = j.next();
				properties_keys.add(k);
			}

			String host = rowkey;
			ColumnPath cp;
			// System.out.println("rkt: inserting 5 ");

			if (((oldPropertylist != null) && (oldPropertylist.size() > 0)) || (rowkey.equals("updatefeed"))) {
				Iterator<String> newPropertyIterator = newProperties.keySet().iterator();

				// System.out.println("rkt: inserting 3 ");
				while (newPropertyIterator.hasNext()) {
					String newProperty = newPropertyIterator.next();
					String newValue = newProperties.get(newProperty);

					boolean changeRequired = true;
					Iterator<String> oldPropertyIterator = oldPropertylist.keySet().iterator();
					while (oldPropertyIterator.hasNext()) {
						String oldProperty = oldPropertyIterator.next();
						String oldValue = oldPropertylist.get(oldProperty);

						if ((oldProperty.equals(newProperty)) && (newValue.equals(oldValue))) {
							changeRequired = false;
						}

						if ((oldProperty.equals(newProperty)) && (!newValue.equals(oldValue))) {
							if (replace) {
								cp = new ColumnPath("reverse");
								cp.setColumn((host).getBytes());
								keyspace.remove(oldProperty + "__" + oldValue, cp);
							}
						}
					}
					// System.out.println("rkt: inserting 2 " + changeRequired);

					if (changeRequired) {
						if (!newProperty.startsWith("info_") && !newProperty.startsWith("stats_")
								&& (!newProperty.equals("checked"))) {
							cp = new ColumnPath("reverse");
							cp.setColumn((host).getBytes());
							keyspace.createTimestamp();
							keyspace.insert(newProperty + "__" + newValue, cp, host.getBytes());
							cp = new ColumnPath("history");
							cp.setSuper_column(newProperty.getBytes());

							java.util.UUID timeuuid = getTimeUUID();
							byte[] timeuuid_encoded = asByteArray(timeuuid);
							cp.setColumn(timeuuid_encoded);
							keyspace.createTimestamp();
							keyspace.insert(host, cp, newValue.getBytes());
						} else {
							if (newProperty.startsWith("stats_host_")) {
								cleanuptables.add("stats_host_" + oldPropertylist.get("host"));

								cp = new ColumnPath("history");
								String p = newProperty;
								p.replaceFirst("stats_host_", "");

								cp.setSuper_column(p.getBytes());
								java.util.UUID timeuuid = getTimeUUID();
								byte[] timeuuid_encoded = asByteArray(timeuuid);
								cp.setColumn(timeuuid_encoded);
								keyspace.insert("stats_host_" + oldPropertylist.get("host"), cp, newValue.getBytes());
							}
						}
						cp = new ColumnPath("forward");
						cp.setColumn((newProperty).getBytes());
						System.out.println("rkt: inserting 1 " + newProperty + " " + newValue);
						keyspace.insert(host, cp, newValue.getBytes());
						changeRequired = true;
					}
				}
			}
			client = keyspace.getClient();
		} finally {
			pool.releaseClient(client);
		}

		Iterator<String> i = cleanuptables.iterator();
		while (i.hasNext()) {
			String host = i.next();
			if (host.startsWith("stats_host_") || (host.startsWith("updatefeed"))) {
				clearOldHistory(zonename, "history", 5000, host, 3600 * 24);
			} else {
				clearOldHistory(zonename, "history", 5000, host, 3600 * 24 * 7);
			}
		}
	}

	public void delHosts(String ipaddr, String zone, ArrayList<String> rowkeys) throws Exception {
		String zonename = getZoneName(ipaddr, zone);
		delHosts(zonename, rowkeys);
	}

	protected void delHosts(String zonename, ArrayList<String> rowkeys) throws Exception {
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		try {
			pool = CassandraClientPoolFactory.INSTANCE.get();
			StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient");
			try {
				client = pool.borrowClient(workingCassandraHostList);
			} catch (NullPointerException e) {
				workingCassandraHostList = cassandraHostList;
			}
			stopWatch.stop();
			updatehostlist(client, stopWatch.getElapsedTime());

			keyspace = client.getKeyspace(zonename, ConsistencyLevel.ZERO);

			long timestamp = System.currentTimeMillis();
			System.out.println(rowkeys.size());

			Iterator<String> i = rowkeys.iterator();
			while (i.hasNext()) {
				String key = i.next();
				HashMap<String, String> propertylist = getRaw(zonename, "forward", key);
				Iterator<String> ii = propertylist.keySet().iterator();
				ColumnPath cp;
				while (ii.hasNext()) {
					String property = ii.next();
					String value = propertylist.get(property);
					cp = new ColumnPath("reverse");
					cp.setColumn((key).getBytes());
					keyspace.remove(property + "__" + value, cp);
				}
				cp = new ColumnPath("forward");
				System.out.println("Deleting forward for " + key);
				keyspace.remove(key, cp);
			}
			client = keyspace.getClient();
		} finally {
			pool.releaseClient(client);
		}
	}

	public String getZoneName(String ipaddress, String zone) {
		return Messages.getString("com.ingenuity.cfmap.zones." + zone + ".name");
	}

	public HashMap<String, HashMap<String, String>> getHostsProperties(String ipaddress, String zone,
			HashMap<String, String> requirements) throws Exception {
		String zonename = getZoneName(ipaddress, zone);
		if (zonename != null) {
			HashMap<String, HashMap<String, String>> combined = getHostsProperties(zonename, requirements);
			return combined;
		}
		return null;
	}

	public HashMap<String, List<Column>> getHostsPropertiesColumns(String z, HashMap<String, String> requirements)
			throws Exception {
		String zonename = getZoneName("", z);
		HashMap<String, List<Column>> combined = new HashMap<String, List<Column>>();
		// CassandraClient rClient = null;
		if (requirements.size() > 0) {
			String property = requirements.keySet().iterator().next();
			String value = requirements.get(property);
			ArrayList<String> keys = getAllReverseRowsFor(zonename, property + "__" + value);
			// long start = System.currentTimeMillis();
			// long total = 0;
			for (int j = 0; j < keys.size(); j++) {
				try {
					List<Column> host_properties = getRawColumns(zonename, "forward", keys.get(j));
					boolean pass = false;
					Set<String> requirements_keys = requirements.keySet();
					Iterator<Column> i = host_properties.iterator();
					while (i.hasNext()) {
						Column column = i.next();
						String columnname = new String(column.name, "UTF-8");
						if (requirements_keys.contains(columnname)) {
							String columnvalue = new String(column.value, "UTF-8");
							if (columnvalue.equals(requirements.get(columnname))) {
								pass = true;
							}
						}
					}

					/*
					 * if (1 == 2) { Iterator<String> i =
					 * requirements.keySet().iterator(); while (i.hasNext() &&
					 * pass) { String _key = i.next(); String _value =
					 * requirements.get(_key); if
					 * (!((host_properties.containsKey(_key)) &&
					 * (host_properties.get(_key).equals(_value)))) { pass =
					 * false; } } }
					 */
					if (pass) {
						combined.put(keys.get(j), host_properties);
					}
				} catch (UnavailableException e) {
					ArrayList<String> hoststodelete = new ArrayList<String>();
					hoststodelete.add(keys.get(j));
					try {
						delHosts(zonename, hoststodelete);
					} catch (NotFoundException ee) {
					} catch (UnavailableException ee) {
					}
				}
			}
		}
		return combined;
	}

	protected HashMap<String, HashMap<String, String>> getHostsProperties(String zonename,
			HashMap<String, String> requirements) throws Exception {
		HashMap<String, HashMap<String, String>> combined = new HashMap<String, HashMap<String, String>>();
		CassandraClient rClient = null;
		if (requirements.size() > 0) {
			String property = requirements.keySet().iterator().next();
			String value = requirements.get(property);
			ArrayList<String> keys = getAllReverseRowsFor(zonename, property + "__" + value);
			long start = System.currentTimeMillis();
			long total = 0;
			for (int j = 0; j < keys.size(); j++) {
				try {
					HashMap<String, String> host_properties = getProperties(zonename, "forward", keys.get(j));
					boolean pass = true;
					Iterator<String> i = requirements.keySet().iterator();
					while (i.hasNext() && pass) {
						String _key = i.next();
						String _value = requirements.get(_key);
						if (!((host_properties.containsKey(_key)) && (host_properties.get(_key).equals(_value)))) {
							pass = false;
						}
					}
					if (pass) {
						combined.put(keys.get(j), host_properties);
					}
				} catch (UnavailableException e) {
					ArrayList<String> hoststodelete = new ArrayList<String>();
					hoststodelete.add(keys.get(j));
					try {
						delHosts(zonename, hoststodelete);
					} catch (NotFoundException ee) {
					} catch (UnavailableException ee) {
					}
				}
			}
		}
		return combined;
	}

	public ArrayList<String> getHosts(String ipaddress, String zone, HashMap<String, String> requirements)
			throws Exception {
		String zonename = getZoneName(ipaddress, zone);
		if (zonename != null) {
			ArrayList<String> combined = getHosts(zonename, requirements);
			return combined;
		}
		return null;
	}

	protected ArrayList<String> getHosts(String zonename, HashMap<String, String> requirements) throws Exception {
		ArrayList<String> combined = new ArrayList<String>();
		CassandraClient rClient = null;
		if (requirements.size() > 0) {
			String property = requirements.keySet().iterator().next();
			String value = requirements.get(property);
			ArrayList<String> keys = getAllReverseRowsFor(zonename, property + "__" + value);
			for (int j = 0; j < keys.size(); j++) {
				System.out.println(" Getting properties for " + keys.get(j));
				try {
					HashMap<String, String> host_properties = getProperties(zonename, "forward", keys.get(j));
					boolean pass = true;
					Iterator<String> i = requirements.keySet().iterator();
					while (i.hasNext() && pass) {
						String _key = i.next();
						String _value = requirements.get(_key);
						if (!((host_properties.containsKey(_key)) && (host_properties.get(_key).equals(_value)))) {
							pass = false;
						}
					}
					if (pass) {
						combined.add(keys.get(j));
					}
				} catch (UnavailableException e) {
					ArrayList<String> hoststodelete = new ArrayList<String>();
					hoststodelete.add(keys.get(j));
					try {
						delHosts(zonename, hoststodelete);
					} catch (NotFoundException ee) {
					} catch (UnavailableException ee) {
					}
				}
			}
		}
		System.out.println(" Returning " + combined.size() + " entries ");
		return combined;
	}

	public HashMap<String, String> getProperties(String ipaddr, String zone, String table, String rowkey)
			throws Exception {
		String zonename = getZoneName(ipaddr, zone);

		return getProperties(zonename, table, rowkey);
	}

	protected HashMap<String, String> getProperties(String zonename, String table, String rowkey) throws Exception {
		// CassandraClient rClient = null;
		return getRaw(zonename, table, rowkey);
	}

	public HashMap<String, String> getRaw(CassandraClient rClient, String ipaddr, String zone, String table,
			String rowkey) throws Exception {
		String zonename = getZoneName(ipaddr, zone);
		if (zonename != null) {
			return getRaw(zonename, table, rowkey);
		}
		return null;
	}

	protected List<Column> getRawColumns(String zonename, String table, String rowkey) throws Exception {
		List<Column> results = null;
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		pool = CassandraClientPoolFactory.INSTANCE.get();
		try {
			client = pool.borrowClient(workingCassandraHostList);
			// System.out.println(client.getIp());
			try {
				keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);
				SlicePredicate predicate = new SlicePredicate();
				predicate.setSlice_range(new SliceRange().setStart("".getBytes()).setFinish("".getBytes()).setCount(
						100000));
				ColumnParent parent = new ColumnParent();
				parent.setColumn_family(table);
				results = keyspace.getSlice(rowkey, parent, predicate);
				client = keyspace.getClient();
			} finally {
				if (client != null) {
					pool.releaseClient(client);
				}
			}
		} catch (NullPointerException e) {
			workingCassandraHostList = cassandraHostList;
		}
		System.out.println("getRawColumn : " + results.size());
		return results;
	}

	protected HashMap<String, String> getRaw(String zonename, String table, String rowkey) throws Exception {
		HashMap<String, String> propertylist = new HashMap<String, String>();
		List<Column> results = getRawColumns(zonename, table, rowkey);
		for (Column result : results) {
			Column column = result;
			propertylist.put(new String(column.name, "UTF-8"), new String(column.value, "UTF-8"));
		}
		return propertylist;
	}

	protected HashMap<String, String> getRaw_(String zonename, String table, String rowkey) throws Exception {
		HashMap<String, String> propertylist = new HashMap<String, String>();
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		pool = CassandraClientPoolFactory.INSTANCE.get();
		try {
			client = pool.borrowClient(workingCassandraHostList);
			System.out.println(client.getIp());
			try {
				keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);
				SlicePredicate predicate = new SlicePredicate();
				predicate.setSlice_range(new SliceRange().setStart("".getBytes()).setFinish("".getBytes()).setCount(
						100000));
				ColumnParent parent = new ColumnParent();
				parent.setColumn_family(table);
				List<Column> results = keyspace.getSlice(rowkey, parent, predicate);
				for (Column result : results) {
					Column column = result;
					propertylist.put(new String(column.name, "UTF-8"), new String(column.value, "UTF-8"));
				}
				client = keyspace.getClient();
			} finally {
				if (client != null) {
					pool.releaseClient(client);
				}
			}
		} catch (NullPointerException e) {
			workingCassandraHostList = cassandraHostList;
		}
		return propertylist;
	}

	public String get(String ipaddr, String zone, String table, String rowkey, String attribute) throws Exception {
		String zonename = getZoneName(ipaddr, zone);
		if (zonename != null) {
			CassandraClient rClient = null;
			return get(rClient, zone, table, rowkey, attribute);
		}
		return null;
	}

	protected String get(CassandraClient rClient, String zonename, String table, String rowkey, String attribute)
			throws Exception {
		String output = "";
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		try {
			if (rClient == null) {
				pool = CassandraClientPoolFactory.INSTANCE.get();

				StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient");
				try {
					client = pool.borrowClient(workingCassandraHostList);
				} catch (NullPointerException e) {
					workingCassandraHostList = cassandraHostList;
				}
				stopWatch.stop();
				updatehostlist(client, stopWatch.getElapsedTime());
			} else {
				client = rClient;
			}
			keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);

			// Keyspace keyspace = client.getKeyspace(zonename);
			SlicePredicate predicate = new SlicePredicate();
			List<byte[]> columnlist = new ArrayList<byte[]>();
			columnlist.add(attribute.getBytes());
			predicate.setColumn_names(columnlist);
			ColumnParent parent = new ColumnParent();
			parent.setColumn_family(table);
			List<Column> results = keyspace.getSlice(rowkey, parent, predicate);
			for (Column result : results) {
				Column column = result;
				output = (new String(column.name, "UTF-8") + " -> " + new String(column.value, "UTF-8"));
			}
			client = keyspace.getClient();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.releaseClient(client);
		}

		return output;
	}

	public HashMap<String, HashMap> getChanges(String ipaddr, String zone, String rowkey) throws Exception {
		String zonename = getZoneName(ipaddr, zone);
		if (zonename != null) {
			return getChanges(zonename, rowkey);
		}
		return null;
	}

	static int clearing_in_use = 0;

	public void clearOldHistory(String ipaddr, String zone, String table, int count, String rowkey, int secondsold)
			throws Exception {
		String zonename = getZoneName(ipaddr, zone);
		System.out.println("Clearing in use 1 : " + clearing_in_use);
		clearOldHistory(zonename, table, count, rowkey, secondsold);
		System.out.println("Clearing in use 2 : " + clearing_in_use);
	}

	public void clearOldRows(String zonename, String table, int count) throws Exception {
		// table = "history";
		if (clearing_in_use > 1) {
			clearing_in_use = 1;
		}
		if (clearing_in_use < 0) {
			clearing_in_use = 0;
		}

		if ((clearing_in_use == 0) && (Messages.getString("com.ingenuity.cfmap.cleanup") != null)
				&& (Messages.getString("com.ingenuity.cfmap.cleanup").equals("on"))) {
			clearing_in_use++;
			// int deleted = 0;
			// HashMap<String, HashMap> sr = new HashMap<String, HashMap>();
			CassandraClientPool pool = null;
			CassandraClientPool pool_delete = null;
			CassandraClient client = null;
			CassandraClient client_delete = null;
			Keyspace keyspace = null;
			Keyspace keyspace_delete = null;
			try {
				pool = CassandraClientPoolFactory.INSTANCE.get();
				pool_delete = CassandraClientPoolFactory.INSTANCE.get();
				StopWatch stopWatch = new LoggingStopWatch("TimeToGetClientChanges");
				try {
					client = pool.borrowClient(workingCassandraHostList);
					client_delete = pool_delete.borrowClient(cassandraHostList);
				} catch (NullPointerException e) {
					workingCassandraHostList = cassandraHostList;
				}
				stopWatch.stop();
				updatehostlist(client, stopWatch.getElapsedTime());
				keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);
				keyspace_delete = client_delete.getKeyspace(zonename, ConsistencyLevel.ZERO);

				KeyRange keyrange = new KeyRange();
				keyrange.setStart_key("");
				keyrange.setEnd_key("");

				SlicePredicate predicate = new SlicePredicate();
				predicate.setSlice_range(new SliceRange().setStart("".getBytes()).setFinish("".getBytes())
						.setCount(100));
				ColumnParent parent = new ColumnParent();
				parent.setColumn_family(table); // "changes"
				Map<String, List<Column>> rows = keyspace.getRangeSlices(parent, predicate, keyrange);

				Iterator<String> keys = rows.keySet().iterator();
				int i = 0;
				while ((keys.hasNext()) && (i < count)) {
					i++;
					String rowkey = keys.next();
					ColumnPath cp = new ColumnPath(table); // "history"
					cp.setSuper_column(rowkey.getBytes());
					keyspace_delete.remove(rowkey, cp);
					System.out.println("Deleting " + rowkey);
				}
				client = keyspace.getClient();
				client_delete = keyspace_delete.getClient();

			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pool.releaseClient(client);
				pool_delete.releaseClient(client_delete);
				clearing_in_use--;
			}
		}
	}

	public void clearOldHistory(String zonename, String table, int count, String rowkey, int secondsold)
			throws Exception {

		if (clearing_in_use > 1) {
			clearing_in_use = 1;

		}
		if (clearing_in_use < 0) {
			clearing_in_use = 0;
		}

		if ((clearing_in_use == 0) && (Messages.getString("com.ingenuity.cfmap.cleanup") != null)
				&& (Messages.getString("com.ingenuity.cfmap.cleanup").equals("on"))) {
			clearing_in_use++;
			long starttimestamp = System.currentTimeMillis() - secondsold * 1000;
			int deleted = 0;
			HashMap<String, HashMap> sr = new HashMap<String, HashMap>();
			CassandraClientPool pool = null;
			CassandraClientPool pool_delete = null;
			CassandraClient client = null;
			CassandraClient client_delete = null;
			Keyspace keyspace = null;
			Keyspace keyspace_delete = null;
			try {
				pool = CassandraClientPoolFactory.INSTANCE.get();
				pool_delete = CassandraClientPoolFactory.INSTANCE.get();
				// client = poolBorrowClient(pool);

				StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient");
				try {
					client = pool.borrowClient(workingCassandraHostList);
				} catch (NullPointerException e) {
					workingCassandraHostList = cassandraHostList;
				}
				stopWatch.stop();
				updatehostlist(client, stopWatch.getElapsedTime());

				client_delete = pool_delete.borrowClient(cassandraHostList);
				keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);
				keyspace_delete = client_delete.getKeyspace(zonename, ConsistencyLevel.ZERO);
				SlicePredicate predicate = new SlicePredicate();
				predicate.setSlice_range(new SliceRange().setStart("".getBytes()).setFinish("".getBytes())
						.setCount(100));

				ColumnParent parent = new ColumnParent();
				parent.setColumn_family(table); // "history"
				List<SuperColumn> results = keyspace.getSuperSlice(rowkey, parent, predicate);

				for (SuperColumn result : results) {
					String colname = new String(result.getName(), "UTF-8");
					List<Column> cols = result.columns;
					Iterator<Column> columni = cols.iterator();
					HashMap<byte[], String> sortedresults = new HashMap<byte[], String>();
					while (columni.hasNext() && (deleted < count)) {
						Column column = columni.next();
						if (column != null && (column.name != null) && (column.value != null)) {
							java.util.UUID uuid_ = this.toUUID(column.name);
							long columntime = (1000 * ((uuid_.timestamp() / 10000000) - 12219292800L));
							if (columntime < starttimestamp) {

								ColumnPath cp = new ColumnPath(table); // "history"
								cp.setSuper_column(colname.getBytes());
								cp.setColumn(column.name);
								keyspace_delete.remove(rowkey, cp);
								deleted++;
							}
						}
					}
					sr.put(colname, sortedresults);
				}
				client = keyspace.getClient();
				client_delete = keyspace_delete.getClient();

			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pool.releaseClient(client);
				pool_delete.releaseClient(client_delete);
				clearing_in_use--;
			}
		}
	}

	protected HashMap<String, HashMap> getChanges(String zonename, String rowkey) throws Exception {
		HashMap<String, HashMap> sr = new HashMap<String, HashMap>();

		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		try {
			pool = CassandraClientPoolFactory.INSTANCE.get();
			StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient");
			try {
				client = pool.borrowClient(workingCassandraHostList);
			} catch (NullPointerException e) {
				workingCassandraHostList = cassandraHostList;
			}
			stopWatch.stop();
			updatehostlist(client, stopWatch.getElapsedTime());

			keyspace = client.getKeyspace(zonename, ConsistencyLevel.ONE);
			SlicePredicate predicate = new SlicePredicate();
			predicate.setSlice_range(new SliceRange().setStart("".getBytes()).setFinish("".getBytes()).setCount(100));

			ColumnParent parent = new ColumnParent();
			parent.setColumn_family("history");
			List<SuperColumn> results = keyspace.getSuperSlice(rowkey, parent, predicate);

			for (SuperColumn result : results) {
				String colname = new String(result.getName(), "UTF-8");
				List<Column> cols = result.columns;
				Iterator<Column> columni = cols.iterator();
				HashMap sortedresults = new HashMap();
				while (columni.hasNext()) {
					Column column = columni.next();
					if (column != null && (column.name != null) && (column.value != null)) {
						sortedresults.put(column.name, new String(column.value, "UTF-8"));
					}
				}
				sr.put(colname, sortedresults);
			}
			client = keyspace.getClient();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.releaseClient(client);
		}
		return sr;
	}

	public String insertandinvert(String ipaddress, String zone, HashMap<String, String> properties) throws Exception {
		String zonename = getZoneName(ipaddress, zone);
		if (zonename != null) {
			return insertandinvert(zonename, properties);
		}
		return null;
	}

	protected void publishChange(String zonename, String hostname, String appname, String port, String clustername,
			String info) throws Exception {
		HashMap<String, String> hashmap1 = new HashMap<String, String>();
		HashMap<String, String> hashmap2 = new HashMap<String, String>();

		HashMap<String, String> hashmap3 = new HashMap<String, String>();
		hashmap3.put("host", hostname);
		hashmap3.put("appname", appname);
		hashmap3.put("port", port);
		hashmap3.put("clustername", clustername);
		hashmap3.put("info", info);

		Gson gson = new Gson();
		String json = gson.toJson(hashmap3);

		hashmap1.put("info", json);
		System.out.println("-- publishChange : " + json);
		updateHost(zonename, "updatefeed", hashmap1, hashmap2, false);
	}

	protected String summarizeChange(HashMap<String, String> newproperties, HashMap<String, String> oldproperties) {
		String result = null;
		Iterator<String> propIterator = newproperties.keySet().iterator();
		Set<String> oldproperties_keys = oldproperties.keySet();
		Set<String> interesting_properties = new HashSet();
		interesting_properties.add("version");
		interesting_properties.add("clustername");
		interesting_properties.add("status");
		interesting_properties.add("buildtag");
		interesting_properties.add("appnamedir");
		interesting_properties.add("deployed_date_long");
		interesting_properties.add("url");
		while (propIterator.hasNext()) {
			String key = propIterator.next();
			if (interesting_properties.contains(key)) {
				String newProperty = newproperties.get(key);
				String oldProperty = "";
				if (oldproperties_keys.contains(key)) {
					oldProperty = oldproperties.get(key);
				}
				if (!newProperty.equals(oldProperty)) {
					String s = key + " changed to " + newProperty + ". ";
					if (result != null) {
						result = result + s;
					} else {
						result = s;
					}
				}
			}
		}
		return result;
	}

	protected String insertandinvert(String zonename, HashMap<String, String> properties) throws Exception {
		String rowkey = null;
		CassandraClientPool pool = null;
		CassandraClient client = null;
		Keyspace keyspace = null;
		try {
			pool = CassandraClientPoolFactory.INSTANCE.get();
			StopWatch stopWatch = new LoggingStopWatch("TimeToGetClient");
			try {
				client = pool.borrowClient(workingCassandraHostList);
				try {
					stopWatch.stop();
					updatehostlist(client, stopWatch.getElapsedTime());

					keyspace = client.getKeyspace(zonename, ConsistencyLevel.ZERO);

					String rowkey_raw = "";
					if (!(properties.containsKey("key") && properties.get("key").length() > 1)) {
						rowkey_raw = (properties.get("host") + "__" + properties.get("port") + "__" + properties
								.get("appname"));
						if ((properties.get("crypt") != null) && (properties.get("crypt").length() > 0)) {
							rowkey_raw = rowkey_raw + "__" + properties.get("crypt");
						}
						rowkey = getMD5(rowkey_raw);
						System.out.println("Adding: " + rowkey);
					} else {
						rowkey = properties.get("key");
					}

					properties.remove("key");
					// properties.remove("crypt");

					Iterator<String> keys = properties.keySet().iterator();
					HashMap<String, String> oldProperties = getRaw(zonename, "forward", rowkey);
					if ((oldProperties != null) && (oldProperties.size() > 0)) {
						updateHost(zonename, rowkey, properties, oldProperties, true);
						String summaryChange = summarizeChange(properties, oldProperties);
						if ((summaryChange != null) && (summaryChange.length() > 10)) {
							publishChange(zonename, properties.get("host"), properties.get("appname"), properties
									.get("port"), properties.get("clustername"), summaryChange);
						}
					} else {

						if (!properties.containsKey("type")) {
							String type = Messages.getString("cfmap_default_type");
							if (type == null) {
								type = "app";
							}
							properties.put("type", type);
						}

						while (keys.hasNext()) {
							String key = (String) keys.next();
							ColumnPath forward_cp = new ColumnPath("forward").setColumn((key).getBytes());
							keyspace.insert(rowkey, forward_cp, properties.get(key).getBytes("UTF-8"));
							ColumnPath reverse_cp = new ColumnPath("reverse").setColumn(rowkey.getBytes());
							keyspace.insert(key + "__" + properties.get(key), reverse_cp, properties.get(key).getBytes(
									"UTF-8"));
							publishChange(zonename, properties.get("host"), properties.get("appname"), properties
									.get("port"), properties.get("clustername"), "New host. ");
						}
					}
					client = keyspace.getClient();
				} finally {
					pool.releaseClient(client);
				}

			} catch (NullPointerException e) {
				workingCassandraHostList = cassandraHostList;
				e.printStackTrace();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "Row inserted : " + rowkey;
	}

	// /===============================================================================================///

	public ArrayList<String> browseGetKeySpaces(String hostport) throws Exception {
		CassandraClientPool pool = CassandraClientPoolFactory.INSTANCE.get();
		CassandraClient client;
		if (hostport == null) {
			client = pool.borrowClient(workingCassandraHostList);
		} else {
			client = pool.borrowClient(hostport);
		}
		ArrayList<String> result = new ArrayList<String>();
		try {
			List<String> keyspaces = client.getKeyspaces();
			Iterator<String> keyspace_iterator = keyspaces.iterator();
			while (keyspace_iterator.hasNext()) {
				String keyspace_name = keyspace_iterator.next();
				System.out.println("1 = " + keyspace_name);
				result.add(keyspace_name);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.releaseClient(client);
		}
		return result;
	}

	public Map<String, Map<String, String>> browseGetColumnFamilies(String hostport, String keyspace_requested)
			throws Exception {
		CassandraClientPool pool = CassandraClientPoolFactory.INSTANCE.get();
		// CassandraClient client = pool.borrowClient(workingCassandraHostList);
		CassandraClient client;
		if (hostport == null) {
			client = pool.borrowClient(workingCassandraHostList);
		} else {
			client = pool.borrowClient(hostport);
		}

		Map<String, Map<String, String>> result = null;
		try {
			List<String> keyspaces = client.getKeyspaces();
			Iterator<String> keyspace_iterator = keyspaces.iterator();
			Keyspace keyspace;
			while (keyspace_iterator.hasNext()) {
				String keyspace_name = keyspace_iterator.next();
				if (keyspace_name.equals(keyspace_requested)) {
					keyspace = client.getKeyspace(keyspace_name, ConsistencyLevel.ONE);
					result = keyspace.describeKeyspace();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.releaseClient(client);
		}
		return result;
	}

	public HashMap<String, HashMap<String, String>> browseGetRows(String hostport, String keyspace_name,
			String columnFamily) throws Exception {
		CassandraClientPool pool = CassandraClientPoolFactory.INSTANCE.get();
		CassandraClient client;
		if (hostport == null) {
			client = pool.borrowClient(workingCassandraHostList[0]);
		} else {
			client = pool.borrowClient(hostport);
		}
		HashMap<String, HashMap<String, String>> result = new HashMap<String, HashMap<String, String>>();
		try {
			Keyspace keyspace;
			keyspace = client.getKeyspace(keyspace_name, ConsistencyLevel.ONE);

			ColumnParent columnParent = new ColumnParent(columnFamily);
			SlicePredicate sp = new SlicePredicate();
			SliceRange sliceRange = new SliceRange(new byte[0], new byte[0], false, 3);
			sp.setSlice_range(sliceRange);

			KeyRange keyRange = new KeyRange();
			keyRange.setCount(1000);
			keyRange.setStart_key("");
			keyRange.setEnd_key("");

			Map<String, List<Column>> rows = keyspace.getRangeSlices(columnParent, sp, keyRange);
			System.out.println(rows.size());

			Iterator<String> keys = rows.keySet().iterator();
			while (keys.hasNext()) {
				String key = keys.next();
				List<Column> columns = rows.get(key);

				System.out.println(key + " " + columns.size());

				Iterator<Column> column_iterator = columns.iterator();
				HashMap<String, String> temp_map = new HashMap<String, String>();
				while (column_iterator.hasNext()) {
					Column c = column_iterator.next();

					if (c != null) {
						System.out.println(" === " + new String(c.getName(), "UTF-8"));
					}
					if (c != null) {
						String c_name = "";
						if (c.name != null) {
							c_name = new String(c.name, "UTF-8");
						}
						String c_value = "";
						if (c.value != null) {
							c_value = new String(c.value, "UTF-8");
						}
						temp_map.put(c_name, c_value);
					}
				}
				result.put(key, temp_map);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.releaseClient(client);
		}
		return result;
	}

	// /===============================================================================================///

	private String getMD5(String s) {
		String signature = null;
		try {
			MessageDigest md5 = MessageDigest.getInstance("MD5");
			md5.update(s.getBytes(), 0, s.length());
			signature = new BigInteger(1, md5.digest()).toString(16);
		} catch (final NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return signature;
	}

	public static boolean isInRange(String targetIpCidr, String testIp) {
		String[] atoms = targetIpCidr.split("/");
		int cidrMask = Integer.parseInt(atoms[1]);
		long target = ipToLong(atoms[0]);
		long test = ipToLong(testIp);
		int tempMask = (2 << (31 - cidrMask)) - 1;
		return (target | tempMask) == (test | tempMask);
	}

	// http://www.experts-exchange.com/Programming/Languages/Java/Q_22546384.html
	public static long ipToLong(String ipAddress) {
		long result = 0;
		try {
			byte[] bytes = InetAddress.getByName(ipAddress).getAddress();
			long octet1 = bytes[0] & 0xFF;
			octet1 <<= 24;
			long octet2 = bytes[1] & 0xFF;
			octet2 <<= 16;
			long octet3 = bytes[2] & 0xFF;
			octet3 <<= 8;
			long octet4 = bytes[3] & 0xFF;
			result = octet1 | octet2 | octet3 | octet4;
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
		return result;
	}

	/**
	 * Gets a new time uuid.
	 * 
	 * @return the time uuid
	 */

	public java.util.UUID getTimeUUID() {
		org.safehaus.uuid.UUIDGenerator uuidgen = org.safehaus.uuid.UUIDGenerator.getInstance();
		org.safehaus.uuid.UUID uuid = uuidgen.generateTimeBasedUUID();
		java.util.UUID uuid_ = java.util.UUID.fromString(uuid.toString());
		return uuid_;
	}

	/**
	 * Returns an instance of uuid.
	 * 
	 * @param uuid
	 *            the uuid
	 * @return the java.util. uuid
	 */
	public java.util.UUID toUUID(byte[] uuid) {
		long msb = 0;
		long lsb = 0;
		assert uuid.length == 16;
		for (int i = 0; i < 8; i++)
			msb = (msb << 8) | (uuid[i] & 0xff);
		for (int i = 8; i < 16; i++)
			lsb = (lsb << 8) | (uuid[i] & 0xff);
		long mostSigBits = msb;
		long leastSigBits = lsb;

		com.eaio.uuid.UUID u = new com.eaio.uuid.UUID(msb, lsb);
		// return java.util.UUID.fromString(u.toString());
		return new java.util.UUID(msb, lsb);
	}

	public long timestamptFromUUID(byte[] uuid) {
		long msb = 0;
		long lsb = 0;
		assert uuid.length == 16;
		for (int i = 0; i < 8; i++)
			msb = (msb << 8) | (uuid[i] & 0xff);
		for (int i = 8; i < 16; i++)
			lsb = (lsb << 8) | (uuid[i] & 0xff);
		long mostSigBits = msb;
		long leastSigBits = lsb;
		com.eaio.uuid.UUID u = new com.eaio.uuid.UUID(msb, lsb);
		return u.time;
	}

	/**
	 * As byte array.
	 * 
	 * @param uuid
	 *            the uuid
	 * 
	 * @return the byte[]
	 */
	public byte[] asByteArray(java.util.UUID uuid) {
		long msb = uuid.getMostSignificantBits();
		long lsb = uuid.getLeastSignificantBits();
		byte[] buffer = new byte[16];

		for (int i = 0; i < 8; i++) {
			buffer[i] = (byte) (msb >>> 8 * (7 - i));
		}
		for (int i = 8; i < 16; i++) {
			buffer[i] = (byte) (lsb >>> 8 * (7 - i));
		}

		return buffer;
	}

}

