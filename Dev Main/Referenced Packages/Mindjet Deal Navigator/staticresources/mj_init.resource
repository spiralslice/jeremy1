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
	contactLayers,
	editIframe,
	mmContainer,
	detailOverlay,
	toolBar,
	contactRoles,
	opportunitiesMap,
	serverConfigObject={}

Ext.onReady(function(){
	//Inits ExtJS popups/tooltips
	Ext.QuickTips.init();

	//Prevents flash to resize when showing upper folder
	var body=document.body ||  document.getElementsByTagName('body').item(0),bodyHeader=document.getElementById('AppBodyHeader'),hg=(!!bodyHeader)?'height:100%;':'';
	body.innerHTML='<div id="bodyDiv" style="width:100%;'+hg+'top:0px;left:0px;">' + body.innerHTML + '</div>';
//	body.style.overflow='hidden';


	if(Ext.isIE7){
		try{
			//IE7 Fix
//			body.style.overflowX='hidden';
//			body.style.overflowY='hidden';
//			if(document.documentElement)document.documentElement.style.overflow='hidden';
			document.getElementById('bodyCell').style.paddingRight='0px';
			document.getElementById('AppBodyHeader').style.width='98%';
			document.getElementById('mmwctoolbar').style.width='99%';
			document.getElementById('mmwc').style.width='99%';
		}catch(e){}
	}
	//Restores sidebar on new document
	Sidebar.prototype.theSidebar = new Sidebar(document.getElementById('sidebarDiv'));	
	
	//Hidden Value entities now needs to be redefined
	iResponse=document.getElementById(CONFIG.iResponse);
	iResponseValue=document.getElementById(CONFIG.iResponseValue);
	iRequest=document.getElementById(CONFIG.iRequest);
	iRequestValue=document.getElementById(CONFIG.iRequestValue);
	
	//start loading contact Information
	mainController.startContactPoller();
	
	window.mainPoller=function(){
			try{		
				//Sizing panel
				try{
					var ps=getPageSize(),co=mmContainer.getHeight()+ mmContainer.getTop();
					if(co!=ps.windowHeight && ps.windowHeight!=arguments.callee.lastWindowHeight || co!=ps.windowHeight || toolBar.isVisible()!=arguments.callee.lastToolbarVisible)mmContainer.setHeight(ps.windowHeight-mmContainer.getTop()-20);
					arguments.callee.lastWindowHeight=ps.windowHeight;
					arguments.callee.lastToolbarVisible=toolBar.isVisible();
					if(!detailOverlay.hidden) detailOverlay.show();
				} catch(e){}
				//retrieve currently selected object
				var object;
				try{
					var topics=mmDocument.GetSelectedTopics(),objects=mmDocument.GetSelectedObjects();
					if(topics.length>0 && mmMap.retrieveObject(topics[0])) object= mmMap.retrieveObject(topics[0]);
					if(!object && objects.length>0 && mmMap.retrieveObject(objects[0])) object= mmMap.retrieveObject(objects[0]);
					//manage multi selection
					/*if(topics.length+objects.length>2 || objects.length>1){
						mmMap.clearSelection();
						mmMap.setSelected(object);
					}*/
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
	window.actionPoller=function(){
			try{		
				//Managing action queue
				var aq=window.actionPoller.actionQueue;
				for(var i in aq){
					if(typeof aq[i][0]=='function') setTimeout(aq[i][0],1);
					aq[i].shift();
					if(aq[i].length==0) delete aq[i];
				}
			} catch(e){
				//This loop can run before some of the objects are created
			}
		};
	window.actionPoller.intervalTime=100;
	window.actionPoller.actionQueue={};
	window.actionPoller.addAction=function(bucket,action,interval){
		var aq=window.actionPoller.actionQueue;
		if(!aq[bucket])aq[bucket]=[];
		if(!interval) interval=window.actionPoller.intervalTime;
		var padding=Math.floor(interval/window.actionPoller.intervalTime)-1;
		for(var i=0;i<padding;i++) aq[bucket].push(null);
		aq[bucket].push(action);
	}
    
    window.startActionPoller=function(){
    	window.actionPoller.interval=setInterval(window.actionPoller,window.actionPoller.intervalTime);
    }

   //Salesforce Sidebar Fix
   var sbOld=Sidebar;Sidebar=function(sd,ec,ip){try{if(!Sidebar.prototype.idt) Sidebar.prototype.idt={ec:ec, ip:ip}; else Sidebar.prototype.oc.call(this,sd,Sidebar.prototype.idt.ec,Sidebar.prototype.idt.ip);}catch(e){}};Sidebar.prototype=sbOld.prototype;Sidebar.prototype.oc=sbOld;
   try{
      if(window.parent && window.parent!=window && !!window.parent.mainController) {
         alert('Unable to open Org Chart.\nA different instance of the application is running in the background.');
         window.parent.mainController.displayForm(false);
      }
   } catch(e){}

   if(!Ext.isGecko3 || typeof(console)=='undefined'){
      console={
         debug:function(msg){
            status=msg;
         }
      }
   }

   applicationInit();
});


