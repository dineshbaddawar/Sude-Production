public class AccountTriggerHandler {
    public static void afterUpdateAccounts(List<Account> newAccounts,Map<Id,Account> oldAccounts){
        Set<Id> accIds = new Set<Id>();
        for(Account acc : newAccounts){
            if((acc.BillingState != oldAccounts.get(acc.Id).BillingState) || (acc.Export__c != oldAccounts.get(acc.Id).Export__c) || (acc.Country_of_Residences__c != oldAccounts.get(acc.Id).Country_of_Residences__c)){
                accIds.add(acc.Id);                
            }
        } 
        List<Quote> QuoteToUpdate = new List<Quote>();
        for(Opportunity opp : [SELECT Id,Account.BillingState,Account.Export__c,Account.Country_of_Residences__c,
                                        (SELECT CGST__c,SGST__c,IGST__c FROM Quotes) 
                                    FROM Opportunity Where AccountId IN : accIds]){
            List<Quote> eachOppQuotes = opp.Quotes;                           
            for(Quote eachQuote : eachOppQuotes){
                if(opp.Account.Export__c == null){
                    if(opp.Account.BillingState == 'Karnataka' && opp.Account.Country_of_Residences__c == 'India'){
                        eachQuote.CGST__c = 9;
                        eachQuote.SGST__c = 9;
                        eachQuote.IGST__c = 0;
                    }else if(opp.Account.BillingState != 'Karnataka' && opp.Account.Country_of_Residences__c == 'India'){
                        eachQuote.CGST__c = 0;
                        eachQuote.SGST__c = 0;
                        eachQuote.IGST__c = 18;
                    }
                 }else if(opp.Account.Export__c =='Deemed Export'){
                    if(opp.Account.BillingState == 'Karnataka' && opp.Account.Country_of_Residences__c == 'India'){
                        eachQuote.CGST__c = 0.05;
                        eachQuote.SGST__c = 0.05;
                        eachQuote.IGST__c = 0;
                    }else if(opp.Account.BillingState != 'Karnataka' && opp.Account.Country_of_Residences__c == 'India'){
                        eachQuote.CGST__c = 0;
                        eachQuote.SGST__c = 0;
                        eachQuote.IGST__c = 0.1;
                    }
                }else if(opp.Account.Export__c == 'Direct Export' || opp.Account.Export__c == 'Deemed Export SUZ'){
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0;
                }
                QuoteToUpdate.add(eachQuote);
            }
            if(!QuoteToUpdate.isEmpty()){
                update QuoteToUpdate;
            }                            
        }

    }
}