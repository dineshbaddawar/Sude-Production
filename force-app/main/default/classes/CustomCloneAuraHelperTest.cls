@isTest
public class CustomCloneAuraHelperTest {
    
    @isTest static void testNameClone() {
        
        List<Section_SeriesWiseFieldsData__mdt> SectionWithSeriesList = new List<Section_SeriesWiseFieldsData__mdt>();
        SectionWithSeriesList = [SELECT MasterLabel,Fields__c,Series_Name__c,Sequence_Order__c FROM Section_SeriesWiseFieldsData__mdt];
        
        Product2 prod = new Product2();
        prod.Name = 'test'; 
        prod.Series_Name__c = 'Name1162';
        prod.Model_Number__c = '1212';
        prod.Product_Name__c = 'dines';
        prod.Series_Name__c = '1182';
        prod.Ambient_Temperature_Humidity__c = '11';
        prod.Model_Number__c ='asdfghj111';
        insert prod; 
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        CustomCloneAuraHelper.getGetRecordDetailsBasedOnSeriesNo(prod.Id);
        CustomCloneAuraHelper.getRecordSectionNameWihFieldApi_Value(prod.Id);
    }
}