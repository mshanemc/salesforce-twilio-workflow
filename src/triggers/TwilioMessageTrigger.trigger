trigger TwilioMessageTrigger on Twilio_Message__c (before insert, after insert) {

	//using after becuase we use the IDs for future calls
	if (trigger.isAfter){
		TwilioWorkflowSMSHelper.messageProcessor(trigger.new);
	} 
}