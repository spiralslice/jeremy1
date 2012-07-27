public with sharing class TaskListExt {
	
	private final Account acct;  

    public TaskListExt(ApexPages.StandardSetController controller) {
       this.acct = (Account)controller.getRecord(); 
    }    
    
    //Can I save this file?
    public ApexPages.StandardSetController accountRecords{
        get {
            if(accountRecords == null) {
                return new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT name FROM Account WHERE Id NOT IN (SELECT AccountId 
                FROM Opportunity WHERE IsClosed = false)]));
            }
            return accountRecords;
        }
        private set;
    }
    
    public List<Account> getAccountPagination() {
         return (List<Account>) accountRecords.getRecords();
    }  

/*
	list<Task> tasklist; //main list for Task view
	list<SelectOption> viewoptions; //filter values
	Integer datefilter = 8; //number from SelectOptions
	
	AP_SortHelper sorter = new AP_SortHelper(); //open source utility class. See SortBy()
	String SortedBy = null;
	Boolean sortAscending = true;
	
	public TaskListCon()
	{
		refreshtasklist();
		refreshviewoptions();
	}
	
	private String date2string(Date d)
	{
		String daystr = (d.day() < 10) ? '0' + String.valueof(d.day()) : String.valueof(d.day());
		String monthstr = (d.month() < 10) ? '0' + String.valueof(d.month()) : String.valueof(d.month());
		String properdate = String.valueof(d.year()) + '-' + monthstr + '-' + daystr ;
		return properdate;
	}
	
	private void SortBy(String value) 
	{        
system.debug('\n\n26Sortedby ' + sortedBy + ' value ' + value);		
		if (sortedBy == value) {             
			sortAscending = !sortAscending;        
		} else {            
			sortAscending = true;        
		}        
		sortedBy = value;   
		tasklist = (List<Task>) sorter.getSortedList(tasklist,SortedBy, sortAscending);
	}
	
	public void setdatefilter(String vf) { 
		datefilter = Integer.valueof(vf); 
		refreshtasklist();
	}
	
	public list<Task> gettasklist() { return tasklist; }
	
	public list<SelectOption> getviewoptions() { return viewoptions; }

	private void refreshtasklist()
	{
		
		String query = 'select Who.Email, Who.Phone, WhoId, Owner.Alias, Subject_Sub_Category__c, Status, ActivityDate, AVB_Type__c,' 
			+ ' AVB_Associate_First_Last_Name__c, AVB_Account_ID__c from Task where IsClosed = false';
		if (datefilter == 1) { //Overdue
			query += ' and ActivityDate < ' + date2string(system.today());
		}
		if (datefilter == 2) { //Today
			query += ' and ActivityDate = ' + date2string(system.today());
		}
		if (datefilter == 3) { //Today + Overdue
			query += ' and ActivityDate <= ' + date2string(system.today());
		}
		if (datefilter == 4) { //Tomorrow
			query += ' and ActivityDate = ' + date2string(system.today().addDays(1));
		}
		if (datefilter == 5) { //Next 7 Days
			query += ' and ActivityDate < ' + date2string(system.today().addDays(7)) + ' and ActivityDate >= ' + date2string(system.today());
		}
		if (datefilter == 6) { //Next 7 Days + Overdue
			query += ' and ActivityDate < ' + date2string(system.today().addDays(7));
		}
		if (datefilter == 7) { //This Month
			query += ' and ActivityDate >= ' + date2string(system.today().toStartOfMonth()) + ' and ActivityDate <= ' + date2string(system.today().addMonths(1).toStartOfMonth());
		}
		if (datefilter == 8) { //All Open
		}
		
		query += ' order by ActivityDate desc';
		
		tasklist = Database.query(query);
	}
	 
	public PageReference SortbyDate()
	{
		SortBy('ActivityDate');
		return null;
	}
	
	public PageReference SortbyStatus() 
	{
		SortBy('Status');
		return null;
	}
	
	public PageReference SortbyAssoc()
	{
		SortBy('AVB_Associate_First_Last_Name__c');
		return null;
	}
	
	public PageReference SortbyOwner()
	{
		SortBy('Owner.Alias');
		return null;
	}
	
	public PageReference SortbyAVBAcct()
	{
		SortBy('AVB_Account_ID__c');
		return null;
	}
	
	public PageReference SortbyType()
	{
		SortBy('AVB_Type__c');
		return null;
	}
	
	public PageReference SortbySubCat()
	{
		SortBy('Subject_Sub_Category__c');
		return null;
	}
	 			
	private void refreshviewoptions()
	{
		viewoptions = new list<SelectOption>();
		viewoptions.add(new SelectOption('1','Overdue'));
		viewoptions.add(new SelectOption('2','Today'));
		viewoptions.add(new SelectOption('3','Today + Overdue'));
		viewoptions.add(new SelectOption('4','Tomorrow'));
		viewoptions.add(new SelectOption('5','Next 7 Days'));
		viewoptions.add(new SelectOption('6','Next 7 Days + Overdue'));
		viewoptions.add(new SelectOption('7','This Month'));
		viewoptions.add(new SelectOption('8','All Open'));
	}
	
	
	
	
	static testmethod void testtasklistcon()
	{
		Date testdate1 = Date.newInstance(2010, 6, 22);
		Date testdate2 = Date.newInstance(2010, 11, 3);
		
test.startTest();		
		TaskListCon t = new TaskListCon();
		String datestring1 = t.date2string(testdate1);
		String datestring2 = t.date2string(testdate2);
		
		list<SelectOption> testviewoptions = t.getviewoptions();
		
		t.setdatefilter('1');
		t.setdatefilter('2');
		t.setdatefilter('3');
		t.setdatefilter('4');
		t.setdatefilter('5');
		t.setdatefilter('6');
		t.setdatefilter('7');
		t.setdatefilter('8');
		
test.stopTest();
		system.assertEquals('2010-06-22', datestring1);
		system.assertEquals('2010-11-03', datestring2);
		system.assertEquals(8,testviewoptions.size());
	}
	
	static testmethod void testsorts()
	{
		list<User> testusers = [select id from User where IsActive = true limit 2];
		
		Account acc = new Account(Name = 'testacc');
		insert acc;
		
		list<Contact> sortcontacts = new list<Contact>();
		sortcontacts.add(new Contact(AccountID = acc.id, LastName = 'testcontacta'));
		sortcontacts.add(new Contact(AccountID = acc.id, LastName = 'testcontactz'));
		insert sortcontacts;
		
		list<Task> sorttasks = new list<Task>();
		sorttasks.add(new Task(whoid = sortcontacts[0].id, ActivityDate = system.today().addDays(-1), 
			Status = 'In Progress', AVB_Associate_First_Last_Name__c = 'Assoc A', //OwnerID = testusers[0].id, 
			AVB_Type__c = 'Billing', Subject_Sub_Category__c = 'Avalon Access' ));
		sorttasks.add(new Task(whoid = sortcontacts[1].id, ActivityDate = system.today().addDays(1), 
			Status = 'Not Started', AVB_Associate_First_Last_Name__c = 'Assoc Z', //OwnerID = testusers[1].id, 
			AVB_Type__c = 'Utilities', Subject_Sub_Category__c = 'Send Letter' ));
		insert sorttasks;
		
		PageReference ref;		
test.starttest();
		TaskListCon tc = new TaskListCon();
		
		ref = tc.SortByDate();
		system.assert(tc.gettasklist()[0].ActivityDate <= tc.gettasklist()[1].ActivityDate);
		ref = tc.SortByStatus();
		system.assert(tc.gettasklist()[0].Status <= tc.gettasklist()[1].Status);
		ref = tc.SortByAssoc();
		system.assert(tc.gettasklist()[0].AVB_Associate_First_Last_Name__c <= tc.gettasklist()[1].AVB_Associate_First_Last_Name__c);
		ref = tc.SortByOwner();
		system.assert(tc.gettasklist()[0].Owner.alias <= tc.gettasklist()[1].Owner.alias);
		ref = tc.SortByAVBAcct();
		system.assert(tc.gettasklist()[0].AVB_Account_ID__c <= tc.gettasklist()[1].AVB_Account_ID__c);
		ref = tc.SortByType();
		system.assert(tc.gettasklist()[0].AVB_Type__c <= tc.gettasklist()[1].AVB_Type__c);
		ref = tc.SortBySubCat();
		system.assert(tc.gettasklist()[0].Subject_Sub_Category__c <= tc.gettasklist()[1].Subject_Sub_Category__c);
		ref = tc.SortBySubCat(); //reverse sort
		system.assert(tc.gettasklist()[0].Subject_Sub_Category__c >= tc.gettasklist()[1].Subject_Sub_Category__c);
		
test.stoptest();
		
	}
	
	
*/
}