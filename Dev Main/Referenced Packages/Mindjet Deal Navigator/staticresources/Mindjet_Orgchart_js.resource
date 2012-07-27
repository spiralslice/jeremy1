// Copyright 1994-2009 Mindjet LLC, San Francisco, CA USA. All rights reserved.
//
// This software is furnished under a license  and may be  used and  copied
// only in  accordance of the  terms of such license and with the inclusion
// of the above copyright note.   This software or any other copies thereof
// may not be provided or otherwise made available to any other person.  No
// title to and ownership of the software is hereby transferred.
//
// The information in this software is subject to change without notice and
// should not be construed as a commitment by Mindjet LLC.
//


//***********************************************************************************
//		Salesforce Sidebar Opener Fix
//***********************************************************************************

var sbOld=Sidebar;Sidebar=function(sd,ec,ip){try{if(!Sidebar.prototype.idt) Sidebar.prototype.idt={ec:ec, ip:ip}; else Sidebar.prototype.oc.call(this,sd,Sidebar.prototype.idt.ec,Sidebar.prototype.idt.ip);}catch(e){}};Sidebar.prototype=sbOld.prototype;Sidebar.prototype.oc=sbOld;
Sidebar.prototype._sizeToBody=Sidebar.prototype.sizeToBody;
Sidebar.prototype.sizeToBody=function(){try{this._sizeToBody();}catch(e){}}
Sidebar.prototype.pin=function (noCookie) {
    if (this.pinned) {
        this.pinned = false;
        this.sizeToBody();
        this.mover.jumpOut();
        if (!noCookie) {
            this.setSidebarCookie("0");
        }
    } else {
        this.pinned = true;
        this.sizeToBody();
        this.mover.jumpIn();
        if (!noCookie) {
            this.setSidebarCookie("1");
        }
    }
    this.setTitleAndClass();
}
//***********************************************************************************
//		Multiple Instances Fix
//***********************************************************************************
try{
	if(window.parent && window.parent!=window && !!window.parent.mainController) {
		alert('Unable to open Org Chart.\nA different instance of the application is running in the background.');
		window.parent.mainController.displayForm(false);
	}
} catch(e){}

