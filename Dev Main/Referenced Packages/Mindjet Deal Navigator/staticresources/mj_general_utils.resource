/* General Handlers and Utilities */

//***********************************************************************************
//		CallBacks Handling
//***********************************************************************************
var callbacksRepository={},onCallbacksErrorRepository={};
var responseHandlerProxy=function(){
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
var requestHandler=function(req,reqValue,callBackFunction,errorFunction,withPriority){
	if(!!callBackFunction) callbacksRepository[req]=callBackFunction;
	if(!!callBackFunction) onCallbacksErrorRepository[req]=errorFunction;
	iRequest.value=req;
	iRequestValue.value=(!!reqValue)?jsonToString(reqValue):"";
	requestHandlerProxy();
}


//***********************************************************************************
//		General Utilities
//***********************************************************************************
get$=function(s){ return document.getElementById(s);} //document.getElementById
HTMLENCODECharactersMap={
		'&':'&amp;',
		'<':'&lt;',
		'>':'&gt;',
		"'":'&apos;',
		'"':'&quot;'
	};
HTMLENCODECharactersList=['&','<','>',"'",'"'];
function HTMLENCODE(str){
	for(var i=1;i<HTMLENCODECharactersList.length;i++){
		var s=HTMLENCODECharactersList[i];
		str=str.split(s).join(HTMLENCODECharactersMap[s]);
	}
	return str;
}
function HTMLDECODE(str){
	for(var i=HTMLENCODECharactersList.length-1;i>=0;i--){
		var s=HTMLENCODECharactersList[i];
		str=str.split(HTMLENCODECharactersMap[s]).join(s);
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
        ret = "\"" + propName + "\":\"" + val + "\""; 
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

//***********************************************************************************
//		Ext JS Extensions
//***********************************************************************************
/*
Ext.Msg.wait=function(title,msg){
	this.hide();
	if(!this.exMask){
		this.exMask=new Ext.LoadMask(Ext.get(Ext.getBody().dom.firstChild), {msg:"Please wait..."});
		this.exMask.el.mask=function (msg, msgCls) {
			var me = this, dom = me.dom, dh = Ext.DomHelper, EXTELMASKMSG = "ext-el-mask-msg", el, mask;
			if (me.getStyle("position") == "static") {
				me.addClass(XMASKEDRELATIVE);
			}
			if ((el = Ext.Element.data(dom, "maskMsg"))) {
				el.remove();
			}
			if ((el = Ext.Element.data(dom, "mask"))) {
				el.remove();
			}
			mask = dh.append(dom, {cls: "ext-el-mask"}, true);
			Ext.Element.data(dom, "mask", mask);
			//*****************************************************
			//if(dom.style.overflow!='hidden') me.addClass(XMASKED);
			//******************************************************
			mask.setDisplayed(true);
			if (typeof msg == "string") {
				var mm = dh.append(dom, {cls: EXTELMASKMSG, cn: {tag: "div"}}, true);
				Ext.Element.data(dom, "maskMsg", mm);
				mm.dom.className = msgCls ? EXTELMASKMSG + " " + msgCls : EXTELMASKMSG;
				mm.dom.firstChild.innerHTML = msg;
				mm.setDisplayed(true);
				mm.center(me);
			}
			if (Ext.isIE &&  !(Ext.isIE7 && Ext.isStrict) && me.getStyle("height") == "auto") {
				mask.setSize(undefined, me.getHeight());
			}
			return mask;
		}
	}
	this.exMask.show();
}
Ext.Msg._hide=Ext.Msg.hide;
Ext.Msg._show=Ext.Msg.show;
Ext.Msg.hide=function(options){
	this._hide(options);
	if(!!this.exMask) this.exMask.hide();
}
Ext.Msg.show=function(options){
	if(!!this.exMask) this.exMask.hide();
	this._show(options);
}*/
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

