public class TallyIntegrationForOpportunityBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext batchContext){
        String dataSource = Label.Migration_Data_Source;
        return Database.getQueryLocator([SELECT Name,SyncedQuoteId,Order_Acknowledgement_Number__c,AccountId,Tally_Response__c,StageName,CloseDate,Order_Reference_Date__c,Order_Reference_Number__c FROM Opportunity WHERE Data_Source__c =: dataSource ]);
    }
    public void execute(Database.BatchableContext batchContext, List<Opportunity> scope){
        for(Opportunity product : scope){
           TallyService.quoteCreationOnTally(product.Id);
        }
    }
    public void finish(Database.BatchableContext BC){
    }

}