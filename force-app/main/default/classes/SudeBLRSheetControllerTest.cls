@isTest
public class SudeBLRSheetControllerTest{
    
    @isTest static void testNameAllClassNew(){
        
        Account acc1 = new Account();
        acc1.Name = 'test 1';
        acc1.Country_of_Residences__c = 'India';
        acc1.Ledger_Type__c = 'Sales Ledger';
        acc1.BillingState = 'Pune';
        acc1.Export__c = null;
        insert acc1;
        
        Contact con = new Contact();
        con.LastName = 'Testing';
        insert con;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test';
        opp1.CloseDate = system.today();
        opp1.StageName = 'Order Acknowledgement';
        opp1.AccountId = acc1.Id;
        insert opp1;
        
        CompanyDetails__c comDetail = new CompanyDetails__c();
        comDetail.Name = 'Testing CompanyDetails';
        insert comDetail;
        
        AccountDetails__c accDetail = new AccountDetails__c();
        accDetail.Name = 'Testing AccountDetails';
        insert accDetail;
        
        Addition_Information__c addInfo = new Addition_Information__c();
        addInfo.Name = 'Testing Additional Information';
        insert addInfo;
        
        Quote quoRec = new Quote();
        quoRec.Name = 'SU-10000-0924/22-24';
        quoRec.Inquiry_Reference_Date__c = system.today();
        quoRec.OpportunityId = opp1.Id;
        quoRec.ContactId = con.Id;
        insert quoRec;
        
        Product2 prod = new Product2();
        prod.Name = 'test'; 
        prod.Model_Number__c = '1212';
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
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec);
        PageReference pageRef1 = Page.SudeBLRSheet;
        pageRef1.getParameters().put('Id', quoRec.Id);
        Test.setCurrentPage(pageRef1);
        SudeBLRSheetController pdf1 = new SudeBLRSheetController(sc1);
        SudeBLRSheetController.getProductList(quoRec.Id);
        NumberToWordConversion var = new NumberToWordConversion();
        var.getNumberToWordConversion(379739);
         var.getNumberToWordConversion(3797339);
        var.getNumberToWordConversion(37973339);
    }
    
    
}