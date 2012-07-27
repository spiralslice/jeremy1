//***********************************************************************************
//		Main Controller
//***********************************************************************************
var startDate=new Date();
var mainController={
	PageSize:80,
	startContactPoller:function(){
		contactsHash={};	//global variable
		contactLayers=[];	//global variable
        requestHandler("getAccountInfo",
			null,
			function(response){
				account=response.Account;
				if(!!response.FeaturedContact) {
					featuredContact=response.FeaturedContact;
				}
				if(!!response.FeaturedOpportunity){
					featuredOpportunity=response.FeaturedOpportunity;
				}
				utilities.initFromAdminObject(response);
				utilities.assignOpportunitiesContactRoles(response);
				
				//Start pooling the contacts from the server
				mainController.contactPoller(mainController.PageSize,'null');
			}
		);
	},
	contactPoller:function(PageSize,ContactIDs){
		requestHandler("getContactsPage",
			{
				PageSize:PageSize,
				ContactIDs:ContactIDs
			},
			function(response){
				//contactObject:{contact:dataObject,childCount:int,childContacts[],layer:int,topic:oTopic:boolean,loaded:(means with all the childs)boolean,childRendered:boolean}
				//contactsHash={contactId:contactObject};
				//contactLayers=[[contactObject]]
				
				var contacts=response.Contacts,childCount=response.ContactsChildCount;
				//Boundaries
				//Callouts
				//Relationships
				//ContactsSecurity (probably in contactObject)
				if(!contactsHash['central']) {
					contactsHash['central']={contact:null,childCount:parseInt(response.ResultSize),childContacts:[],loaded:false,layer:0,childRendered:false};
					contactLayers[0]=[contactsHash['central']];
				}
				for(var i in contacts){
					var current=contactsHash[contacts[i].Id]={contact:contacts[i],childCount:childCount[contacts[i].Id],childContacts:[],loaded:childCount[contacts[i].Id]==0,childRendered:false};
					var reportsTo=(contacts[i].ReportsToId!='null')?contacts[i].ReportsToId:'central';
					contactsHash[reportsTo].childContacts.push(current);
					current.layer=contactsHash[reportsTo].layer+1;
					if(contactLayers.length<=current.layer)contactLayers[current.layer]=[];
					contactLayers[current.layer].push(current);
					if(contactsHash[reportsTo].childContacts.length==contactsHash[reportsTo].childCount) contactsHash[reportsTo].loaded=true;
				}
				if(response.HasNext=='true'){
					setTimeout(mainController.contactPoller.createClosure(null,mainController.PageSize,""),100);
					return;
				} else if(response.ContactCount!='0'){
					for(var i=0;i<contactLayers.length;i++){
						for(var h=0;h<contactLayers[i].length;h++){
							if(!contactLayers[i][h].loaded){
								setTimeout(mainController.contactPoller.createClosure(null,mainController.PageSize,(!contactLayers[i][h].contact)?'null':"'" + contactLayers[i][h].contact.Id + "'") ,100);
								return;
							}
						}
					}
				}
			}
		);
	},
	startContactDrawer:function(withInit){
		utilities.setCentralTopicText();
		mmCentralTopic.oContact=contactsHash['central'];
		contactsHash['central'].topic=mmCentralTopic;
		if(!!withInit) {
			var MapObjectConstraints=mmCentralTopic.GetMapObjectConstraints();
			MapObjectConstraints.SetConstrainedChildTypesActivated(true);
			MapObjectConstraints.RemoveAllTypes();
			MapObjectConstraints.AddAllowedChildTypes('isUpdateableReportsTo');
			//ReadOnly
			MapObjectConstraints.EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmTextReadOnly);
		} else {
			featuredContact=null;
			featuredOpportunity=null;
		}
		//This instruction generates some kind of internal error that may stop the loading of the map
		setTimeout(function(){
				mmCentralTopic.GetSubTopicLayout().SetGrowthDirection(MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionOrgChart);
			},1000);
		if(!!withInit) {
			mmMap.initObjectsEventListening();
			window.startMainPoller();
			window.startActionPoller();
			/*if(!!featuredContact) {
				setTimeout(
					function(){
						utilities.setDetailContent(mmMap.retrieveTopicByContactId(featuredContact.Id));
						mmMap.FilterObjects(function(obj){
						    obj=mmMap.retrieveObject(obj);
						    if (!!obj && !!obj.contact && !!featuredContact && featuredContact.Id==obj.contact.Id){
						    	setTimeout(function(topic){
									mmMap.setFocus(topic);
									mmMap.setSelected(topic);
								}.createClosure(null,obj),2000);
								return true;
						    }
						},MmwEnumerations.MmwFilter.mmHideOthers,MmwEnumerations.MmwFilter.mmShowSubTopics);
					},3000);
			}*/
		}
		mmMap.clearEventQueue();
		setTimeout(function(){utilities.manageSelectedObject(mmCentralTopic);},100);
		//these should go after the first objects are created?!!
		setTimeout(function(){
			Ext.Msg.hide();
			mmCentralTopic.GetSubTopicLayout().SetGrowthDirection(MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionOrgChart);
		},2000);
		setTimeout(function(){
			mmCentralTopic.GetSubTopicLayout().SetGrowthDirection(MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionOrgChart);
		},4000);
		mainController.contactDrawer(mmCentralTopic);
	},
	contactDrawer:function(topic,layer){
		var counter=10,interval=2000;
		if(typeof layer=='undefined') layer=2;
		var oMainContact=topic.oContact;
		if(oMainContact.childRendered){
			var needsRendering=false;
			for(var i=0;i<oMainContact.childContacts.length;i++){
				if(!oMainContact.childContacts.childRendered) needsRendering=true;
			}
			if(!needsRendering) return;
		}
		//contactObject:{contact:dataObject,childCount:int,childContacts[],layer:int,topic:oTopic:boolean,loaded:(means with all the childs)boolean,childRendered:boolean}
		//contactsHash={contactId:contactObject};
		//contactLayers=[[contactObject]]
		
		if(!oMainContact.loaded){
			if(oMainContact.childCount>0 && oMainContact.childContacts.length==0){
				//if(topic!=mmCentralTopic) topic.SetCollapsed(true);
				//topic.loadingTopic=topic.GetSubTopics().AddNewTopic('Loading...');
				//if(topic!=mmCentralTopic) topic.SetCollapsed(true);
			} else {
				if(topic.loadingTopic) {
					topic.loadingTopic.Delete();
					topic.loadingTopic=null;
				}
				for(var i=0;i<oMainContact.childCount;i++){
					if(i<oMainContact.childContacts.length){
						var oContact=oMainContact.childContacts[i];
						if(oContact.childRendered) continue;
						if(!oContact.topic) {
							oContact.topic=utilities.addSubLevelContactToMap(topic,oContact,oContact.contact/*,response.ContactsSecurity*/);
							counter--;
							if(oContact.childCount>0 && layer==1){
								oContact.topic.loadingTopic=oContact.topic.GetSubTopics().AddNewTopic('Loading...');
								if(oContact.topic!=mmCentralTopic) oContact.topic.SetCollapsed(true);
							}
						}
						if(oContact.childCount>0 && layer==2) setTimeout(mainController.contactDrawer.createClosure(null,oContact.topic,1),interval);
					} else {
						//i'm in the unloaded piece, wait 2 seconds and try again
						setTimeout(mainController.contactDrawer.createClosure(null,topic,layer),interval);
						return;
					}
					if(counter==0 && i<oMainContact.childCount.length-1) {
						//can't display more contacts, wait 2 seconds and try again
						setTimeout(mainController.contactDrawer.createClosure(null,topic,layer),interval);
						break;
					}
				}
			}
		} else {
			if(topic.loadingTopic) {
				topic.loadingTopic.Delete();
				topic.loadingTopic=null;
			}
			for(var i=0;i<oMainContact.childContacts.length;i++){
				var oContact=oMainContact.childContacts[i];
				if(oContact.childRendered) continue;
				if(!oContact.topic) {
					oContact.topic=utilities.addSubLevelContactToMap(topic,oContact,oContact.contact/*,response.ContactsSecurity*/);
					counter--;
					if(oContact.childCount>0 && layer==1){
						oContact.topic.loadingTopic=oContact.topic.GetSubTopics().AddNewTopic('Loading...');
						if(oContact.topic!=mmCentralTopic) oContact.topic.SetCollapsed(true);
					}
				} 
				//start loading the following piece
				if(layer==2 && oContact.childCount>0) setTimeout(mainController.contactDrawer.createClosure(null,oContact.topic,1),300);
				if(counter==0 && i<oMainContact.childContacts.length-1) {
					//can't display more contacts, wait 2 seconds and try again
					setTimeout(mainController.contactDrawer.createClosure(null,topic,layer),interval);
					return;
				}
			}
			oMainContact.childRendered=true;
		}
	},
	loadInitialMap:function(withInit){
		Ext.Msg.wait("","Loading...");
        requestHandler("getAccountInfo",
			null,
			function(withInit,response){
				var f=function(){
					Ext.Msg.wait("","Loading " + response.ContactCount + " Contacts...");

					requestHandler("getObjectsMap",
						null,
						function(withInit,response){
							Ext.Msg.wait("","Rendering...");
							var reportsToMap=utilities.parseContactMap(response.Contacts);
							if(!!reportsToMap['central']) {
								for(var i=0;i<reportsToMap['central'].length;i++){
									utilities.addSubLevelContactToMap(mmCentralTopic,reportsToMap['central'][i],reportsToMap,response.ContactsSecurity);
								}
								for(var i in response.Relationships){
									utilities.createRelationshipFromObject(response.Relationships[i]);
								}
								for(var i in response.Callouts){
									utilities.createCalloutFromObject(response.Callouts[i]);
								}
								for(var i in response.Boundaries){
									utilities.createBoundaryFromObject(response.Boundaries[i]);
								}
							}


						}.createClosure(null,withInit)
					);
				}.createClosure(null,withInit,response);
				/*if(response.OriginalContactCount!=response.ContactCount && withInit){
					Ext.Msg.alert("Maximum Capability Reached","Only " + response.ContactCount + " of " + response.OriginalContactCount + " Contacts will be displayed", f);
				} else {*/
					f();
				//}	
			}.createClosure(null,withInit)
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
	createNewContact:function(){
		var f=function(recordType){
			requestHandler("getLastCreatedContact",
				{requestType:'init'},
				function(recordType,response){
					var topics=mmDocument.GetSelectedTopics(),parentTopic=(topics.length<1 || !mmMap.retrieveObject(topics[0]))?null:mmMap.retrieveObject(topics[0]);
					var reportsToData="",recordTypeData="";
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
					mmMap.lastUserCreatedContact=response.Contact;
					
				}.createClosure(null,recordType)
			);
		}
		if(utilities.userHasContactRecordtypes()){
			serverConfigObject.recordTypesDialog.callBackFunction=f;
			serverConfigObject.recordTypesDialog.show();
		}else f();
	},
	handleWindowCallBack:function(oSearch){
		mainController.displayForm(false);		
		if(oSearch.op=="edit"){
			requestHandler("getLastModifiedContact",
				null,
				function(response){
					if(!!mmMap.lastUserModifiedContact && (mmMap.lastUserModifiedContact.Id!=response.Contact.Id || mmMap.lastUserModifiedContact.lastmodifieddate!=response.Contact.lastmodifieddate)){
						var topic=mmMap.retrieveTopicByContactId(response.Contact.Id);
						if(!!topic) {
							topic.securityAccess=response.ContactsSecurity[response.Contact.Id];
							if(topic.contact.ReportsToId!=response.Contact.ReportsToId) {
								topic.Delete();
								mmMap.clearEventQueue();
								Ext.Msg.wait("","Loading...");
								requestHandler("getObjectsMap",
									null,
									function(contact,response){			
										mmMap.clearDirtyStoredObjects();
										//Refreshing Contacts
										//utilities.initFromAdminObject(response.MindjetAdminObject);
										var reportsToMap=utilities.parseContactMap(response.Contacts),
											parentTopic=mmMap.retrieveTopicByContactId(contact.ReportsToId)||mmCentralTopic,
											mapHookup=(parentTopic==mmCentralTopic)?'central':contact.ReportsToId;
										if(!!reportsToMap[mapHookup]) {
											for(var i=0;i<reportsToMap[mapHookup].length;i++){
												if(reportsToMap[mapHookup][i].Id==contact.Id){
													utilities.addSubLevelContactToMap(parentTopic,reportsToMap[mapHookup][i],reportsToMap,response.ContactsSecurity);
												}
											}
										}
										utilities.refreshDecoratingObjects(response);
										//utilities.setFeaturedContactBoundary(reportsToMap,false);
										//utilities.assignOpportunitiesContactRoles(response);
										mmMap.clearEventQueue();
										mmMap.setSelected(parentTopic);
										mmMap.setFocus(parentTopic);
										setTimeout(function(parentTopic){if(!parentTopic.contact) utilities.setDetailContent(parentTopic);}.createClosure(null,parentTopic),400);
										setTimeout(function(){Ext.Msg.hide();},100);
									}.createClosure(null,response.Contact)
								);
							} else {
								utilities.removeFavorIcon(topic,topic.contact);
								utilities.addFavorIcon(topic,response.Contact);
								topic.contact=response.Contact;
								topic.SetText(utilities.getTopicContent(topic));
								utilities.setTopicFormat(topic,response.Contact);
								mmMap.clearEventQueue();
								mmMap.setSelected(topic);
								mmMap.setFocus(topic);
								setTimeout(function(topic){utilities.setDetailContent(topic);}.createClosure(null,topic),400);
								utilities.resetRelationships(topic);
							}
						}
					}
				}
			);
		} else if(oSearch.op=="new"){
			requestHandler("getLastCreatedContact",
				{requestType:'verify'},
				function(response){
					if(!!mmMap.lastUserCreatedContact && !!response.Contact && response.Contact.Id!=mmMap.lastUserCreatedContact.Id){
						//the contact was created
						var parentTopic=(!!response.Contact.ReportsToId && !!mmMap.retrieveTopicByContactId(response.Contact.ReportsToId))?mmMap.retrieveTopicByContactId(response.Contact.ReportsToId):mmCentralTopic;
						parentTopic.SetCollapsed(false);
						var childTopic=parentTopic.GetSubTopics().AddNewTopic("");
						mmMap.storeObject(childTopic);
						childTopic.contact=response.Contact;
						childTopic.securityAccess=response.ContactsSecurity[childTopic.contact.Id];
						childTopic.SetText(utilities.getTopicContent(childTopic));
						utilities.setTopicFormat(childTopic,response.Contact);
						mmMap.clearEventQueue();
						mmMap.setSelected(childTopic);
						mmMap.setFocus(childTopic);
						utilities.setDetailContent(childTopic);
					}
				}
			
			);
		}		
	},
	displayForm:function(display,action){
		display=(typeof display=='boolean')?display:true;
		action=(!action)?'about:blank':action;
		var body=Ext.get(Ext.DomQuery.select("body")[0]),
			bodydiv=Ext.get("bodyDiv"),
			sideBar=Ext.get("sidebarDiv");
		var hookupBar=Ext.get("hookupBar");
		if(!hookupBar){
			hookupBar=body.createChild({tag:'div', id: 'hookupBar', style:'padding: 2px; background-color:#EDEDED; position:absolute; top:0px; left:0px; border: 1px solid #8F8F8F; width: 100%; height:25px;'});
			hookupBar.insertHtml('afterBegin','<button onclick="mainController.displayForm(false);" style="float:left;" class="btn">Return to Mindjet Deal Navigator</button>');
		}
		var editIframe=Ext.get("editIframe");
		if(!editIframe){
			editIframe=body.createChild({tag:'iframe',id: 'editIframe', style:'border: 1px solid #8F8F8F; width:100%; position:absolute; top:25px; left:0px; height:' + (getPageSize().windowHeight-25)+'px'});
		} 
		hookupBar.setDisplayed(display);
		editIframe.setDisplayed(display);
		bodydiv.dom.style.width=(display)?'0px':'100%';
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
					var newSize=getPageSize().windowHeight-25;
					newSize=(newSize>0)?newSize:0;
					editIframe.setHeight(newSize);
					this.previousHeight=this.getHeight();
				}.createClosure(bodydiv,editIframe),500
			);
		}
	},
	moveContact:function(obj,from,to){
		var contact=(obj)?obj.contact:null,mmObjectId=(obj)?obj.GetId():null;
		var toContact=(to || to == mmCentralTopic)?to.contact:null,mmToObjectId=(to)?to.GetId():null;
		if(!!to) to.SetCollapsed(false);
		mmMap.clearEventQueue();
		requestHandler(
			"moveContact",
			{
				mmObjectId:mmObjectId,
				mmToObjectId:mmToObjectId,
				contact:contact,
				toContact:toContact
			},
			function(topic,to,response){
				if(!!topic && !!to && typeof(to.level)=='number') topic.level=to.level+1;
				else topic.level=0;
				utilities.setTopicFormat(topic,topic.contact,topic.level>1,false);
				(function(parentTopic){
					var sts=parentTopic.GetSubTopics(),c=sts.GetCount();
					for(var i=0;i<c;i++){
						var st=sts.Item(i);
						st.level=parentTopic.level+1;
						utilities.setTopicFormat(st,st.contact,st.level>1,false);
						arguments.callee(st);
					}
				})(topic);
				
				
				/*requestHandler("getObjectsMap",
					null,
					function(obj,response){
						var contact=obj.contact;
						//utilities.initFromAdminObject(response.MindjetAdminObject);
						var reportsToMap=utilities.parseContactMap(response.Contacts);
						
						//utilities.setFeaturedContactBoundary(reportsToMap,true);
						mmMap.clearEventQueue();
					}.createClosure(null,obj)
				)*/
				
				
				
			}.createClosure(null,obj,to)
		)
		//return false;
	},
	//This is a dev only feature only
	createContact:function(topic){
		var mmObjectId=(typeof topic!='string')?topic.GetId():null;
		//********************************************************
		//		Flagging
		//if(!!mmMap.getMapObjectAttribute(topic,'contact')) return;
		//********************************************************
		var newText=((typeof topic!='string')?topic.GetText():topic).split(" "),
			lastName=(newText.length==1)?newText[0]:newText.slice(1).join(" "),
			firstName=(newText.length>1)?newText[0]:"",
			parentTopic=mmMap.retrieveObject(mmDocument.GetSelectedTopics()[0]),
			parentContact=((parentTopic)?parentTopic.contact:null);
		
		requestHandler(
			"createContact",
			{
				mmObjectId:mmObjectId,
				firstName:firstName,
				lastName:lastName,
				accountId:account.Id,
				parentContact:parentContact,
				mmParentObjectId:((parentTopic)?parentTopic.GetId():null)
			},
			function(response){
				if(!!response.mmObjectId) mmDocument.SearchObjectById(response.mmObjectId).Delete();
				var subTopicsGroup=(!!response.mmParentObjectId)?mmMap.retrieveObject(response.mmParentObjectId).GetSubTopics():mmCentralTopic.GetSubTopics();
				var newTopic=subTopicsGroup.AddNewTopic(utilities.getTopicContent(response.Contact));
				mmMap.storeObject(newTopic);
				newTopic.contact=response.Contact;
				mmMap.setSelected(newTopic);
				mmMap.setFocus(newTopic);
				mmMap.clearEventQueue();
			}
		)
	},
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
		//Handling Security
		if(!utilities.getSecurityContext('Contact','isUpdateable',primaryTopic) || !utilities.getSecurityContext('Contact','isUpdateable',secondaryTopic)){
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
			}.createClosure(null,relationship,primaryTopic,secondaryTopic)
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
				newText:newText
			},
			function(response){
				var callout=mmMap.retrieveObject(response.mmObjectId);
				callout.SetText(HTMLDECODE(response.callout.Text__c));
				callout.callout=response.callout;
				mmMap.clearEventQueue();
				//if(!!response.Message) alert(response.Message);
			}
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
				utilities.setTopicFormat(topic,response.contact);
				utilities.resetRelationships(topic);
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
				if(ot=='Callout'){
					requestHandler("deleteCallout",
						{callout:object.callout},
						function(object,response){ 
							//mmMap.deleteStoredObject(object.id);
							var actualObj=mmDocument.SearchObjectById(object.id);
							if(!!actualObj) actualObj.Delete();
						}.createClosure(null,object)
					);
				} else if(ot=='Contact'){
					Ext.Msg.wait("","Loading...");
					requestHandler("getObjectsMap",
						null,
						function(contact,response){
							mmMap.clearDirtyStoredObjects();
							//Refreshing Contacts
							//utilities.initFromAdminObject(response.MindjetAdminObject);
							var reportsToMap=utilities.parseContactMap(response.Contacts);
							if(reportsToMap[contact.Id]) {
								for(var i=0;i<reportsToMap[contact.Id].length;i++){
									utilities.addSubLevelContactToMap(mmCentralTopic,reportsToMap[contact.Id][i],reportsToMap,response.ContactsSecurity);
								}
							}
							utilities.refreshDecoratingObjects(response);
							//utilities.setFeaturedContactBoundary(reportsToMap,false);
							//utilities.assignOpportunitiesContactRoles(response);

							if(featuredContact && contact.Id==featuredContact.Id) {
								featuredContact=null;
							}								
							mmMap.clearEventQueue();
							setTimeout(function(){Ext.Msg.hide();},100);
							requestHandler("deleteContact",{contact:contact});
						}.createClosure(null,object.contact)
					);
				} else if(ot=='Relationship'){
					requestHandler("deleteRelationship",
						{relationship:object.relationship},
						function(object,response){ 
							//mmMap.deleteStoredObject(object.id);
						}.createClosure(object)
					);
				} else if(ot=='Boundary'){
					object.Delete();
					requestHandler(
						"deleteBoundary",
						{
							boundary:object.boundary
						}
					)
				}
				// This is used in case the delete button is pressed and the event is generated
				// directly by the map
				if(!originalPassed) { 
					object.isDeleted=true;
					object.Delete();
					mmMap.deleteStoredObject(object.id);
					mmMap.clearEventQueue();
				}
			}.createClosure(null,object)
		);
	}
}


