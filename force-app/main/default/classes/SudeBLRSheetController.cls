/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-03-10 18:44:55
* @modify date 2023-03-10 18:44:55
* @desc [description]
*/

public class SudeBLRSheetController {
    public Static Account accData {get;set;}
    public Static Opportunity oppData {get;set;}
    public Static List<OpportunityLineItem> prodLineItem {get;set;}
    public Static Quote quoteData {get;set;}
    public Static CompanyDetails__c compDetails {get;set;}
    public Static AccountDetails__c BankAccDetails {get;set;}
    public Static Terms_Conditions__c termDetails {get;set;}
    public Static Addition_Information_Details__c addinfoDetails {get;set;}
    Public Static String ProductlineItemId {get;set;}
    Public Static String resultString {get;set;}
    public Static Product2 productDetails {get;set;}
    public Static Addition_Information__c addInfo {get;set;}
    public String TotalPricewithTaxInWords {get;set;}
    Public string NumbersInWords{get;set;}
    public static integer totalQty{get;set;}
    Public Static Contact conDetails {get;set;}
    Public static string formatAmount{get;set;}
    Public static string unitpriceformatAmount{get;set;}
    Public static string subtotalformatAmount{get;set;}
    Public static string netTotalformatAmount{get;set;}
    Public static string TotalPricewithTax {get;set;} 
    Public static string SGSTformatAmount{get;set;}
    Public static string CGSTformatAmount{get;set;}
    Public static string IGSTformatAmount{get;set;}
    Public Static List<string> rightAmountFormatData {get;set;}
    Public static string DiscountformatAmount{get;set;}
    Public static Decimal AmountAfterDiscount {get;set;}
    public static integer CGSTFormatValue {get;set;}
    public static integer SGSTFormatValue {get;set;}
    public static integer IGSTFormatValue {get;set;}
    Public static Decimal NetTotalAfterDiscount {get;set;} 
    Public static Decimal AmountWithAllTaxes {get;set;} 
    Public static Decimal FreightAmount {get;set;}
    Public static Decimal PackingAmount {get;set;}
    Public static Decimal InsuranceAmount {get;set;}
    Public static Decimal PackingAmountNew {get;set;}
    Public static Decimal PackingAmountWithNTP {get;set;}
    Public static Decimal FreightAmountWithNTP {get;set;} 
    Public static Boolean ShowFreightAmount {get;set;}
    Public static Decimal InsuranceAmountWithNTP {get;set;}
    Public static Boolean ShowPackingAmount {get;set;}
    Public static Boolean IsBillingStateKarnataka {get;set;}
    Public static Boolean ShowDiscountAmount {get;set;}
    Public static Decimal CGSTAmount {get;set;}
    Public static Decimal SGSTAmount {get;set;}
    Public static Decimal IGSTAmount {get;set;}
    Public static Decimal AllTotalTaxWithPriceValue {get;set;}
    Public static string PackingAmountWithNTPformatAmount{get;set;}
    Public static string FreightAmountWithNTPformatAmount{get;set;}
    Public static string InsuranceAmountWithNTPformatAmount{get;set;}
    
