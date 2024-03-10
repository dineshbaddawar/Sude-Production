/*
 * Description :    This class is to Generate Quote Details As PDF 
 * author      :    Bigworks Team   
 * TestClass   :    TallyService_TC
 */
public class DisplayQuoteDetailController {
    public List<QuoteLineItem>  quotesItem {get;set;}
    public Decimal  totalPriceUSD {get;set;}
    public Decimal  subTotalAmount{get;set;}
    public Decimal  grandTotalWithDiscount {get;set;}
    public Decimal  discountPercentage {get;set;}
    public Decimal  discountAmount {get;set;}
    public Account parentAccount { get; set; }
    public Decimal totalQuantity { get; set;}
    public Decimal totalPriceBeforePacking { get; set;}
    public Decimal PackingPrice{ get; set;}
    public Decimal totalPriceWithPacking { get; set;}
    public Decimal PackingInsuranceFright { get; set;}
    public Decimal CGSTPrice { get; set;}
    public Decimal SGSTPrice { get; set;}
    public Decimal IGST { get; set;}
   public Decimal subTotalForTotal { get; set;}
    public Decimal priceWithAllTaxes { get; set;}
    public Bank_Details__mdt bankDetails { get; set; }
    Id quoteId ;
    public Boolean hasQuoteItems{ get; set; }
    public Quote syncedQuote {get; set;}
    Boolean isPDFGenerated ;
    public Set<Id> productIds;
    public Contact childContact { get; set; }
    public DisplayQuoteDetailController(ApexPages.StandardController controller) {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        totalPriceUSD = 0;
        subTotalAmount = 0;
        totalQuantity = 0.00;
        discountAmount = 0;
        totalPriceBeforePacking = 0.00;
        PackingPrice = 0.00;
        totalPriceWithPacking  = 0.00;
        CGSTPrice = 0.00;
        SGSTPrice = 0.00;
        IGST = 0.00;
        priceWithAllTaxes = 0.00;
        PackingInsuranceFright = 0.00;
        productIds = new Set<Id>(); 
        hasQuoteItems = false;
        parentAccount = new Account();
        bankDetails = [SELECT Account_Name__c,Account_No__c,Bank_AD_Code__c,BANK_NAME__c,BRANCH__c,GST_No__c,HSN_CODE__c,IEC_No__c,MICR_Code__c,PAN_No__c,RTGS__c,SSI__c,Swift_Code__c,Udyam_No__c,UDYOG_AADHAR__c FROM Bank_Details__mdt LIMIT 1];
        syncedQuote = [SELECT Name,AccountId,Subtotal,Subtotal_Discount_Value__c,Grand_Total_P_T__c ,Freight__c,Extra_P_F__c,QuoteNumber,Packing__c,Insurance__c,Inquiry_Number__c,Customer_Body__c,Contact.Name,Contact.Salutation,Packing_Value__c ,
                      Opportunity.CurrencyIsoCode,Prices__c,Delivery_Period__c,Delivery_terms__c,Extra_GST__c,Freight_Insurance__c ,Validity__c,Warranty__c,Payment_Terms__c, Discount,
                        Email,Phone,fax,CGST__c,CGST_Value__c,IGST__c,IGST_Value__c,SGST__c,Enquiry_Reference__c,Inquiry_Reference_Date__c,SGST_Value__c FROM Quote WHERE Id =: quoteId ];      
        subTotalForTotal = (syncedQuote.Subtotal).setScale(2);
        childContact = new Contact();
        parentAccount = [SELECT Name,BillingStreet,BillingCity,BillingPostalCode,BillingCountry,Fax,Phone,website,billingstate,Country_of_Residences__c,
                         Deemed_Export__c,(SELECT Salutation,Name,Email FROM Contacts) FROM Account Where Id =: syncedQuote.AccountId];
        List<Contact> allContacts = parentAccount.Contacts;
        if(allContacts != null && allContacts.size() > 0){
           childContact = allContacts[0]; 
        }
        quotesItem = new List<QuoteLineItem>();
        if(syncedQuote.Extra_P_F__c == null){
            syncedQuote.Extra_P_F__c = '0';
        }
        if(syncedQuote.Extra_GST__c == null){
            syncedQuote.Extra_GST__c = '0';
        }
        if(syncedQuote.Validity__c == null){
            syncedQuote.Validity__c = 0;
        }
        
        
        for(QuoteLineItem eachItem : [SELECT Id,Product2Id,Product2.Name,Product2.HSN_Code__c,UnitPrice ,Product2.Valve_Size_in_mm__c,Quoteid,
                                      Discount , Quantity , ListPrice , TotalPrice , Quote.discount, Quote.GrandTotal,Product2.Product_Name__c,
                                      Quote.Subtotal,Product2.Description ,Product2.ProductCode ,Product2.Type__c,
                                      Product2.Valve_Size__c,Product2.Family,Total_Price_W_O_Discount__c
                                      FROM QuoteLineItem WHERE Quoteid =:quoteId ]){
            if(eachItem.Quote.Subtotal != null){
               totalPriceUSD = eachItem.Quote.Subtotal;                               
            }
            totalQuantity += eachItem.Quantity;
            totalPriceBeforePacking += eachItem.TotalPrice;
            eachItem.Product2.Name = getbreakWord(eachItem.Product2.Name , 15);
            eachItem.Product2.Description = getbreakWord(eachItem.Product2.Description , 16);
            if(eachItem.Quote.GrandTotal != null){
               grandTotalWithDiscount = eachItem.Quote.GrandTotal;                               
            }
            if(eachItem.Quote.discount != null){
               discountPercentage = eachItem.Quote.discount;                               
            }
            if(eachItem.Product2Id != null){
               productIds.add(eachItem.Product2Id);
            }
            quotesItem.add(eachItem); 
            hasQuoteItems = true;
        }
        if(quotesItem.size() > 0){
            if(syncedQuote.Packing_Value__c != null){
                PackingPrice = syncedQuote.Packing_Value__c ;
            }
               
            if(syncedQuote.Freight__c != null){
                PackingInsuranceFright += syncedQuote.Freight__c;
            }
            if(syncedQuote.Insurance__c != null){
                PackingInsuranceFright += syncedQuote.Insurance__c;
            }
            PackingInsuranceFright += PackingPrice ;
            PackingInsuranceFright = PackingInsuranceFright.setScale(2);
            
            
            totalPriceWithPacking = totalPriceBeforePacking + PackingInsuranceFright ;
            if(syncedQuote.Grand_Total_P_T__c != null){
                priceWithAllTaxes = syncedQuote.Grand_Total_P_T__c;
            }else{
                priceWithAllTaxes = 0;
            }
            priceWithAllTaxes = priceWithAllTaxes.setScale(2);
        }
        isPDFGenerated = false; 
        if(ApexPages.currentPage().getParameters().get('isPDFGenerated') != null){
            isPDFGenerated = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isPDFGenerated'));
        }
    }
    public string getbreakWord(String textVal,Integer count){
        String allStrings = '';
        if(textVal != null) {
            integer j= 1;
            for (Integer i = 0; i < textVal.length(); i++) {
                if(i/count == j){
                    allStrings = allStrings + '\n';
                    j++;
                }
                allStrings = allStrings + textVal.substring(i,i+1);
            }
        }
        return allStrings ;
    }
    public void generatePDF(){
        if(isPDFGenerated == false){
            PageReference pdf = Page.SUDEBangaloreQuotePDF; 
            system.debug('pdf '+pdf);
            String currentQuoteId = pdf.getParameters().put('id', quoteId );
            String isPDFGenerated = pdf.getParameters().put('isPDFGenerated', 'true'); 
            String Title = syncedQuote.Name+'_V%';
            List<ContentDocumentLink> datasheetLinksToDelete = new List<ContentDocumentLink>();
            for(ContentDocumentLink datasheet : [SELECT Id,ContentDocumentId   
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId  =: quoteId 
                                                 AND (NOT(ContentDocument.Title LIKE : Title))]){
                datasheetLinksToDelete.add(datasheet);
            }
            if(datasheetLinksToDelete.size() > 0){
                delete datasheetLinksToDelete;
            }
            QuoteDocument quoteDoc = new QuoteDocument();
            if(!Test.isRunningTest()){
                quoteDoc.Document =  pdf.getContentAsPDF();
            }
            else{
                quoteDoc.Document =  Blob.valueOf('Test');
            }
            quoteDoc.QuoteId = quoteId ;
            insert quoteDoc;
            List<ContentDocumentLink> datasheetLinksToInsert = new List<ContentDocumentLink>();
            if(productIds.size() > 0){
                for(ContentDocumentLink eachDocLink : [SELECT Id,ContentDocumentId , LinkedEntityId  
                                                            FROM ContentDocumentLink 
                                                            WHERE LinkedEntityId IN : productIds]){
                    ContentDocumentLink eachConDocLink = New ContentDocumentLink();
                    eachConDocLink.LinkedEntityId = quoteId ;
                    eachConDocLink.ContentDocumentId = eachDocLink.ContentDocumentId;
                    eachConDocLink.shareType = 'V';
                    datasheetLinksToInsert.add(eachConDocLink);
                }
                if(datasheetLinksToInsert.size() > 0){
                    insert datasheetLinksToInsert ;
                }
           }
        }
    }
}