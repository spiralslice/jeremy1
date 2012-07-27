@istest
private Class test_testclass {
	
	static testmethod void testmakeUsers()
	{
		id prfid = [select id from Profile limit 1].id;
      	list<User> users = new list<User>();
    	for (Integer i = 0; i < 2; i++) {
	          String digit = String.valueOf(i);
	          users.add(new User(
	            alias = 'user' + digit, 
	            email='standarduser@example.com', 
	              emailencodingkey='UTF-8', 
	              lastname='Testing ' + digit, 
	              languagelocalekey='en_US', 
	              localesidkey='en_US', 
	              profileid = prfid, 
	              timezonesidkey='America/Los_Angeles', 
	              username='testuser' + digit + '@example.com'
	              ));
          
        }
        insert users;
	}
}