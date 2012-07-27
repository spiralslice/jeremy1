public without sharing class UnSubCon {
	String webindex;
	String EmailAddress;
	//EmailPrefs__c standardprefs;
	String personID;
	String Comments = '';
	list<Contact> cons = new list<Contact>();
	list<Lead> leads = new list<Lead>();
	String reportingEmailAddress = 'salesforce@synapticap.com';
	
	
	public UnSubCon () 
	{

		if (ApexPages.CurrentPage().getParameters().get('em') != null) {
			//Get Email Address from URL parameters
			EmailAddress = ApexPages.CurrentPage().getParameters().get('em');
			//Basic validation
			if ((!EmailAddress.contains('@')) || (!EmailAddress.contains('.')) || (EmailAddress.length() < 8)) EmailAddress = null;
		}
		if (EmailAddress != null) {
			cons = [select id, HasOptedOutOfEmail, Description from Contact where Email = :EmailAddress];
			leads = [ select id, HasOptedOutOfEmail, Description from Lead where Email = :EmailAddress];
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'cons ' + cons.size()));
		}
		
		/*
		try {
			standardprefs = [select Name, Unsubscribe_Recipient__c from EmailPrefs__c where Name = 'Standard Preferences' limit 1];
		} catch (Exception exc) {
			standardprefs = new EmailPrefs__c(Name = 'Standard Preferences',Unsubscribe_Recipient__c = 'it@hopefoundation.org');
		}
		
		reportingEmailAddress = standardprefs.Unsubscribe_Recipient__c;
		*/
	}
	
	public String getEmailAddress() { 
		return EmailAddress;
	}
	
	public String getComments() { return Comments; }
	public void setComments(String c) { Comments = c; }
	
	public PageReference UnsubscribeEmail()
	{
		/*
system.debug('\n\nstandardprefs id ' + standardprefs.id);		
		if (standardprefs.id == null) {
			insert standardprefs;
		} else {
			update standardprefs;
		}
		*/
		String results = 'Received Unsubscribe request from email address ' + EmailAddress + '<br/>';
		results += '<strong>URL parameters:</strong><br/>';
		results += '<table >';
		map<String, String> parms = ApexPages.CurrentPage().getParameters();
		for (String i : parms.keyset()) {
			results += '<tr><td>' + i + '</td><td>' + parms.get(i) + '</td></tr>';
		}
		results += '</table><br/>';
		 
		
		if ((cons.size() > 0) || (leads.size() > 0)) {
			results += 'Records Opted Out:<br/><strong>Contact IDs:</strong><br/>';
			for (Contact c : cons) {
				c.HasOptedOutOfEmail = true;
				String olddesc = (c.Description == null) ? ' ' : c.Description;
				c.Description = 'Unsubscribed via web form ' + system.today().format() + '\r\n' + olddesc; 
				results += '<a href="/' + c.id + '">' + c.id + '</a><br/>';
			}
			
			results += '<br/><strong>Lead IDs:</strong><br/>';
			for (Lead l : leads) {
				l.HasOptedOutOfEmail = true;
				String olddesc = (l.Description == null) ? ' ' : l.Description;
				l.Description = 'Unsubscribed via web form ' + system.today() + '\r\n' + olddesc; 
				results += '<a href="/' + l.id + '">' + l.id + '</a><br/>';
			}
			update cons;
			update leads;
		} else {
			Lead newlead = new Lead(
				LastName = 'No Name Specified',
				Company = 'No Account Specified',
				Email = EmailAddress,
				HasOptedOutOfEmail = true,
				Description = 'Created and unsubscribed via web form ' + system.today() + '\r\n'
				);
			insert newlead;
			results += '<strong>New Lead Created:</strong><br/>';
			results += '<a href="/' + newlead.ID + '">' + newlead.ID + '</a><br/>';
		}
		
		results += '<br/><strong>Comments entered on page:</strong><br/>';
		results += Comments;
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
		email.setToAddresses(new list<String> {reportingEmailAddress});
		email.setSubject('Unsubscribe received from web');
		email.setHTMLbody(results);
		email.setPlainTextBody(results);
		list<Messaging.SingleEmailMessage> ems = new list<Messaging.SingleEmailMessage>();
		ems.add(email);
		
		Messaging.sendEmail(ems);
	
		PageReference pageref = Page.UnsubResult; 
		return pageref;
	}
	
}