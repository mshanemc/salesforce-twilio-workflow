salesforce-twilio-worklow
=========================
Explanation [blog here](https://shane-force.herokuapp.com/2014/12/04/sms-text-from-salesforce-workflow/) showing what this is for

Everything from the [twilio-salesforce repo](https://github.com/twilio/twilio-salesforce), but added the following:

* A custom object to hold messages (to/from numbers plus message text)
* a trigger and helper class to take messages of type Inbound and push them to the API
* test coverage for the above

You can install from the code here OR find the package located [here](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tj0000001WfqF) 