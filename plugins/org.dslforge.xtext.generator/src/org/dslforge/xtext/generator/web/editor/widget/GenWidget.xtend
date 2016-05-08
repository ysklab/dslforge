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
package org.dslforge.xtext.generator.web.editor.widget

import org.dslforge.common.AbstractGenerator
import org.dslforge.common.IWebProjectFactory
import org.dslforge.xtext.generator.XtextGrammar
import org.eclipse.core.runtime.IProgressMonitor

class GenWidget extends AbstractGenerator {

	val JavaRelativePath = "/editor/widget/"
	val JsRelativePath = "/"
	var XtextGrammar grammar
	var String keywordList;

	override doGenerate(IWebProjectFactory factory, IProgressMonitor monitor) {
		grammar = factory.input as XtextGrammar
		projectName = grammar.getProjectName()
		grammarShortName = grammar.getShortName()
		basePath = grammar.getBasePath()
		keywordList = grammar.getKeywords(",", true)
		factory.generateFile("src-gen/"+ basePath + JavaRelativePath, grammarShortName + ".java", toJava(), monitor)
		factory.generateFile("src-js/"+ basePath + JsRelativePath, grammarShortName + ".js", toJavaScript(), monitor)
	}

	def toJava() '''
/**
 * @Generated by DSLFORGE
 */
package «projectName».editor.widget;

import java.util.ArrayList;
import java.util.List;

import org.dslforge.styledtext.BasicText;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.rap.rwt.remote.Connection;
import org.eclipse.rap.rwt.remote.RemoteObject;
import org.eclipse.swt.widgets.Composite;

public class «grammarShortName» extends BasicText {
	
	private static final long serialVersionUID = 1L;
	
	private static final String REMOTE_TYPE = "«projectName».editor.widget.«grammarShortName»";
	
	public «grammarShortName»(Composite parent, int style) {
		super(parent, style);
	}
	
	@Override
	protected RemoteObject createRemoteObject(Connection connection) {
		return connection.createRemoteObject(REMOTE_TYPE);
	}
	
	@Override 
	protected void setupClient() {
		super.setupClient();
		List<IPath> languageResources = new ArrayList<IPath>();
		languageResources.add(new Path("src-js/«basePath»/ace/theme-eclipse.js"));
		languageResources.add(new Path("src-js/«basePath»/ace/snippets/«grammarShortName.toLowerCase».js"));		
		languageResources.add(new Path("src-js/«basePath»/ace/mode-«grammarShortName.toLowerCase».js"));
		languageResources.add(new Path("src-js/«basePath»/ace/worker-«grammarShortName.toLowerCase».js"));
		languageResources.add(new Path("src-js/«basePath»/parser/antlr-all-min.js"));
		languageResources.add(new Path("src-js/«basePath»/parser/«grammarShortName»Parser.js"));
		languageResources.add(new Path("src-js/«basePath»/parser/«grammarShortName»Lexer.js"));
		registerJsResources(languageResources, getClassLoader());
		loadJsResources(languageResources);
	}

	@Override
	protected ClassLoader getClassLoader() {
		ClassLoader classLoader = «grammarShortName».class.getClassLoader();
		return classLoader;
	}
}
'''

