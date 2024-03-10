@isTest
public class TechnicalDocumentAuraControllerTest {
    
    @isTest static void testNameAllClassNew() {
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
            
        Quote quo11 = new Quote();
        quo11.Name = 'Test data';
        quo11.OpportunityId = opp1.Id;
        quo11.Inquiry_Reference_Date__c = system.today();
        quo11.SGST__c = null;
        insert quo11;
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = opp1.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert(attachment);
        TechnicalDocumentAuraController.attachFileToOppLineItem(opp1.id);
    }
}