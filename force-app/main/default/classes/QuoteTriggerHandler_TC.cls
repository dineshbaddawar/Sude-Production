@isTest
public class QuoteTriggerHandler_TC {
    testMethod static void quoteCreationIfNonKar(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Ledger_Type__c = 'Customer Ledger';
        acc.GST_Number__c = '123456788';
        acc.BillingState = 'TT';
        acc.BillingCountry = 'TTCON';
        acc.BillingPostalCode = '5235622';
        acc.Email__c = 'tally@gmail.com';
        acc.Country_of_Residences__c = 'India';
        acc.GST_Registration_Type__c = 'Regular';
        acc.Phone = '77';
        acc.Tally_Response__c = 'Success';
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        insert opp;
        List<Quote> quotesInsert = new List<Quote>();
        for(Integer i=0;i<=3;i++){
            Quote newQuote = new Quote();
            newQuote.OpportunityID = opp.Id;
            newQuote.Name = 'Test Quote';
            newQuote.ExpirationDate = Date.today();
            newQuote.Effective_Date__c = Date.today();
            newQuote.Pricebook2Id = Test.getStandardPricebookId();
            newQuote.Packing_Value__c = 2000;
            if(i == 0){
                newQuote.CGST__c = 10;
                newQuote.SGST__c = 10;       
            }else if(i== 1){
                newQuote.CGST__c = 10;
            }else if(i== 2){
                newQuote.SGST__c = 10;
            }else if(i== 3){
                newQuote.SGST__c = 10;
            }
            quotesInsert.add(newQuote);
        }
        
        Quote newQuote1 = new Quote();
        newQuote1.OpportunityID = opp.Id;
        newQuote1.Name = 'Test Quote';
        newQuote1.ExpirationDate = Date.today();
        newQuote1.Effective_Date__c = Date.today();
        newQuote1.Pricebook2Id = Test.getStandardPricebookId();
        newQuote1.Packing_Value__c = 2000;
        quotesInsert.add(newQuote1);
        insert quotesInsert;
        acc.BillingState = 'Karnataka';
        acc.Country_of_Residences__c = 'India';
        acc.Export__c = 'Direct Export';
        update acc;
    }
    testMethod static void quoteCreationIfKar(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Ledger_Type__c = 'Customer Ledger';
        acc.GST_Number__c = '123456788';
        acc.BillingState = 'Karnataka';
        acc.BillingCountry = 'TTCON';
        acc.BillingPostalCode = '5235622';
        acc.Email__c = 'tally@gmail.com';
        acc.Country_of_Residences__c = 'India';
        acc.GST_Registration_Type__c = 'Regular';
        acc.Phone = '77';
        acc.Tally_Response__c = 'Success';
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        insert opp;
        List<Quote> quotesInsert = new List<Quote>();
        for(Integer i=0;i<=3;i++){
            Quote newQuote = new Quote();
            newQuote.OpportunityID = opp.Id;
            newQuote.Name = 'Test Quote';
            newQuote.ExpirationDate = Date.today();
            newQuote.Effective_Date__c = Date.today();
            newQuote.Pricebook2Id = Test.getStandardPricebookId();
            newQuote.Packing_Value__c = 2000;
            if(i == 0){
                newQuote.CGST__c = 10;
                newQuote.SGST__c = 10;       
            }else if(i== 1){
                newQuote.CGST__c = 10;
            }else if(i== 2){
                newQuote.SGST__c = 10;
            }else if(i== 3){
                newQuote.SGST__c = 10;
            }
            quotesInsert.add(newQuote);
        }
        Quote newQuote1 = new Quote();
        newQuote1.OpportunityID = opp.Id;
        newQuote1.Name = 'Test Quote';
        newQuote1.ExpirationDate = Date.today();
        newQuote1.Effective_Date__c = Date.today();
        newQuote1.Pricebook2Id = Test.getStandardPricebookId();
        newQuote1.Packing_Value__c = 2000;
        quotesInsert.add(newQuote1);
        insert quotesInsert;
         acc.BillingState = 'Karnataka';
        acc.Country_of_Residences__c = 'India';
        acc.Export__c = 'Deemed Export';
        update acc;
        
    }
    testMethod static void quoteCreationIfKarDeemed(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Ledger_Type__c = 'Customer Ledger';
        acc.GST_Number__c = '123456788';
        acc.BillingState = 'Karnataka';
        acc.BillingCountry = 'TTCON';
        acc.BillingPostalCode = '5235622';
        acc.Email__c = 'tally@gmail.com';
        acc.Country_of_Residences__c = 'India';
        acc.GST_Registration_Type__c = 'Regular';
        acc.Export__c = 'Deemed Export';
        acc.Phone = '77';
        acc.Tally_Response__c = 'Success';
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        insert opp;
        List<Quote> quotesInsert = new List<Quote>();
        for(Integer i=0;i<=3;i++){
            Quote newQuote = new Quote();
            newQuote.OpportunityID = opp.Id;
            newQuote.Name = 'Test Quote';
            newQuote.ExpirationDate = Date.today();
            newQuote.Effective_Date__c = Date.today();
            newQuote.Pricebook2Id = Test.getStandardPricebookId();
            newQuote.Packing_Value__c = 2000;
            if(i == 0){
                newQuote.CGST__c = 10;
                newQuote.SGST__c = 10;       
            }else if(i== 1){
                newQuote.CGST__c = 10;
            }else if(i== 2){
                newQuote.SGST__c = 10;
            }else if(i== 3){
                newQuote.SGST__c = 10;
            }
            quotesInsert.add(newQuote);
        }
        Quote newQuote1 = new Quote();
        newQuote1.OpportunityID = opp.Id;
        newQuote1.Name = 'Test Quote';
        newQuote1.ExpirationDate = Date.today();
        newQuote1.Effective_Date__c = Date.today();
        newQuote1.Pricebook2Id = Test.getStandardPricebookId();
        newQuote1.Packing_Value__c = 2000;
        quotesInsert.add(newQuote1);
        insert quotesInsert;
         acc.BillingState = 'AP';
        acc.Country_of_Residences__c = 'India';
        acc.Export__c = 'Deemed Export';
        update acc;
          
    }
    testMethod static void quoteCreationIfNoKarDeemed(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Ledger_Type__c = 'Customer Ledger';
        acc.GST_Number__c = '123456788';
        acc.BillingState = 'Hyderabad';
        acc.BillingCountry = 'TTCON';
        acc.BillingPostalCode = '5235622';
        acc.Export__c = 'Deemed Export';
        acc.Email__c = 'tally@gmail.com';
        acc.Country_of_Residences__c = 'India';
        acc.GST_Registration_Type__c = 'Regular';
        acc.Phone = '77';
        acc.Tally_Response__c = 'Success';
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        insert opp;
        List<Quote> quotesInsert = new List<Quote>();
        for(Integer i=0;i<=3;i++){
            Quote newQuote = new Quote();
            newQuote.OpportunityID = opp.Id;
            newQuote.Name = 'Test Quote';
            newQuote.ExpirationDate = Date.today();
            newQuote.Effective_Date__c = Date.today();
            newQuote.Pricebook2Id = Test.getStandardPricebookId();
            newQuote.Packing_Value__c = 2000;
            if(i == 0){
                newQuote.CGST__c = 10;
                newQuote.SGST__c = 10;       
            }else if(i== 1){
                newQuote.CGST__c = 10;
            }else if(i== 2){
                newQuote.SGST__c = 10;
            }else if(i== 3){
                newQuote.SGST__c = 10;
            }
            quotesInsert.add(newQuote);
        }
        Quote newQuote1 = new Quote();
        newQuote1.OpportunityID = opp.Id;
        newQuote1.Name = 'Test Quote';
        newQuote1.ExpirationDate = Date.today();
        newQuote1.Effective_Date__c = Date.today();
        newQuote1.Pricebook2Id = Test.getStandardPricebookId();
        newQuote1.Packing_Value__c = 2000;
        quotesInsert.add(newQuote1);
        insert quotesInsert;
        acc.BillingState = 'AP';
        acc.Country_of_Residences__c = 'India';
        acc.Export__c = null;
        update acc;
    }
    testMethod static void quoteCreationIfNotIndia(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Ledger_Type__c = 'Customer Ledger';
        acc.GST_Number__c = '123456788';
        acc.BillingState = 'Nepalian';
        acc.BillingCountry = 'TTCON';
        acc.BillingPostalCode = '5235622';
        acc.Email__c = 'tally@gmail.com';
        acc.Country_of_Residences__c = 'Nepal';
        acc.GST_Registration_Type__c = 'Regular';
        acc.Phone = '77';
        acc.Tally_Response__c = 'Success';
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.Export__c ='Direct Export';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        insert opp;
        List<Quote> quotesInsert = new List<Quote>();
        for(Integer i=0;i<=3;i++){
            Quote newQuote = new Quote();
            newQuote.OpportunityID = opp.Id;
            newQuote.Name = 'Test Quote';
            newQuote.ExpirationDate = Date.today();
            newQuote.Effective_Date__c = Date.today();
            newQuote.Pricebook2Id = Test.getStandardPricebookId();
            newQuote.Packing_Value__c = 2000;
            if(i == 0){
                newQuote.CGST__c = 10;
                newQuote.SGST__c = 10;       
            }else if(i== 1){
                newQuote.CGST__c = 10;
            }else if(i== 2){
                newQuote.SGST__c = 10;
            }else if(i== 3){
                newQuote.SGST__c = 10;
            }
            quotesInsert.add(newQuote);
        }
        Quote newQuote1 = new Quote();
        newQuote1.OpportunityID = opp.Id;
        newQuote1.Name = 'Test Quote';
        newQuote1.ExpirationDate = Date.today();
        newQuote1.Effective_Date__c = Date.today();
        newQuote1.Pricebook2Id = Test.getStandardPricebookId();
        newQuote1.Packing_Value__c = 2000;
        quotesInsert.add(newQuote1);
        insert quotesInsert;
        acc.BillingState = 'Karnataka';
        acc.Country_of_Residences__c = 'India';
        acc.Export__c = null;
        update acc;
        
    }
}