	def toJavaScript() '''
/**
 * @Generated by DSLFORGE
 */
//minify using as YUI Compressor, Google Closure Compiler, or JSMin. 
(function() {
	rap.registerTypeHandler("«projectName».editor.widget.«grammarShortName»", {
		factory : function(properties) {
			return new «projectName».editor.widget.«grammarShortName»(properties);
		},
		destructor : "destroy",	 
		properties : [ "url", "text", "editable", "status", "annotations", "scope", "proposals", "font", "dirty", "markers", "background"],
		events : ["Modify", "TextChanged", "Save", "FocusIn", "FocusOut", "Selection", "CaretEvent", "ContentAssist"],
		methods : ["addMarker", "insertText", "removeText", "setProposals"]
	});

	rwt.qx.Class.define("«projectName».editor.widget.«grammarShortName»", {
		extend :org.dslforge.styledtext.BasicText,
		construct : function(properties) {
			this.base(arguments, properties);
		},
		members : {
		
			setScope : function(scope) {
				this.base(arguments, scope);
			},
		
			onCompletionRequest : function(pos, prefix, callback) {
				if (this.isFocused) {
					var remoteObject = rap.getRemoteObject(this);
					if (remoteObject) {
						remoteObject.call("getProposals", { value : this.editor.getValue(), pos : pos, prefix : prefix});
					}	
					var proposals = this.proposals==null?[":"]:this.proposals;		
			        var wordList = Object.keys(proposals);
			        callback(null, wordList.map(function(word) {
			            return {
			            	iconClass: " " + typeToIcon(proposals[word].split(":")[1]),
			                name: word,
			                value: proposals[word].split(":")[0],
			                score: 1,
			                meta: "[" + proposals[word].split(":")[1] + "]"
			            };
			        }));	
				}
			},
			
			setProposals : function(proposals) {
				this.proposals = proposals;	
			},
			
			createEditor : function() {
				var basePath = 'rwt-resources/src-js/org/dslforge/styledtext/ace';
				ace.require("ace/config").set("basePath", basePath);
				var workerPath = 'rwt-resources/src-js/«basePath»/ace';
				ace.require("ace/config").set("workerPath", workerPath);
				var themePath = 'rwt-resources/src-js/«basePath»/ace';
				ace.require("ace/config").set("themePath", themePath);
				var editor = this.editor = ace.edit(this.element);
				var editable = this.editable;				
				if (editor != null) {

					//Set the Id of this editor
					var guid = this._url;
					
					//Set language mode
					editor.getSession().setMode("ace/mode/«grammarShortName.toLowerCase»");	

					//Set theme
					editor.setTheme("ace/theme/eclipse");	

					//Default settings
					editor.getSession().setUseWrapMode(true);
				    editor.getSession().setTabSize(4);
				    editor.getSession().setUseSoftTabs(true);
					editor.getSession().getUndoManager().reset();
					editor.setShowPrintMargin(false);		 
					editor.setReadOnly(!editable);		
					editor.$blockScrolling = Infinity;
					
					//Load content assist module
					this.langTools = ace.require("ace/ext/language_tools");
					
					//Initialize the global index
					if (this._scope==null) 
						this._scope=[];
					
					//Initialize the completion proposals
					if (this.proposals==null) 
						this.proposals=[":"];
					
					var self = this;
					this.globalScope = {	
						getCompletions: function(editor, session, pos, prefix, callback) {
							self.onCompletionRequest(pos, prefix, callback);	
						},
						getDocTooltip: function(item) {
						    item.docHTML = ["<b>", item.caption, "</b>", 
						                    "<hr></hr>", 
						                    item.meta.substring(1,item.meta.length-1)
						                    ].join("");
						}
					}
					
					//Add completer and enable content assist
					if (!this.useCompleter)
						this.langTools.setCompleters([]);
					this.langTools.addCompleter(this.globalScope);
					editor.setOptions({
					    enableBasicAutocompletion: true,
					    enableSnippets: true
					});	
					this.completers = editor.completers;		
	
					//Add documentation hover
					var TokenTooltip = ace.require("ace/ext/tooltip").TokenTooltip;	
					editor.tokenTooltip = new TokenTooltip(editor);		 	

				 	//Initialize the index
				 	index = this._scope;

				 	//Initialize the completion proposals
				 	proposals = this.proposals;
				 	
					//Handle the global index
				 	if (this.useSharedWorker) {
						if (typeof SharedWorker == 'undefined') {	
							alert("Your browser does not support JavaScript shared workers.");
						} else {
							//Compute worker's http URL
							var filePath = 'rwt-resources/src-js/org/dslforge/styledtext/global-index.js';
							var httpURL = computeWorkerPath(filePath);
							var worker = this.worker = new SharedWorker(httpURL);		
							editor.on("change", function(event) {					        
								worker.port.postMessage({
									message: editor.getValue(), 
							        guid: guid, 
							        index: index
							    });
						    });
							worker.port.onmessage = function(e) {
							 	//update the index reference
							 	index = e.data.index;
						    };	

						}	
				 	}

				 	//On focus get event
					editor.on("focus", function() {
				 		self.onFocus();
				 	});
					
					//On focus lost event
				 	editor.on("blur", function() {
				 		self.onBlur();
				 	});
				 	
				 	//On input event
				 	editor.on("input", function() {
						if (!editor.getSession().getUndoManager().isClean())
							self.onModify();
				 	});
				 	
				 	//On mouse down event
				 	editor.on("mousedown", function() { 
				 	    // Store the Row/column values 
				 	}) 
				 	
				 	//On cursor move event
				 	editor.getSession().getSelection().on('changeCursor', function() { 
				 	    if (editor.$mouseHandler.isMousePressed)  {
				 	      // the cursor changed using the mouse
				 	    }
				 	    // the cursor changed
				 	    self.onChangeCursor();
				 	});
				 	editor.getSession().on('changeCursor', function() { 
				 	    if (editor.$mouseHandler.isMousePressed)  {
				 	      // remove last stored values 
				 	     console.log("remove last stored values");
				 	    }
				 	    // Store the Row/column values 
				 	    console.log("store the row/column values");
				 	}); 
				 	
				 	//On text change event
					editor.on("change", function(event) {					        
						// customize
			        });	
					
					//Bind keyboard shorcuts
					editor.commands.addCommand({
						name: 'saveFile',
						bindKey: {
						win: 'Ctrl-S',
						mac: 'Command-S',
						sender: 'editor|cli'
						},
						exec: function(env, args, request) {
							self.onSave();
						}
					});
					
					//Done
			        this.onReady();
				}
			},
		}
	});
	
	var computeWorkerPath = function (path) {
        path = path.replace(/^[a-z]+:\/\/[^\/]+/, "");
        path = location.protocol + "//" + location.host
            + (path.charAt(0) == "/" ? "" : location.pathname.replace(/\/[^\/]*$/, ""))
            + "/" + path.replace(/^[\/]+/, "");
        return path;
    };
    
	var typeToIcon = function(type) {
		var cls = "ace-";
		var suffix;
		if (type == "?") suffix = "unknown";
		else if (type == "keyword") suffix = type;
		else if (type == "identifier") suffix = type;
		else if (type == "number" || type == "string" || type == "bool") suffix = type;
		else if (/^fn\(/.test(type)) suffix = "fn";
		else if (/^\[/.test(type)) suffix = "array";
		else suffix = "object";
		return cls + "completion " + cls + "completion-" + suffix;
	};
	
}());
'''
}
