trigger QuoteTrigger on Quote (before insert,before update) {
    if(Trigger.isBefore && Trigger.IsInsert){
	    QuoteTriggerHandler.beforeInsertQuote(Trigger.New);
    }else if(Trigger.isBefore && Trigger.IsUpdate){
	   // QuoteTriggerHandler.beforeUpdateQuote(Trigger.New,Trigger.OldMap);
    }
}