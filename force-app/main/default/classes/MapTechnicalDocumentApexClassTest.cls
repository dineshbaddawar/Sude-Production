@isTest
public class MapTechnicalDocumentApexClassTest {

    @isTest static void testMapTechnicalDocumentApexClass(){
        
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
        
        Company_Information__mdt CompanyInfo = [SELECT MasterLabel FROM Company_Information__mdt];
        CompanyAdditionalInfo__mdt CompanyAddInfo = [SELECT MasterLabel FROM CompanyAdditionalInfo__mdt];
        Tech_Additional_Information__c TechAddInfo = new Tech_Additional_Information__c();
        TechAddInfo.Opportunity__c = opp1.Id;
        
        Quote quoRec = new Quote();
        quoRec.Name = 'SU-10000-0924/22-24';
        quoRec.Inquiry_Reference_Date__c = system.today();
        quoRec.OpportunityId = opp1.Id;
        insert quoRec;
        
        Product2 prod = new Product2(); 
        prod.Name = '1181F-SU/2WNCPOD/40/40/BR/S4/BN/BSP/SPC1-230VAC/IP65/SPC1-230VAC/IP65/SPC1-230VAC/IP65'; 
        prod.Model_Number__c = '1212_GH';
        prod.Product_Name__c = 'dines';
        prod.Series_Name__c = '1182';
        prod.Ambient_Temperature_Humidity__c = '11-JK';
        prod.Model_Number__c ='asdfghj111';
        prod.ProductCode ='1250/DE/PN10/300/WCB/S6/E/WAFER-LUG/150/SD-3001-08-E-20/WG40-E/3P-IM-415-50-0.75-4PFC/S2/ELS-1NOC/POT1/CPT200-1/TH/IP65/SERVO';
        insert prod; 
        
         Product2 prod1 = new Product2(); 
        prod1.Name = 'test-eyey'; 
        prod1.Model_Number__c = '1212ljl_GH';
        prod1.Product_Name__c = 'dinecjs';
        prod1.Series_Name__c = '1100';
        prod1.Ambient_Temperature_Humidity__c = '11-cjcpijJK';
        prod1.Model_Number__c ='asdfghjcicjpcc111';
        prod1.ProductCode ='12cc50';
        insert prod1; 
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp1.id;
        oppline.UnitPrice = 22;
        oppline.Quantity = 22;
        oppline.PricebookEntryId = standardPrice.id;
        insert oppline;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(oppline);
       // PageReference pageRef1 = Page.TechnicalMapVfPageUpdated;
          PageReference pageRef1 = Page.TechnicalMapVfPage;
        pageRef1.getParameters().put('Id',oppline.Id);
        Test.setCurrentPage(pageRef1);
       // MapTechnicalDocumentApexClassUpdated pdf1 = new MapTechnicalDocumentApexClassUpdated(sc1);
         MapTechnicalDocumentApexClass pdf1 = new MapTechnicalDocumentApexClass(sc1);
        MapTechnicalDocumentApexClass.mytest();
    }
}