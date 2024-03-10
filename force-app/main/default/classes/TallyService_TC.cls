@isTest
public class TallyService_TC{
    
    testMethod static void quoteSync(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        
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
        acc.Data_Source__c = 'Ready To Sync';

        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.MobilePhone = '77';
        con.AccountId = acc.id;
        insert con;
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Family = 'AUS';
        product.Data_Source__c = 'Ready To Sync';
        product.isActive = true;
        insert product;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.Description = 'Price Book 2009 Products';
        pb.IsActive = true;
        insert pb;
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        Quote newQuote = new Quote();
        newQuote.OpportunityID = opp.Id;
        newQuote.Name = 'Test Quote';
        newQuote.ExpirationDate = Date.today();
        newQuote.Effective_Date__c = Date.today();
        newQuote.Pricebook2Id = Test.getStandardPricebookId();
        newQuote.Packing_Value__c = 2000;
        newQuote.Packing__c = 2;
        newQuote.CGST__c = 9;
        newQuote.SGST__c = 9;
        newQuote.IGST__c = 28;
        newQuote.Freight__c = 20;
        newQuote.Insurance__c = 10;
        insert newQuote;
        
        QuoteLineItem lineItem = new QuoteLineItem();
        lineItem.QuoteID = newQuote.Id;
        lineItem.UnitPrice = 20;
        lineItem.Product2Id = product.Id;
        lineItem.Quantity = 2;
        lineItem.ServiceDate = Date.today();
        lineItem.PricebookEntryId = pbe.id;
        insert lineItem;
        
        opp.SyncedQuoteId = newQuote.id;
        update opp;
        PageReference pageRef = Page.SUDEBangaloreQuotePDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',newQuote.id);
        
        Test.startTest();
            TallyService service = new TallyService();
            TallyService.responseBody = '<CREATED>1</CREATED>';
            TallyService.statusCode = 200;
            TallyService.QuoteWrapper recordWrapper = new TallyService.QuoteWrapper();
            recordWrapper.quoteId = opp.Id;
            TallyService.tallyServiceForQuoteInvoked(new List<TallyService.QuoteWrapper>{recordWrapper});
            TallyService.tallyServiceForQuoteAction(acc.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.responseBody = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCode = 200;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.responseBody = 'error';
            TallyService.statusCode = 200;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.responseBody = 'ERR_CONNECT_FAIL';
            TallyService.statusCode = 503;
            TallyService.responseBodyFor2ndEndPoint = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCodeFor2ndEndPoint = 200;            
            TallyService.tallyServiceForQuoteAction(opp.Id);


            
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newQuote);
            DisplayQuoteDetailController ec = new DisplayQuoteDetailController(sc);
            ApexPages.currentPage().getParameters().put('isPDFGenerated','false');
            ec.generatePDF();

        Test.stopTest();

    }
    testMethod static void opportunityTaxPDF(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        
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
        acc.Data_Source__c = 'Ready To Sync';
                insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.MobilePhone = '77';
        con.AccountId = acc.id;
        insert con;
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Family = 'AUS';
        product.Data_Source__c = 'Ready To Sync';
        product.isActive = true;
        insert product;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.Description = 'Price Book 2009 Products';
        pb.IsActive = true;
        insert pb;
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        Quote newQuote = new Quote();
        newQuote.OpportunityID = opp.Id;
        newQuote.Name = 'Test Quote';
        newQuote.ExpirationDate = Date.today();
        newQuote.Effective_Date__c = Date.today();
        newQuote.Pricebook2Id = Test.getStandardPricebookId();
        newQuote.Packing_Value__c = 2000;
        newQuote.Packing__c = 2;
        newQuote.Freight__c = 20;
        newQuote.Insurance__c = 10;
        insert newQuote;
        
        QuoteLineItem lineItem = new QuoteLineItem();
        lineItem.QuoteID = newQuote.Id;
        lineItem.UnitPrice = 20;
        lineItem.Product2Id = product.Id;
        lineItem.Quantity = 2;
        lineItem.ServiceDate = Date.today();
        lineItem.PricebookEntryId = pbe.id;
        insert lineItem;
        
        opp.SyncedQuoteId = newQuote.id;
        update opp;
        PageReference pageRef = Page.SUDECommercialInvoicePDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        Test.startTest();
            TallyService service = new TallyService();
            TallyService.responseBody = '<CREATED>1</CREATED>';
            TallyService.statusCode = 200;
            TallyService.QuoteWrapper recordWrapper = new TallyService.QuoteWrapper();
            recordWrapper.quoteId = opp.Id;
            TallyService.tallyServiceForQuoteInvoked(new List<TallyService.QuoteWrapper>{recordWrapper});
            TallyService.tallyServiceForQuoteAction(acc.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);
            TallyService.tallyServiceForQuoteAction(opp.Id);


            
            TallyService.responseBody = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCode = 200;
            TallyService.tallyServiceForQuoteAction(opp.Id);

            newQuote.Effective_Date__c = null;
            update newQuote;
            TallyService.responseBody = 'error';
            TallyService.statusCode = 200;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.responseBody = 'ERR_CONNECT_FAIL';
            TallyService.statusCode = 503;
            TallyService.responseBodyFor2ndEndPoint = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCodeFor2ndEndPoint = 200;
            
            TallyService.tallyServiceForQuoteAction(opp.Id);

            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(opp);
            SUDECommercialInvoicePDFController ec = new SUDECommercialInvoicePDFController(sc);

        Test.stopTest();

    }
    testMethod static void salesLedgerSync(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        Account acc = new Account();
        acc.Data_Source__c = 'Ready To Sync';
                acc.Name = 'Test Account';
        acc.Ledger_Type__c = 'Sales Ledger';
        acc.GST_Number__c = '123456788';
        acc.BillingState = 'TT';
        acc.BillingCountry = 'TTCON';
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingPostalCode = '5235622';
        acc.Email__c = 'tally@gmail.com';
        acc.Country_of_Residences__c = 'India';
        acc.GST_Registration_Type__c = 'Regular';
        acc.Phone = '77';
        
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Order Acknowledgement';
        opp.Name = 'Test Opp';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        Quote newQuote = new Quote();
        newQuote.OpportunityID = opp.Id;
        newQuote.Name = 'Test Quote';
        newQuote.ExpirationDate = Date.today();
        newQuote.Effective_Date__c = Date.today();
        newQuote.Pricebook2Id = Test.getStandardPricebookId();
        newQuote.Packing_Value__c = 2000;
        newQuote.Freight__c = 20;
        newQuote.Insurance__c = 10;
        insert newQuote;
        
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Family = 'AUS';
        product.Data_Source__c = 'Ready To Sync';
        product.isActive = true;
        insert product;
        opp.Data_Source__c = 'Ready To Sync';
        opp.SyncedQuoteId = newQuote.id;
        update opp;
        Test.startTest();
            TallyService.responseBody = '<CREATED>1</CREATED>';
            TallyService.statusCode = 200;
            TallyService.tallyServiceForQuoteAction(acc.Id);
            acc.Ledger_Type__c = 'Customer Ledger';
            acc.Tally_Response__c =  null;
            update acc;
            TallyService.responseBody = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCode = 200;
            TallyService.tallyServiceForQuoteAction(acc.Id);
            acc.Tally_Response__c =  null;
            acc.Ledger_Type__c = 'Tax Ledger';
            update acc;

            TallyService.responseBody = 'ERR_CONNECT_FAIL';
            TallyService.statusCode = 503;
            TallyService.responseBodyFor2ndEndPoint = 'ERR_CONNECT_FAIL';
            TallyService.statusCodeFor2ndEndPoint = 503;
            TallyService.responseBodyFor2ndEndPoint = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCodeFor2ndEndPoint = 200;            
            TallyService.tallyServiceForQuoteAction(acc.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);

            
            TallyService.responseBodyFor2ndEndPoint = '<CREATED>1</CREATED>';
            TallyService.statusCodeFor2ndEndPoint = 200;            
            TallyService.tallyServiceForQuoteAction(acc.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);

            
            TallyService.responseBodyFor2ndEndPoint = 'ERR_CONNECT_FAIL';
            TallyService.statusCodeFor2ndEndPoint = 503;            
            TallyService.tallyServiceForQuoteAction(acc.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);
            TallyIntegrationForOpportunityBatch tallyOppBatch = new TallyIntegrationForOpportunityBatch();            
            
            Database.executeBatch(tallyOppBatch ,1);
            
            cred.Alternative_End_Point__c = 'ww.google.com';
            update cred ;
            newQuote.Effective_Date__c = null;
            update newQuote;
            
            TallyService.responseBody = 'ERR_CONNECT_FAIL';
            TallyService.statusCode = 503;
            TallyService.responseBodyFor2ndEndPoint = '<LINEERROR>1</LINEERROR>';
            TallyService.statusCodeFor2ndEndPoint = 200;
            product.Tally_Response__c = '';
            update product;            
            acc.Tally_Response__c =  null;
            update acc;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);
            
