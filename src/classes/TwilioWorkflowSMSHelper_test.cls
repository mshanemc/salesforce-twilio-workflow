@isTest
private class TwilioWorkflowSMSHelper_test {
	
	@isTest static void testHelperGood() {

		Test.setMock(HttpCalloutMock.class, makeMock('TwilioPostGoodSMS', 201));
		dataSetup();		

		Test.startTest();

		Twilio_Message__c tm = new Twilio_Message__c(
			Recipient_Phone__c = '5558765309', 
			Message_Body__c = 'hello!', 
			Direction__c = 'Outbound'
		);
		insert tm;
		
		Test.stopTest();

		tm = [select id, Status__c, Error_Comments__c from Twilio_Message__c where id=:tm.id];
		system.assertEquals('Success', tm.Status__c);

	}

	@isTest static void testHelperBad() {

		Test.setMock(HttpCalloutMock.class, makeMock('TwilioPostBadSMS', 400));
		dataSetup();		

		Test.startTest();

		Twilio_Message__c tm = new Twilio_Message__c(
			Recipient_Phone__c = '5558765309', 
			Message_Body__c = 'hello!', 
			Direction__c = 'Outbound'
		);
		insert tm;
		
		Test.stopTest();

		tm = [select id, Status__c, Error_Comments__c from Twilio_Message__c where id=:tm.id];
		system.assertEquals('Error', tm.Status__c);
		system.assertEquals('The \'From\' number 1281607256 is not a valid phone number or shortcode.', tm.Error_Comments__c);

	}



	@isTest static void dataSetup(){
		//create our custom setting
		TwilioConfig__c tc = new TwilioConfig__c();
		tc.AccountSid__c = 'ACb16f51a6b555b12f9cbb2934c64617f3';
		tc.AuthToken__c = '3347e880d3145ea1b5826749cf2d3813';
		tc.Twilio_Number__c = '2816072152';
		tc.API_Version__c = '2010-04-01';
		tc.Twilio_Version__c = '3.2.0';
		tc.API_Endpoint__c = 'https://api.twilio.com';

		insert tc;
	}

	public static StaticResourceCalloutMock makeMock(string resource, integer statusCode){
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource(resource);
		mock.setStatusCode(statusCode);
		mock.setHeader('Content-Type', 'application/json');
		return mock;
	}

	@isTest static void testBulkTrigger() {

		Test.setMock(HttpCalloutMock.class, makeMock('TwilioPostGoodSMS', 201));
		dataSetup();		

		Test.startTest();

		list<Twilio_Message__c> tms = new list<Twilio_Message__c>();
		for (integer x=0; x<200; x++){
			tms.add( new Twilio_Message__c(
						Recipient_Phone__c = '5558765309', 
						Message_Body__c = 'hello!'+x,
						Direction__c = 'Outbound'
						)
			);
		}
		insert tms;
		
		Test.stopTest();
		list<Twilio_Message__c> tms2Assert = [select id, Status__c, Message_Body__c, Direction__c, Recipient_Phone__c from Twilio_Message__c where id in: tms];
		
		integer assertCount = 0;
		for (Twilio_Message__c tm:tms2Assert){
			system.assertEquals('Success', tm.Status__c, 'on Assert ' + assertCount +', tm is: ' + tm );
		}

	}

	
	
}