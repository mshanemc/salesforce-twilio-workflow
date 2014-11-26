@isTest
private class Twilio_TestTwilioWorkflowSMSHelper {
	
	@isTest static void test_method_one() {
		//populate and create the custom setting
		TwilioConfig__c tc = TwilioConfig__c.getOrgDefaults();
		if (tc == null) tc = new TwilioConfig__c();

		tc.AccountSid__c = 'ACa18f51a8a555a12f9caa2934c84817f3';
		tc.AuthToken__c = 'ee43e880de145ea1b5826349cf2de81e';
		upsert tc;

		//send the message
		Twilio_Message__c tm = new Twilio_Message__c();
		tm.Direction__c = 'Outbound';
		tm.Message_Body__c = 'Test';
		tm.Recipient_Phone__c = '999999999';
		tm.Sender_Phone__c = '9999999999';

		test.startTest();
		insert tm; 
		test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}