//***********************************************************************************
//		No Console Fix
//***********************************************************************************
if(!Ext.isGecko3 || typeof(console)=='undefined'){
	console={
		debug:function(msg){
			status=msg;
		}
	}
}
//***********************************************************************************
//		Main Controller
//***********************************************************************************
var mainController={
	contactPoller:function(CallBack,ResponseObject){
		var StartNewRequest=false;
		if(!ResponseObject) {
			ResponseObject={ContactPolledCount:0};
			StartNewRequest=true;
		}
		requestHandler("getObjectsMapPage",
			{ StartNewRequest:StartNewRequest },
			function(CallBack,ResponseObject,response){
				ResponseObject.ContactPolledCount+=parseInt(response.ResultSize);
				Ext.Msg.wait("","Loading " + parseInt(ResponseObject.ContactPolledCount) + " contacts of " + parseInt(response.ContactCount) + "");
				try{
					for(var i in response) {
						if(!ResponseObject[i]) ResponseObject[i]=response[i];
						else {
							for(var k in response[i]){
								if(typeof response[i][k]!='function') ResponseObject[i][k]=response[i][k];	
							}
						}
					}
					if(response.HasNext=='true'){
						setTimeout(mainController.contactPoller.createClosure(null,CallBack,ResponseObject),100);
						return;
					} else {
						Ext.Msg.hide();
						if(CallBack) CallBack(ResponseObject);
					}
				}catch(e){
					console.debug(e);
				}
			}.createClosure(null,CallBack,ResponseObject)
		);
	},
	loadInitialMap:function(withInit){
		Ext.Msg.wait("","Loading...");
        requestHandler("getAccountInfo",
			null,
			function(withInit,response){
				var f=function(){
					Ext.Msg.wait("","Loading " + response.ContactCount + " contacts");
					account=response.Account;
					utilities.setCentralTopicText();
					if(!!response.FeaturedContact) {
						featuredContact=response.FeaturedContact;
					}
					if(!!response.FeaturedOpportunity){
						featuredOpportunity=response.FeaturedOpportunity;
					}
					if(!!withInit) {
						utilities.initFromAdminObject(response);
						var MapObjectConstraints=mmCentralTopic.GetMapObjectConstraints();
						MapObjectConstraints.SetConstrainedChildTypesActivated(true);
						MapObjectConstraints.RemoveAllTypes();
						MapObjectConstraints.AddAllowedChildTypes(['isUpdateableReportsTo']);
						//mmCentralTopic.GetFormatting().SetSubtopicConnectionStyle( MmwEnumerations.MmwSubtopicsConnectionStyle.mmNoLine );
						//ReadOnly
						MapObjectConstraints.EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmTextReadOnly);
					} else {
						featuredContact=null;
						featuredOpportunity=null;
					}
					mmCentralTopic.GetSubTopicLayout().SetGrowthDirection(MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionOrgChart);
					mainController.contactPoller(
						function(withInit,ContactCount,response){
							Ext.Msg.wait("","Rendering...");
							var reportsToMap=utilities.parseContactMap(response.Contacts);
							var f2=function(response,withInit,featuredContact,reportsToMap,ContactCount){
								utilities.assignOpportunitiesContactRoles(response,withInit);
								mmMap.initObjectsEventListening();
								mmMap.clearEventQueue();
								if(!!withInit) {
									window.startMainPoller();
									if(!!featuredContact && ContactCount>1) {
										setTimeout(
											function(){
												utilities.setDetailContent(mmMap.retrieveTopicByContactId(featuredContact.Id));
												mmMap.FilterObjects(function(obj){
													if (!arguments.callee.found) {
														obj = mmMap.retrieveObject(obj);
														if (!!obj && !!obj.contact && !!featuredContact && featuredContact.Id == obj.contact.Id) {
															setTimeout(function(topic){
																mmMap.setFocus(topic);
																mmMap.setSelected(topic);
																topic.SetLevelOfDetail(1000);
															}.createClosure(null, obj), 1000);
															arguments.callee.found=true;
															return true;
														}
													} 
													return false;
												},MmwEnumerations.MmwFilter.mmHideOthers,MmwEnumerations.MmwFilter.mmShowSubTopics);
											},2000);
									}
								} 
								setTimeout(function(){utilities.manageSelectedObject(mmCentralTopic);},100);
								setTimeout(function(){
									Ext.Msg.hide();
								},2000);
							}.createClosure(null,response,withInit,featuredContact,reportsToMap,ContactCount);
							var f1=function(response){
								for(var i in response.Relationships){
									utilities.createRelationshipFromObject(response.Relationships[i]);
								}
								for(var i in response.Callouts){
									utilities.createCalloutFromObject(response.Callouts[i]);
								}
								for(var i in response.Boundaries){
									utilities.createBoundaryFromObject(response.Boundaries[i]);
								}
							}.createClosure(null,response);
							
							
							if(!!reportsToMap['central']) {
								utilities.addSubLevelContactToMapCaller(mmCentralTopic,reportsToMap['central'],reportsToMap,response.ContactsSecurity,function(){f1();f2();},ContactCount);
							} else f2();
						}.createClosure(null,withInit,response.ContactCount)
					);
				}.createClosure(null,withInit,response);
				if(response.OriginalContactCount!=response.ContactCount && withInit){
					Ext.Msg.alert("Maximum Capability Reached","Only " + response.ContactCount + " of " + response.OriginalContactCount + " Contacts will be displayed", f);
				} else {
					f();
				}	
			}.createClosure(null,withInit),
			function(errorMessage){
				Ext.Msg.show({
				   title:'Server Error',
				   msg: errorMessage,
				   buttons: Ext.Msg.OK,
				   icon: Ext.MessageBox.WARNING
				});
			}
		)
	},
	pollNewContact:function(callBack,timeoutCallback,timeout,timeoutInterval){
		if(!timeout) timeout=1000000;
		if(!timeoutInterval) timeoutInterval=500;
		var f=function(lastUserCreatedContact,timeout,timeoutInterval,callback,timeoutCallback,response){
			if(!!response.Contact && !lastUserCreatedContact){
				arguments.callee.delegateArguments[0]=response.Contact;
			} else if(!!response.Contact && response.Contact.Id!=lastUserCreatedContact.Id){
				callback(response);
				return;
			} else if(timeout<=0){
				timeoutCallback();
				return;
			}
			arguments.callee.delegateArguments[2]-=timeoutInterval;	//decreasing the timeout value
			setTimeout(function(fn){ requestHandler("getLastCreatedContact",null,fn)}.createClosure(null,arguments.callee),timeoutInterval);
		}.createClosure(null,null,timeout,timeoutInterval,callback,timeoutCallback)();
	},
	pollEditContact:function(callBack){
		if(!timeout) timeout=1000000;
		if(!timeoutInterval) timeoutInterval=500;
		var f=function(lastUserModifiedContact,timeout,timeoutInterval,callback,timeoutCallback,response){
			if(!!response.Contact && !lastUserModifiedContact){
				arguments.callee.delegateArguments[0]=response.Contact;
			} else if(!!response.Contact && response.Contact.Id==lastUserModifiedContact.Id && response.Contact.lastmodifieddate!=lastUserModifiedContact.lastmodifieddate){
				callback(response);
				return;
			} else if(timeout<=0 || (!!response.Contact && response.Contact.Id!=lastUserModifiedContact.Id)){
				timeoutCallback();
				return;
			}
			arguments.callee.delegateArguments[2]-=timeoutInterval;	//decreasing the timeout value
			setTimeout(function(fn){ requestHandler("getLastModifiedContact",null,fn)}.createClosure(null,arguments.callee),timeoutInterval);
		}.createClosure(null,null,timeout,timeoutInterval,callback,timeoutCallback)();
	},
	editContact:function(){
		var topics=mmDocument.GetSelectedTopics(),topic=(topics.length<1 || !mmMap.retrieveObject(topics[0]))?null:mmMap.retrieveObject(topics[0]);
		mainController.displayForm(true,CONFIG.baseURLForEdit.split('{Id}').join(topic.contact.Id));
		mmMap.lastUserModifiedContact=topic.contact;
	},
	createNewContact:function(){
		var f=function(recordType){
			var topics=mmDocument.GetSelectedTopics(),parentTopic=(topics.length<1 || !mmMap.retrieveObject(topics[0]))?null:mmMap.retrieveObject(topics[0]);
			var reportsToData="",recordTypeData="";
			if(mmMap.typeOf(parentTopic)!='Contact') parentTopic=null;
			if(!!parentTopic){
				var nm="";
				if(parentTopic.contact.FirstName!='null') nm+=parentTopic.contact.FirstName;
				if(parentTopic.contact.FirstName!='null' && parentTopic.contact.LastName!='null') nm+=' ';
				if(parentTopic.contact.LastName!='null') nm+=parentTopic.contact.LastName;
				reportsToData='&con8=' + escape(nm) +'&con8_lkid=' + parentTopic.contact.Id.substr(0,15);
			}
			if(!!recordType){
				recordTypeData="&RecordType=" + recordType;
			}
			mainController.displayForm(true,CONFIG.baseURLForNew + '&con4_lkid=' + account.Id.substr(0,15) + reportsToData + recordTypeData);
			//mmMap.lastUserCreatedContact=response.Contact;
		}
		if(utilities.userHasContactRecordtypes()){
			serverConfigObject.recordTypesDialog.callBackFunction=f;
			serverConfigObject.recordTypesDialog.show();
		}else f();
	},
	handleWindowCallBack:function(oSearch){
		mainController.displayForm(false);	
		console.debug("handleWindowCallBack");	
		if(oSearch.op=="edit"){
			requestHandler("getContact",
				{id:mmMap.lastUserModifiedContact.Id},
				function(response){
					if (!!mmMap.lastUserModifiedContact && (mmMap.lastUserModifiedContact.Id == response.Contact.Id && mmMap.lastUserModifiedContact.lastmodifieddate != response.Contact.lastmodifieddate)) {
						var topic = mmMap.retrieveTopicByContactId(response.Contact.Id);
						if (!!topic) {
							topic.securityAccess = response.ContactsSecurity[response.Contact.Id];
							if (topic.contact.ReportsToId != response.Contact.ReportsToId) {
								var parentTopic = mmMap.retrieveTopicByContactId(response.Contact.ReportsToId) || mmCentralTopic;
								mmMap.ReparentObject(topic, parentTopic, true);
								topic.level=(typeof parentTopic.level=='number')?parentTopic.level+1:0;
							} 	
							utilities.removeFavorIcon(topic, topic.contact);
							utilities.addFavorIcon(topic, response.Contact);
							topic.contact = response.Contact;
							topic.SetText(utilities.getTopicContent(topic));
							utilities.setTopicFormat(topic, response.Contact, utilities.lastLevelOrgChart(topic.level));
							utilities.resetTopicLevel(topic);
							mmMap.clearEventQueue();
							mmMap.setSelected(topic);
							setTimeout(function(topic){
								///mmMap.setFocus(topic);
								utilities.setDetailContent(topic);
							}.createClosure(null, topic), 400);
							utilities.resetRelationships(topic);
						}
					}
				}
			);
		} else if(oSearch.op=="new"){
			if(oSearch.res=='saved'){
				requestHandler("getContact",
					{id:oSearch.newid},
					function(response){
						//the contact was created
						var parentTopic=(!!response.Contact.ReportsToId && !!mmMap.retrieveTopicByContactId(response.Contact.ReportsToId))?mmMap.retrieveTopicByContactId(response.Contact.ReportsToId):mmCentralTopic;
						//Unfolding the tree
						mmMap.ExpandBranchSegment(parentTopic);
						var childTopic=parentTopic.GetSubTopics().AddNewTopic("");
						childTopic.level=(typeof parentTopic.level=='number')?parentTopic.level+1:0;
						childTopic.contact=response.Contact;
						childTopic.securityAccess=response.ContactsSecurity[childTopic.contact.Id];
						childTopic.SetText(utilities.getTopicContent(childTopic));
						utilities.setTopicFormat(childTopic,response.Contact,utilities.lastLevelOrgChart(childTopic.level));
						mmMap.storeObject(childTopic);
						mmMap.clearEventQueue();
						mmMap.setSelected(childTopic);
						mmMap.setFocus(childTopic);
						utilities.setDetailContent(childTopic);
					}
				);
			}
		}		
	},
	displayForm:function(display,action){
		display=(typeof display=='boolean')?display:true;
		action=(!action)?'about:blank':action;
		var body=Ext.get(Ext.DomQuery.select("body")[0]),
			bodydiv=Ext.get("bodyDiv"),
			sideBar=Ext.get("sidebarDiv");
		//document.body.style.overflow = 'hidden';
		var hookupBar=Ext.get("hookupBar");
		if(!hookupBar){
			hookupBar=body.createChild({tag:'div', id: 'hookupBar', style:'padding: 2px; background-color:#EDEDED; position:absolute; top:0px; left:0px; border: 1px solid #8F8F8F; right:0px; height:22px;'});
			hookupBar.insertHtml('afterBegin','<button onclick="mainController.displayForm(false);" style="float:left;" class="btn">Return to Mindjet Deal Navigator</button>');
		}
		var editIframe=Ext.get("editIframe");
		if(!editIframe){
			editIframe=body.createChild({tag:'iframe',id: 'editIframe', style:'border: 1px solid #8F8F8F; right:0px; position:absolute; top:27px; left:0px; height:' + (getPageSize().windowHeight-28)+'px'});
		} 
		hookupBar.setDisplayed(display);
		editIframe.setDisplayed(display);
		bodydiv.dom.style.width=(display)?'0px':'auto';
		
		sideBar.dom.style.display=display?'none':'block';

		setTimeout(function(){editIframe.dom.src=action;},1);
		mmMap.clearSelection();//or will retain the input
		if(!bodydiv.poller){
			bodydiv.poller=setInterval(
				function(editIframe){
					if(!this.previousHeight || this.previousHeight==this.getHeight()){
						this.previousHeight=this.getHeight();
						return;
					}
					var newSize=getPageSize().windowHeight-28;
					newSize=(newSize>0)?newSize:0;
					editIframe.setHeight(newSize);
					this.previousHeight=this.getHeight();
				}.createClosure(bodydiv,editIframe),500
			);
		}
	},
	moveContact:function(obj,from,to){
		var contact=(!!obj && !!obj.contact)?obj.contact.Id:null;
		var toContact=(!!to && !!to.contact)?to.contact.Id:'';
		if(!contact) return;
		mmMap.clearEventQueue();
		requestHandler(
			"moveContact",
			{
				contact:contact,
				toContact:toContact
			},
			function(topic,to,response){
				if(!!to) to.SetCollapsed(false);
				if(!!topic && !!to && typeof(to.level)=='number') topic.level=to.level+1;
				else topic.level=0;
				utilities.setTopicFormat(topic,topic.contact,utilities.lastLevelOrgChart(topic.level));
				topic.contact=response.contact;
				utilities.resetTopicLevel(topic);
				mmMap.clearEventQueue();
			}.createClosure(null,obj,to),
			function(topic,errorMessage){
				Ext.Msg.show({
					title:'Server Error',
					msg: errorMessage,
					buttons: Ext.Msg.OK,
					fn: function(topic){
						var oldParent=mmMap.retrieveTopicByContactId(topic.contact.ReportsToId)||mmCentralTopic;
						mmMap.ReparentObject(topic,oldParent);
						mmMap.clearEventQueue();
					}.createClosure(null,topic),
					icon: Ext.MessageBox.WARNING
				});
			}.createClosure(null,obj)
		)
		//return false;
	},
	//This is a dev only feature only
	createRelationship:function(relationship){
		var primaryTopic,secondaryTopic;
		if(!relationship) {
			var topics=mmDocument.GetSelectedTopics();
			if(topics.length<2 || !mmMap.retrieveObject(topics[0]) || !mmMap.retrieveObject(topics[1])) {
				return;
			};
			relationship=topics[0].GetRelationships().AddRelationship(topics[1],"");
			primaryTopic=topics[0];
			secondaryTopic=topics[1];
		} else {
			primaryTopic=mmMap.retrieveObject(relationship.GetConnectionObject1());
			secondaryTopic=mmMap.retrieveObject(relationship.GetConnectionObject2());
			if(!primaryTopic || !secondaryTopic || !primaryTopic.contact || !secondaryTopic.contact) {
				relationship.Delete();
				mmMap.clearEventQueue();
				return;
			}
		}
		//Handling Security and duplicates
		if(!utilities.getSecurityContext('Contact','isUpdateable',primaryTopic) || !utilities.getSecurityContext('Contact','isUpdateable',secondaryTopic) || mmMap.retrieveRelationshipsByContactId(primaryTopic.contact.Id,secondaryTopic.contact.Id).length>0){
			setTimeout(function(relationship){
				relationship.Delete();
				mmMap.clearEventQueue();
			}.createClosure(null,relationship),100);
			return;
		} 
		requestHandler(
			"createRelationship",
			{
				primaryContact:mmMap.retrieveObject(primaryTopic).contact.Id,
				secondaryContact:mmMap.retrieveObject(secondaryTopic).contact.Id
			},
			function(relationship,primaryTopic,secondaryTopic,response){
				relationship.relationship=response.Relationship;
				utilities.setRelationshipFormat(relationship,primaryTopic.contact,secondaryTopic.contact);
				mmMap.storeObject(relationship);
			}.createClosure(null,relationship,primaryTopic,secondaryTopic),
			function(relationship,errorMessage){
				Ext.Msg.show({
					title:'Server Error',
					msg: errorMessage,
					buttons: Ext.Msg.OK,
					fn: function(relationship){
						mmMap.deleteStoredObject(relationship);
					}.createClosure(null,relationship),
					icon: Ext.MessageBox.WARNING
				});
			}.createClosure(null,relationship)
		)
	},
	createCallout:function(){
		var object,objectType,relatedObject,topics=mmDocument.GetSelectedTopics(),objects=mmDocument.GetSelectedObjects();
		if(topics.length>0 && mmMap.retrieveObject(topics[0])) {
			object= topics[0];
			objectType='contact';
			relatedObject=mmMap.retrieveObject(topics[0]).contact;
		} else if(objects.length>0 && mmMap.retrieveObject(objects[0])) {
			object=objects[0];
			objectType='relationship';
			relatedObject=mmMap.retrieveObject(objects[0]).relationship;
		}
		if(!object || !relatedObject) return;
		var callout=object.GetCallouts().AddNewTopic("Comment");
		callout.relatedObject=object;
		callout.isCallout=true;
		mmMap.storeObject(callout);
		utilities.setCalloutFormat(callout);
		requestHandler(
			"createCallout",
			{
				text:callout.GetText(),
				relatedObject:relatedObject,
				objectType:objectType
			},
			function(callout,response){
				callout.callout=response.callout;
			}.createClosure(null,callout),
			function(callout,errorMessage){
				Ext.Msg.show({
					title:'Server Error',
					msg: errorMessage,
					buttons: Ext.Msg.OK,
					fn: function(callout){
						mmMap.deleteStoredObject(callout);
					}.createClosure(null,callout),
					icon: Ext.MessageBox.WARNING
				});
			}.createClosure(null,callout)
		)
	},
	updateCalloutText:function(callout){
		if(!callout || !callout.callout) return;
		var mmObjectId=callout.GetId(),calloutData=callout.callout;
		var newText=callout.GetText();
		requestHandler(
			"updateCalloutText",
			{
				callout:calloutData,
				mmObjectId:mmObjectId,
				newText:CLEARJSONCHARS(newText)
			},
			function(callout,response){
				var text=HTMLDECODE(response.callout.Text__c);
				if(text=='null') text=' ';
				callout.SetText(text);
				callout.callout=response.callout;
				mmMap.clearEventQueue();
				//if(!!response.Message) alert(response.Message);
			}.createClosure(null,callout)
		)
	},
	updateExternal:function(external){
		var topics=mmDocument.GetSelectedTopics(),topic=(topics.length==0)?null:mmMap.retrieveObject(topics[0]);
		if(!!topic && !topic.contact) return;
		requestHandler(
			"updateExternal",
			{
				external:external,
				contact:topic.contact
			},
			function(topic,response){
				topic.contact=response.contact;
				utilities.setTopicFormat(topic,response.contact,utilities.lastLevelOrgChart(topic.level));
				utilities.resetRelationships(topic);
			}.createClosure(null,topic),
			function(topic,errorMessage){
				Ext.Msg.show({
					title:'Server Error',
					msg: errorMessage,
					buttons: Ext.Msg.OK,
					fn: function(topic){
						utilities.setTopicFormat(topic,topic.contact,utilities.lastLevelOrgChart(topic.level));
						toolBar.items.get('external').toggle(topic.contact[CONFIG.externalField]=="true",true);
					}.createClosure(null,topic),
					icon: Ext.MessageBox.WARNING
				});
			}.createClosure(null,topic)
		)
	},
	createBoundary:function(color){
		var topics=mmDocument.GetSelectedTopics(),topic=(topics.length==0)?null:mmMap.retrieveObject(topics[0]);
		if(!!topic && !topic.contact) return;
		var objects=mmDocument.GetSelectedObjects();
		var boundary=mmMap.retrieveObject((!topic && objects.length>0)?objects[0]:((!!topic)?topic.GetBoundary():null));
		if(!!boundary && !boundary.boundary) boundary=null;
		if(!!topic && !boundary){
			boundary=topic.CreateBoundary(CONFIG.defaultBoundaryShape,CONFIG.defaultBoundaryOutlineAlpha+ CONFIG.defaultBoundaryOutlineColor,CONFIG.defaultBoundaryFillAlpha + color);
			mmMap.storeObject(boundary);
			requestHandler(
				"createBoundary",
				{
					contact:topic.contact,
					color:color
				},
				function(boundary,response){
					boundary.boundary=response.boundary;
				}.createClosure(null,boundary)
			)
		} else if(!!boundary){
			boundary.GetFormatting().SetFillColor(CONFIG.defaultBoundaryFillAlpha + color);
			boundary.boundary.FillColor__c=color;
			requestHandler(
				"updateBoundary",
				{
					boundary:boundary.boundary
				},
				function(response){}
			)
		}
	},
	updateFavor:function(topic,favorValue){
    	Ext.Msg.wait("","Loading...");
		requestHandler(
			"updateFavor",
			{
				contact:topic.contact,
				favor:favorValue
			},
			function(topic,response){
				utilities.removeFavorIcon(topic,topic.contact);
				utilities.addFavorIcon(topic,response.contact);
				topic.contact=response.contact;
				utilities.manageSelectedObject(topic,true);//Menu items needs to be recalculated
				setTimeout(function(){Ext.Msg.hide();},100);						
			}.createClosure(null,topic)
		);
	},
	manageOpportunityContactRole:function(opty,item,checked){
		var topic=(!!item.opportunityContactRole)?mmMap.retrieveTopicByContactId(item.opportunityContactRole.ContactId):mmMap.currentlySelectedObject;
		if(item.opportunityContactRole){
			//delete
			requestHandler(
				"deleteOpportunityContactRole",
				{
					ocr:item.opportunityContactRole
				},
				function(topic,ocr,response){
					for(var i in topic.opportunityContactRoles){
						if(topic.opportunityContactRoles[i].Id==ocr.Id){
							//Delete Role
							mmMap.removeTextMarker(topic,opportunitiesMap[ocr.OpportunityId].Name,ocr.Role);
							delete topic.opportunityContactRoles[i];
						}
					}
					if(mmMap.currentlySelectedObject==topic){
						utilities.setDetailContent(topic);
						utilities.markOpportunityRolesMenuItems(topic.opportunityContactRoles);
					}
				}.createClosure(null,topic,item.opportunityContactRole)
			);
			item.opportunityContactRole=null;
		} else {
			requestHandler(
				"createOpportunityContactRole",
				{
					opportunity:opty,
					role:item.text,
					contact:topic.contact
				},
				function(topic,response){
					if(!topic.opportunityContactRoles) topic.opportunityContactRoles={};
					topic.opportunityContactRoles[response.opportunityContactRole.Id]=response.opportunityContactRole;
					mmMap.addTextMarker(topic,opportunitiesMap[response.opportunityContactRole.OpportunityId].Name,response.opportunityContactRole.Role);
					if(mmMap.currentlySelectedObject==topic){
						utilities.setDetailContent(topic);
						utilities.markOpportunityRolesMenuItems(topic.opportunityContactRoles);
					}
				}.createClosure(null,topic)
			);
		}
	},
	clearMap:function(withReload){
		mmMap.stopObjectsEventListening();
		mmMap.clearMap();
		if(withReload) this.loadInitialMap();
	},
	deleteObject:function(object){
		var originalPassed=!!object;
		if(originalPassed) object=mmMap.retrieveObject(object);
		else {	
			var topics=mmDocument.GetSelectedTopics(),objects=mmDocument.GetSelectedObjects();
			if(topics.length>0) object=mmMap.retrieveObject(topics[0]);
			if(!object && objects.length>0) object=mmMap.retrieveObject(objects[0]);
			if(!object) return;
		}
		if(!!object.isDeleted) return;
		var oType=mmMap.typeOf(object);
		if(oType=='Callout') oType='Comment';
		Ext.Msg.confirm("Delete " + oType,"Do you want to delete this " + oType + " ?",
			function(object,btn){
				if((btn instanceof Array && btn[0]!='yes') || (typeof btn=='string' && btn!='yes')) return;
				var ot=mmMap.typeOf(object);
				Ext.Msg.wait("","Deleting...");
				if(ot=='Callout'){
					requestHandler("deleteCallout",
						{callout:object.callout},
						function(object,response){ 
							object=mmDocument.SearchObjectById(object.id);
							if (!!object) {
								mmMap.deleteStoredObject(object);
								setTimeout(mmMap.clearDirtyStoredObjects,100);
							}
							setTimeout(function(){Ext.Msg.hide();},100);
						}.createClosure(null,object)
					);
				} else if(ot=='Contact'){
					requestHandler("deleteContact",
						{contact:object.contact},
						function(contact,object,response){
							if(featuredContact && contact.Id==featuredContact.Id) {
								featuredContact=null;
							}
							var aChilds=mmMap.retrieveTopicByReportsToId(contact.Id);
							for(var i=0;i<aChilds.length;i++){
								mmMap.ReparentObject(aChilds[i],mmCentralTopic);
								aChilds[i].contact.ReportsToId='null';
								aChilds[i].level=0;
								utilities.resetTopicLevel(aChilds[i]);
							}
							setTimeout(function(){Ext.Msg.hide();},100);
							if (!!object) {
								mmMap.deleteStoredObject(object);
								setTimeout(mmMap.clearDirtyStoredObjects,100);
							}
						}.createClosure(null,object.contact,object),
						function(errorMessage){
							Ext.Msg.show({
							   title:'Server Error',
							   msg: errorMessage,
							   buttons: Ext.Msg.OK,
							   fn: function(){},
							   icon: Ext.MessageBox.WARNING
							});
						}
					);
				} else if(ot=='Relationship'){
					requestHandler("deleteRelationship",
						{relationship:object.relationship},
						function(object,response){ 
							mmMap.deleteStoredObject(object);
							setTimeout(mmMap.clearDirtyStoredObjects,100);
							setTimeout(function(){Ext.Msg.hide();},100);
						}.createClosure(null,object)
					);
				} else if(ot=='Boundary'){
					requestHandler(
						"deleteBoundary",
						{ boundary:object.boundary},
						function(object,response){ 
							mmMap.deleteStoredObject(object);
							setTimeout(mmMap.clearDirtyStoredObjects,100);
							setTimeout(function(){Ext.Msg.hide();},100);
						}.createClosure(null,object)
					)
				}
				setTimeout(mmMap.clearDirtyStoredObjects,100);
			}.createClosure(null,object)
		);
	}
}

