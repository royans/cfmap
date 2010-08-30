package com.ingenuity.cfmap;

import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class Messages {

	// CLASS MEMBERS ..................................................

	private static final String BUNDLE_NAME = "messages"; //$NON-NLS-1$

	private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

	// CONSTRUCTORS ...................................................
	private Messages() {
	}

	// METHODS ........................................................

	public static String getString(String key) {
		try {
			// System.out.println("found - "+
			// RESOURCE_BUNDLE.getString(key)+": "+key);
			return RESOURCE_BUNDLE.getString(key);
		} catch (MissingResourceException e) {
			System.out.println("resource not found: " + key);
			return '!' + key + '!';
			// return null;
		}
	} // end method getString()

}
