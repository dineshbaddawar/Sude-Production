@isTest
public class SudeBLRSheetAuraControllerTest {
    
    @isTest Static Void testinsertQuotesAttachement(){
        List<Quote> quoteList = new List<Quote>();
        
        Account acc1 = new Account();
        acc1.Name = 'test 1';
        acc1.Country_of_Residences__c = 'India';
        acc1.Ledger_Type__c = 'Sales Ledger';
        acc1.BillingState = 'Pune';
        acc1.Export__c = null;
        insert acc1;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test';
        opp1.CloseDate = system.today();
        opp1.StageName = 'Order Acknowledgement';
        opp1.AccountId = acc1.Id;
        insert opp1;
        
        Product2 prod = new Product2();
        prod.Name = 'test'; 
        prod.Product_Name__c = 'dines';
        prod.Series_Name__c = '1182';
        prod.Ambient_Temperature_Humidity__c = '11';
        prod.Model_Number__c ='asdfghj111';
        insert prod; 
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp1.id;
        oppline.UnitPrice = 22;
        oppline.Quantity = 22;
        oppline.PricebookEntryId = standardPrice.id;
        insert oppline;
        
        Quote quoRec = new Quote();
        quoRec.Name = 'SU-10000-0924/22-24';
        quoRec.Inquiry_Reference_Date__c = system.today();
        quoRec.OpportunityId = opp1.Id;
        insert quoRec;
        quoteList.add(quoRec);
        
        List<Attachment> attachList = new List<Attachment>();
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        Attachment attach = new Attachment();
        attach.Name = 'Quote Invoice.Pdf';
        attach.IsPrivate = false;
        attach.parentId = opp1.Id;
        attach.Body = bodyBlob;
        attach.ContentType = 'application/pdf';
        Insert attach; 
        System.debug('attach=='+ attach);
        attachList.add(attach);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quoRec);
        PageReference pageRef = Page.SudeBLRSheet; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(quoRec.Id));
        Test.setCurrentPage(pageRef);
        
        SudeBLRSheetAuraController.insertQuotesAttachement(quoRec.Id);
        SudeBLRSheetAuraController.getQuoteIdFormOpportunity(opp1.Id);
        SudeBLRSheetAuraController.insertQuoteFromOpportunity(opp1.Id);
    }
}