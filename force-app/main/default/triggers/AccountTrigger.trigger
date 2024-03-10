trigger AccountTrigger on Account (After Update) {
    if(Trigger.isAfter && Trigger.IsUpdate){
        AccountTriggerHandler.afterUpdateAccounts(Trigger.New,Trigger.OldMap);
    }
}