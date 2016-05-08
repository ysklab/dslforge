/**
 * <copyright>
 *
 * Copyright (c) 2015 PlugBee. All rights reserved.
 * 
 * This program and the accompanying materials are made available 
 * under the terms of the Eclipse Public License v1.0 which 
 * accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Amine Lajmi - Initial API and implementation
 *
 * </copyright>
 */
package org.dslforge.xtext.generator.web.editor

import org.dslforge.common.AbstractGenerator
import org.dslforge.common.IWebProjectFactory
import org.dslforge.xtext.generator.XtextGrammar
import org.eclipse.core.runtime.IProgressMonitor

class GenActionBarContributor extends AbstractGenerator{
	
	var XtextGrammar grammar
	
	new() {
		relativePath = "/editor/"	
	}
	
	override  doGenerate(IWebProjectFactory factory, IProgressMonitor monitor) {
		grammar = factory.input as XtextGrammar
		projectName=grammar.getProjectName()
		grammarShortName= grammar.getShortName()
		basePath=grammar.getBasePath()
		factory.generateFile("src-gen/" + basePath + relativePath, "Abstract" + grammarShortName + "ActionBarContributor.java", toJavaSrcGen(), monitor)
		factory.generateFile("src/" + basePath + relativePath, grammarShortName + "ActionBarContributor.java", toJavaSrc(), monitor)
	}
	
	def toJavaSrcGen()'''
/**
 * @Generated by DSLFORGE
 */
package «projectName».editor;

import org.dslforge.texteditor.BasicTextEditorContributor;

public abstract class Abstract«grammarShortName»ActionBarContributor extends BasicTextEditorContributor {

	public Abstract«grammarShortName»ActionBarContributor() {
		super();
	}
}
'''
	def toJavaSrc()'''
/**
 * @Generated by DSLFORGE
 */
package «projectName».editor;

public class «grammarShortName»ActionBarContributor extends Abstract«grammarShortName»ActionBarContributor {

	public «grammarShortName»ActionBarContributor() {
		super();
	}
}
'''
}