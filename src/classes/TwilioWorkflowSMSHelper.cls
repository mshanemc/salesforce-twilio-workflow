public with sharing class TwilioWorkflowSMSHelper {

    
    //callout to Twilio for a single message
	public static Twilio_Message__c sendSMSNow(Twilio_Message__c tm){

		HttpRequest req = requestBuilder();
		req.setBody(bodyBuilder(tm));
		system.debug(req);
		http h = new http();
		HttpResponse res = h.send(req);

		TwilioResponse tr = (TwilioResponse)JSON.deserialize(res.getBody(), TwilioResponse.class);
		system.debug(tr);
		
		if (tr.Status == 'queued'){
			tm.Status__c = 'Success';
		} else {
			tm.Status__c = 'Error';
			tm.Error_Comments__c = tr.message;
		}

		system.debug(tm);
		return tm;
        
	}
    
    //takes a list of recordIds
	@future(Callout=true)
	public static void sendSMSLater(List<Id> recordIds){
		//reconstitute the record List
		List<Twilio_Message__c> tms = [select id, Recipient_Phone__c, Message_Body__c,
		Status__c, Error_Comments__c from Twilio_Message__c where id in: recordIds];

		List<Twilio_Message__c> tmsToUpdate = new List<Twilio_Message__c>();

		for (Twilio_Message__c tm:tms){			

			Twilio_Message__c tm2Update = sendSMSNow(tm);
			system.debug(tm);

			tmsToUpdate.add(tm2Update);
		}

		update tmsToUpdate;
	}
    
    
    
    
	//receives records from trigger, batches them based on the callout limit, 
	//and passes those batches to the future call
	public static void messageProcessor(List<Twilio_Message__c> tms){

		List<List<Id>> RecordIdBatches = new List<List<Id>>();

		Integer Batchsize = Limits.GetLimitCallouts();
		List<Id> RecordIdBatch = new List<Id>();

		for (Twilio_Message__c tm:tms){
			if (tm.Direction__c == 'Outbound'){
				if (RecordIdBatch.size()<Batchsize){
					RecordIdBatch.add(tm.Id); //add to batch if there's room
				} else {
					//if a batch is done, add it to the List and get a new one ready
					RecordIdBatches.add(RecordIdBatch);
					system.debug('batch complete: ');
					system.debug(RecordIdBatch);

					RecordIdBatch = new List<Id>();
					RecordIdBatch.add(tm.Id);
				}
			} 
		}
		//add whatever was in the final batch to the List
		RecordIdBatches.add(RecordIdBatch);

		//loop through the batches and pass to our future callout method
		for (List<Id> messageBatch:RecordIdBatches){
			sendSMSLater(messageBatch);
		}
	}

	

	

	
	public static HttpRequest requestBuilder (){
		TwilioConfig__c tc = TwilioConfig__c.getOrgDefaults();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(urlBuilder());
		req.setHeader(
			'Authorization', 'Basic '
			+EncodingUtil.base64Encode(Blob.valueOf(
				tc.AccountSid__c 
				+ ':' 
				+ tc.AuthToken__c
				)
			)
		);
		req.setMethod('POST');
		return req;
	}

	public static string bodyBuilder(Twilio_Message__c tm){
		TwilioConfig__c tc = TwilioConfig__c.getOrgDefaults();

		string output = 
			'To=' + '1' + tm.Recipient_Phone__c +
			'&Body=' + tm.Message_Body__c +
			'&From=' + '1' + tc.Twilio_Number__c;
		
		system.debug(output);
		return output;

	}

	public static string urlBuilder(){
		
		TwilioConfig__c tc = TwilioConfig__c.getOrgDefaults();

		return 
			tc.API_Endpoint__c 
			+ '/' +
			tc.API_Version__c
			+ '/' +
			'Accounts'
			+ '/' +
			tc.AccountSid__c
			+ '/' +
			'SMS/Messages.json'
		;

	}

	//JSON deserializing for good (status) and bad (message)
	public class TwilioResponse {
		public string status {get;set;}
		public string message {get;set;}
	}

}