/*
   mj_appinit.js
*/

var applicationInit = function(){
	//try {
	    mmMap = new MindMap();
	    //***********************************************************************************
		//		mmMap Initialization
		//***********************************************************************************
	    mmMap.defaultMapURL = CONFIG.blankMapURL;
	    mmMap.libs = ["base", "utils"];
	    mmMap.DOMNode = "mmwc";
	    mmMap.ui.flashWMode  				= 'transparent';
	    //mmMap.ui.flashNotAvailableURL
	    //mmMap.ui.flashInsufficientVersionURL
	    mmMap.ui.toolBar  					= false;
	    mmMap.ui.taskPane 					= false;
	    mmMap.ui.controlBar 				= false;
	    mmMap.ui.statusBar                  = true;	
	    mmMap.ui.contextMenuMap             = false;
	    mmMap.ui.contextMenuTopic           = false;
	    mmMap.ui.contextMenuRelationship    = false;
	    mmMap.ui.contextMenuBoundary        = false;
	    mmMap.ui.captureFloatingTopics      = false;
	    mmMap.ui.disableShortcuts      		= true;
	    mmMap.ui.uiStyling                  = mmMap.mmPlayerStyle;
		
	    //***********************************************************************************
		//		mmMap general Objects management
		//***********************************************************************************
	    mmMap.setMapObjectAttribute=function(obj,key,value,uri){
	    	if(!obj.GetCustomAttributesSet) return;
	    	if(!uri) uri='default';
	    	var cas=obj.GetCustomAttributesSet(),ca=cas.FindCustomAttributes(uri)||cas.AddCustomAttributes(uri);
			ca.SetValue(key,value);
	    }
	    mmMap.getMapObjectAttribute=function(obj,key,uri){
	    	if(!obj.GetCustomAttributesSet) return;
	    	if(!uri) uri='default';
	    	var cas=obj.GetCustomAttributesSet(),ca=cas.FindCustomAttributes(uri);
			return (!!ca)?ca.GetValue(key):null;
	    }
	    mmMap.__storedObjects={};
	    mmMap.storeObject=function(obj){
	    	this.__storedObjects[obj.id]=obj;
	    }
	    mmMap.retrieveObject=function(obj){
	    	if(!obj) return null;
	    	if(typeof obj!='string') obj=obj.id;
	    	return this.__storedObjects[obj];
	    }
	    mmMap.deleteStoredObject=function(obj){
	    	if(!obj) return null;
	    	if(typeof obj!='string') obj=obj.id;
	    	delete this.__storedObjects[obj];
	    }
		mmMap.clearMap=function(){
			for(var i in this.__storedObjects){
				try{
					this.__storedObjects[i].Delete();
				} catch(e){}
			}
			this.__storedObjects={}
		}
	    mmMap.clearDirtyStoredObjects=function(){
	    	var obj,flag;
	    	for(var i in this.__storedObjects){
	    		flag=true;
	    		try{
	    			flag=mmDocument.SearchObjectById(i);
	    		} catch(e){
	    			this.deleteStoredObject(i);
	    		}
	    		if(!flag) this.deleteStoredObject(i);
	    	}
	    }
	    //***********************************************************************************
		//		mmMap Relationships management
		//***********************************************************************************
	    mmMap.retrieveRelationshipsByRelationshipId=function(id){
	    	for(var s in this.__storedObjects)	{
	    		if(this.__storedObjects[s].relationship && this.__storedObjects[s].relationship.Id==id) return this.__storedObjects[s];
	    	}
	    	return null;
	    }
	    mmMap.retrieveRelationshipsByContactId=function(id1,id2){
	    	var relationships=[]
	    	for(var s in this.__storedObjects)	{
	    		if(!!id1 && !id2){
		    		if(this.__storedObjects[s].relationship &&
		    			(this.__storedObjects[s].relationship.primaryContact__c==id1 || this.__storedObjects[s].relationship.secondaryContact__c==id1)
		    		) relationships.push(this.__storedObjects[s]);
		    	} else if(!!id1 && !!id2){
		    		if(this.__storedObjects[s].relationship &&
		    			(this.__storedObjects[s].relationship.primaryContact__c==id1 && this.__storedObjects[s].relationship.secondaryContact__c==id2)
		    		) relationships.push(this.__storedObjects[s]);	
		    	}
	    	}
	    	return relationships;
	    }
	    mmMap.retrieveRelationshipByCallout=function(obj){
	    	var so= this.retrieveCalloutAssociatedObject(obj);
			if(this.typeOf(so)=='Contact' || !so) return null;
	    	return so;
	    }
	    //***********************************************************************************
		//		mmMap Topics/Contact management
		//***********************************************************************************
	    mmMap.retrieveTopicsByRelationship=function(relObj){
	    	var c1=(this.typeOf(relObj)=='Relationship')?this.retrieveTopicByContactId(relObj.relationship.primaryContact__c):null,
	    		c2=(this.typeOf(relObj)=='Relationship')?this.retrieveTopicByContactId(relObj.relationship.secondaryContact__c):null;
	    	return [c1,c2];
	    }
	    mmMap.retrieveTopicByBoundary=function(relObj){
	    	if(this.typeOf(relObj)!='Boundary') return null;
	    	return this.retrieveTopicByContactId(relObj.boundary.Contact__c);
	    }
	    mmMap.retrieveTopicByContactId=function(id){
	    	for(var s in this.__storedObjects)	{
	    		if(this.__storedObjects[s].type=='topic' &&  this.__storedObjects[s].contact && this.__storedObjects[s].contact.Id==id) return this.__storedObjects[s];
	    	}
	    	return null;
	    }
	    mmMap.retrieveTopicByCallout=function(obj){
	    	var so= this.retrieveObjectCallout(obj);
			if(this.typeOf(so)=='Relationship' || !so) return null;
	    	return so;
	    }
	    //***********************************************************************************
		//		mmMap callout management
		//***********************************************************************************	    
	    mmMap.retrieveCalloutAssociatedObject=function(callout){
	    	if(callout.callout) return callout.relatedObject;
	    	if(callout.Contact__c=='null')return this.retrieveRelationshipsByRelationshipId(callout.Relationship__c);
	    	else return this.retrieveTopicByContactId(callout.Contact__c);
	    }
	    mmMap.retrieveObjectCallout=function(obj){
	    	if(!obj.id) return null;
	    	for(var s in this.__storedObjects)	{
	    		if(this.__storedObjects[s].isCallout && this.__storedObjects[s].relatedObject.id==obj.id) return this.__storedObjects[s]
	    	}
	    	return null;
	    }
	    mmMap.retrieveCalloutByCalloutId=function(id){
	    	for(var s in this.__storedObjects)	{
	    		if(this.__storedObjects[s].callout && this.__storedObjects[s].callout.Id==id) return this.__storedObjects[s];
	    	}
	    	return null;
	    }
	    //***********************************************************************************
		//		mmMap boundary management
		//***********************************************************************************
	    mmMap.retrieveBoundaryByBoundaryId=function(id){
	    	for(var s in this.__storedObjects)	{
	    		if(this.__storedObjects[s].boundary && this.__storedObjects[s].boundary.Id==id) return this.__storedObjects[s];
	    	}
	    	return null;
	    }
	    //***********************************************************************************
		//
		//		mmMap.typeOf(object)
		//			returns null,Callout,Contact,Relationship,Boundary
		//
		//***********************************************************************************
		mmMap.typeOf=function(obj){
			if(!obj) return null;
			if(obj.type=="topic") {
				return(!!obj.isCallout)?'Callout':((!obj.contact)?null:'Contact');
			} else if(obj.type=="relationship"){
				return 'Relationship';
			} else if(obj.boundary){
				return 'Boundary';
			}
			return null;
		}
	    //***********************************************************************************
		//		mmMap System functionalities
		//***********************************************************************************
	    mmMap.setFocus=function(obj){
	    	mmw.focusTopic(obj.id);
	    }
	    mmMap.setSelected=function(obj){
	    	 mmw.selectObject(obj);
	    }
	    mmMap.clearSelection=function(){
	    	 mmw.clearSelection();
	    }
	    mmMap.undo=function(){
	    	 mmw.swf().unDo();
	    }
	    mmMap.redo=function(){
	    	 mmw.swf().reDo();
	    }
	    mmMap.clearEventQueue=function(immediateFlag){
	    	mmw.eventQueue = [];
	    }
	    mmMap.promptXML=function(){
	    	prompt("",mmw.swf().getMapXML());
	    }
	    //***********************************************************************************
		//		mmMap Event Listening
		//***********************************************************************************
	    mmMap.initObjectsEventListening=function(){
	    	setTimeout(function(){
				this.AddEventListener("uri:test:OnCreated", MmwEventTypes.MapObject.OnCreated, null, 
					function(time, obj, parent, cancel) {
						console.debug("Object created");
						//mmMap.clearEventQueue();
						console.debug("Object created, type is " + obj.type);
						if(obj.type=="relationship") mainController.createRelationship(obj);
						/*if(mmMap.retrieveObject(obj))  return;
						if(obj.type=="topic") mainController.createContact(obj);
						else if(obj.type=="relationship") mainController.createRelationship(obj);*/
					}
				);
				
				this.AddEventListener("uri:test:OnModified", MmwEventTypes.MapObject.OnModified, null, 
					function(time, obj, prop, subobj, cancel) {
						console.debug("Object modified prop " + prop);
						obj=mmMap.retrieveObject(obj);
						if(!!obj && prop=='Text' && obj.isCallout) {
							mmMap.clearEventQueue();
							if(obj.isCallout) mainController.updateCalloutText(obj);
						} else if (prop.indexOf("Collapsed") != -1) {
							mmMap.clearEventQueue();
							mainController.contactDrawer(obj);
						}
					}
				);
				
				this.AddEventListener("uri:test:OnDeleted", MmwEventTypes.MapObject.OnDeleted, null, 
					function(time, obj, parent, cancel) {
						console.debug("Object deleted");
						//obj=mmMap.retrieveObject(obj);
						//if(!obj) return;
						//mainController.deleteObject(obj);
					}
				);
				
				this.AddEventListener("uri:test:OnMoved", MmwEventTypes.MapObject.OnMoved, null, 
					function(time, obj, from, to, cancel) {
						console.debug("Object moved");
						obj=mmMap.retrieveObject(obj);
						/*if(!to){ //floating topic undo
							mmMap.undo();
							mmMap.clearEventQueue();
							return;
						}*/
						to=mmMap.retrieveObject(to);
						if(!obj) return;
						var sObj=(!obj)?'':"type is " + obj.type;
						var sTo=(!to)?'nowhere': to.GetText();
						console.debug("Object moved," + sObj + ' to '+ sTo);
						cancel= mainController.moveContact(obj,from,to);
					}
				);
				
				this.AddEventListener("uri:test:OnClicked", MmwEventTypes.MapObject.OnClicked, null, function(obj) {
					console.debug("Object clicked");
					obj=mmMap.retrieveObject(obj);
					utilities.manageSelectedObject(obj);
				});
				
				this.AddEventListener("uri:test:OnDialogOpen", MmwEventTypes.UI.OnDialogOpen, null, function(obj) {
					toolBar.setVisible(false);
				});
				
				this.AddEventListener("uri:test:OnDialogClose", MmwEventTypes.UI.OnDialogClose, { id:'client.mindjet.views.print::PrintPreview'}, function(obj) {
					toolBar.setVisible(true);
				});
				mmMap.clearEventQueue();
			}.createClosure(this),
			500);
	    }
	    //***********************************************************************************
		//		mmMap Map Markers
		//***********************************************************************************
	    mmMap.createTextMarkerGroup=function(name){
	    	var mg=this.getTextMarkerGroup(name)||mmDocument.GetMapMarkerGroups().AddTextMarkerGroup(name);
	    	while(mg.GetCount()>0) mg.Item(0).Delete();
			return mg;
		}
		mmMap.getTextMarkerGroup=function(name){
			var c=mmDocument.GetMapMarkerGroups().GetCount();
			for(var i=0;i<c;i++){
				if(mmDocument.GetMapMarkerGroups().Item(i).GetName()==name) return mmDocument.GetMapMarkerGroups().Item(i);
			}
			return null;
		}
		mmMap.createTextMarker=function(group,label){
			if(!mmDocument.mapMarkers) {
				mmDocument.mapMarkers={store:{},index:0};
			}
			if(!mmDocument.mapMarkers.store[group]) mmDocument.mapMarkers.store[group]={};
			if(!mmDocument.mapMarkers.store[group][label]) {
				mmDocument.mapMarkers.store[group][label]={textMarkerGroup:mmMap.createTextMarkerGroup(group+":"+label),label:(function(ns){var s='';for(var i=0;i<ns;i++) s+=' '; return '.' + s +'.';})(mmDocument.mapMarkers.index++)};
				var tmg=mmDocument.mapMarkers.store[group][label];
				tmg.textMarkerGroup.AddTextMarker(tmg.label);
			}
			return mmDocument.mapMarkers.store[group][label];
		}
		mmMap.addTextMarker=function(topic,group,label){
			var tmg=mmMap.createTextMarker(group,label);
			topic.GetTextMarkers().AddTextMarker(null,HTMLDECODE(group+":"+label));
		}
		mmMap.removeTextMarker=function(topic,group,label){
			var tmg=mmMap.createTextMarker(group,label);
			topic.GetTextMarkers().RemoveTextMarker(null,HTMLDECODE(group+":"+label));
		}
		mmMap.addIcon=function(topic,signature){
			if(!topic.iconMap) topic.iconMap={};
			if(!topic.iconMap[signature]){
				topic.iconMap[signature]=true;
				topic.GetIcons().AddCustomIconBySignature(signature);
			}
		}
		mmMap.hasIcon=function(topic,signature){
			return !(!topic.iconMap || !topic.iconMap[signature]);
		}		
		mmMap.removeIcon=function(topic,signature){
			if(!topic.iconMap) topic.iconMap={};
			if(!!topic.iconMap[signature]){
				delete topic.iconMap[signature];
				topic.GetIcons().RemoveAll();
				for(var i in topic.iconMap) topic.GetIcons().AddCustomIconBySignature(i);
			}
		}
		mmMap.mapIconMarkersSignatures={};
		mmMap.mapIconMarkers={};
		mmMap.loadIconFile=function(group,key,iconFile){
			if(!mmMap.iconGroup) mmMap.iconGroup=mmDocument.GetMapMarkerGroups().AddIconMarkerGroup("SFDCIcons");
			if(!mmMap.mapIconMarkers[group]) mmMap.mapIconMarkers[group]={};
			if(!mmMap.mapIconMarkers[group][key]) {
				if(iconFile!='') mmMap.mapIconMarkers[group][key]=mmMap.iconGroup.AddCustomIcon("SFDCIcon", CONFIG.baseURLforMapMarkersIcons + iconFile);
				else mmMap.mapIconMarkers[group][key]=null;
			}
		}
		mmMap.getIcon=function(group,key){
			if(!mmMap.mapIconMarkers[group] || !mmMap.mapIconMarkers[group][key]) return null;
			return mmMap.mapIconMarkers[group][key];
		}
	    //***********************************************************************************
		//		mmMap Text Markers
		//***********************************************************************************
		mmMap.print=function(selected){
			var framed=false;
			try{
				framed = window.parent!=window;
			} catch(e){
				framed=true;
			}
			if(getPageSize().windowHeight<=600) framed=true;
			detailOverlay.hide();
			if(selected){
				var topics=mmDocument.GetSelectedTopics(),topic;
				if(topics.length>0) topic=mmMap.retrieveObject(topics[0]);
				if(topic && framed) mmDocument.PrintNoPreview(topic);
				else if(topic) mmDocument.Print(topic);
			} else if(!framed) mmDocument.Print();
			else mmDocument.PrintNoPreview();
		}
		mmMap.addAction=function(obj,fn,interval){
			if(!obj) obj='central';
			if(typeof obj!='string') obj=obj.id;
			window.actionPoller.addAction(obj,fn,interval);
		}
		mmMap.RemoveFilters=function(){
			this.filtered=false;
			mmDocument.RemoveFilters();
		}
		mmMap.FilterObjects=function(f,a,b){
			this.filtered=true;
			mmDocument.FilterObjects(f,a,b);
		}
		mmMap.isFiltered=function(){
			return !!this.filtered;
		}
	    mmMap.appCustomStart = function() {
	    	//******************************************************************
	    	//	Flash overlapping patch
	    	//******************************************************************
	    	/*setTimeout(
		    	function(){
		    		//debugger
		    		var ems = (!Ext.isIE)?document.embeds:document.getElementsByTagName('object');
					for (var  i = 0, em; em = ems[i]; i++) {
						if(!Ext.isIE) em.setAttribute('wmode', 'transparent');
						else {
							var bFound=false;
							for(var i=0;i<em.childNodes.length; i++){
								if(em.childNodes[i].name=="WMode"){
									em.childNodes[i].value='transparent';
									bFound=true;
									break;
								}
							}
							if(!bFound){
								var p=document.createElement('PARAM');
								p.value='transparent';
								p.name='wmode';
								em.appendChild(p);
							}
						}
						var nx = em.nextSibling, pn = em.parentNode;
						pn.removeChild(em);
						pn.insertBefore(em, nx);
					}
		
				},100);*/
	    	//******************************************************************
	    	//	Map Opening Listener
	    	//******************************************************************
    		var callback=function(time, obj, parent, cancel) {
		    	//******************************************************************
		    	//	Patches
		    	//******************************************************************
			    mmw.topic.SetPosition = function(x, y) { mmw.swf().applyDeltas([{ id:this.id , path: 'Offset_CX', value:x }, { id:this.id , path: 'Offset_CY', value:y }]); }
		    	
				mmw.topic.CreateBoundary = function(shape, lineColor, fillColor) {
					var newID = mmw.swf().addBoundary(this.id);
					var newItem = begetObject(mmw.boundary);
					newItem.id = newID;
					if (shape) {
						newItem.GetFormatting().SetShape(shape);
					}
					if (lineColor) {
						newItem.GetFormatting().SetLineColor(lineColor);
					}
					if (fillColor) {
						newItem.GetFormatting().SetFillColor(fillColor);
					}
					return newItem;
				}
				
				mmw.disableFeature(MmwEnumerations.MmwEnablableFeature.mmMindjetMenu);
				mmw.disableFeature(MmwEnumerations.MmwEnablableFeature.mmTrialButton);
				mmw.disableFeature(MmwEnumerations.MmwEnablableFeature.mmStatusbarPrintIcon);
				mmw.disableFeature(MmwEnumerations.MmwEnablableFeature.mmMultipleSelect);
				
				mmw.commands.DisableAllShortcuts();//keyboard shortcuts
				/*mmw.processEvents= function() {
					mmw.eventsStarted = true;
					while(mmw.eventQueue.length > 0) {
						try {
							var evt = mmw.eventQueue.shift();
							for (var i=0; i<mmw.listeners.length; i++) {
								var listener = mmw.listeners[i];
								if (listener) {
									var filter = listener.filter;
									if (filter===null || filter(evt)) {
										if (evt.type != MmwEnumerations.MmwChangeType.mmDelete) {
											var object = mmw.apiObjectForId(evt.id);
										}
										try { listener.callback(evt, object); } catch (err) {}
									}
								} // if listener
							} // for listener
						} catch (err) {
							mmw.log(err);
						}
					} //while/eventqueue
					setTimeout("mmw.processEvents()", 100);
				}*/
		    	//******************************************************************
		    	//	Add ons to the config object
		    	//******************************************************************
		    	CONFIG.alternateTopicShape=MmwEnumerations.MmwTopicShape.mmTopicShapeRoundedRectangle;  //mmTopicShapeNone
		    	CONFIG.defaultTopicShape=MmwEnumerations.MmwTopicShape.mmTopicShapeRectangle;
				CONFIG.defaultBoundaryShape=MmwEnumerations.MmwBoundaryShape.mmBoundaryShapeCurvedRectangle;
				CONFIG.defaultCalloutShape=MmwEnumerations.MmwTopicShape.mmTopicShapeRoundedRectangleBalloon;
				CONFIG.alternateRelationshipLineStyle=MmwEnumerations.MmwLineDashStyle.mmLineStyleRoundDot;
				CONFIG.relationshipLineStyle=MmwEnumerations.MmwLineDashStyle.mmLineStyleSolid;
				
		    	//******************************************************************
		    	//	Global Variables Initialization
		    	//******************************************************************
		    	mmDocument=this.GetCurrentDocument();
		    	mmCentralTopic=mmDocument.GetCentralTopic();
		    	//mmCentralTopic.SetTextReadOnly(true);
		    	mmMap.isLoadingInitialMap=true;
		    	editIframe=get$('editIframe');
		    	mmContainer=Ext.get('mmwc');
		    	
		    	
		    	utilities.initContactRecordTypesCombo();
		    	utilities.initToolbarAddOns();
		    	utilities.rebuildOpportunitiesRolesMenues(true);
		    	utilities.initDetailOverlay();
				
				mainController.startContactDrawer(true);
				
			}.createClosure(this);
			//var filter=function(evt) { return evt.type == 'app_start'; };
			//var listener={filter:filter,callback:callback,uri:'app_start'};
			//mmw.addListener(listener);
			var MapOpenedEventName='OnOpened';
			try{ MapOpenedEventName=MmwEventTypes.Document.OnMapOpened; }catch(e){}
			this.AddEventListener("uri:" + MapOpenedEventName,
			    MapOpenedEventName,
			    null,
				callback
			);
		};
	    mmMap.callOnLoad = mmMap.launch;
	    mmMap.load();
		utilities.initToolbar();    

	/*}   
	catch(err)
	{
	    alert(err);
		debugger
	}*/
}




