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
		if(reportsToMap['central']){
			var f=function(reportsTo,reportsToMap){
				if(!reportsToMap[reportsTo]) return 0;
				reportsToMap[reportsTo].subLevelCounter=0;
				for(var i=0;i<reportsToMap[reportsTo].length;i++) reportsToMap[reportsTo].subLevelCounter+=arguments.callee(reportsToMap[reportsTo][i].Id,reportsToMap);
				reportsToMap[reportsTo].sort(function(a,b){return a.subLevelCounter-b.subLevelCounter});
				return reportsToMap[reportsTo].subLevelCounter + reportsToMap[reportsTo].length;
				
			}('central',reportsToMap);
		}
		return reportsToMap;
	},
	addSubLevelContactToMap:function(topic,oContact,contact,reportsToMap,securityMap,level){
		if(typeof level=='undefined') level=0;
		else level++;
		if(topic!=mmCentralTopic) topic.SetCollapsed(true);
		var childTopic=topic.GetSubTopics().AddNewTopic('',0,false);
		if(topic!=mmCentralTopic) topic.SetCollapsed(true);
		//childTopic.level=level;
		
		//Record Security
		//childTopic.securityAccess=securityMap[contact.Id];
		utilities.setTopicFormat(childTopic,contact,level>1,!utilities.isFeaturedChart());
		mmMap.storeObject(childTopic);
		childTopic.contact=contact;
		childTopic.oContact=oContact;
		childTopic.opportunityContactRoles={};
		childTopic.SetText(utilities.getTopicContent(childTopic));
		utilities.addFavorIcon(childTopic,contact);
		//if(!!reportsToMap[contact.Id]){
		//	for(var i=0;i<reportsToMap[contact.Id].length;i++) arguments.callee(childTopic,reportsToMap[contact.Id][i],reportsToMap,securityMap,level);
		//}
		return childTopic;
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
			callout=obj.GetCallouts().AddNewTopic(HTMLDECODE(cal.Text__c));
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
		for(var i in map.Opportunities){
			var opty=map.Opportunities[i];
			opportunitiesMap[map.Opportunities[i].Id]=map.Opportunities[i];
		}
		for(var i in map.OpportunityContactRoles){
			var topic=mmMap.retrieveTopicByContactId(i);
			if(!!topic) {
				topic.opportunityContactRoles=map.OpportunityContactRoles[i];
				topic.GetTextMarkers().RemoveAll();
				for(var k in topic.opportunityContactRoles){
					if(!opportunitiesMap[topic.opportunityContactRoles[k].OpportunityId]) continue;
					var opty=opportunitiesMap[topic.opportunityContactRoles[k].OpportunityId];
					mmMap.addTextMarker(topic,opty.Name,topic.opportunityContactRoles[k].Role);
				}
			}
		}
		serverConfigObject.contactRoles=map.ContactRoles;
		serverConfigObject.opportunitiesMap=opportunitiesMap;
		serverConfigObject.opportunitiesFilteredMap={};
		serverConfigObject.opportunitiesMapByStage={};
		serverConfigObject.opportunitiesList=[];
		serverConfigObject.opportunitiesSecurityMap=map.OpportunitiesSecurity;
		serverConfigObject.contactRolesMap=map.ContactRoles;
		for(var i in opportunitiesMap){
			//Sorting Opportunities by type
			//---
			serverConfigObject.opportunitiesList.push(opportunitiesMap[i]);
			if(!serverConfigObject.opportunitiesMapByStage[opportunitiesMap[i].StageName]) serverConfigObject.opportunitiesMapByStage[opportunitiesMap[i].StageName]=[];
			serverConfigObject.opportunitiesMapByStage[opportunitiesMap[i].StageName].push(opportunitiesMap[i]);
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
		//Configuring Mindjet Admin Object
		serverConfigObject.MindjetAdminObject=response.MindjetAdminObject;
		serverConfigObject.MindjetAdminObject.favorIconsCouplesMap={};
	},
	//***********************************************************************************
	//		Toolbars and dialogs
	//***********************************************************************************
	initContactRecordTypesCombo:function(){
		if(serverConfigObject.ContactRecordTypes.length>0){
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
				height:100,
				autoScroll:false,
                buttonAlign:"center",
                width:330,
                height:100,
                minHeight: 80,
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
	},
	initToolbarAddOns:function(){	
		//Configuring Favors Icons
		var favorsMenu=toolBar.items.get('favors');
		favorsMenu.setText((serverConfigObject.MindjetAdminObject.Favor_Field_Name__c=='null')?'Favor':serverConfigObject.MindjetAdminObject.Favor_Field_Name__c);
		favorsMenu.menu.removeAll();
		
		if(serverConfigObject.MindjetAdminObject.Favor_Icons__c=="null" || serverConfigObject.MindjetAdminObject.Favor_Icons__c=="") return;
		var couples=serverConfigObject.MindjetAdminObject.Favor_Icons__c.split(',');

		for(var i=0;i<couples.length;i++){
			var couple=couples[i].split('###');
			if(couple.length==1) couple.push('');
			serverConfigObject.MindjetAdminObject.favorIconsCouplesMap[couple[0]]=couple;
			mmMap.loadIconFile("favors",couple[0],couple[1]);
			couples[i]=couple;
		}
		couples.unshift(['---None---','null']);
		serverConfigObject.MindjetAdminObject.favorIconsCouplesMap['---None---']=['---None---','null'];
		//Configuring Favors Menu
		for(var i=0;i<couples.length;i++){
			var couple=couples[i];
			var favorsMenuItem=favorsMenu.menu.addMenuItem(
	            {
	                text: couple[0],
	                id: (couple[0]=='---None---')?"nullFavor":couple[0]+'favor',
	                icon: (couple[1]=='null')?Ext.BLANK_IMAGE_URL:CONFIG.baseURLforMapMarkersIcons +couple[1],
	                handler:function(favorValue){
						mainController.updateFavor(mmMap.currentlySelectedObject, favorValue);
	                }.createClosure(null,(couple[0]=='---None---')?null:couple[0])
	            }
			);	
		}
	},
	rebuildOpportunitiesRolesMenues:function(withInit){
		// Rebuild Opportunities and Roles Menues
		var rolesMenu=toolBar.items.get('opportunitiesroles');
		rolesMenu.menu.removeAll();
		var opportunitiesMap=serverConfigObject.opportunitiesMap;
		for(var i in opportunitiesMap){
			
			//Don't show closed Opportunities on the roles Menu?!
			if(opportunitiesMap[i].isClosed=='true') continue;
			//Don't show Opportunities with RO permission on the roles Menu
			if(serverConfigObject.opportunitiesSecurityMap[i].indexOf('RW')!=0) continue;
			
			var optyItem=rolesMenu.menu.addMenuItem(
	            {
	                text: opportunitiesMap[i].Name,
	                id: opportunitiesMap[i].Id,
	                menu:{}
	            }
			);
			for(var k in serverConfigObject.contactRolesMap){
				optyItem.menu.addMenuItem(
					{ 
						checked: false,
						checkHandler: function(opty,item,checked){
							mainController.manageOpportunityContactRole(opty,item,checked);
						}.createClosure(null,opportunitiesMap[i]),
						text: serverConfigObject.contactRolesMap[k],
						id:opportunitiesMap[i].Id+'#'+serverConfigObject.contactRolesMap[k]
					}
				);
			}
		}
		
		//	Setting up filtering options for opportunities
		var data=[], cbValue=null;
		if(!!featuredOpportunity){
			cbValue=featuredOpportunity.StageName;
		}
		
		for(var i in serverConfigObject.opportunitiesMapByStage){
			if(cbValue==null) cbValue=i;
			data.push([i,i]);
		}
		
		data.sort(function(a,b){
			return serverConfigObject.opportunitiesMapByStage[a[0]][0].Probability -serverConfigObject.opportunitiesMapByStage[b[0]][0].Probability
		})
		
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
								hideOnClick: false, 
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
										setTimeout(function(){				
											mmMap.FilterObjects(
												function(bFilter,obj){
												    obj=mmMap.retrieveObject(obj);
												    if (!obj || !obj.opportunityContactRoles) return false;
													for(var k in obj.opportunityContactRoles){
														if(!!serverConfigObject.opportunitiesFilteredMap[obj.opportunityContactRoles[k].OpportunityId]) return true;				    
												    }
												    return false;
												}.createClosure(null,bFilter),MmwEnumerations.MmwFilter.mmHideOthers,MmwEnumerations.MmwFilter.mmHideSubTopics);
											}.createClosure(null,bFilter),100);
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
	initDetailOverlay:function(){
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
			var vis=mmDocument.GetScrollbarsVisible(),hsbv=vis[MmwEnumerations.MmwChromeElements.mmHorizontalScrollbar],vsbv=vis[MmwEnumerations.MmwChromeElements.mmVerticalScrollbar],el=this.getEl();
			this.hidden = false;
			this.getEl().dom.style.visibility='visible';
			this.getEl().setWidth(parseInt(mmContainer.getWidth()*0.25));
			this.getEl().setLeft(mmContainer.getLeft() + mmContainer.getWidth() - this.getEl().getWidth() - ((vsbv)?40:0));
			this.getEl().setTop(toolBar.getEl().getHeight() + 20);
			//this.setHeight(mmContainer.getHeight() - ((hsbv)?47:30));
			//this._show();
		}
		detailOverlay.hide=function(){
			this.hidden = true;
			this.getEl().dom.style.visibility='hidden';
			this.getEl().setLeft(-10000);
			this.getEl().setTop(-10000);
		}
		//detailOverlay.addListener('hide', function(){ detailOverlay.enableShow=false; toolBar.items.get('detail').toggle(false,true);} );
		detailOverlay.render();
		detailOverlay.hide();
		detailOverlay.enableShow=true;
	},
	initToolbar:function(){
	    //***********************************************************************************
		//		Toolbar Initialization
		//***********************************************************************************
		var ie7MenuWidthFix=function(self){ 
			setTimeout(
				function(){
					self.el.dom.style.width='auto'; 
					if(self.parentMenu) self.parentMenu.el.dom.style.width='auto';
				},100); 
		};
		var colorMenu = new Ext.menu.ColorMenu({
			autoHeight :true,
        	/*listeners:{
        		show:(Ext.isIE7)?ie7MenuWidthFix:null
        	},*/
	        handler: function(cm, color){
	            setTimeout(function(color){ mainController.createBoundary(color)}.createClosure(null,color),1);
	        }  
	    });
		//colorMenu.palette=new Ext.ColorPalette();
		colorMenu.palette.colors = CONFIG.boundariesPalette;
		
	    toolBar = new Ext.Toolbar({
			style: {
                border: '1px solid #999999',
                borderBottom: '0px'
            },
	    	renderTo:'mmwctoolbar',
	    	minWidth: 0,
	        items: [
				{
					text: 'New',
	                iconCls: 'toolbar-button new',
	                id:'insertContact',
			        handler: function(){setTimeout(function(){mainController.createNewContact()},100);},
	                disabled:true
	            },
				{
					text: 'Insert',
	                iconCls: 'toolbar-button insert',
	                id:'insert',
			        menu:{
			        	minWidth: 0,
			        	/*listeners:{
			        		show:(Ext.isIE7)?ie7MenuWidthFix:null
			        	},*/
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
					text: 'Edit',
	                iconCls: 'toolbar-button edit',
	                id:'edit',
			        handler: function(){setTimeout(function(){mainController.editContact()},100);},
	                disabled:true
	            },
				{
	                text: 'Delete',
	                iconCls: 'toolbar-button delete',
	                id:'deleteBtn',
	                handler: function(){mainController.deleteObject()},
	                disabled:true
	            },'-',
	            {
	                text: 'Roles',
	                //scale:'medium',
	                iconCls: 'toolbar-button opportunities',
	                id:'opportunitiesroles',
	                menu:{
	                	minWidth: 0/*,
			        	listeners:{
			        		show:(Ext.isIE7)?ie7MenuWidthFix:null
			        	}*/
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
			        	/*listeners:{
			        		show:(Ext.isIE7)?ie7MenuWidthFix:null
			        	},*/
	                	minWidth: 0
	                },
	                disabled:true
	            },
				{
					//In this menu the items whose id start with opptyFilter are used by the application. 
					//Changing that part of the id would compromise the functionality
	                text: 'Filter',
	                //scale:'medium',
	                iconCls: 'toolbar-button filter',
	                id:'opptyFilterMenu',
			        menu:{
			        	/*listeners:{
			        		show:(Ext.isIE7)?ie7MenuWidthFix:null
			        	},*/
			        	minWidth: 0,
			        	style:(Ext.isIE7)?"width:auto;":"",
				        items:[
				            {id:'opptyFilterComboTitle', text: 'Stage Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', activeClass:''},
				            '-'
				        ]
				    },
	                disabled:true
	            },{
	            	text: 'Filter',
	                iconCls: 'toolbar-button clearFilter',
	                id:'clearFilter',
	                handler: function(){utilities.clearFiltering();},
	                disabled:true
	            },'-',
				{
	                text: 'Print',
	                iconCls: 'toolbar-button print',
	                id:'print',
			        menu:{
			        	/*listeners:{
			        		show:(Ext.isIE7)?ie7MenuWidthFix:null
			        	},*/
				        items:[
				            { id:'printAll',handler: function(){mmMap.print(false)},text: 'Print Org Chart'},
				            { id:'printSingle',handler: function(){mmMap.print(true)},text: 'Print Selected Contact'}
				        ]
				    },
	                disabled:true
	            },
				{
					text: 'Refresh',
	                iconCls: 'toolbar-button refresh',
	                id:'refresh',
	                handler: function(){mainController.clearMap(true)},
	                disabled:true
	            },'->',
	            /*{
	            	text: 'Detail',
			        enableToggle: true,
			        iconCls:'toolbar-button detail',
			        id:'detail',
			        toggleHandler: function(item, pressed){
			        	detailOverlay.enableShow=pressed;
			        	if(!pressed) detailOverlay.hide();
			        	else utilities.manageSelectedObject(mmMap.currentlySelectedObject,true);
				    },
			        pressed: true,
			        disabled:true
			    },*/
				{
	                text: 'Help',
	                iconCls: 'toolbar-button help',
	                id:'help',
			        menu:{
			        	/*listeners:{
			        		show:(Ext.isIE7)?ie7MenuWidthFix:null
			        	},*/
				        items:[
				            { id:'gotoHelp',handler: function(){ window.open('http://onlinehelp.mindjet.com/help/mj_orgchart/ENU/mindjet_org_chart_help.htm','_blank','status=1,width=800,height:600')},text: 'Help'},
				            { id:'ver',text: 'Version 1.0.112(Beta)',disabled:true,style:'color:black !important;'}
				        ]
				    },
	                disabled:true
	            }
	        ]
	    });
    	toolBar.doLayout();
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
	},
	//***********************************************************************************
	//		Format and Content
	//***********************************************************************************
	setCentralTopicText:function(){
		var topicText=HTMLDECODE(account.Name);
		mmCentralTopic.SetText(topicText);
	},
	enableDetailPanel:function(enable){
		
	},
	setDetailContent:function(topic){
		if(!detailOverlay.enableShow || !topic.contact) {
			detailOverlay.hide();
			return;
		}
		var contact=topic.contact;
		detailOverlay.setTitle("<B>Contact Details</B>&nbsp;<A href='javascript:void(mainController.displayForm(true,\"/"+ contact.Id+"\"))'>More...</A>");
		var DetailData='\
			<center><table cellspacing="0" cellpadding="0" border="0" class="detailList" width="95%"><tbody>\
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
			DetailData+='<tr class="dataRow"><td style="font-wight:bolder;"><B>' + orderedSecurityContext[i][1].label + '</B></td><td class="dataCol">' + ((contact[orderedSecurityContext[i][0]]!="null")?contact[orderedSecurityContext[i][0]]:'&nbsp;') + '</td></tr>';
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
				optMap[opty.Id].ocr.push(topic.opportunityContactRoles[k].Role);
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
		if(!topic || !topic.contact) return;
		var s='',fn,ln,ttl,contact=topic.contact
		fn=(utilities.getSecurityContext('Contact','isAccessible',topic,'FirstName') && contact.FirstName!='null')? contact.FirstName : 'null';
		ln=(utilities.getSecurityContext('Contact','isAccessible',topic,'LastName') && contact.LastName!='null')? contact.LastName : 'null';
		ttl=(utilities.getSecurityContext('Contact','isAccessible',topic,'Title') && contact.Title!='null')? contact.Title : 'null';
		s+=((fn=='null')?"": fn);
		s+=((fn!='null' && ln!='null')?" ": "");
		s+=((ln=='null')?"": ln);
		s+=((fn!='null' || ln!='null')?"\n": "");
		s+=((ttl!='null')?ttl: "");
		if(s=='') s="No data displayed\nfor this contact";
		return HTMLDECODE(s);
	},
	setTopicFormat:function(topic,contact,blockOrgChartDirection,blockSubTopicExpansion){
		if(!contact) contact=topic.contact;
		
		//Setting Expansion Layout
		if(typeof(blockOrgChartDirection)=='boolean'){
			mmMap.addAction(topic,function(topic,blockOrgChartDirection,contact){
					topic.GetSubTopicLayout().SetGrowthDirection((!blockOrgChartDirection)?MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionOrgChart:MmwEnumerations.MmwTopicGrowthDirection.mmTopicGrowthDirectionTree);
				}.createClosure(null,topic,blockOrgChartDirection,contact),500);
			mmMap.addAction(topic,function(topic,blockOrgChartDirection,contact){
					if(!!contact) topic.GetFormatting().SetShape((contact[CONFIG.externalField]=="true")?CONFIG.alternateTopicShape:CONFIG.defaultTopicShape);
				}.createClosure(null,topic,blockOrgChartDirection,contact),600);
		}
		//Setting Collapsed
		//if(typeof(blockSubTopicExpansion)=='boolean' && !!blockSubTopicExpansion){
			mmMap.addAction(topic,function(topic){
					topic.SetCollapsed(true);
				}.createClosure(null,topic));
		//}
		topic.GetFormatting().SetShape((contact[CONFIG.externalField]=="true")?CONFIG.alternateTopicShape:CONFIG.defaultTopicShape);
		
		//Record Security
		var isUpdateable=utilities.getSecurityContext('Contact','isUpdateable',topic),isDeletable=utilities.getSecurityContext('Contact','isDeletable',topic),isUpdateableReportsTo=utilities.getSecurityContext('Contact','isUpdateable',topic,'ReportsToId');
		topic.GetTextFormatting().SetTextColor((!isUpdateable)?"11DDDDDD":"FF000000");
		topic.GetFormatting().SetLineColor((!isDeletable)?"11DDDDDD":"FF000000");
		topic.GetFormatting().SetFillColor((!isUpdateable)?'FFFFFFFF':'FFFFFFFF');
		topic.GetTextFormatting().SetBold(false);
		topic.GetTextFormatting().SetSize(10);
		topic.GetTextFormatting().SetAlignment(MmwEnumerations.MmwTextAlignment.mmLeft); 

		//D&D
		var MapObjectConstraints=topic.GetMapObjectConstraints();
		MapObjectConstraints.SetConstrainedChildTypesActivated(true);
		MapObjectConstraints.RemoveAllTypes();
		if(isUpdateableReportsTo) MapObjectConstraints.AddTypes('isUpdateableReportsTo');
		MapObjectConstraints.AddAllowedChildTypes('isUpdateableReportsTo');
		
		//ReadOnly & No Drag to Floating
		MapObjectConstraints.EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmTextReadOnly);
		MapObjectConstraints.EnableFeature(MmwEnumerations.MmwMapObjectFeatures.mmNoDragToFloating);
		
		
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
		for(var k in serverConfigObject.contactRoles) return true;
		return false;
	},
	userHasContactRecordtypes:function(){
		return serverConfigObject.ContactRecordTypes.length>0;
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
		
		if(!serverConfigObject.SecurityContext[objectName]) return false;
		var sc=serverConfigObject.SecurityContext[objectName];
		
		if(attribute=='isAccessible'){
			if(!!topic && !!topic.securityAccess) {
				var f=sc.isAccessible;
				if(!!fieldName && !!sc[fieldName]) f=f && sc[fieldName].isAccessible;
				return f;
			} else return sc.isAccessible;
		} else if(attribute=='isDeletable'){
			if(!!topic && !!topic.securityAccess){
				if(objectName=='Contact') return topic.securityAccess=='RWD' && sc.isDeletable;
				else return topic.securityAccess.indexOf('RW')==0 && sc.isDeletable;
			} else return sc.isDeletable;
		} else if(attribute=='isUpdateable'){
			if(!!topic && !!topic.securityAccess) {
				var f=topic.securityAccess.indexOf('RW')==0 && sc.isUpdateable;
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
					printSingle:true,
					edit:true,
					insertCallout:!mmMap.retrieveObjectCallout(object),
					insertBoundary:true,
					insertIconMarker:true,
					opportunitiesroles:true,
					favors:true,
					external:true,
					ver:true,
					deleteBtn:!isDeletable
				}
			);
		} else if(ot=='Contact'){
			toolBar.disableItems(
				(function(obj){
					var ret={
						clearFilter:!mmMap.isFiltered(),
						opptyFilterMenu:serverConfigObject.opportunitiesList.length==0,
						insertContact:!utilities.getSecurityContext('Contact','isCreateable'),
						edit:!utilities.getSecurityContext('Contact','isUpdateable',obj),
						deleteBtn:!utilities.getSecurityContext('Contact','isDeletable',obj),
						insertCallout:!!mmMap.retrieveObjectCallout(object) || !utilities.getSecurityContext('Contact','isUpdateable',obj),
						insertBoundary:!utilities.getSecurityContext('Boundary__c','isUpdateable',object),
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
					printSingle:true,
					edit:true,
					insertCallout:!!mmMap.retrieveObjectCallout(object) || !utilities.getSecurityContext('Relationship__c','isUpdateable',topics[0]) || !utilities.getSecurityContext('Relationship__c','isUpdateable',topics[1]),
					insertBoundary:true,
					insertIconMarker:true,
					opportunitiesroles:true,
					favors:true,
					external:true,
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
					printSingle:true,
					edit:true,
					insertCallout:true,
					insertIconMarker:true,
					opportunitiesroles:true,
					favors:true,
					external:true,
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
					printSingle:true,
					edit:true,
					insertCallout:true,
					insertBoundary:true,
					insertIconMarker:true,
					deleteBtn:true,
					opportunitiesroles:true,
					favors:true,
					ver:true,
					external:true
				}
			);
		}
	}
}

