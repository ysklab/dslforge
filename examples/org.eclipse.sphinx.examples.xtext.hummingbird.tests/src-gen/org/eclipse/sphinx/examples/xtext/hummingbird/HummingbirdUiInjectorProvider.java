/*
 * generated by Xtext
 */
package org.eclipse.sphinx.examples.xtext.hummingbird;

import org.eclipse.xtext.junit4.IInjectorProvider;

import com.google.inject.Injector;

public class HummingbirdUiInjectorProvider implements IInjectorProvider {
	
	@Override
	public Injector getInjector() {
		return org.eclipse.sphinx.examples.xtext.hummingbird.ui.internal.HummingbirdActivator.getInstance().getInjector("org.eclipse.sphinx.examples.xtext.hummingbird.Hummingbird");
	}
	
}
