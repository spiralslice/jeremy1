public with sharing class cloneQuoteExt {
	Quote oldQuote;
	Quote newQuote;
	
	public cloneQuoteExt(ApexPages.standardcontroller con) {
		this.oldQuote = (Quote)con.getRecord();
	}
	
	public static Quote cloneQuote(Quote old) 
	{
		Quote original = [select id, Name, OpportunityID from Quote where id = :old.id];
		Quote duplicate = new Quote();
		
		duplicate.put('Name','testname');
		
		return duplicate;
	}
}