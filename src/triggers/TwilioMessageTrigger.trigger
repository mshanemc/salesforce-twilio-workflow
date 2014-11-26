trigger TwilioMessageTrigger on Twilio_Message__c (before insert) {

	//loop through the messages from this insert
	for (Twilio_Message__c tm:trigger.new){
		//is it inbound?
		if (tm.Direction__c == 'Outbound'){
			//make a call to the TwilioAPI
			TwilioWorkflowSMSHelper.sendSMS(tm.Sender_Phone__c, tm.Recipient_Phone__c, tm.Message_Body__c);
		}
	}
}