            cred.Alternative_End_Point__c = 'ww.google.com';
            update cred ;
            TallyService.responseBody = 'ERR_CONNECT_FAIL';
            TallyService.statusCode = 503;
            TallyService.responseBodyFor2ndEndPoint = 'ERR_CONNECT_FAIL';
            TallyService.statusCodeFor2ndEndPoint = 503;
            product.Tally_Response__c = '';
            update product;            
            acc.Tally_Response__c =  null;
            update acc;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);

            TallyService.responseBody = '<LINEERROR>1</LINEERROR>';            
            TallyService.statusCode = 200;
            product.Tally_Response__c = null;
            update product;            
            acc.Tally_Response__c =  null;
            update acc;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);
            
            TallyService.responseBody = 'ERR_CONNECT_FAIL';
            TallyService.statusCode = 503;
            TallyService.responseBodyFor2ndEndPoint = 'ERR_CONNECT_FAIL';
            TallyService.statusCodeFor2ndEndPoint = 503;
            product.Tally_Response__c = '';
            update product;            
            acc.Tally_Response__c =  null;
            update acc;
            TallyService.tallyServiceForQuoteAction(acc.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);


            acc.Tally_Response__c = 'Success';
            update acc;
            product.Tally_Response__c = 'Success';
            update product;
            TallyService.tallyServiceForQuoteAction(opp.Id);
            TallyService.tallyServiceForQuoteAction(product.Id);

        Test.stopTest();
    }
    testMethod static void accountSyncBatch(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        
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
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.Data_Source__c = 'Ready To Sync';
                insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.MobilePhone = '77';
        con.AccountId = acc.id;
        insert con;
        
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Data_Source__c = 'Ready To Sync';
        product.Family = 'AUS';
        product.isActive = true;
        insert product;
        
        Test.startTest();
            TallyIntegrationForAccountsBatch tallyBatch = new TallyIntegrationForAccountsBatch();            
            TallyIntegrationForAccountsBatch.responseBody = 'ERR_CONNECT_FAIL';
            TallyIntegrationForAccountsBatch.statusCode = 503;
            TallyIntegrationForAccountsBatch.responseBodyFor2ndEndPoint = '<LINEERROR>1</LINEERROR>';
            TallyIntegrationForAccountsBatch.statusCodeFor2ndEndPoint = 200;
            Database.executeBatch(tallyBatch ,1);

            
            
            TallyIntegrationForProductsBatch tallyBatch1 = new TallyIntegrationForProductsBatch();            
            TallyIntegrationForProductsBatch.responseBody = 'ERR_CONNECT_FAIL';
            TallyIntegrationForProductsBatch.statusCode = 503;
            TallyIntegrationForProductsBatch.responseBodyFor2ndEndPoint = '<LINEERROR>1</LINEERROR>';
            TallyIntegrationForProductsBatch.statusCodeFor2ndEndPoint = 200;
            Database.executeBatch(tallyBatch1 ,1);  

        Test.stopTest();

    }
    testMethod static void accountSyncBatch1(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        
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
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.Data_Source__c = 'Ready To Sync';        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Family = 'AUS';
        product.isActive = true;
        product.Data_Source__c = 'Ready To Sync';
        insert product;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.MobilePhone = '77';
        con.AccountId = acc.id;
        insert con;
        Test.startTest();
            TallyIntegrationForAccountsBatch tallyBatch = new TallyIntegrationForAccountsBatch();
            TallyIntegrationForAccountsBatch.responseBody = '<CREATED>1</CREATED>';
            TallyIntegrationForAccountsBatch.statusCode = 200;
            Database.executeBatch(tallyBatch ,1);
            
            TallyIntegrationForProductsBatch tallyBatch1 = new TallyIntegrationForProductsBatch();            
            TallyIntegrationForProductsBatch.responseBody = '<CREATED>1</CREATED>';
            TallyIntegrationForProductsBatch.statusCode = 200;
            Database.executeBatch(tallyBatch1 ,1);    
            
        Test.stopTest();

    }
    testMethod static void accountSyncBatch2(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        
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
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.Data_Source__c = 'Ready To Sync';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.MobilePhone = '77';
        con.AccountId = acc.id;
        insert con;
         
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Family = 'AUS';
        product.Data_Source__c = 'Ready To Sync';
        product.isActive = true;
        insert product;
        Test.startTest();
            TallyIntegrationForAccountsBatch tallyBatch = new TallyIntegrationForAccountsBatch();          
            TallyIntegrationForAccountsBatch.responseBody = '<LINEERROR>1</LINEERROR>';
            TallyIntegrationForAccountsBatch.statusCode = 200;
            Database.executeBatch(tallyBatch ,1);
            
            TallyIntegrationForProductsBatch tallyBatch1 = new TallyIntegrationForProductsBatch();            
            TallyIntegrationForProductsBatch.responseBody = '<LINEERROR>1</LINEERROR>';
            TallyIntegrationForProductsBatch.statusCode = 200;
            
            Database.executeBatch(tallyBatch1 ,1);            
        Test.stopTest();

    }
    testMethod static void accountSyncBatch4(){
        TallyCredentials__c cred = new TallyCredentials__c();
        cred.Company__c = 'CAMP';
        cred.End_Point__c = 'https://www.test.com';
        insert cred;
        
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
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.Data_Source__c = 'Ready To Sync';        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.MobilePhone = '77';
        con.AccountId = acc.id;
        insert con;
        
        Product2 product = new Product2();
        product.Name = 'Anti-infectives 2007';
        product.Data_Source__c = 'Ready To Sync';
        product.Family = 'AUS';
        product.isActive = true;
        insert product;
        
        Test.startTest();
            TallyIntegrationForAccountsBatch tallyBatch = new TallyIntegrationForAccountsBatch();            
            TallyIntegrationForAccountsBatch.responseBody = 'ERR_CONNECT_FAIL';
            TallyIntegrationForAccountsBatch.statusCode = 503;
            TallyIntegrationForAccountsBatch.responseBodyFor2ndEndPoint = '<CREATED>1</CREATED>';
            TallyIntegrationForAccountsBatch.statusCodeFor2ndEndPoint = 200;
            Database.executeBatch(tallyBatch ,1);
            
            TallyIntegrationForProductsBatch tallyBatch1 = new TallyIntegrationForProductsBatch();            
            TallyIntegrationForProductsBatch.responseBody = 'ERR_CONNECT_FAIL';
            TallyIntegrationForProductsBatch.statusCode = 503;
            TallyIntegrationForProductsBatch.responseBodyFor2ndEndPoint = '<CREATED>1</CREATED>';
            TallyIntegrationForProductsBatch.statusCodeFor2ndEndPoint = 200;
            Database.executeBatch(tallyBatch1 ,1);
            
          
        Test.stopTest();

    }
}