var utilities={
	//***********************************************************************************
	//		Object Creation
	//***********************************************************************************
	parseContactMap:function(contacts){
		var reportsToMap={};
		contactsHash={};	//global variable
		for(var i in contacts){
			contactsHash[contacts[i].Id]=contacts[i];
			var reportsTo=(contacts[i].ReportsToId!='null')?contacts[i].ReportsToId:'central';
			if(!reportsToMap[reportsTo]) reportsToMap[reportsTo]=[];
			reportsToMap[reportsTo].push(contacts[i]);
		}
		for(var i in reportsToMap){
			//When a contact is not readable but has other contacts that reports to it
			//the reportsToId will appear anyway on those contacts. We need to reattach them to
			//the central topic
			if(!contactsHash[i] && i!='central') { 
				if(!reportsToMap['central']) reportsToMap['central']=[];
				for(var k=0;k<reportsToMap[i].length;k++){
					reportsToMap[i][k].ReportsToId='null';
					reportsToMap['central'].push(reportsToMap[i][k]);
				}
				delete reportsToMap[i];
			}
		}
		/*if(reportsToMap['central']){
			var f=function(reportsTo,reportsToMap){
				if(!reportsToMap[reportsTo]) return 0;
				reportsToMap[reportsTo].subLevelCounter=0;
				for(var i=0;i<reportsToMap[reportsTo].length;i++) reportsToMap[reportsTo].subLevelCounter+=arguments.callee(reportsToMap[reportsTo][i].Id,reportsToMap);
				reportsToMap[reportsTo].sort(function(a,b){return a.subLevelCounter-b.subLevelCounter});
				return reportsToMap[reportsTo].subLevelCounter + reportsToMap[reportsTo].length;
				
			}('central',reportsToMap);
		}*/
		return reportsToMap;
	},
	
	addSubLevelContactToMapCaller:function(topic,contactLayerArray,reportsToMap,securityMap,callback,totalCount,isNestedCall,currentLevel){
		if(!isNestedCall) {
			utilities.loadingToken={
				currentCount:0,
				totalCount:(isNaN(totalCount))?null:parseInt(totalCount),
				functionsQueue:[],
				callback:callback,
				callBackRendering:
					function(){
						var loadingToken=utilities.loadingToken;
						if(loadingToken.functionsQueue.length>0) {
							var msg="Rendering " + loadingToken.currentCount + " contacts";
							if(!!loadingToken.totalCount) msg+=" of " + loadingToken.totalCount;
							loadingToken.waitHeader.innerHTML=msg;
							setTimeout(loadingToken.functionsQueue.shift(),100);
						} else {
							Ext.Msg.hide();
							loadingToken.callback();
						}
					}
			};
			utilities.loadingToken.waitHeader=Ext.Msg.wait("","Rendering...").getDialog().header.child('span').dom;
			currentLevel=0;
		}
		var loadingToken=utilities.loadingToken,chunkLength=30;
		
		loadingToken.functionsQueue.push(function(contactLayerArray,topic,currentLevel){
			var loadingToken=utilities.loadingToken;
			loadingToken.currentCount+=contactLayerArray.length;
			for(var k=0;k<contactLayerArray.length;k++) utilities.addSubLevelContactToMap(topic,contactLayerArray[k],reportsToMap,securityMap,currentLevel);
			loadingToken.callBackRendering();
		}.createClosure(null,contactLayerArray.splice(0,chunkLength),topic,currentLevel));
		
		while(contactLayerArray.length>0) {
			utilities.addSubLevelContactToMapCaller(topic,contactLayerArray.splice(0,chunkLength),reportsToMap,securityMap,null,null,true);
		}
		if(!isNestedCall) setTimeout(loadingToken.callBackRendering,200);
	},
	addSubLevelContactToMap:function(topic,contact,reportsToMap,securityMap,currentLevel){
		var formatMap=utilities.getContactFormat(contact,securityMap[contact.Id],utilities.lastLevelOrgChart(currentLevel));
		var childTopic=topic.XAddTopic(utilities.getContactContent(contact,securityMap[contact.Id]),formatMap);
		//setTimeout(childTopic.XSetFormatting.createClosure(childTopic,formatMap),100);
		childTopic.level=currentLevel;
		//var childTopic=topic.subTopics.AddNewTopic(utilities.getContactContent(contact,securityMap[contact.Id]),60000,false);
		//Record Security
		childTopic.securityAccess=securityMap[contact.Id];
		//utilities.setTopicFormat(childTopic,contact,isNestedCall,!utilities.isFeaturedChart());
		mmMap.storeObject(childTopic);
		childTopic.contact=contact;
		childTopic.opportunityContactRoles={};
		utilities.addFavorIcon(childTopic,contact);
		if(!!reportsToMap[contact.Id]){
			utilities.addSubLevelContactToMapCaller(childTopic,reportsToMap[contact.Id],reportsToMap,securityMap,null,null,true,currentLevel+1);
		}
	},
	createRelationshipFromObject:function(rel){
		var topic1=mmMap.retrieveTopicByContactId(rel.primaryContact__c),
			topic2=mmMap.retrieveTopicByContactId(rel.secondaryContact__c);
		if(!!topic1 && !! topic2){
			var relationship=topic1.GetRelationships().AddRelationship(topic2,"");
			relationship.relationship=rel;
			utilities.setRelationshipFormat(relationship,topic1.contact,topic2.contact);
			mmMap.storeObject(relationship);
		}
	},
	createCalloutFromObject:function(cal){
		var callout,obj=mmMap.retrieveCalloutAssociatedObject(cal);
		if(obj) {
			var text=HTMLDECODE(cal.Text__c);
			if(text=='null') text=' '; 
			callout=obj.GetCallouts().AddNewTopic(text);
			callout.callout=cal;
			callout.relatedObject=obj;
			callout.isCallout=true;
			mmMap.storeObject(callout);
			utilities.setCalloutFormat(callout);
			
			//ReadOnly
			var ot=mmMap.typeOf(obj);
			if(ot=='Contact'){
				if(!utilities.getSecurityContext('Callout__c','isUpdateable',obj)) callout.GetMapObjectConstraints().EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmTextReadOnly);
			} else if(ot=='Relationship'){
				var topics=mmMap.retrieveTopicsByRelationship(obj);
				if(!utilities.getSecurityContext('Callout__c','isUpdateable',topics[0]) || !utilities.getSecurityContext('Callout__c','isUpdateable',topics[1])) callout.GetMapObjectConstraints().EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmTextReadOnly);
			}
		} 
	},
	createBoundaryFromObject:function(bou){
		var boundary,topic=mmMap.retrieveTopicByContactId(bou.Contact__c);
		if(topic) {
			boundary=topic.CreateBoundary(CONFIG.defaultBoundaryShape,CONFIG.defaultBoundaryOutlineAlpha+CONFIG.defaultBoundaryOutlineColor,CONFIG.defaultBoundaryFillAlpha + bou.FillColor__c);
			boundary.boundary=bou;
			mmMap.storeObject(boundary);
		} 
	},
	refreshDecoratingObjects:function(objectMap){
		try{
			//Refreshing Relationship 
			for(var i in objectMap.Relationships){
				if(mmMap.retrieveRelationshipsByContactId(objectMap.Relationships[i].primaryContact__c,objectMap.Relationships[i].secondaryContact__c).length>0) continue;
				utilities.createRelationshipFromObject(objectMap.Relationships[i]);
			}
			//Refreshing Callouts
			for(var i in objectMap.Callouts){
				var associateObject=mmMap.retrieveCalloutAssociatedObject(objectMap.Callouts[i]);
				var currentCallout=mmMap.retrieveCalloutByCalloutId(objectMap.Callouts[i].Id);
				if(!!associateObject && !currentCallout) utilities.createCalloutFromObject(objectMap.Callouts[i]);
				//if(!!mmMap.retrieveCalloutAssociatedObject(objectMap.Callouts[i]) && !map.retrieveCalloutByCalloutId(objectMap.Callouts[i].Id)) utilities.createCalloutFromObject(objectMap.Callouts[i]);
			}
			//Refreshing Boundaries
			for(var i in objectMap.Boundaries){
				if(!!mmMap.retrieveBoundaryByBoundaryId(objectMap.Boundaries[i].Id) || !mmMap.retrieveTopicByContactId(objectMap.Boundaries[i].Contact__c)) continue;
				utilities.createBoundaryFromObject(objectMap.Boundaries[i]);
			}
			utilities.assignOpportunitiesContactRoles(objectMap);
		}catch(e){alert(e)}
	},
	addFavorIcon:function(topic,favorOrContact){
		var favor=(typeof(favorOrContact)=='string')? favorOrContact: favorOrContact[serverConfigObject.MindjetAdminObject.Favor_Field__c],
			signature=mmMap.getIcon("favors",favor);
		if(!!signature && !mmMap.hasIcon(topic,signature)) mmMap.addIcon(topic,signature);	
	},
	removeFavorIcon:function(topic,favorOrContact){
		var favor=(typeof(favorOrContact)=='string')? favorOrContact: favorOrContact[serverConfigObject.MindjetAdminObject.Favor_Field__c],
			signature=mmMap.getIcon("favors",favor);
		if(!!signature && mmMap.hasIcon(topic,signature)) mmMap.removeIcon(topic,signature);
	},
	//***********************************************************************************
	//		Assets Setup
	//***********************************************************************************
	assignOpportunitiesContactRoles:function(map,withInit){
		//this function is called by the map loader to bind opportunity/opportunity contact roles data 
		//to the rest of the map
		opportunitiesMap={};
		opportunitiesArray=[];
		serverConfigObject.contactRoles=[];
		for(var i in map.Opportunities){
			var opty=map.Opportunities[i];
			opportunitiesMap[map.Opportunities[i].Id]=map.Opportunities[i];
			opportunitiesArray.push(map.Opportunities[i]);
		}
		for(var i in map.ContactRoles){
			serverConfigObject.contactRoles.push(map.ContactRoles[i]);
		}
		serverConfigObject.contactRoles.sort();
		for(var i in map.OpportunityContactRoles){
			var topic=mmMap.retrieveTopicByContactId(i);
			if(!!topic) {
				topic.opportunityContactRoles=map.OpportunityContactRoles[i];
				topic.GetTextMarkers().RemoveAll();
				for(var k in topic.opportunityContactRoles){
					if(!opportunitiesMap[topic.opportunityContactRoles[k].OpportunityId]) continue;
					var opty=opportunitiesMap[topic.opportunityContactRoles[k].OpportunityId];
					var role=(topic.opportunityContactRoles[k].Role!='null')?topic.opportunityContactRoles[k].Role:'';
					mmMap.addTextMarker(topic,opty.Name,role);
				}
			}
		}
		opportunitiesArray.sort(function(a,b){return(a.Name.toLowerCase()>b.Name.toLowerCase())?1:-1});
		serverConfigObject.opportunitiesMap=opportunitiesMap;
		serverConfigObject.opportunitiesFilteredMap={};
		serverConfigObject.opportunitiesMapByStage={};
		//serverConfigObject.opportunitiesClosedLostList=[];
		//serverConfigObject.opportunitiesClosedWonList=[];
		//serverConfigObject.opportunitiesOpenList=[];
		serverConfigObject.opportunitiesList=[];
		
		// Rebuild Opportunities and Roles Menues
		var rolesMenu=toolBar.items.get('opportunitiesroles');
		rolesMenu.menu.removeAll();
		
		for(var i =0;i<opportunitiesArray.length;i++){
			var oppty=opportunitiesArray[i];
			//Sorting Opportunities by type
			//---
			serverConfigObject.opportunitiesList.push(oppty);
			if(!serverConfigObject.opportunitiesMapByStage[oppty.StageName]) serverConfigObject.opportunitiesMapByStage[oppty.StageName]=[];
			serverConfigObject.opportunitiesMapByStage[oppty.StageName].push(oppty)
			//---
				//if(oppty.isClosed=='true') {
				//	((oppty.isWon=='true')?serverConfigObject.opportunitiesClosedWonList:serverConfigObject.opportunitiesClosedLostList).push(oppty);
				//} else serverConfigObject.opportunitiesOpenList.push(oppty);
			
			
			
			//Don't show closed Opportunities on the roles Menu?!
			if(oppty.isClosed=='true') continue;
			//Don't show Opportunities with RO permission on the roles Menu
			if(map.OpportunitiesSecurity[oppty.Id].indexOf('RW')!=0) continue;
			
			var optyItem=rolesMenu.menu.addMenuItem(
	            {
	                text: oppty.Name,
	                id: oppty.Id,
	                menu:{
						listeners:ie7MenuWidthFix
					}
	            }
			);
			for(var k=0;k<serverConfigObject.contactRoles.length;k++){
				optyItem.menu.addMenuItem(
					{ 
						checked: false,
						checkHandler: function(opty,item,checked){
							mainController.manageOpportunityContactRole(opty,item,checked);
						}.createClosure(null,oppty),
						text: serverConfigObject.contactRoles[k],
						id:oppty.Id+'#'+serverConfigObject.contactRoles[k]
					}
				);
			}
		}
		for(var i in serverConfigObject.opportunitiesMapByStage){
			serverConfigObject.opportunitiesMapByStage[i].sort(function(a,b){return (a.Name.toLowerCase()>b.Name.toLowerCase())?1:-1});
		}
		//	Setting up filtering options for opportunities
		var data=[], cbValue=null;
		if(!!featuredOpportunity){
			//---
			//if(featuredOpportunity.isClosed=='true') {
			//	cbValue=((featuredOpportunity.isWon=='true')?'closedwon':'closedlost');
			//} else cbValue='open';
			//---
			cbValue=featuredOpportunity.StageName;
		}
		//if(serverConfigObject.opportunitiesOpenList.length>0) {if(cbValue==null) cbValue='open'; data.push(['Open','open']);}
		//if(serverConfigObject.opportunitiesClosedWonList.length>0) {if(cbValue==null) cbValue='closedwon'; data.push(['Closed/Won','closedwon']);}
		//if(serverConfigObject.opportunitiesClosedLostList.length>0) {if(cbValue==null) cbValue='closedlost'; data.push(['Closed/Lost','closedlost']);}
		
		for(var i in serverConfigObject.opportunitiesMapByStage){
			if(cbValue==null) cbValue=i;
			data.push([i,i]);
		}
		
		/*data.sort(function(a,b){
			return serverConfigObject.opportunitiesMapByStage[a[0]][0].Probability -serverConfigObject.opportunitiesMapByStage[b[0]][0].Probability
		})*/
		
		//Setting up the combo and featuredOpportunity initial filering
		if(cbValue!=null) {
			if(data.length>1) data.unshift(['All','all']);
			var opptyFilterComboStore = new Ext.data.ArrayStore({
			    fields: ['label','value'],
			    data:data
			});
			var parentItem=Ext.getCmp('opptyFilterComboTitle'),parentMenu=Ext.getCmp('opptyFilterMenu').menu;
			if(!withInit) {
				var cb=Ext.getCmp('opptyFilterCombo');
				cb.destroy();
				((!!parentMenu.menu)?parentMenu.menu:parentMenu).items.each(
					function(item){
						if(item.id.indexOf('OpptyItem')!=0) return;
						try{
							this.remove(item);
						} catch(e){
							//
						}
					}.createClosure((!!parentMenu.menu)?parentMenu.menu:parentMenu)
				);
			}
		    var cb = new Ext.form.ComboBox({
		        displayField: 'label',
		        valueField:'value',
		        typeAhead: true,
		        triggerAction: 'all',
		        mode: 'local',
		        iconCls: 'no-icon-combo',
		        selectOnFocus: true,
		        forceSelection:true,
		        listAlign:'t-br?',
		        width: 120,
		        shadow:false,
		        id:'opptyFilterCombo',//this component is named 'opptyFilter'...in order to be not removed when the opptys are cleared
		        getListParent: function() {
		            return this.el.up('.x-menu');
		            //return Ext.get('mmwc');
		        },
		        store:opptyFilterComboStore
		    });
			parentMenu.insert(parentMenu.items.indexOf(parentItem)+1,cb);
			cb.addListener('expand',
				function(combo){
					combo.el.up('.x-menu').setStyle('overflow','visible');
					combo.list.setStyle('zIndex','100000');
					setTimeout(function(){combo.list.setLeft(combo.el.getLeft()-combo.el.up('.x-menu').getLeft());},10);
					
				}
			); 
			cb.addListener('select', 
				function(combo,data,rowIndex){
	        		var value=combo.getValue(),optTypes;
	        		
	        		if(value=='all') optTypes=serverConfigObject.opportunitiesList;
	        		else optTypes=serverConfigObject.opportunitiesMapByStage[value]
	        		
	        		//switch(value){
	        		//	case 'all': optTypes=serverConfigObject.opportunitiesList; break;
	        		//	case 'open': optTypes=serverConfigObject.opportunitiesOpenList; break;
	        		//	case 'closedwon': optTypes=serverConfigObject.opportunitiesClosedWonList; break;
	        		//	case 'closedlost': optTypes=serverConfigObject.opportunitiesClosedLostList; break;
	        		//}
	        		
					var opptyFilterMenu=toolBar.items.get('opptyFilterMenu');
					opptyFilterMenu.menu.items.each(
						function(item){
							if(item.id.indexOf('OpptyItem')!=0) return;
							opptyFilterMenu.menu.remove(item);
						}
					);
					serverConfigObject.opportunitiesFilteredMap={};
					mmMap.RemoveFilters();
	        		for(var i=0;i<optTypes.length;i++){
						opptyFilterMenu.menu.addMenuItem(
							{ 
								checked: false,
								hideOnClick: true, 
								checkHandler: function(opty,item,checked){
									if(!checked) delete serverConfigObject.opportunitiesFilteredMap[opty.Id];
									else serverConfigObject.opportunitiesFilteredMap[opty.Id]=true;
									var bFilter=false;
									for(var i in serverConfigObject.opportunitiesFilteredMap) {
										bFilter=true;
										break;
									}
									//***********************************************************************************
									//		Opportunity Filtering
									//***********************************************************************************
									//Actual Filtering
									mmMap.RemoveFilters();
									setTimeout(function(bFilter){
										//This first filtering is just to display all
										//i need also to uncollapse everything
										//This wouldn't work:
										mmMap.FilterObjects(
												function(obj){
												    obj=mmMap.retrieveObject(obj);
												    if (!obj || !obj.opportunityContactRoles) return true;
												    obj.SetCollapsed(false);
												    return true;
												},MmwEnumerations.MmwFilter.mmHideOthers,MmwEnumerations.MmwFilter.mmShowSubTopics);
										if(!bFilter){
											mmMap.RemoveFilters();
											return;
										}
										var filteredObjectsMap=mmMap.retrieveFilteredOpportunityObjects(serverConfigObject.opportunitiesFilteredMap);
										if(filteredObjectsMap[0].length==0){
											Ext.Msg.alert("Opportunity Filter","There are no contacts associated with the selected opportunities");
											mmMap.RemoveFilters(); 
											return;	
										} /*else if(filteredObjectsMap[0].length==filteredObjectsMap[1]){
											mmMap.RemoveFilters();
											return;
										}*/
										setTimeout(
											function(bFilter,filteredObjectsMap){				
												mmMap.FilterObjectsById( filteredObjectsMap,MmwEnumerations.MmwFilter.mmHideOthers,MmwEnumerations.MmwFilter.mmHideSubTopics);
											}.createClosure(null,bFilter,filteredObjectsMap[0]),100
										);
									}.createClosure(null,bFilter),100);	
									//What if there is no object filtered?!!
								}.createClosure(null,optTypes[i]),
								text: optTypes[i].Name,
								id:'OpptyItem'+ optTypes[i].Id
							}
						);
	        		}
	        	}
	        );
	        cb.setValue(cbValue);
	        setTimeout(function(withInit){
	        	cb.fireEvent("select",cb);
				if(!!featuredOpportunity && !!withInit){
					toolBar.items.get('opptyFilterMenu').menu.items.get('OpptyItem'+featuredOpportunity.Id).setChecked(true);
				}
			}.createClosure(null,withInit),2000);
		}

	},
	markOpportunityRolesMenuItems:function(opportunityContactRoles){
		//This function is called from the object selection to change 
		//Roles selected per contact in the opty menu
		var rolesMenu=toolBar.items.get('opportunitiesroles');
		rolesMenu.menu.items.each(
			function(item){
				if(!!item.menu && !!item.menu.items){
					item.menu.items.each(
						function(subItem){
							subItem.suspendEvents(false);
							subItem.setChecked(false);
							subItem.opportunityContactRole=null;
							subItem.resumeEvents();
						}
					)
				}
			}
		);
		for(var i in opportunityContactRoles){
			var item=rolesMenu.menu.items.get(opportunityContactRoles[i].OpportunityId);
			if(!item || !item.menu || !item.menu.items) continue;
			var subItem=item.menu.items.get(opportunityContactRoles[i].OpportunityId + '#' + opportunityContactRoles[i].Role);
			if(!subItem) continue;
			subItem.suspendEvents(false);
			subItem.setChecked(true);
			subItem.opportunityContactRole=opportunityContactRoles[i];
			subItem.resumeEvents();
		}
	},
	initFromAdminObject:function(response){
		if(!!serverConfigObject.MindjetAdminObject) {
			if(serverConfigObject.MindjetAdminObject.Favor_Field_Name__c!=response.Favor_Field_Name__c) serverConfigObject.MindjetAdminObject.preventFavor=true;
			return;
		}
		//Configuring Contact Security Context
		serverConfigObject.SecurityContext={};
		serverConfigObject.SecurityContext['Contact']=response.ContactSecurityContext;
		serverConfigObject.SecurityContext['Boundary__c']=response.BoundarySecurityContext;
		serverConfigObject.SecurityContext['Callout__c']=response.CalloutSecurityContext;
		serverConfigObject.SecurityContext['Relationship__c']=response.RelationshipSecurityContext;
		
		for(var h in serverConfigObject.SecurityContext){
			for(var i in serverConfigObject.SecurityContext[h]){
				if(!(i in {'isUpdateable':true,'isAccessible':true,'isNillable':true,'isCreateable':true,'isDeletable':true,'isQueryable':true})){
					var a=serverConfigObject.SecurityContext[h][i].split(',');
					serverConfigObject.SecurityContext[h][i]={};
					for(var k=0;k<a.length;k++){
						var ae=a[k].split('=');
						if(ae[1]=="true" || ae[1]=="false") serverConfigObject.SecurityContext[h][i][ae[0]]=ae[1]=="true";
						else serverConfigObject.SecurityContext[h][i][ae[0]]=ae[1];
					}
				} else serverConfigObject.SecurityContext[h][i]=serverConfigObject.SecurityContext[h][i]=="true";
			}
		}
		
		//Configuring ContactRecordTypes
		serverConfigObject.ContactRecordTypesMap=response.ContactRecordTypes;
		serverConfigObject.ContactRecordTypes=[];
		for(var i in serverConfigObject.ContactRecordTypesMap){
			if(i=='default' || serverConfigObject.ContactRecordTypesMap[i]=='Master') continue;
			serverConfigObject.ContactRecordTypes.push([i,serverConfigObject.ContactRecordTypesMap[i]]);
			//serverConfigObject.ContactRecordTypes[((i==serverConfigObject.ContactRecordTypesMap['default'])?'unshift':'push')]([i,serverConfigObject.ContactRecordTypesMap]);
		}
		serverConfigObject.ContactRecordTypes.sort(function(a,b){
			return (a[1]<b[1])?-1:1;
		});
		if(serverConfigObject.ContactRecordTypes.length>1){
			//There is not just one Contact Recordtype available for this user
			var recordTypesComboStore = new Ext.data.ArrayStore({
			    fields: ['value','label'],
			    data:serverConfigObject.ContactRecordTypes
			});
			serverConfigObject.recordTypesCombo = new Ext.form.ComboBox({
		        displayField: 'label',
		        valueField:'value',
		        typeAhead: true,
		        triggerAction: 'all',
		        mode: 'local',
		        iconCls: 'no-icon-combo',
		        selectOnFocus: true,
		        forceSelection:true,
		        width: 300,
		        style:'padding-left: 0px;',
		        shadow:false,
		        id:'recordTypesCombo',
		        store:recordTypesComboStore,
		        autoScroll:false
		    });
		   	serverConfigObject.recordTypesDialog = new Ext.Window({
		   		autoCreate : true,
		        autoWidth:false,
		        resizable:false,
		        closable:true,
		        closeAction:'hide',
		        plain: true,
		        collapsible: false,
				id:'recordTypesDialog',
				modal:true,
				shadow:false,
				bodyBorder:false,
				autoHeight :false,
				height:150,
				autoScroll:false,
                buttonAlign:"center",
                width:350,
                plain:true,
                footer:true,
                title: 'Please Select a Record Type',
			    items:[
			    	serverConfigObject.recordTypesCombo
			    ],
		        buttons: [
		        {
		        	id:"recordTypesDialogConfirm",
		        	text: 'OK',
		            handler: function(){
		            	serverConfigObject.recordTypesDialog.hide();
						if(!!serverConfigObject.recordTypesDialog.callBackFunction){
							serverConfigObject.recordTypesDialog.callBackFunction(serverConfigObject.recordTypesCombo.getValue());
						}
		            }
		        },{
		            id:"recordTypesDialogCancel",
		            text: 'Cancel',
		            handler: function(){
		                serverConfigObject.recordTypesDialog.hide();
		            }
		        }]
		    });
			serverConfigObject.recordTypesDialog.addListener('show',
				function(){
					serverConfigObject.recordTypesCombo.setValue(serverConfigObject.ContactRecordTypesMap['default']);
					serverConfigObject.recordTypesDialog.body.up('').dom.style.backgroundColor="#EEEEEE";
					serverConfigObject.recordTypesDialog.center();
				}
			);
            serverConfigObject.recordTypesDialog.render(document.body);
            serverConfigObject.recordTypesDialog.getEl().addClass('x-window-dlg');
		}
		
		
		//Configuring Mindjet Admin Object
		serverConfigObject.MindjetAdminObject=response.MindjetAdminObject;
		serverConfigObject.MindjetAdminObject.favorIconsCouplesMap={};
		
		//Configuring Favors Icons
		var favorsMenu=toolBar.items.get('favors');
		favorsMenu.setText((serverConfigObject.MindjetAdminObject.Favor_Field_Name__c=='null')?'Favor&nbsp;':serverConfigObject.MindjetAdminObject.Favor_Field_Name__c + '&nbsp;');
		favorsMenu.menu.removeAll();
		
		if (serverConfigObject.MindjetAdminObject.Favor_Icons__c != "null" && serverConfigObject.MindjetAdminObject.Favor_Icons__c != "") {
			var couples = serverConfigObject.MindjetAdminObject.Favor_Icons__c.split(',');
			
			for (var i = 0; i < couples.length; i++) {
				var couple = couples[i].split('###');
				if (couple.length == 1) 
					couple.push('');
				serverConfigObject.MindjetAdminObject.favorIconsCouplesMap[couple[0]] = couple;
				mmMap.loadIconFile("favors", couple[0], couple[1]);
				couples[i] = couple;
			}
			couples.unshift(['---None---', 'null']);
			serverConfigObject.MindjetAdminObject.favorIconsCouplesMap['---None---'] = ['---None---', 'null'];
			//Configuring Favors Menu
			for (var i = 0; i < couples.length; i++) {
				var couple = couples[i];
				var favorsMenuItem = favorsMenu.menu.addMenuItem({
					text: couple[0],
					id: (couple[0] == '---None---') ? "nullFavor" : couple[0] + 'favor',
					icon: (couple[1] == 'null') ? Ext.BLANK_IMAGE_URL : CONFIG.baseURLforMapMarkersIcons + couple[1],
					handler: function(favorValue){
						mainController.updateFavor(mmMap.currentlySelectedObject, favorValue);
					}.createClosure(null, (couple[0] == '---None---') ? null : couple[0])
				});
			}
		}
		//Configuring other CSV attributes
		serverConfigObject.MindjetAdminObject.CSVConfig={};
		var aCSV=serverConfigObject.MindjetAdminObject.CSV_Config__c.split(',');
		for (var i = 0; i < aCSV.length; i++) {
			if(aCSV[i].length>0){
				var aCSVi=aCSV[i].split('=');
				serverConfigObject.MindjetAdminObject.CSVConfig[aCSVi[0]]=aCSVi[1];
			}
		}
	},
	//***********************************************************************************
	//		Format and Content
	//***********************************************************************************
	setCentralTopicText:function(){
		var topicText=HTMLDECODE(account.Name);
		mmCentralTopic.SetText(topicText);
	},
	enableDetailPanel:function(enable){},
	setDetailContent:function(topic){
		if(!detailOverlay.enableShow || !topic.contact) {
			detailOverlay.hide();
			return;
		}
		var contact=topic.contact;
    	detailOverlay.el.dom.style.backgroundColor = "#ffffff";
		detailOverlay.setTitle("<B>Contact Details</B>&nbsp;<A href='javascript:void(mainController.displayForm(true,\"/"+ contact.Id+"\"))'>More...</A>");
		var DetailData='\
			<center><table id="detailTableContent" cellspacing="0" cellpadding="0" border="0" class="detailList" width="95%"><tbody>\
			<tr><td colspan="2" class="data2Col  first  last ">\
			<table cellspacing="0" cellpadding="0" border="0" class="list" width="100%" style="text-align:left;"><colgroup span="2"/><tbody id="tb">';

		var excludedFields={'isUpdateable':true,'isAccessible':true,'isNillable':true,'isCreateable':true,'isDeletable':true,'isQueryable':true};
		excludedFields[serverConfigObject.MindjetAdminObject.Favor_Field__c]=true;
		excludedFields[CONFIG.externalField]=true;
		//Fields are ordered by the order field in the security context
		var orderedSecurityContext=[];
		for(var i in serverConfigObject.SecurityContext['Contact']){
			if(!(i in excludedFields) && serverConfigObject.SecurityContext['Contact'][i].isAccessible && !!serverConfigObject.SecurityContext['Contact'][i].order){
				orderedSecurityContext.push([i,serverConfigObject.SecurityContext['Contact'][i]]);
			}
		}
		orderedSecurityContext.sort(function(a,b){return parseInt(a[1].order)-parseInt(b[1].order)});
		for(var i=0;i<orderedSecurityContext.length;i++){
			DetailData+='<tr class="dataRow"><td style="font-weight:bolder; width:1%;" width="1%"><B>' + orderedSecurityContext[i][1].label + '</B></td><td class="dataCol">' + ((contact[orderedSecurityContext[i][0]]!="null")?contact[orderedSecurityContext[i][0]]:'&nbsp;') + '</td></tr>';
		}
		
		DetailData+='opportunityContactRoles\
			</tbody></table>\
			</td></tr></tbody></table></center>';
		var optLines='';
		if(topic.opportunityContactRoles){
			var optMap={};
			for(var k in topic.opportunityContactRoles){
				if(!opportunitiesMap[topic.opportunityContactRoles[k].OpportunityId]) continue;
				optLines='<tr class="dataRow even"><td class="labelCol"><B>Opportunities</B></td><td id="con5_ilecell" class="dataCol col02 inlineEditWrite">&nbsp;</td></tr>';
				var opty=opportunitiesMap[topic.opportunityContactRoles[k].OpportunityId];
				if(!optMap[opty.Id]) optMap[opty.Id]={opty:opty,ocr:[]};
				if(topic.opportunityContactRoles[k].Role!='null') optMap[opty.Id].ocr.push(topic.opportunityContactRoles[k].Role);
			}
			var k=0;
			for(var i in optMap){
				var name=(optMap[i].opty.Name!='null')?optMap[i].opty.Name:'',
					stage=(optMap[i].opty.StageName!='null')?optMap[i].opty.StageName:'',
					prob=(optMap[i].opty.Probability!='null')?optMap[i].opty.Probability:'';
				optLines+='\
					<tr class="dataRow '+ ((i%2==0)?'odd':'even') +'">\
						<td class="labelCol" colspan="2">\
						&nbsp;&nbsp;<b>' + name + '</b>\
						</td>\
					</tr>\
					<tr class="dataRow '+ ((i%2!=0)?'odd':'even') +'">\
						<td class="labelCol" colspan="2">\
							<table border="0" cellspacing="0" cellpadding="0">\
							<tr><td style="border:0px solid;"><b>&nbsp;&nbsp;Role(s):&nbsp;</b>' + optMap[i].ocr.join(', ') + '</td></tr>\
							<tr><td style="border:0px solid;"><b>&nbsp;&nbsp;Stage:&nbsp;</b>' + stage + '</td></tr>\
							<tr><td style="border:0px solid;"><b>&nbsp;&nbsp;Probability(%):&nbsp;</b>' + prob + '</td></tr>\
							</table>\
						</td>\
					</tr>';
			}
		} 
		DetailData=DetailData.split('opportunityContactRoles').join(optLines);
		//Detail.innerHTML=content;
		detailOverlay.show();
		detailOverlay.body.dom.innerHTML=DetailData;
	},
	clearDetail:function(){
		detailOverlay.hide();
	},
	getTopicContent:function(topic){
		if(!topic || !topic.contact) return'';
		return utilities.getContactContent(topic.contact,topic.securityAccess);
	},
	getContactContent:function(contact,securityAccess){
		var s='',fn,ln,ttl;
		fn=(utilities.getSecurityContextFromSecurityAccess('Contact','isAccessible',securityAccess,'FirstName') && contact.FirstName!='null')? contact.FirstName : 'null';
		ln=(utilities.getSecurityContextFromSecurityAccess('Contact','isAccessible',securityAccess,'LastName') && contact.LastName!='null')? contact.LastName : 'null';
		ttl=(utilities.getSecurityContextFromSecurityAccess('Contact','isAccessible',securityAccess,'Title') && contact.Title!='null')? contact.Title : 'null';
		s+=((fn=='null')?"": fn);
		s+=((fn!='null' && ln!='null')?" ": "");
		s+=((ln=='null')?"": ln);
		s+=((fn!='null' || ln!='null')?"\n": "");
		s+=((ttl!='null')?ttl: "");
		if(s=='') s="No data displayed\nfor this contact";
		return HTMLDECODE(s);
	},
	getContactFormat:function(contact,securityAccess,topicGrowthDirectionTree){
		var isUpdateable=utilities.getSecurityContextFromSecurityAccess('Contact','isUpdateable',securityAccess),
			isDeletable=utilities.getSecurityContextFromSecurityAccess('Contact','isDeletable',securityAccess),
			isUpdateableReportsTo=utilities.getSecurityContextFromSecurityAccess('Contact','isUpdateable',securityAccess,'ReportsToId');
		var types=(isUpdateableReportsTo)?['isUpdateableReportsTo']:[];
		var growthDirection=(!topicGrowthDirectionTree)?MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionOrgChart:MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionTree;		
		var features={};
		features[MmwEnumerations.MmwMapObjectFeatures.mmTextReadOnly]=true;
		features[MmwEnumerations.MmwMapObjectFeatures.mmNoDragToFloating]=true;
		return {
			"features":features,
			"growthDirection":growthDirection,
			"types":types,
			"allowedChildTypes":['isUpdateableReportsTo'],
			"bold":"false",
			"fillColor":(!isDeletable)?"FFFFFFFF":"FFFFFFFF",
			"size":"10",
			"alignment":MmwEnumerations.MmwTextAlignment.mmLeft,
			"constrainedChildTypes":"true",
			"textColor":(!isUpdateable)?"11DDDDDD":"FF000000",
			"lineColor":(!isDeletable)?"11DDDDDD":"FF000000",
			"shape":(contact[CONFIG.externalField]=="true")?CONFIG.alternateTopicShape:CONFIG.defaultTopicShape				
		}
	},
	setTopicFormat:function(topic,contact,topicGrowthDirectionTree){
		if(!contact) contact=topic.contact;
		topic.XSetFormatting(utilities.getContactFormat(contact,topic.securityAccess,topicGrowthDirectionTree));
		return;
	},
	resetTopicLevel:function(parentTopic){
		if(typeof parentTopic.level!='number') parentTopic.level=0;
		var sts=parentTopic.GetSubTopics(),c=sts.GetCount();
		for(var i=0;i<c;i++){
			var st=mmMap.retrieveObject(sts.Item(i));
			st.level=parentTopic.level+1;
			utilities.setTopicFormat(st,st.contact,utilities.lastLevelOrgChart(st.level));
			arguments.callee(st);
		}
	},
	setRelationshipFormat:function(relationship,primaryContact,secondaryContact){
		var ext=(secondaryContact[CONFIG.externalField]=="true" || primaryContact[CONFIG.externalField]=="true");
		relationship.GetFormatting().SetLineDashStyle((ext)?CONFIG.alternateRelationshipLineStyle:CONFIG.relationshipLineStyle);	
		relationship.GetFormatting().SetLineColor((ext)?CONFIG.relationshipExternalLineColor:CONFIG.relationshipLineColor);	
	},
	setCalloutFormat:function(callout){
		callout.GetFormatting().SetLineColor(CONFIG.calloutLineColor);
		callout.GetFormatting().SetFillColor(CONFIG.calloutBackgroundColor);
		callout.GetFormatting().SetShape(CONFIG.defaultCalloutShape);
		
		//D&D
		var MapObjectConstraints=callout.GetMapObjectConstraints();
		MapObjectConstraints.SetConstrainedChildTypesActivated(true);
		MapObjectConstraints.RemoveAllTypes();
		MapObjectConstraints.EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmNoDragToFloating);
	},
	resetRelationships:function(topicOrContact){
		var id=(!topicOrContact.contact)?topicOrContact.Id:topicOrContact.contact.Id,
			rels=mmMap.retrieveRelationshipsByContactId(id);
		for(var i=0;i<rels.length;i++){
			var rel=rels[i];
			utilities.setRelationshipFormat(rel,
				mmMap.retrieveTopicByContactId(rel.relationship.primaryContact__c).contact,
				mmMap.retrieveTopicByContactId(rel.relationship.secondaryContact__c).contact
			);
		}
	},
	//***********************************************************************************
	//		Security
	//***********************************************************************************
	userHasContactRolesAccess:function(){
		return serverConfigObject.contactRoles.length>0;
	},
	userHasContactRecordtypes:function(){
		return serverConfigObject.ContactRecordTypes.length>1;
	},
	getSecurityContext:function(objectName,attribute,topic,fieldName){
		//Fields Security:
		//isAccessible: is visible by the user
		//isUpdateable: is Updateable by the user
		
		//Objects Access Security
		//isDeletable
		//isCreateable
		//isAccessible
		//isUpdateable
		
		return utilities.getSecurityContextFromSecurityAccess(objectName,attribute,(!!topic && !!topic.securityAccess)?topic.securityAccess:null,fieldName);
	},
	getSecurityContextFromSecurityAccess:function(objectName,attribute,securityAccess,fieldName){
		//Fields Security:
		//isAccessible: is visible by the user
		//isUpdateable: is Updateable by the user
		
		//Objects Access Security
		//isDeletable
		//isCreateable
		//isAccessible
		//isUpdateable
		
		if(!serverConfigObject.SecurityContext[objectName]) return false;
		var sc=serverConfigObject.SecurityContext[objectName];
		
		if(attribute=='isAccessible'){
			var f=sc.isAccessible;
			if(!!fieldName && !!sc[fieldName]) f=f && sc[fieldName].isAccessible;
			return f;
		} else if(attribute=='isDeletable'){
			if(!!securityAccess){
				if(objectName=='Contact') return securityAccess=='RWD' && sc.isDeletable;
				else return securityAccess.indexOf('RW')==0 && sc.isDeletable;
			} else return sc.isDeletable;
		} else if(attribute=='isUpdateable'){
			if(!!securityAccess) {
				var f=securityAccess.indexOf('RW')==0 && sc.isUpdateable;
				if(!!fieldName && !!sc[fieldName]) f=f && sc[fieldName].isUpdateable;
				return f;
			} else return sc.isUpdateable;
		} else if(attribute=='isCreateable'){
			return sc.isCreateable;
		}
	},
	//***********************************************************************************
	//		Others
	//***********************************************************************************
	isFeaturedChart:function(){
		return featuredOpportunity || featuredContact;
	},
	lastLevelOrgChart:function(level){
		return parseInt(serverConfigObject.MindjetAdminObject.CSVConfig['LastLevelOrgChartLayout'])<=level;
	},
	clearFiltering:function(){
		mmMap.RemoveFilters();
		serverConfigObject.opportunitiesFilteredMap={};
		var opptyFilterMenu=toolBar.items.get('opptyFilterMenu');
		opptyFilterMenu.menu.items.each(
			function(item){
				if(item.id.indexOf('OpptyItem')==0) item.setChecked(false,true);
			}
		);
	},
	manageSelectedObject:function(object,forceCalculation){
		if(mmMap.currentlySelectedObject==object && !forceCalculation) return;
		mmMap.currentlySelectedObject=object;
		var ot=mmMap.typeOf(object);
		utilities.clearDetail();
		toolBar.items.get('external').toggle(false,true);
		if(ot=='Callout'){
			var rel=mmMap.retrieveRelationshipByCallout(object),
				topic=(!!rel)?mmMap.retrieveTopicsByRelationship(rel):mmMap.retrieveTopicByCallout(object),
				isDeletable=true;
			if(topic instanceof Array){
				isDeletable=utilities.getSecurityContext('Callout__c','isDeletable',topic[0]) && utilities.getSecurityContext('Callout__c','isDeletable',topic[1]);
			} else {
				isDeletable=utilities.getSecurityContext('Callout__c','isDeletable',topic);
			}
			toolBar.disableItems(
				{
					clearFilter:!mmMap.isFiltered(),
					opptyFilterMenu:(serverConfigObject.opportunitiesList.length==0),
					insertContact:(!utilities.getSecurityContext('Contact','isCreateable')),
					insertRelationship:!utilities.getSecurityContext('Relationship__c','isCreateable'),
					printSingle:true,
					edit:true,
					insertCallout:!mmMap.retrieveObjectCallout(object),
					insertBoundary:true,
					insertIconMarker:true,
					opportunitiesroles:true,
					favors:true,
					external:true,
					prodName:true,
					ver:true,
					deleteBtn:!isDeletable
				}
			);
		} else if(ot=='Contact'){
			toolBar.disableItems(
				(function(obj){
					var boundary=mmMap.retrieveBoundaryByTopic(obj);
					var ret={
						clearFilter:!mmMap.isFiltered(),
						opptyFilterMenu:serverConfigObject.opportunitiesList.length==0,
						insertContact:!utilities.getSecurityContext('Contact','isCreateable'),
						insertRelationship:!utilities.getSecurityContext('Relationship__c','isCreateable'),
						edit:!utilities.getSecurityContext('Contact','isUpdateable',obj),
						deleteBtn:!utilities.getSecurityContext('Contact','isDeletable',obj),
						insertCallout:!(!mmMap.retrieveObjectCallout(object) && utilities.getSecurityContext('Contact','isUpdateable',obj) && utilities.getSecurityContext('Callout__c','isCreateable')),
						insertBoundary:!(utilities.getSecurityContext('Contact','isUpdateable',obj) && ((utilities.getSecurityContext('Boundary__c','isCreateable') && !boundary) || (utilities.getSecurityContext('Boundary__c','isUpdateable') && !!boundary))),
						prodName:true,
						ver:true,
						opportunitiesroles:(
							function(){
								if(!utilities.userHasContactRolesAccess()) return true;
								var rolesMenu=toolBar.items.get('opportunitiesroles');
								if(rolesMenu.menu.items.length>0) return false;
								return true;
							})()
					};
					ret.favors=(function(){for(var i in serverConfigObject.MindjetAdminObject.favorIconsCouplesMap){return false;} return true;})() || !!serverConfigObject.MindjetAdminObject.preventFavor;
					if(!utilities.getSecurityContext('Contact','isUpdateable',obj,CONFIG.externalField)) ret.external=true;
					if(!utilities.getSecurityContext('Contact','isUpdateable',obj,serverConfigObject.MindjetAdminObject.Favor_Field__c)) ret.favors=true;
					var favor=obj.contact[serverConfigObject.MindjetAdminObject.Favor_Field__c];
					ret[((favor=="null" || favor=="")?"nullFavor":favor+'favor')]=true;
					return ret;
				}.createClosure(null,object))()
			);
			toolBar.items.get('external').toggle(object.contact[CONFIG.externalField]=="true",true);
			utilities.markOpportunityRolesMenuItems(object.opportunityContactRoles);
			setTimeout(function(object){
				utilities.setDetailContent(object);
			}.createClosure(null,object),500);
		} else if(ot=='Relationship'){
			var topics=mmMap.retrieveTopicsByRelationship(object);
			toolBar.disableItems(
				{
					clearFilter:!mmMap.isFiltered(),
					opptyFilterMenu:serverConfigObject.opportunitiesList.length==0,
					insertContact:!utilities.getSecurityContext('Contact','isCreateable'),
					insertRelationship:!utilities.getSecurityContext('Relationship__c','isCreateable'),
					printSingle:true,
					edit:true,
					insertCallout:!!mmMap.retrieveObjectCallout(object) || !utilities.getSecurityContext('Relationship__c','isUpdateable',topics[0]) || !utilities.getSecurityContext('Relationship__c','isUpdateable',topics[1]) || !utilities.getSecurityContext('Callout__c','isCreateable'),
					insertBoundary:true,
					insertIconMarker:true,
					opportunitiesroles:true,
					favors:true,
					external:true,
					prodName:true,
					ver:true,
					deleteBtn:!utilities.getSecurityContext('Relationship__c','isDeletable',topics[0]) || !utilities.getSecurityContext('Relationship__c','isDeletable',topics[1])
				}
			);
		} else if(ot=='Boundary'){
			var topic=mmMap.retrieveTopicByBoundary(object);
			toolBar.disableItems(
				{
					clearFilter:!mmMap.isFiltered(),
					opptyFilterMenu:serverConfigObject.opportunitiesList.length==0,
					insertContact:!utilities.getSecurityContext('Contact','isCreateable'),
					insertRelationship:!utilities.getSecurityContext('Relationship__c','isCreateable'),
					printSingle:true,
					edit:true,
					insertCallout:true,
					insertIconMarker:true,
					opportunitiesroles:true,
					favors:true,
					external:true,
					prodName:true,
					ver:true,
					deleteBtn:!utilities.getSecurityContext('Boundary__c','isDeletable',topic),
					insertBoundary:!utilities.getSecurityContext('Boundary__c','isUpdateable',topic) 
				}
			);
		} else {
			toolBar.disableItems(
				{
					clearFilter:!mmMap.isFiltered(),
					opptyFilterMenu:serverConfigObject.opportunitiesList.length==0,
					insertContact:!utilities.getSecurityContext('Contact','isCreateable'),
					insertRelationship:!utilities.getSecurityContext('Relationship__c','isCreateable'),
					printSingle:true,
					edit:true,
					insertCallout:true,
					insertBoundary:true,
					insertIconMarker:true,
					deleteBtn:true,
					opportunitiesroles:true,
					favors:true,
					prodName:true,
					ver:true,
					external:true
				}
			);
		}
	}
}
//***********************************************************************************
//		MM Objects Initialization
//***********************************************************************************

