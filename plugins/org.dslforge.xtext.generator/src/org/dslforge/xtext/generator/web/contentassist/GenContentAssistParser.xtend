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
package org.dslforge.xtext.generator.web.contentassist

import com.google.common.collect.Maps
import java.io.File
import java.util.Map
import org.dslforge.common.AbstractGenerator
import org.dslforge.common.IWebProjectFactory
import org.dslforge.xtext.generator.XtextGrammar
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.mwe.core.WorkflowContext
import org.eclipse.emf.mwe.core.issues.IssuesImpl
import org.eclipse.emf.mwe.core.monitor.NullProgressMonitor
import org.eclipse.xpand2.output.Outlet
import org.eclipse.xtend.expression.Variable
import org.eclipse.xtext.generator.Generator
import org.eclipse.xtext.generator.LanguageConfig
import org.eclipse.xtext.generator.Naming
import org.eclipse.xtext.generator.grammarAccess.GrammarAccessFragment
import org.eclipse.xtext.generator.parser.antlr.AntlrOptions
import org.eclipse.xtext.generator.parser.antlr.XtextAntlrUiGeneratorFragment
import org.eclipse.xtext.resource.XtextResourceSet

/**
 * The Xtext generator is invoked with a minimal set of fragments necessary 
 * to generate the content assist artifacts in the web plugin.
 */
class GenContentAssistParser extends AbstractGenerator {

	var XtextGrammar wrapped
	var String workspaceRoot;

	override doGenerate(IWebProjectFactory factory, IProgressMonitor monitor) {
		wrapped = factory.input as XtextGrammar
		projectName = wrapped.getProjectName()
		grammarShortName = wrapped.getShortName()
		basePath = wrapped.getBasePath()
		workspaceRoot = ResourcesPlugin.workspace.root.location.toString
		
		// initialize global variables
		var Map<String, Variable> globalVars = Maps.newHashMap();
		val Naming naming = new Naming()
		naming.hasIde = false;
		naming.hasUI = true;
		naming.grammarId = wrapped.grammar.name;
		naming.setProjectNameUi(getProjectNameUi());
		naming.setUiBasePackage(getProjectNameUi());
		
		// we disable the generation of the runtime plugin, 
		// as we give priority to the Xtext workflow
		// naming.setProjectNameRt(getProjectNameRt());
		naming.setProjectNameIde(null);
		naming.setProjectNameUi(getProjectNameUi());
		naming.setUiBasePackage(getProjectNameUi());
		naming.setActivatorName(projectNameUi + ".internal." + "Activator");
		naming.setFileHeader("/*Hacked by DSL Forge*/");
		naming.setHasUI(true);
		naming.setHasIde(false);

		// the language config
		val languageConfig = new LanguageConfig()
		languageConfig.uri = wrapped.grammar.eResource.URI.toString //set the grammar handle
		languageConfig.setForcedResourceSet(new XtextResourceSet());
		languageConfig.fileExtensions = wrapped.getFileExtension();
		languageConfig.addFragment(new GrammarAccessFragment)
		languageConfig.addFragment(new WebContentAssistFragment(wrapped.grammar))
		languageConfig.addFragment(new XtextAntlrUiGeneratorFragment)
		languageConfig.registerNaming(naming);

		val AntlrOptions antlrOptions = new AntlrOptions();
		antlrOptions.setBacktrack(false);
		antlrOptions.setMemoize(false);

		var Generator xtextGenerator = new Generator()
		xtextGenerator.pathUiProject = pathUiProject
		xtextGenerator.projectNameRt = wrapped.getDslProjectName()
		xtextGenerator.projectNameUi = projectNameUi
		xtextGenerator.activator = projectNameUi + ".internal." + "Activator"
		xtextGenerator.encoding = "UTF-8"
		xtextGenerator.addLanguage(languageConfig)
		xtextGenerator.naming = naming
		xtextGenerator.mergeManifest = false;
		globalVars.put(Naming.GLOBAL_VAR_NAME, new Variable(Naming.GLOBAL_VAR_NAME, naming));

		try {
			// invoke the workflow programmatically
			val IssuesImpl issuesImpl = new IssuesImpl();
			xtextGenerator.invoke(new WorkflowContext() {

				override get(String slotName) {
					throw new UnsupportedOperationException("Couldn't get workflow slot name: grammar " + wrapped.grammar.name);
				}

				override getSlotNames() {
					throw new UnsupportedOperationException("Couldn't get workflow slot names: grammar " + wrapped.grammar.name);
				}

				override set(String slotName, Object value) {
					throw new UnsupportedOperationException("Couldn't set workflow slot name: grammar" + wrapped.grammar.name);
				}

			}, new NullProgressMonitor(), issuesImpl);
			//remove the unused artifacts.
			deleteFile(
				projectName + "/" + "src-gen" + "/" + basePath + "/" + "Abstract" + grammarShortName.toFirstUpper +
					"UiModule.java")
					deleteFile(projectName + "/" + "src" + "/" + basePath + "/" + grammarShortName.toFirstUpper +
						"UiModule.java")

				} catch (Exception ex) {
					throw new UnsupportedOperationException("Couldn't execute workflow of grammar " + wrapped.grammar.name);
				}
			}

			def deleteFile(String filePath) {
				val String pathname = workspaceRoot + "/" + filePath;
				val File file = new File(pathname);
				if (file.exists()) {
					if (!file.delete()) {
						throw new IllegalStateException("couldn't delete file '" + pathname);
					}
				}
			}

			def String getPathIdeProject() {
				return null;
			}

			def String getProjectNameUi() {
				return projectName;
			}

			def String getProjectNameRt() {
				return wrapped.getDslProjectName();
			}

			def String getSrcGenPath() {
				return "/src-gen"
			}

			def String getSrcPath() {
				return "/src"
			}

			def String getPathUiProject() {
				return workspaceRoot + "/" + projectName;
			}

			def getPathRtProject() {
				return workspaceRoot + "/" + wrapped.getDslProjectName();
			}

			def String getEncoding() {
				return "UTF-8";
			}

			def Outlet createOutlet(boolean append, String encoding, String name, boolean overwrite, String path) {
				val Outlet outlet = new Outlet(append, encoding, name, overwrite, path);
				return outlet;
			}
		}
		