    public SudeBLRSheetController(ApexPages.StandardController ctrl){
        String recordId = ApexPages.currentPage().getParameters().get('id');
        compDetails  = [Select Name,CompanyName__c,Fax__c,RupeeSign__c,OfficeAddress__c,Address__c,Contact__c,Email__c,Website__c,CGST__c,IGST__c,SGSTC__c from CompanyDetails__c];
        BankAccDetails = [Select Name,ACCOUNT_NAME__c,ACCOUNT_NO__c,    Address__c, BankName__c,Branch__c,ECCNO__c, Email__c,GST_NO__c, Import_ExportCodeNo__c, NEFT_RTGS_IFSC_CODE__c, Pan_No__c,Swift_No__c from AccountDetails__c];
        addInfo = [SELECT Id,Actuator__c,Cell_No__c,Comp_Name__c,Designation__c,Company_Name__c,Necessary__c,Cable__c,Delivery__c,Mounting__c,Quotation__c,Required__c,The__c,Third__c FROM Addition_Information__c];
        try{
            quoteData = [Select Id,Name,createdDate,Discount,Discount__c,Freight__c,Insurance__c,AmountWithDiscount__c,Packing_Value__c,
                         Subtotal,Packing__c,CGST__c,SGST__c,IGST__c,Grand_Total_P_T__c,CGST_Value__c,SGST_Value__c,IGST_Value__c,
                         TotalPrice,Total_Excluding_GST__c,OpportunityId,AccountId,ExpirationDate,QuoteNumber,Inquiry_Reference_Date__c,
                         Amount_Without_Round_Off__c,Round_Off__c,Academic_Year__c,Sequence_Number__c,Effective_Date__c,ContactId,
                         BillingCity,BillingStreet,BillingState,BillingPostalcode,BillingCountry, Extra_P_F__c, Freight_Insurance__c,
                         Payment_Terms__c, Delivery_Terms__c, Warranty__c, Validity__c, Prices__c, Ex_Works__c, Commission_Assistance__c,
                         Contact.Name, Customer_Body__c
                         from Quote 
                         where id=:recordId ];
            system.debug('quoteData=== >'+quoteData);
            resultString = quoteData.Name.substring(0, quoteData.Name.length() - 5);
            if(quoteData.CreatedDate!= null){
                Integer currentYear = System.now().year();
                Integer previousYear = currentYear-1;
                Integer nextYear = currentYear+1;
                if (quoteData.CreatedDate < DateTime.newInstance(currentYear, 4, 1, 0, 0, 0)) {
                    resultString += String.valueOf(previousYear).substring(2) + '-' + String.valueOf(currentYear).substring(2);
                } 
                else{
                    resultString += String.valueOf(currentYear).substring(2) + '-' + String.valueOf(nextYear).substring(2);
                }
            }
            if(quoteData.BillingState !=null){
                if(quoteData.BillingState  == 'Karnataka' || quoteData.BillingState  == 'KA' ){
                    IsBillingStateKarnataka = true;
                }else{
                    IsBillingStateKarnataka = false;
                }
            }
            if(quoteData.Freight__c !=null){
                FreightAmount = quoteData.Freight__c;
            }else{
                FreightAmount = 0;
            }
            if(FreightAmount == 0){
                ShowFreightAmount = false;
            }else{
                ShowFreightAmount = true;
            }
            if(quoteData.Packing__c !=null){
                PackingAmount = quoteData.Packing__c;
            }else{
                PackingAmount = 0;
            }
            if(PackingAmount == 0){
                ShowPackingAmount = false;
            }else{
                ShowPackingAmount = true;
            }
            if(quoteData.Insurance__c !=null){
                InsuranceAmount = quoteData.Insurance__c;
            }else{
                InsuranceAmount = 0;
            }
            if(quoteData.CGST__c !=null){
                CGSTAmount = quoteData.CGST__c;
            }else{
                CGSTAmount = 0;
            }
            if(quoteData.SGST__c !=null){
                SGSTAmount = quoteData.SGST__c;
            }else{
                SGSTAmount = 0;
            }
            if(quoteData.IGST__c !=null){
                IGSTAmount = quoteData.IGST__c;
            }else{
                IGSTAmount = 0;
            }
            if(quoteData.Discount__c == 0 || quoteData.Discount__c == null){
                ShowDiscountAmount = false;
            }else{
                ShowDiscountAmount = true;
            }
            Decimal subtotalrA = quoteData.Subtotal;
            List<String> argssub = new String[]{'0','number','###,###,##0.00'};
                subtotalformatAmount = String.format(subtotalrA.format(), argssub);
            Decimal DicountAmount = quoteData.AmountWithDiscount__c; 
            List<String> Discountargssub1 = new String[]{'0','number','###,###,##0.00'};
                DiscountformatAmount = String.format(DicountAmount.format(), Discountargssub1);
            Decimal netTotalrA = quoteData.TotalPrice - DicountAmount;
            List<String> argssub1 = new String[]{'0','number','###,###,##0.00'};
                netTotalformatAmount = String.format(netTotalrA.format(), argssub1);
            PackingAmountNew = (PackingAmount / 100) * (quoteData.Subtotal -DicountAmount);
            Decimal netTotalrANew = quoteData.Subtotal - DicountAmount + PackingAmountNew + FreightAmount;
            List<String> argssub11 = new String[]{'0','number','###,###,##0.00'};
                netTotalformatAmount = String.format(netTotalrANew.format(), argssub11);
            Decimal CGSTTotalrA = (quoteData.CGST__c / 100) * netTotalrANew;
            List<String> CGSTargssub1 = new String[]{'0','number','###,###,##0.00'};
                CGSTformatAmount = String.format(CGSTTotalrA.format(), CGSTargssub1);
            Decimal SGSTTotalrA = (quoteData.SGST__c / 100) * netTotalrANew;
            List<String> SGSTargssub1 = new String[]{'0','number','###,###,##0.00'};
                SGSTformatAmount = String.format(SGSTTotalrA.format(), SGSTargssub1);
            Decimal IGSTTotalrA = (quoteData.IGST__c / 100 ) *  netTotalrANew; 
            List<String> IGSTargssub1 = new String[]{'0','number','###,###,##0.00'};
                IGSTformatAmount = String.format(IGSTTotalrA.format(), IGSTargssub1);
            PackingAmountWithNTP = PackingAmount * netTotalrA;
            FreightAmountWithNTP = FreightAmount;
            InsuranceAmountWithNTP = InsuranceAmount;
            List<String> argssub2 = new String[]{'0','number','###,###,##0.00'};
                PackingAmountWithNTPformatAmount = String.format(PackingAmountNew.format(), argssub2);
            List<String> argssub3 = new String[]{'0','number','###,###,##0.00'};
                FreightAmountWithNTPformatAmount = String.format(FreightAmountWithNTP.format(), argssub3);
            List<String> argssub4 = new String[]{'0','number','###,###,##0.00'};
                InsuranceAmountWithNTPformatAmount = String.format(InsuranceAmountWithNTP.format(), argssub4);
            if(IsBillingStateKarnataka == true){
                AllTotalTaxWithPriceValue = netTotalrANew + CGSTTotalrA + SGSTTotalrA;
                System.debug('Karnataka State Inside  == >'+AllTotalTaxWithPriceValue);
            }else{
                AllTotalTaxWithPriceValue = netTotalrANew + IGSTTotalrA;
                System.debug('Karnataka State Outside  == >'+AllTotalTaxWithPriceValue);
            }
            NetTotalAfterDiscount = Integer.valueOf(quoteData.TotalPrice)-DicountAmount;   
            Decimal formatNetTotalAfterDiscount = NetTotalAfterDiscount;
            CGSTFormatValue = Integer.valueOf(quoteData.CGST__c.intvalue());
            SGSTFormatValue = Integer.valueOf(quoteData.SGST__c.intvalue());
            IGSTFormatValue = Integer.valueOf(quoteData.IGST__c.intvalue());
            if(!String.isBlank(quoteData.ContactId)){
                conDetails = [SELECT Id,Name,Email FROM Contact WHERE Id =: quoteData.ContactId];
            }            
            if(!String.isBlank(quoteData.AccountId)){
                accData = [Select Id,Name,Phone,Email__c,Website,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,ShippingCity,ShippingCountry,ShippingState from Account Where Id=:quoteData.AccountId];
            }            
            if(!String.isBlank(quoteData.OpportunityId)){
                oppData = [Select Id,AccountId,Amount__c,Amount,StageName,Order_Reference_Number__c,Order_Reference_Date__c,Probability,Amend_Date__c,Actuator_Motor__c from Opportunity WHERE ID =:quoteData.OpportunityId];
            }
            if(!String.isBlank(oppData.Id)){
                prodLineItem = [select Id,Product2.Name,Product2.Product_Name__c,OpportunityId,Product2Id,Product2.Model_Number__c,UnitPrice,Quantity,Discount,ProductCode,TotalPrice,ListPrice,Product2.Description,Product2.Valve_Type__c from OpportunityLineItem Where OpportunityId =:oppData.Id];
                for(OpportunityLineItem opp : prodLineItem){ 
                    if(String.isNotBlank(opp.Product2.Product_Name__c)){
                        String ProductModel=opp.Product2.Product_Name__c;
                        if(ProductModel.contains('-')){
                            ProductModel =ProductModel.replace('-','- ');
                            opp.Product2.Product_Name__c=ProductModel;
                        }
                    }
                    if(String.isNotBlank(opp.Product2.Name)){
                        String ProductName=opp.Product2.Name;
                        if(ProductName.contains('-')){
                            ProductName =ProductName.replace('-','- ');
                            opp.Product2.Name=ProductName;
                        }
                    }
                }
            }
            totalQty = prodLineItem.size();            
            if(!String.isBlank(recordId)){
                List<Terms_Conditions__c> termCondRec  = [SELECT Id,Name,Packing_Forwarding__c,Freight_Insurance__c,Ex_Works__c,Payment_Terms__c,Delivery_Period__c,Commission_Assistance__c,Warrenty_Period__c,Quotation_Validity__c,Quote__c,CurrencyIsoCode,Attn__c,Email_Body__c FROM Terms_Conditions__c WHERE Quote__c=:recordId  LIMIT 1];
                if(termCondRec.size()>0){
                    termDetails = termCondRec[0];
                }                
                addinfoDetails = [SELECT Id,Quote__c,Delivery__c,Mounting__c,Quotation__c,Necessary__c,Cable__c,Required__c,Third__c,Actuator__c,The__c FROM Addition_Information_Details__c WHERE Quote__c =:recordId];
                AmountWithAllTaxes = AllTotalTaxWithPriceValue;
                NumbersInWords=String.valueOf(integer.valueOf(AmountWithAllTaxes)); 
                NumberToWordConversion converter = new NumberToWordConversion();
                TotalPricewithTaxInWords = converter.getNumberToWordConversion(AmountWithAllTaxes);
                Decimal rA = Decimal.valueOf(NumbersInWords); 
                List<String> args = new String[]{'0','number','###,###,##0.00'};
                    formatAmount = String.format(rA.format(), args);
            }
        }catch(Exception e){
            System.debug('Error :'+e.getMessage() +' AND Line :'+e.getLineNumber());
        }
    }
    
    public static List<QuoteLineItem> getProductList(Id quoteId){
        return [select id from QuoteLineItem where QuoteId =: quoteId];
    }
    
    
}