//Global Variables
var mmMap,
	mmDocument,
	mmCentralTopic,
	account,
	featuredContact,
	featuredOpportunity,
	contactsHash,
	editIframe,
	mmContainer,
	detailOverlay,
	toolBar,
	bodyDiv,
	contactRoles,
	opportunitiesMap,
	serverConfigObject={};

var framed=true;
try{
	framed=window.parent && window.parent!=window;
}catch(e){}

Ext.onReady(function(){
	//Inits ExtJS popups/tooltips
	Ext.QuickTips.init();

	//Prevents flash to resize when showing upper folder
	var body=document.body ||  document.getElementsByTagName('body').item(0),
		bodyHeader=document.getElementById('AppBodyHeader'),
		hg=(!!bodyHeader)?'height:100%;':'',
		theme3SideSpacer=(CONFIG.UITheme!='Theme3')?'':'padding-left:10px;';//this is a trick to make the side 
	body.innerHTML='<div id="bodyDiv" style="right:0px;'+hg+theme3SideSpacer+'position:absolute;top:0px;left:0px;overflow:auto;">' + body.innerHTML + '</div>';
	body.style.overflow='hidden';
	bodyDiv=Ext.get("bodyDiv");
	//***********************************************************************************
	//		Salesforce Sidebar New Object Button Fix
	//***********************************************************************************
	try {
		new MenuButton("createNew", null);
	}catch(e){}
	
	if(CONFIG.UITheme=='Theme3') body.style.margin='0px';
	if(Ext.isIE7){
		try{
			//IE7 Fix
			body.style.overflowX='hidden';
			body.style.overflowY='hidden';
			if(document.documentElement)document.documentElement.style.overflow='hidden';
			document.getElementById('bodyCell').style.paddingRight='0px';
			document.getElementById('AppBodyHeader').style.width='98%';
			document.getElementById('mmwctoolbar').style.width='99%';
			document.getElementById('mmwc').style.width='99%';
			var meta;
			try {
				if (document.createElement && (meta = document.createElement('meta'))) {
					// set properties
					meta.httpEquiv = "Page-Enter";
					meta.content = "revealtrans(duration=0.0)";
					// now add the meta element to the head
					document.getElementsByTagName('head').item(0).appendChild(meta);
				}
			} catch(e){}
			document.execCommand('BackgroundImageCache', false, true);
		}catch(e){}
	}
	
	//Restores sidebar on new document
	Sidebar.prototype.theSidebar = new Sidebar(document.getElementById('sidebarDiv'));	
	
	window.mainPoller=function(){
			try{		
				//Sizing panel
				try{
					var ps=getPageSize(),
						containerTop=mmContainer.getTop(),containerLeft=mmContainer.getLeft(),
						gapH=((framed)?0:20),gapW=((framed)?0:30),
						containerHeight=mmContainer.getHeight()+ containerTop + gapH,
						containerWidth=mmContainer.getWidth()+containerLeft+gapW;
					var sidebarVisible=false
					try{
						sidebarVisible=document.getElementById('sidebarDiv').className.indexOf('sidebarDivVisible')>=0;
					}catch(e){}
					try{
						if (containerHeight != ps.windowHeight && (!arguments.callee.lastWindowHeight  || ps.windowHeight != arguments.callee.lastWindowHeight) || 
							toolBar.isVisible() != arguments.callee.lastToolbarVisible) {
							mmContainer.setHeight(ps.windowHeight - containerTop - gapH);
						}
						if (containerWidth != ps.windowWidth && (!arguments.callee.lastWindowWidth  || ps.windowWidth != arguments.callee.lastWindowWidth) ||
							sidebarVisible != arguments.callee.lastSidebarVisible) {
							toolBar.setWidth(ps.windowWidth - containerLeft - gapW);
							mmContainer.setWidth(ps.windowWidth - containerLeft - gapW);
						}
					} catch(e){}
					arguments.callee.lastWindowHeight=ps.windowHeight;
					arguments.callee.lastWindowWidth=ps.windowWidth;
					arguments.callee.lastToolbarVisible=toolBar.isVisible();
					arguments.callee.lastSidebarVisible=sidebarVisible;
					
					if(!detailOverlay.hidden) detailOverlay.show();
				} catch(e){}
				//retrieve currently selected object
				var object;
				try{
					var topics=mmDocument.GetSelectedTopics(),objects=mmDocument.GetSelectedObjects();
					if(topics.length>0 && mmMap.retrieveObject(topics[0])) object= mmMap.retrieveObject(topics[0]);
					if(!object && objects.length>0 && mmMap.retrieveObject(objects[0])) object= mmMap.retrieveObject(objects[0]);
				} catch(e){}
				//manage currently selected object
				try{
					utilities.manageSelectedObject(object);
				} catch(e){}
				//managing filter menu
				Ext.getCmp('clearFilter')[mmMap.isFiltered()?'enable':'disable']();
			} catch(e){
				//This loop may run before some of the objects are created
			}
		};
	window.mainPoller.intervalTime=500;
	
    window.startMainPoller=function(){
    	window.mainPoller.interval=setInterval(window.mainPoller,window.mainPoller.intervalTime);
    }

    applicationInit();
});


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
	   	mmMap.ui.flashNotAvailableURL		= 'Mindjet_FlashProblem';
	    mmMap.ui.flashInsufficientVersionURL= 'Mindjet_FlashProblem';
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
	    mmMap.ui.useToolTips				= false;
		mmMap.ui.playerMindjetMenu			= false;
		mmMap.ui.playerTrialButton			= false;
		mmMap.ui.playerSBPrintButton 		= false;
		mmMap.ui.useIconMouseActions		= false;
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
			if(typeof obj=='string')obj=this.__storedObjects[obj];
			if(!obj || !obj.id) return null;
	    	delete this.__storedObjects[obj.id];
			try { obj.Delete(); } catch(e){}
	    }
		mmMap.clearMap=function(){
			for(var i in this.__storedObjects){
				try{ this.__storedObjects[i].Delete(); } catch(e){}
			}
			this.__storedObjects={}
		}
	    mmMap.clearDirtyStoredObjects=function(){
	    	for(var i in this.__storedObjects) this.clearDirtyStoredObject(i);
	    }
		mmMap.clearDirtyStoredObject=function(id){ //returns true if the object was deleted
	    	var f=true;
    		try{ f=mmDocument.SearchObjectById(id); } catch(e){ f=false; }
    		if(!f) delete this.__storedObjects[id];
			return !f;
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
		//		mmMap Boundary management
		//***********************************************************************************
		mmMap.retrieveBoundaryByTopic=function(topic){
			try {
				return mmMap.retrieveObject((!!topic) ? topic.GetBoundary() : null);
			} catch(e){
				return null;
			}
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
			var oSearch={},oFound=[];
			if(typeof id=='Array'){
				for(var i=0; i<id.lenght; i++) oSearch[id[i]]=true;
			} else {
				oSearch[id]=true;
			}
	    	for(var s in this.__storedObjects)	{
	    		if (this.__storedObjects[s].type == 'topic' && this.__storedObjects[s].contact && this.__storedObjects[s].contact.Id in oSearch) {
					if(typeof id=='Array') oFound.push(this.__storedObjects[s]);
					else return this.__storedObjects[s];
				}
	    	}
	    	if(typeof id=='Array')return oFound;
			return null;
	    }
	    mmMap.retrieveTopicByReportsToId=function(id){
	    	var ret=[];
	    	for(var s in this.__storedObjects)	{
	    		if(this.__storedObjects[s].type=='topic' &&  this.__storedObjects[s].contact && this.__storedObjects[s].contact.ReportsToId==id) ret.push(this.__storedObjects[s]);
			}
	    	return ret;
	    }
	    mmMap.retrieveTopicByCallout=function(obj){
	    	var so= this.retrieveObjectCallout(obj);
			if(this.typeOf(so)=='Relationship' || !so) return null;
	    	return so;
	    }
		mmMap.retrieveAllObjectsIds = function(opportunitiesFilteredMap){
			var objList=[];
			for (var s in this.__storedObjects) {
				objList.push(this.__storedObjects[s].id);
			}
			return objList;
		}
		mmMap.retrieveFilteredOpportunityObjects=function(opportunitiesFilteredMap){
			var objectFilteredMap={},objectFilteredList=[],objectFilteredContactsIds={},objectFilteredRelatedContactsIds={};
	    	//filtering objects
			var topicCounter=0;
			for(var s in this.__storedObjects)	{
				var obj=this.__storedObjects[s];
	    		if(obj.type=='topic' &&  obj.contact && obj.opportunityContactRoles) {
					topicCounter++;
					for(var k in obj.opportunityContactRoles){
						if (!!opportunitiesFilteredMap[obj.opportunityContactRoles[k].OpportunityId]) {
							objectFilteredMap[obj.id] = true;
							objectFilteredContactsIds[obj.contact.Id]=true;
						}
				    }		
				}
	    	}
			//filtering relationships
			for(var s in this.__storedObjects)	{
				var obj=this.__storedObjects[s];
	    		if(this.typeOf(obj)=='Relationship') {
					for(var k in objectFilteredContactsIds){
				    	if(obj.relationship.primaryContact__c==k){
							objectFilteredRelatedContactsIds[obj.relationship.secondaryContact__c]=true;
						} else if(obj.relationship.secondaryContact__c==k){
							objectFilteredRelatedContactsIds[obj.relationship.primaryContact__c]=true;
						}
					}		
				}
	    	}
			//adding related objects
	    	for(var s in this.__storedObjects)	{
				var obj=this.__storedObjects[s];
	    		if(obj.type=='topic' &&  obj.contact && obj.contact.Id in objectFilteredRelatedContactsIds) objectFilteredMap[obj.id] = true;
	    	}
			for(var i in objectFilteredMap)objectFilteredList.push(i);
			return [objectFilteredList,topicCounter];
		}
	    //***********************************************************************************
		//		mmMap callout management
		//***********************************************************************************	    
	    mmMap.retrieveCalloutAssociatedObject=function(callout){
	    	if(callout.callout) return this.retrieveObject(callout.relatedObject);
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
	    mmMap.ReparentObject=function(child,parent,withExpandParentNodes){
			if(mmMap.clearDirtyStoredObject(child.id) || mmMap.clearDirtyStoredObject(parent.id)) return;
			if (!!withExpandParentNodes) {
				mmMap.ExpandBranchSegment(parent);
				setTimeout(function(child, parent){
					mmw.ReparentObject(child, parent);
					mmMap.clearEventQueue();
				}.createClosure(null, child, parent), 400);
			}
			else {
				mmw.ReparentObject(child, parent);
				mmMap.clearEventQueue();
			}
	    }
		mmMap.ExpandBranchSegment=function(lastNodeToExpand){
			var chainTopic = lastNodeToExpand, chainTopics = [];
			while (!!chainTopic && chainTopic!=mmCentralTopic && !!chainTopic.contact) {
				chainTopics.push(chainTopic);
				chainTopic = mmMap.retrieveTopicByContactId(chainTopic.contact.ReportsToId);
			}
			for (var i = chainTopics.length - 1; i >= 0; i--) {
				chainTopics[i].SetCollapsed(false);
			}
		}
	    //***********************************************************************************
		//		mmMap Event Listening
		//***********************************************************************************
		mmMap.stopObjectsEventListening=function(){
			this.DeleteEvent("uri:test:OnCreated");
			this.DeleteEvent("uri:test:OnModified");
			this.DeleteEvent("uri:test:OnDeleted");
			this.DeleteEvent("uri:test:OnMoved");
			this.DeleteEvent("uri:test:OnClicked");
			this.DeleteEvent("uri:test:OnDialogOpen");
			this.DeleteEvent("uri:test:OnDialogClose");
		}
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
						//if(!obj) debugger;
						//console.debug("Object modified, type is " + obj.type +  " prop " + prop);
						obj=mmMap.retrieveObject(obj);
						if(!!obj && prop=='Text' && obj.isCallout) {
							mmMap.clearEventQueue();
							if(obj.isCallout) mainController.updateCalloutText(obj);
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
			var inFrame=framed;
			if(getPageSize().windowHeight<=600) inFrame=true;
			detailOverlay.hide();
			if(selected){
				var topics=mmDocument.GetSelectedTopics(),topic;
				if(topics.length>0) topic=mmMap.retrieveObject(topics[0]);
				if(topic && inFrame) mmDocument.PrintNoPreview(topic);
				else if(topic) mmDocument.Print(topic);
			} else if(!inFrame) mmDocument.Print();
			else mmDocument.PrintNoPreview();
		}
		mmMap.RemoveFilters=function(){
			this.filtered=false;
			mmDocument.RemoveFilters();
		}
		mmMap.FilterObjects=function(f,a,b){
			this.filtered=true;
			mmDocument.FilterObjects(f,a,b);
		}
		mmMap.FilterObjectsById=function(f,a,b){
			this.filtered=true;
			mmDocument.FilterObjectsById(f,a,b);
		}
		mmMap.isFiltered=function(){
			return !!this.filtered;
		}
	    mmMap.appCustomStart = function() {
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
		    	CONFIG.alternateTopicShape=MmwEnumerations.MmwTopicShape.mmTopicShapeHexagon;
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
		    	mainController.loadInitialMap(true);
		    	
				detailOverlay = new Ext.Window({
				    layout:'fit',
				    width:300,
				    resizable:false,
				    closable:true,
				    //collapsible:true,
				    closeAction:'hide',
				    plain: true,
					id:'detailOverlayDialog',
					modal:true,
					shadow:false,
					bodyBorder:false,
					autoHeight :false,
					//height:400,
					autoScroll:true,
					animCollapse:true,
					draggable :false,
					modal : false,
					//cls:'x-panel-body',
					renderTo:Ext.get(mmContainer.dom.parentNode),
					//unstyled:true,
					title:'<B>Contact Details</B>'
				});
				detailOverlay._show=detailOverlay.show;
				detailOverlay.show=function(){
					var vis=mmDocument.GetScrollbarsVisible(),
						hsbv=vis[MmwEnumerations.MmwChromeElements.mmHorizontalScrollbar],
						vsbv=vis[MmwEnumerations.MmwChromeElements.mmVerticalScrollbar],
						el=this.getEl(),
						isMacSafari=Ext.isMac && Ext.isSafari,
						ofst=(Ext.isIE7)?(CONFIG.UITheme!='Theme3')?[19,2,0,47,30]:[29,12,0,47,30]:(CONFIG.UITheme!='Theme3')?[17,0,0,47,30]:[27,10,9,47,30];
					this.hidden = false;
					el.dom.style.visibility='visible';
					this.setWidth(parseInt(mmContainer.getWidth()*0.25));
					el.setLeft(mmContainer.getLeft() + mmContainer.getWidth() - el.getWidth() - ((vsbv)?ofst[0]:ofst[1]) + getScrollXY()[0]);
					el.setTop(toolBar.getEl().getHeight()+ofst[2]);
					var h=mmContainer.getHeight() - ((hsbv)?ofst[3]:ofst[4]),cont=Ext.get('detailTableContent');
					if(typeof this.bodyGap=='undefined') {
						this.setHeight(h);
						this.bodyGap=this.body.getHeight()-h;
					}
					var bh=this.body.getHeight(),th=this.getHeight();
					if (!!cont) {
						var ch=cont.getHeight()+18;
						if(ch>h+this.bodyGap) ch=h+this.bodyGap;
						if(ch==bh) return;
						this.body.setHeight(ch);
					} 
				}
				detailOverlay.hide=function(){
					this.hidden = true;
					var el=this.getEl();
					el.dom.style.visibility='hidden';
					el.setLeft(-10000);
					el.setTop(-10000);
				}
				//detailOverlay.addListener('hide', function(){ detailOverlay.enableShow=false; toolBar.items.get('detail').toggle(false,true);} );
				detailOverlay.render();
				detailOverlay.hide();
				detailOverlay.enableShow=true;
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
	    
	    //***********************************************************************************
		//		Toolbar Initialization
		//***********************************************************************************
		var colorMenu = new Ext.menu.ColorMenu({
        	listeners:ie7MenuWidthFix,
	        handler: function(palette, color){
	            setTimeout(function(color){ mainController.createBoundary(color)}.createClosure(null,color),1);
				try { palette.select(''); }catch(e){}
				palette.value=null;
	        }  
	    });
		colorMenu.palette.colors = CONFIG.boundariesPalette;
		
	    toolBar = new Ext.Toolbar({
			style: {
                border: '1px solid #999999',
                borderBottom: '0px'
            },
			forceLayout:true,
	    	renderTo:'mmwctoolbar',
	    	minWidth: 0,
	        items: [
				{
					text: 'New&nbsp;',
	                iconCls: 'toolbar-button new',
	                id:'insertContact',
			        handler: function(){setTimeout(function(){mainController.createNewContact()},100);},
	                disabled:true
	            },
				{
					text: 'Insert&nbsp;',
	                iconCls: 'toolbar-button insert',
	                id:'insert',
			        menu:{
						autoWidth:Ext.isIE7,forceLayout:Ext.isIE7,
			        	listeners:ie7MenuWidthFix,
				        items:[
							{ id:'insertRelationship',handler: function(){setTimeout(function(){mmMap.InteractiveAddRelationship();},100);},text: "Relationship"},
							{ id:'insertCallout',handler: function(){setTimeout(function(){mainController.createCallout()},100);},text: "Comment"},
							{ id:'insertBoundary',text: "Boundary", menu:colorMenu }//,
							/*{ id:'insertIconMarker',text: "Icon Marker", menu:mapMarkersMenu },*/
							//{ id:'insertEmptyContect',handler: function(){setTimeout(function(){mainController.createContact("New Contact")},100);},text: "TEST TEST Create"}
				        ]
				    },
	                disabled:true
	            },'-',
				{
					text: 'Edit&nbsp;',
	                iconCls: 'toolbar-button edit',
	                id:'edit',
			        handler: function(){setTimeout(function(){mainController.editContact()},100);},
	                disabled:true
	            },
				{
	                text: 'Delete&nbsp;',
	                iconCls: 'toolbar-button delete',
	                id:'deleteBtn',
	                handler: function(){mainController.deleteObject()},
	                disabled:true
	            },'-',
	            {
	                text: 'Opportunities&nbsp;',
	                //scale:'medium',
	                iconCls: 'toolbar-button opportunities',
	                id:'opportunitiesroles',
	                menu:{
	                	minWidth: 0,
			        	listeners:ie7MenuWidthFix
	                },
	                disabled:true
	            },
	            {
			        text: 'External&nbsp;',
			        enableToggle: true,
			        iconCls:'toolbar-button external',
			        id:'external',
			        toggleHandler: function onItemToggle(item, pressed){
			        	mainController.updateExternal(pressed);
				    },
			        pressed: false,
			        disabled:true
			    },
	            {
	                text: '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',
	                //scale:'medium',
	                iconCls: 'toolbar-button favors',
	                id:'favors',
	                menu:{
						autoWidth:Ext.isIE7,forceLayout:Ext.isIE7,
			        	listeners:ie7MenuWidthFix,
	                	minWidth: 0
	                },
	                disabled:true
	            },
				{
					//In this menu the items whose id start with opptyFilter are used by the application. 
					//Changing that part of the id would compromise the functionality
	                text: 'Filter&nbsp;',
	                //scale:'medium',
	                iconCls: 'toolbar-button filter',
	                id:'opptyFilterMenu',
			        menu:{
			        	listeners:ie7MenuWidthFix,
			        	autoWidth:Ext.isIE7,forceLayout:Ext.isIE7,
				        items:[
				            {id:'opptyFilterComboTitle', text: 'Show Opportunities&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', activeClass:''},
				            '-'
				        ]
				    },
	                disabled:true
	            },{
	            	text: 'Show All&nbsp;',
	                iconCls: 'toolbar-button clearFilter',
	                id:'clearFilter',
	                handler: function(){utilities.clearFiltering();},
	                disabled:true
	            },'-',
				{
	                text: 'Print&nbsp;',
	                iconCls: 'toolbar-button print',
	                id:'print',
			        menu:{
			        	listeners:ie7MenuWidthFix,
						autoWidth:Ext.isIE7,forceLayout:Ext.isIE7,
				        items:[
				            { id:'printAll',handler: function(){mmMap.print(false)},text: 'Print Org Chart'},
				            { id:'printSingle',handler: function(){mmMap.print(true)},text: 'Print Selected Contact'}
				        ]
				    },
	                disabled:true
	            },
				{
					text: 'Refresh&nbsp;',
	                iconCls: 'toolbar-button refresh',
	                id:'refresh',
	                handler: function(){mainController.clearMap(true)},
	                disabled:true
	            },'->',
				{
	                text: 'Help&nbsp;',
	                iconCls: 'toolbar-button help',
	                id:'help',
			        menu:{
			        	listeners:ie7MenuWidthFix,
						autoWidth:Ext.isIE7,forceLayout:Ext.isIE7,
				        items:[
				            { id:'gotoHelp',handler: function(){ window.open('http://onlinehelp.mindjet.com/help/mj_orgchart/ENU/mindjet_org_chart_help.htm','_blank','status=1,width=800,height:600')},text: 'Help'},
							{ id:'prodName', text:'Mindjet Deal Navigator 1.0',disabled:true},
				            { id:'ver',text: 'Version 1.129 (1031)',disabled:true,style:'color:black !important;'}
				        ]
				    },
	                disabled:true
	            }
	        ]
	    });
    	toolBar.doLayout();
/*	    new Ext.ToolTip({
	        target: 'clearFilter',
	        html: 'Clear Filter'
	    });
	    new Ext.ToolTip({
	        target: 'print',
	        html: 'Print'
	    });
	    new Ext.ToolTip({
	        target: 'refresh',
	        html: 'Refresh'
	    });
	    new Ext.ToolTip({
	        target: 'detail',
	        html: 'Detail',
	        defaultAlign :"tr-b"
	    });
	    new Ext.ToolTip({
	        target: 'help',
	        html: 'Help',
	        defaultAlign :"tr-b"
	    });
	    new Ext.ToolTip({
	    	target:'insertContact',
	    	html:'New Contact'
	    });
	    new Ext.ToolTip({
	    	target:'insert',
	    	html:'Insert'
	    });
	    new Ext.ToolTip({
	    	target:'deleteBtn',
	    	html:'Delete'
	    });
	    new Ext.ToolTip({
	    	target:'edit',
	    	html:'Edit Contact'
	    });
	    new Ext.ToolTip({
	    	target:'opptyFilterMenu',
	    	html:'Filter'
	    });*/
		//***********************************************************************************
		//		toolBar.disableItems
		//		use:
		//			toolBar.disableItems({id1:true,id2:true,id3:true...});
		//***********************************************************************************
    	toolBar.disableItems=function(items,menu){
    		if(!menu) menu=this; if(!items) items={};
    		if(!menu.items) return;
    		for(var i=0;i<menu.items.items.length;i++){
    			menu.items.items[i][!!items[menu.items.items[i].id]?'disable':'enable']();
    			if(menu.items.items[i].menu) arguments.callee(items,menu.items.items[i].menu)
    		}
    	}
	/*}   
	catch(err)
	{
	    alert(err);
		debugger
	}*/
}

//***********************************************************************************
//		Global Configuration
//***********************************************************************************

CONFIG.msgSeparationToken='%22#';
CONFIG.defaultBoundaryFillAlpha="88";
CONFIG.defaultBoundaryOutlineAlpha="FF";
CONFIG.defaultBoundaryOutlineColor="999999";
CONFIG.featuredBoundaryOutlineColor="A0C0FF";
CONFIG.featuredBoundaryOutlineWeight=6;
CONFIG.defaultBoundaryOutlineWeight=1;
CONFIG.calloutBackgroundColor="FFD0E0FF";
CONFIG.calloutLineColor="FFD0E0FF";
CONFIG.relationshipLineColor="FFA0C0FF";
CONFIG.relationshipExternalLineColor="FFFF0000";    
CONFIG.mapMarkersIcons=["arrow-down.png",
                "arrow-left.png",
                "arrow-right.png",
                "arrow-up.png",
                "bomb.png",
                "book.png",
                "broken-connection.png",
                "calendar.png",
                "camera.png",
                "cellphone.png",
                "check.png",
                "clock.png",
                "coffee-cup.png",
                "dollar.png",
                "email.png",
                "emergency.png",
                "euro.png",
                "exclamation-mark.png",
                "fax.png",
                "flag-black.png",
                "flag-blue.png",
                "flag-green.png",
                "flag-orange.png",
                "flag-purple.png",
                "flag-red.png",
                "flag-yellow.png",
                "folder.png",
                "glasses.png",
                "hourglass.png",
                "house.png",
                "information.png",
                "judge-hammer.png",
                "key.png",
                "letter.png",
                "lightbulb.png",
                "magnifying-glass.png",
                "mailbox.png",
                "marker1.png",
                "marker2.png",
                "marker3.png",
                "marker4.png",
                "marker5.png",
                "marker6.png",
                "marker7.png",
                "meeting.png",
                "megaphone.png",
                "no-entry.png",
                "note.png",
                "on-hold.png",
                "padlock-locked.png",
                "padlock-unlocked.png",
                "phone.png",
                "question-mark.png",
                "redo.png",
                "resource1.png",
                "resource2.png",
                "rocket.png",
                "rolodex.png",
                "scales.png",
                "smiley-angry.png",
                "smiley-happy.png",
                "smiley-neutral.png",
                "smiley-sad.png",
                "smiley-screaming.png",
                "stop.png",
                "thumbs-down.png",
                "thumbs-up.png",
                "traffic-lights-red.png",
                "two-end-arrow.png",
                "two-feet.png",
                "unknown.png"];
CONFIG.boundariesPalette=['FFFFFF','FF00FF','FFCC00','FFFF00','00FF00','00FFFF','00CCFF','FF9900','C0C0C0','FF99CC','FFCC99','FFFF99','CCFFCC','CCFFFF','99CCFF','CC99FF'];

//***********************************************************************************
//		Global Objects Store
//***********************************************************************************

window.__objects={}
var store=function(key1,key2,obj){
	if(!window.__objects[key1]) window.__objects[key1]={};
	window.__objects[key1][key2]=obj;
}
var retrieve=function(key1,key2){
	if(!key1 || !window.__objects[key1]) return null;
	if(!key2){
		for(var i in window.__objects[key1]) return window.__objects[key1][i];
	} else if(!window.__objects[key1][key2]) return null;
	else return window.__objects[key1][key2];
}


//***********************************************************************************
//		CallBacks Handling
//***********************************************************************************
var callbacksRepository={},onCallbacksErrorRepository={};
var iResponse,iResponseValue,iRequest,iRequestValue;

var refreshRequestHandlers = function(){
	iRequest = document.getElementById(CONFIG.iRequest);
	iRequestValue = document.getElementById(CONFIG.iRequestValue);
}
var refreshResponseHandlers = function(){
	iResponse = document.getElementById(CONFIG.iResponse);
	iResponseValue = document.getElementById(CONFIG.iResponseValue);
}
var responseHandlerProxy=function(){
	refreshResponseHandlers();
	var oResponseValue=(iResponseValue.value!="")?iResponseValue.value.split(CONFIG.msgSeparationToken).join('"'):"";
	/*if(oResponseValue!=unescape(oResponseValue)){
		responseHandlerProxy.defaultErrorResponder("Response contains values that indicate a possible code injection attack");
	} else {*/
		var oResponseValue=(oResponseValue!="")?evalJson(oResponseValue):{}
		if(oResponseValue.status=='error'){
			(onCallbacksErrorRepository[iResponse.value]||responseHandlerProxy.defaultErrorResponder)(oResponseValue.errorMessage);
		} else if(!!callbacksRepository[iResponse.value]) {
			callbacksRepository[iResponse.value](oResponseValue);
		}
	//}
	delete callbacksRepository[iResponse.value];
	delete onCallbacksErrorRepository[iResponse.value];
}
responseHandlerProxy.defaultErrorResponder=function(errorMessage){
	Ext.Msg.show({
	   title:'Server Error',
	   msg: errorMessage,
	   buttons: Ext.Msg.OK,
	   fn: function(){mainController.clearMap(true);},
	   icon: Ext.MessageBox.WARNING
	});
};

//***********************************************************************************
//		Request Handling
//***********************************************************************************
//to initiate a request use requestHandler(requestName,JSONRequestValue,callBackFunction(response object),errorFunction (errorMessage))
var requestHandler=function(req,reqValue,callBackFunction,errorFunction){
	refreshRequestHandlers();
	if(!!callBackFunction) callbacksRepository[req]=callBackFunction;
	if(!!errorFunction) onCallbacksErrorRepository[req]=errorFunction;
	iRequest.value=req;
	iRequestValue.value=(!!reqValue)?jsonToString(reqValue):"";
	requestHandlerProxy();
}


//***********************************************************************************
//		General Utilities
//***********************************************************************************
get$=function(s){ return document.getElementById(s);} //document.getElementById

function CLEARJSONCHARS(str){
	return str.replace(/[\}\{]/g,"");
	return str;
}
function HTMLENCODE(str){
	var m={'}':'&#125;','{':'&#123;','[':'&#91;',']':'&#93;',':':'&#58;','"':'&quot;',"'":'&apos;','<':'&lt;','>':'&gt;'};
	str=str.split('&').join('&amp;');
	return str.replace(/[\}\{\[\]:"'><]/g,function(a){return m[a];});
}
function HTMLDECODE(str){
	var m={'}':'&#125;','{':'&#123;','[':'&#91;',']':'&#93;',':':'&#58;','"':'&quot;',"'":'&apos;','<':'&lt;','>':'&gt;'};
	str=str.toString().split('&amp;').join('&');
	for(var i in m){
		str=str.toString().split(m[i]).join(i);
	}
	
	return str;
}

Function.prototype.createClosure=function(){	//	createClosure(scope, argument1,argument2...
	var scope=arguments[0]||null,aArguments=[];
	for(var i=1;i<arguments.length;i++) aArguments.push(arguments[i]); //no slice on arguments
	var f=function(){
		var c=arguments.callee, f=c.delegateFunction, a=c.delegateArguments, s=c.delegateScope, args=[];
		for(var i=0;i<a.length;i++) args.push(a[i]);
		for(var i=0;i<arguments.length;i++) args.push(arguments[i]); //no slice on arguments
		var ret= f.apply(s,args);
		if(!!ret) return ret;
	};
	f.delegateArguments=aArguments;
	f.delegateScope=scope;
	f.delegateFunction=this;
	//this.delegateArguments=aArguments;
	//this.delegateScope=scope;
	return f;
}
String.prototype.lTrim=function(){return this.replace(/^\s+/gm,'')};
String.prototype.rTrim=function(){return this.replace(/\s+$/gm,'')};
String.prototype._replace=function(s,r){return this.split(s).join(r)};
evalJson=function(strJSON){
	if(!strJSON || strJSON=="") strJSON="null"; strJSON=strJSON.lTrim().rTrim(); eval("a=" + strJSON); return a; 
}


jsonToString = function(oJson,propName) {
    var ret,val,propName=propName || "";
    if(typeof(oJson) != "object" || oJson instanceof Date || oJson==null) {
        if(typeof(oJson)== "undefined" || oJson==null) val=""
        else if(oJson instanceof Date) val=oJson.toShortString()
        else if(isNaN(oJson)){
            var m = {'\b': '\\b','\t': '\\t','\n': '\\n', '\f': '\\f','\r': '\\r','"' : '\\"', '\\': '\\\\'};
            if (/["\\\x00-\x1f]/.test(oJson)) {
                val=  oJson.replace(/[\x00-\x1f\\"]/g, function (a) {
                    var c = m[a];
                    if (c) return c;
                    c = a.charCodeAt();
                    return '\\u00' + Math.floor(c / 16).toString(16) + (c % 16).toString(16);
                });
            } else val= oJson;
        } else val= oJson.toString();
		var m={',':'&#44;','}':'&#125;','{':'&#123;','[':'&#91;',']':'&#93;',':':'&#58;','"':'&quot;',"'":'&apos;'};
        ret = "\"" + propName + "\":\"" + val.replace(/[\}\{\[\]:"',]/g,function(a){return m[a];}) + "\"";
    } else if(oJson instanceof Array) {
        ret = ((propName=="")?"":'"' + propName + '"') + ":["
        for(var i=0;i<oJson.length;i++){ret += arguments.callee(oJson[i],"") + ",";}
        ret=ret.slice(0,ret.length-1);
        ret+="]";
    } else if(typeof oJson!="function"){
        ret = ((propName=="")?"":'"' + propName + '"') + ":{"
        for(var i in oJson){ret += arguments.callee(oJson[i],i)+ ",";}
        ret=ret.slice(0,ret.length-1);
        ret+="}";
    } else ret = "\"" + propName + '":"null"';
    if(ret.indexOf(":")==0) ret=ret.slice(1,ret.length);
    return ret;
}

var getPageSize=function(){
    var xScroll, yScroll;
    if (window.innerHeight && window.scrollMaxY) {    
        xScroll = document.body.scrollWidth;
        yScroll = window.innerHeight + window.scrollMaxY;
    } else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
        xScroll = document.body.scrollWidth;
        yScroll = document.body.scrollHeight;
    } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
        xScroll = document.body.offsetWidth;
        yScroll = document.body.offsetHeight;
    }
    
    var windowWidth, windowHeight;
    if (self.innerHeight) {    // all except Explorer
        windowWidth = self.innerWidth;
        windowHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
        windowWidth = document.documentElement.clientWidth;
        windowHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
        windowWidth = document.body.clientWidth;
        windowHeight = document.body.clientHeight;
    }    
    
    // for small pages with total height less then height of the viewport
    if(yScroll < windowHeight){
        pageHeight = windowHeight;
    } else { 
        pageHeight = yScroll;
    }

    // for small pages with total width less then width of the viewport
    if(xScroll < windowWidth){    
        pageWidth = windowWidth;
    } else {
        pageWidth = xScroll;
    }

    //arrayPageSize = new Array(pageWidth,pageHeight,windowWidth,windowHeight) 
    return {
        pageWidth: pageWidth,
        pageHeight: pageHeight,
        windowWidth: windowWidth,
        windowHeight: windowHeight
    };
}
var getScrollXY=function() {
	var scr=bodyDiv.getScroll();
	return[scr.left-bodyDiv.getPadding('l'),scr.top-bodyDiv.getPadding('t')];
}

//***********************************************************************************
//		Ext JS Extensions
//***********************************************************************************


//ExtJS Menu Fix
var ie7MenuWidthFix = (Ext.isIE7)?{
	show: function(self){
		var f=function(){
			self.el.dom.style.width = '200px';
			if (self.parentMenu) self.parentMenu.el.dom.style.width = '200px';
		}
		var f1=function(){
			self.el.dom.style.width = 'auto';
			if (self.parentMenu) self.parentMenu.el.dom.style.width = 'auto';
		}
		setTimeout(f, 1);
		setTimeout(f1, 100);
	}
}:{};
//***********************************************************************************
//		Ext JS Components
//***********************************************************************************

Ext.ns('Mindjet.menu');

Mindjet.menu.MapMarkerIconController= function(config){
    Ext.apply(this, config);
    if(!this.id){
        this.id = Ext.id();
    }
    Mindjet.menu.MapMarkerIconController.instances[this.id]=this;
};
Mindjet.menu.MapMarkerIconController.instances={};
Mindjet.menu.MapMarkerIconController.clickHandler =  function(gridId,value){
    var grid=Ext.getCmp(gridId);
    grid.fireEvent("select",value);
};
Mindjet.menu.MapMarkerIconController.prototype = {
    init : function(grid){
        this.grid = grid;
    },
    renderer : function(v, p, record, rowIndex){
		return (v!=null)?"<img style='width:16px; height:16px; cursor:pointer' src='"+ CONFIG.baseURLforMapMarkersIcons+v +"' onmouseup='Mindjet.menu.MapMarkerIconController.clickHandler(\""+ this.grid.id +"\",\""+ v +"\");' />":"&nbsp;";
    }
};

Mindjet.menu.MapMarkersMenu = Ext.extend(Ext.menu.Menu, {
    enableScrolling : false,
    hideOnClick : true,
    initComponent : function(){
		var plugins=[],store=[],cm=[],cols=5,config=this.initialConfig;
		for(var i=0;i<cols;i++){
			var dic=new Mindjet.menu.MapMarkerIconController({
				       width: 32,
				       height: 32,
				       resizable:false, 
				       sortable: false,
				       trackMouseOver:false
				    });
			plugins.push(dic);
			cm.push(dic);
			store.push(i+"");
		}
		store = new Ext.data.ArrayStore({
		    fields: store
		});
		while(config.iconsList.length % cols!=0) {
			config.iconsList.push(null);
		}
		var i=0,data=[]
		while(i<config.iconsList.length){
			data.push(config.iconsList.slice(i,i+cols));
			i+=cols;
		}
		store.loadData(data);
        Ext.apply(this, {
            plain: true,
            showSeparator: false,
            items: this.grid = new Ext.grid.GridPanel(
            	{
            		hideHeaders:true,
            		plugins:plugins,
            		cm:new Ext.grid.ColumnModel(cm),
            		autoHeight :true,
            		store:store,
            		width:cols*32,
            		style:''
            	}
            )
        });
    	this.grid.addEvents({"select" : true});    
        this.grid.purgeListeners();
        Mindjet.menu.MapMarkersMenu.superclass.initComponent.call(this);
        this.relayEvents(this.grid, ['select']);
        this.on('select', this.menuHide, this);
        if(this.handler){
            this.on('select', this.handler, this.scope || this);
        }
    },
    menuHide : function(){
        if(this.hideOnClick){
            this.hide(true);
        }
    }
});