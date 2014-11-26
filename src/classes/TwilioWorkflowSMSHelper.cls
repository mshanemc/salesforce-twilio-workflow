public with sharing class TwilioWorkflowSMSHelper {
	

	@future(Callout=true)
	public static void sendSMS(string fromNumber, string toNumber, string body){

		//get our authorization info
		TwilioConfig__c tc = TwilioConfig__c.getOrgDefaults();
		TwilioRestClient client = new TwilioRestClient(tc.AccountSid__c, tc.AuthToken__c);

		Map<String,String> params = new Map<String,String> {
	        'To'   => '+1'+toNumber,
	        'From' => '+1'+fromNumber,
	        'Body' => body
	    };
		
		if (Test.isRunningTest()) return;
		
		TwilioSMS sms = client.getAccount().getSMSMessages().create(params);
	}
}