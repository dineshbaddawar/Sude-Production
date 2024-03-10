public class QuoteTriggerHandler {
   public static void beforeInsertQuote(List<Quote> newQuotes){
        Set<Id> parentOppIds = new Set<Id>();
        for(Quote eachQuote : newQuotes){
            parentOppIds.add(eachQuote.OpportunityId); 
        }
        Map<Id,Opportunity> parentOppMap = new Map<Id,Opportunity>([SELECT Account.BillingState,Account.Deemed_Export__c,Account.Export__c,Account.Country_of_Residences__c FROM Opportunity WHERE ID IN : parentOppIds]);
        for(Quote eachQuote : newQuotes){
            Opportunity opp = parentOppMap.get(eachQuote.OpportunityId);
            if(opp.Account.BillingState == 'Karnataka' && opp.Account.Export__c == null && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 9;
                    eachQuote.SGST__c = 9;
                    eachQuote.IGST__c = 0;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 9;
                    eachQuote.SGST__c = 9;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 9;
                    eachQuote.IGST__c = 0;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 9;
                    eachQuote.IGST__c = 0; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 9;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 9;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0;
                }    
            }else if(opp.Account.BillingState != 'Karnataka' && opp.Account.Export__c == null && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 18;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 18;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.IGST__c = 18; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 18;
                } 
            }else if(opp.Account.BillingState == 'Karnataka' && opp.Account.Export__c =='Deemed Export' && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                    eachQuote.SGST__c = 0.05;
                    eachQuote.IGST__c = 0;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                    eachQuote.SGST__c = 0.05;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0.05;
                    eachQuote.IGST__c = 0;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                    eachQuote.IGST__c = 0; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0.05;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0;
                }  
            }else if(opp.Account.BillingState != 'Karnataka' && opp.Account.Export__c =='Deemed Export' && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0.1;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0.1;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.IGST__c = 0.1; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0.1;
                } 
            }else if(opp.Account.Export__c == 'Direct Export' || opp.Account.Export__c == 'Deemed Export SUZ'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.IGST__c = 0; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0;
                } 
            }
        }
    }
   /* public static void beforeUpdateQuote(List<Quote> newQuotes){
        Set<Id> parentOppIds = new Set<Id>();
        for(Quote eachQuote : newQuotes){
            parentOppIds.add(eachQuote.OpportunityId); 
        }
        Map<Id,Opportunity> parentOppMap = new Map<Id,Opportunity>([SELECT Account.BillingState,Account.Deemed_Export__c,Account.Country_of_Residences__c FROM Opportunity WHERE ID IN : parentOppIds]);
        for(Quote eachQuote : newQuotes){
            Opportunity opp = parentOppMap.get(eachQuote.OpportunityId);
            if(opp.Account.BillingState == 'Karnataka' && opp.Account.Deemed_Export__c == false && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 9;
                    eachQuote.SGST__c = 9;
                    eachQuote.IGST__c = 0;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 9;
                    eachQuote.SGST__c = 9;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 9;
                    eachQuote.IGST__c = 0;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 9;
                    eachQuote.IGST__c = 0; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 9;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 9;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0;
                }    
            }else if(opp.Account.BillingState != 'Karnataka' && opp.Account.Deemed_Export__c == false && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 18;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 18;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.IGST__c = 18; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 18;
                } 
            }else if(opp.Account.BillingState == 'Karnataka' && opp.Account.Deemed_Export__c == true && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                    eachQuote.SGST__c = 0.05;
                    eachQuote.IGST__c = 0;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                    eachQuote.SGST__c = 0.05;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0.05;
                    eachQuote.IGST__c = 0;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                    eachQuote.IGST__c = 0; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0.05;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0.05;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0;
                }  
            }else if(opp.Account.BillingState != 'Karnataka' && opp.Account.Deemed_Export__c == true && opp.Account.Country_of_Residences__c == 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0.1;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0.1;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.IGST__c = 0.1; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0.1;
                } 
            }else if(opp.Account.Deemed_Export__c == false && opp.Account.Country_of_Residences__c != 'India'){
                if(eachQuote.CGST__c == null && eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0;
                }else if(eachQuote.CGST__c == null && eachQuote.SGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.SGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.SGST__c = 0;
                    eachQuote.IGST__c = 0;
                } else if(eachQuote.CGST__c == null && eachQuote.IGST__c == null) {
                    eachQuote.CGST__c = 0;
                    eachQuote.IGST__c = 0; 
                }else if(eachQuote.CGST__c == null) {
                    eachQuote.CGST__c = 0;
                }else if(eachQuote.SGST__c == null) {
                    eachQuote.SGST__c = 0;
                }else if(eachQuote.IGST__c == null) {
                    eachQuote.IGST__c = 0;
                } 
            }
        }
    }*/
}