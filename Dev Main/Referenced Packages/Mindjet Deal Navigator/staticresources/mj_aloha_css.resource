/* Copyright 1994-2009 Mindjet LLC, San Francisco, CA USA. All rights reserved.
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
*/

<style type="text/css">

    #mmwc2{ float:left; width:75% height:600px; } 
    #ccc2{ width:200px;}
    #editIframe {
	width: 100%;
    }
    
    bodyCell a:hover {
        text-decoration: none;
        color: transparent;
    }
    
    bodyCell button,
    bodyCell .x-btn,
    bodyCell .x-date-mp-ok,
    bodyCell .x-date-mp-cancel,
    bodyCell a.roundBtn,
    bodyCell a.roundBtn:hover,
    bodyCell a.roundBtn:active,
    bodyCell input.btn,
    bodyCell button.btn,
    bodyCell input.btnDisabled,
    bodyCell input.btnCancel,
    bodyCell .menuButton .menuButtonButton {
        color: #333;
        margin: 0px;
        padding: 2px 3px;
        border: 0px;
        border-bottom-color: #7f7f7f;
        background: transparent none;
        font-weight:bold;
        font-size: .9em;
        -moz-border-radius: 0px; /* This will round the corners in Firefox */
        -webkit-border-radius: 0px; /* This will round the corners in Safari */
    }
    
    bodyCell .x-menu-list,
    bodyCell .menuButton .menuButtonMenu,
    bodyCell .searchCustomization .menuButton .menuButtonMenu {
        background-color: #fff;
        border: 1px solid #000;
        -moz-box-shadow: 0 1px 5px #727272;
        -webkit-box-shadow: 0 1px 5px #727272;
        padding:0;
    }
    bodyCell .x-menu-list .x-menu-list-item,
    bodyCell .googleDocMutton .menuButtonMenu a,
    bodyCell .searchCustomization .menuButton .menuButtonMenu a,
    #browseTags .menuButton .menuButtonMenu a,
    bodyCell .bMyTask .menuButton .menuButtonMenu input.theOption,
    bodyCell .menuButton .menuButtonMenu a {
        background-color: transparent;
        border: 0;
        padding:4px 10px;
        font-weight: normal;
        font-size: 1em;
    }
    bodyCell .x-menu-list .x-menu-item-active,
    bodyCell .googleDocMutton .menuButtonMenu a:hover,
    bodyCell .searchCustomization .menuButton .menuButtonMenu a:hover,
    #browseTags .menuButton .menuButtonMenu a:hover,
    bodyCell .menuButton .menuButtonMenu a:hover,
    bodyCell .menuButton .menuButtonMenu input.theOption:hover {
        background: #e0f5fc none;
        color:#015ba7;
        border: 0;
        text-decoration: underline;
        cursor: pointer;
    }
    bodyCell .x-menu-list .x-menu-list-item{
        padding:2px 10px;
    }
    bodyCell .x-menu-list .x-menu-item-active a{
        border:0;
    }
    
    bodyCell div.x-window div.x-window-tl {
        background:transparent none no-repeat scroll 0 0;
        padding-left: 6px;
        padding-right: 0px;
    }
    bodyCell div.x-window div.x-window-tr {
        padding: 0px 6px 0px 0px;
        background:transparent none no-repeat scroll right 0;
    }
    bodyCell div.x-window div.x-window-tl div.x-window-header {
        font-family: inherit;
        padding: padding:5px 0 4px;
    }
    bodyCell div.x-window .x-tool-close, bodyCell div.x-window .x-tool-close-over {
        background-image:url(../images/gray-extend/panel/tool-sprites.gif);
        width:15px;
        height:15px;
    }
    
    bodyCell div.x-window .x-window-header-text {
        color: #000;
        font-size: 11px;
    }
    bodyCell div.x-window div.x-window-mr {
        background-image:url(../images/gray-extend/window/left-right.png);
        border: none;
        padding: 0;
    }
    .overlayDialog .innerContent,
    .inlineOverlayDialog .innerContent {
        padding: 12px 16px;
    }
    div.x-window div.x-window-mc {
        padding: 12px 16px 0;
        background-color: transparent;
        font-family: inherit;
        border: 0 none;
    }
    div.x-window div.x-panel-body {
        background-color: transparent;
    }
    bodyCell div.x-window div.x-window-br{
        background-image:url(../images/gray-extend/window/right-corners.png);
    }
    bodyCell div.x-window div.x-window-bc{
        background-image:url(../images/gray-extend/window/top-bottom.png);
    }
    div.x-window-bc div.x-window-footer,
    div.x-window div.x-panel-btns-ct {
        padding: 0;
        background: transparent none;
    }
    bodyCell div.x-window div.x-window-bl{
        background-image:url(../images/gray-extend/window/left-corners.png);
    }
    bodyCell div.x-window div.x-window-ml{
        background-image:url(../images/gray-extend/window/left-right.png);
        padding: 0;
    }
    bodyCell div.x-window div.x-window-tc {
        background-image:url(../images/gray-extend/window/top-bottom.png);
        padding:0;
    }
    div.x-window div.x-window-footer {
        background:transparent url(/img/alohaSkin/overlay_crns_ext.png) no-repeat scroll right bottom;
        padding-right:6px;
    }
    
    div.x-window div.x-panel-btns {
        background:transparent url(/img/alohaSkin/overlayBtmLft.png) no-repeat scroll left bottom;
        padding:8px 0 12px;
    }

	.x-btn-mc{width:45px;}
	.x-btn button {width:45px;}

	.toolbar-button {
		padding: 0px 0px 2px 17px !important; 
		margin: 0px 5px 0px 5px !important; 
		width:auto !important;
	}
	.print{background-image:url(../images/icon_sfdc_print.png) !important; }
	.insert{background-image:url(../images/icon_sfdc_insert.png) !important; }
	.format{background-image:url(../images/Brush-32x32.png) !important; }
	.delete{background-image:url(../images/icon_sfdc_delete.png) !important; }
	.refresh{background-image:url(../images/icon_sfdc_refresh.png) !important; }
	.edit{background-image:url(../images/icon_sfdc_edit.png) !important; }
	.new{background-image:url(../images/icon_sfdc_newcontact.png) !important; }
	.opportunities{background-image:url(../images/icon_sfdc_role.png) !important; }
	.test{background-image:url(../images/boundary_32.png) !important; }
	.favors{background-image:url(../images/icon_sfdc_favor.png) !important; }
	.external{background-image:url(../images/icon_sfdc_external.png) !important; }
	.filter{background-image:url(../images/icon_sfdc_filter.png) !important; }
	.clearFilter{background-image:url(../images/icon_sfdc_filter_remove.png) !important; }
	.help{background-image:url(../images/icon_help_circle.png) !important; }
	.detail{background-image:url(../images/icon_detail_panel.png) !important; }

	.ajaxLoader{background-image:url(../images/loader.gif) !important;}
	.closeForm{background-image:url(../images/bouton_close.png) !important;}

	#hookupBarA{cursor: pointer; padding: 8px 0px 8px 8px; font-size: 32px; font-weight:bolder; color:white; background-color:#888888; position:absolute; top:0px; left:0px; border: 1px solid black; width: 100%; height:50px;}

	x-menu-list-item {
		margin:0px;
		padding-left:0px;
		padding-right:0px;
	}
	ul .x-menu-list-item, ol .x-menu-list-item {
		margin:0px;
		padding-left:0px;
		padding-right:0px;
	}
	.x-grid3-row {
		border-width:0px;
	}
	.x-color-palette {
		background-color:#ffffff
	}
	.ext-el-mask-msg {
		background-color:#D7D7D7;
		background-image:none !important;
		border-color:#8F8F8F;
		padding:0px;
	}
	.x-mask-loading div {
		background:#FBFBFB url(../images/loader2.gif) no-repeat scroll center 15px !important;
	}
	.ext-el-mask-msg div {
		font-size:20px;
		height:40px;
		padding-left:60px;
		padding-right:60px;
		padding-top:40px;
	}
	.x-btn-mc{
		width:auto;
	}
	.x-toolbar {
		padding:4px !important;
	}
	.no-icon-combo {
		padding: 3px; position: static; float: left;padding-right: 6px;
	}
	.x-btn button {
		width:auto !important;
	}
	.x-window-mc .x-window-body-noborder {
		height: auto !important;
	}
   #detailOverlayDialog {
      border: 1px solid #cccccc;
   }
</style>


