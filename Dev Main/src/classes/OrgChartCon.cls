public with sharing class OrgChartCon {
	public Account acct { get; set; }
	
	public OrgChartCon()
	{
		Id accid = ApexPages.CurrentPage().getParameters().get('id');
		if (accid != null) {
			this.acct = [select id, Name, 
				(select id, FirstName, LastName, Title, ReportsToId, ReportsTo.FirstName, ReportsTo.LastName, ReportsTo.Title 
				from Contacts where Show_On_Org_Chart__c = true)
				from Account where id = :accid];
		}
	}
	
	public String getContactHierarchy(){
         GoogleViz gv = new GoogleViz();
        gv.cols = new list<GoogleViz.col> { 
            new GoogleViz.Col('col1','Name','string'),
            new GoogleViz.Col('col2','Manager','string'),
            new GoogleViz.Col('col3','ToolTip','string')
        };
        
        for (Contact c : acct.Contacts) {
        	GoogleViz.row r = new GoogleViz.row();
        	
        	//Contact Name
        	r.cells.add(new GoogleViz.cell(getContactName(c)));
        	
        	//manager Name
	        if(c.ReportsToId != null){                                 
	            // Add manager name to row
	            r.cells.add(new GoogleViz.cell(getManagerName(c)));
	        }else{
	            // No Manager to add to the Selected Contact row
	            r.cells.add ( new GoogleViz.cell( '' ) );
	        }
	        
	        //ToolTip
	        r.cells.add(new GoogleViz.cell(c.Title));
        	
        	gv.addrow(r);
        }
        
        
        
        return gv.toJsonString();
    }
    
    private String getContactName(Contact con){
        string contactname = '<a href="/' + con.id + '">' + con.FirstName + ' ' + con.LastName + '</a><br/>' + con.Title;
        return contactname;
    }
    
    private string getManagerName(Contact con) {
    	string managername = '<a href="/' + con.id + '">' + con.ReportsTo.FirstName + ' ' + con.ReportsTo.LastName + '</a><br/>' + con.ReportsTo.Title;
    	return managername;
    }
    
   
}