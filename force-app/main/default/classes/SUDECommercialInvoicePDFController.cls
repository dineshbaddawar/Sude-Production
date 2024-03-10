public class SUDECommercialInvoicePDFController {
    public List<QuoteLineItem>  quotesItem {get;set;}
    public Decimal totalPrice { get; set;}
    public String shippingAddress { get; set;}
    public String billingAddress { get; set;}
    public String DateFormated { get; set; }
    public String formatedReferenceDate { get; set; }
    public String formatedEffectiveDate { get; set; }
    public Opportunity selectedOpp { get; set; }
    public Decimal totalQuantity { get; set;}
    public Decimal totalPriceBeforePacking { get; set;}
    public Decimal PackingPrice{ get; set;}
    public Decimal totalPriceWithPacking { get; set;}
    public Decimal CGSTPrice { get; set;}
    public Decimal SGSTPrice { get; set;}
    public Decimal IGST { get; set;}
    public Decimal priceWithAllTaxes { get; set;}
    public Decimal  totalPriceUSD {get;set;}
    public Decimal  grandTotalWithDiscount {get;set;}
    public Quote syncedQuote {get; set;}
    public Boolean hasQuoteItems{ get; set; }
    public Decimal  discountPercentage {get;set;}
    public Bank_Details__mdt bankDetails { get; set; }
    public List<String> termsAndConditons { get; set; }
    public decimal totalAmountFor9Per { get; set; }
    public decimal totalAmountFor18Per { get; set; }
    public decimal totalAmountForDirectExport { get; set; }
    public decimal totalAmountForSEZExport { get; set; }
    public String amountInwords { get; set; }
    public SUDECommercialInvoicePDFController (ApexPages.StandardController controller) {
        quotesItem = new List<QuoteLineItem>();
        Id oppId = ApexPages.currentPage().getParameters().get('id');
        discountPercentage = 0;
        totalPriceUSD = 0;
        totalQuantity = 0.00;
        totalAmountFor9Per = 0.00;
        totalAmountFor18Per = 0.00;
        totalPriceBeforePacking = 0.00;
        PackingPrice = 0.00;
        totalPriceWithPacking  = 0.00;
        totalAmountForDirectExport = 0.00;
        totalAmountForSEZExport = 0.00;
        amountInwords = '';
        CGSTPrice = 0.00;
        SGSTPrice = 0.00;
        IGST = 0.00;
        priceWithAllTaxes = 0.00;
        DateFormated = Date.Today().format();
        hasQuoteItems = false;
        termsAndConditons = new List<String>();
        bankDetails = [SELECT Account_Name__c,Account_No__c,Bank_AD_Code__c,BANK_NAME__c,BRANCH__c,GST_No__c,IFSC_Code__c,HSN_CODE__c,
                               IEC_No__c,MICR_Code__c,PAN_No__c,RTGS__c,SSI__c,Swift_Code_For_Commercial_Invoice__c,Udyam_No__c,UDYOG_AADHAR__c,
                               Commercial_Invoice_Terms_And_Conditons__c  
                               FROM Bank_Details__mdt LIMIT 1];
        if(bankDetails.Commercial_Invoice_Terms_And_Conditons__c != null){
            termsAndConditons = bankDetails.Commercial_Invoice_Terms_And_Conditons__c.split('>>');
            termsAndConditons.remove(0);

        }
        selectedOpp = [SELECT Name,AccountId,Account.GST_Number__c,SyncedQuoteId,Order_Acknowledgement_Number__c,Order_Acknowledgement_Number2__c,Account.Vendor_code__c,CurrencyIsoCode,
                                        Order_Reference_Number__c,Order_Reference_Date__c FROM Opportunity WHERE Id=:oppId];
        Account parentAccount = [Select Name,BillingStreet,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,BillingCity,BillingState,
                                        BillingPostalCode,ShippingCountry FROM Account WHERE Id=:selectedOpp.accountId];
        if(selectedOpp.Order_Reference_Date__c != null){
            formatedReferenceDate = selectedOpp.Order_Reference_Date__c.format();
        }
 
        totalPrice = 0;
        syncedQuote = [SELECT Name,Destination__c,Freight__c,Insurance__c,Despatch_Through__c,Grand_Total_P_T__c,Opportunity.Account.Vendor_code__c,Opportunity.Account.Country_of_Residences__c,Subtotal,Discount ,AccountId,QuoteNumber,
                        Packing__c,Inquiry_Number__c,Customer_Body__c,Contact.Name,Contact.Salutation,Packing_Value__c ,Effective_Date__c   ,
                        Prices__c,Delivery_Period__c,Extra_GST__c,Extra_P_F__c,Freight_Insurance__c ,Validity__c,Warranty__c,Payment_Terms__c,contact.Phone,
                        BillingStreet,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,BillingCity,BillingState,
                        BillingPostalCode,ShippingCountry,
                        Email,Phone,fax,CGST__c,CGST_Value__c,IGST__c,IGST_Value__c,SGST__c,Enquiry_Reference__c,SGST_Value__c FROM Quote WHERE Id =: selectedOpp.SyncedQuoteId]; 
        if(syncedQuote.Effective_Date__c != null){
            formatedEffectiveDate= syncedQuote.Effective_Date__c.format();
        }
        if(syncedQuote.Extra_P_F__c == null){
            syncedQuote.Extra_P_F__c = '0';
        }
        if(syncedQuote.Extra_GST__c == null){
            syncedQuote.Extra_GST__c = '0';
        }
        if(syncedQuote.Validity__c == null){
            syncedQuote.Validity__c = 0;
        }
        if(syncedQuote.discount != null){
           discountPercentage = syncedQuote.discount;                               
        }
        if(syncedQuote.Subtotal != null){
           totalPriceUSD = syncedQuote.Subtotal *(discountPercentage /100);  
           totalPriceUSD = totalPriceUSD.setscale(2);                             
        }
        billingAddress = '';
        billingAddress = parentAccount.Name + ' <br>';
        if(syncedQuote.BillingStreet != null){
            billingAddress +=    syncedQuote.BillingStreet + '<br>';
        }
        if(syncedQuote.BillingCity != null || syncedQuote.BillingPostalCode != null ||  syncedQuote.BillingState != null){
            String state = '';
            if(syncedQuote.BillingCity != null){
                state += syncedQuote.BillingCity + ' ,';
            }
            if(syncedQuote.BillingPostalCode != null){
                state += syncedQuote.BillingPostalCode + ' ,' ;
            }
            if(syncedQuote.BillingState != null){
                state += syncedQuote.BillingState + ' ,' ;
            }
            state = state.removeEnd(' ,');
            billingAddress += state + '<br>';
        }
        if(syncedQuote.BillingCountry != null){
            billingAddress += syncedQuote.BillingCountry ;        
        }
        shippingAddress = '';
        shippingAddress = parentAccount.Name + ' <br>';
        if(syncedQuote.ShippingStreet != null){
            shippingAddress +=    syncedQuote.ShippingStreet + '<br>';
        }
        if(syncedQuote.ShippingCity != null || syncedQuote.ShippingPostalCode != null ||  syncedQuote.ShippingState != null){
            String state = '';
            if(syncedQuote.ShippingCity != null){
                state += syncedQuote.ShippingCity + ' ,';
            }
            if(syncedQuote.ShippingPostalCode != null){
                state += syncedQuote.ShippingPostalCode + ' ,' ;
            }
            if(syncedQuote.ShippingState!= null){
                state += syncedQuote.ShippingState+ ' ,' ;
            }
            state = state.removeEnd(' ,');
            shippingAddress += state + '<br>';
        }
        if(syncedQuote.ShippingCountry!= null){
            shippingAddress += syncedQuote.ShippingCountry;        
        }
        
        if(selectedOpp != null && selectedOpp.SyncedQuoteId != null){
            for(QuoteLineItem eachItem : [SELECT Id,Product2Id,Product2.Name,Product2.HSN_Code__c,UnitPrice ,Product2.Valve_Size_in_mm__c,Quoteid,
                                      Discount , Quantity , ListPrice , TotalPrice , Quote.discount, Quote.GrandTotal,Product2.Product_Name__c,
                                      Quote.Subtotal,Product2.Description ,Product2.ProductCode ,Product2.Type__c,
                                      Product2.Valve_Size__c,Product2.Family,Total_Price_W_O_Discount__c
                                      FROM QuoteLineItem WHERE Quoteid =:selectedOpp.SyncedQuoteId]){
                if(eachItem.Discount != null){
                   eachItem.Discount = eachItem.Discount.setScale(2); 
                }else{
                    eachItem.Discount = 0.00;
                } 
                totalQuantity += eachItem.Quantity;
                totalPriceBeforePacking += eachItem.TotalPrice ;
                eachItem.Product2.Name = getbreakWord(eachItem.Product2.Name , 15);
                eachItem.Product2.Description = getbreakWord(eachItem.Product2.Description , 16);
                if(eachItem.Quote.GrandTotal != null){
                   grandTotalWithDiscount = eachItem.Quote.GrandTotal;                               
                }
                totalAmountFor9Per += eachItem.TotalPrice ;
                totalAmountFor18Per += eachItem.TotalPrice ; 
                totalAmountForSEZExport += eachItem.TotalPrice ;
                totalAmountForDirectExport += eachItem.TotalPrice ;
                quotesItem.add(eachItem); 
                hasQuoteItems = true;
            } 
            
            
            Decimal otherCharges = 0.00;
            if(syncedQuote.Insurance__c != null){
                otherCharges += syncedQuote.Insurance__c ;
                
            }
            if(syncedQuote.Freight__c != null){
                otherCharges += syncedQuote.Freight__c;
                
            }
            if(syncedQuote.Packing_Value__c != null){
                otherCharges += syncedQuote.Packing_Value__c.setScale(2);
                
            }
            if(syncedQuote.SGST_Value__c != null)
            {
                totalAmountFor9Per += syncedQuote.SGST_Value__c.setScale(2) ;
                
            }
            if(syncedQuote.CGST_Value__c != null){
                totalAmountFor9Per += syncedQuote.CGST_Value__c.setScale(2) ;
            }
            
            if(syncedQuote.IGST_Value__c != null){
                totalAmountFor18Per += syncedQuote.IGST_Value__c.setScale(2) ;
            }
            totalAmountFor9Per += otherCharges ;
            totalAmountForSEZExport += otherCharges ;
            totalAmountForDirectExport += otherCharges ;
            totalAmountFor18Per += otherCharges ;
            
            totalAmountFor9Per = totalAmountFor9Per.setScale(0);
            totalAmountForSEZExport = totalAmountForSEZExport.setScale(0);
            totalAmountForDirectExport = totalAmountForDirectExport.setScale(0);
            totalAmountFor18Per = totalAmountFor18Per.setScale(0);
            integer n = 0;
            if(syncedQuote.CGST__c == 9.00 && syncedQuote.SGST__c == 9.00){
                n  = integer.ValueOf(totalAmountFor9Per);
            }
            if(syncedQuote.IGST__c == 18.00 && syncedQuote.CGST__c == 0 && syncedQuote.SGST__c == 0){
                n = integer.ValueOf(totalAmountFor18Per);
             }
            if(syncedQuote.IGST__c == 0.00 && syncedQuote.CGST__c == 0.00 && syncedQuote.SGST__c == 0.00 && syncedQuote.Opportunity.Account.Country_of_Residences__c != 'India'){
                n = integer.ValueOf(totalAmountForDirectExport);
             }
            if(syncedQuote.IGST__c == 0.00 && syncedQuote.CGST__c == 0.00 && syncedQuote.SGST__c == 0.00 && syncedQuote.Opportunity.Account.Country_of_Residences__c == 'India'){
                n = integer.ValueOf(totalAmountForSEZExport);
            }
                   
            if(syncedQuote.IGST__c == 0.10 && syncedQuote.CGST__c == 0 && syncedQuote.SGST__c == 0){
                n = integer.ValueOf(totalAmountFor18Per);
            }
            if(syncedQuote.IGST__c == 0.00 && syncedQuote.CGST__c == 0.05 && syncedQuote.SGST__c == 0.05){
                n = integer.ValueOf(totalAmountFor9Per);
            }
            string amo = ConvertCurrencyToWords.english_number(n);
            string amo1 = amo.remove(',');
            amountInwords = amo1;    
            if(quotesItem.size() > 0){
                if(syncedQuote.Packing__c != null && syncedQuote.Packing__c != 0.00){
                    PackingPrice  = totalPriceBeforePacking * syncedQuote.Packing__c / 100 ;
                    PackingPrice = PackingPrice.setscale(2);
                }else{
                    if(syncedQuote.Packing_Value__c != null){
                        PackingPrice = syncedQuote.Packing_Value__c ;
                    }
                    syncedQuote.Packing__c = 0.00;
                }
                totalPriceWithPacking = totalPriceBeforePacking + PackingPrice  ;
                priceWithAllTaxes = totalPriceWithPacking + syncedQuote.CGST_Value__c + syncedQuote.SGST_Value__c+syncedQuote.IGST_Value__c ; 
            }
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
    
    @AuraEnabled
    public static String validateSelectedOpportunity(Id recordId){
        String idPrifix = String.valueOf(recordId);
        opportunity foundOpportunity = [SELECT Name,Order_Reference_Number__c,Order_Reference_Date__c FROM Opportunity WHERE Id=:recordId];
        if(foundOpportunity.Order_Reference_Number__c == null || foundOpportunity.Order_Reference_Date__c == null ){
            return 'Order Reference Number & Date are mandatory';
        }
        return 'visible';
    }
}