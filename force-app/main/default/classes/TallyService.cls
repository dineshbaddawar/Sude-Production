/* 
* @description  Sync Account ,Quote information to Tally
* @author       Bigworks Team 
* @Date         03/02/2021
* @TestClass    TallyService_TC
* -----------------------------------------------------------------------
*/
global class TallyService {
    public static String responseBody ;
    public static Integer statusCode;
    public static String responseBodyFor2ndEndPoint ;
    public static Integer statusCodeFor2ndEndPoint ;

    public static String accountCreationOnTally(Id recordId){
        Account account = [SELECT Id,Ledger_Type__c,Name,BillingStreet,GST_Number__c,Vendor_code__c,PAN_No__c,owner.Name,BillingState,BillingPostalCode,BillingAddress,BillingCountry,Email__c,Tally_Response__c,Country_of_Residences__c,
                           GST_Registration_Type__c,Phone,BillingCity,ShippingState,ShippingPostalCode,ShippingAddress,ShippingCountry,ShippingStreet,ShippingCity,
                           (SELECT Salutation,Name,MobilePhone FROM Contacts)  
                           FROM Account WHERE ID =: recordId];
        String Tally_Response = '';
        if(account.Tally_Response__c != null){
            Tally_Response = account.Tally_Response__c;
        }
        if(account.Tally_Response__c != 'Success' && Tally_Response.contains(' already exists!') == false ){
            String mailBody = 'Account \''+account.Name+'\' failed to sync and error is below<br/>';
            try{
                Ledger_Parent__mdt ledgerParent = [SELECT Parent_Name__c  FROM Ledger_Parent__mdt WHERE MasterLabel =: account.Ledger_Type__c];
                
                Contact childContact = new Contact();
                if(account.Contacts != null && account.Contacts.size() > 0){
                    childContact = account.Contacts[0];   
                }   
                TallyCredentials__c credentials = [SELECT End_Point__c,Alternative_End_Point__c,Company__c FROM TallyCredentials__c];                       
                
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type','text/xml');
                req.setEndpoint(credentials.End_Point__c);
                
                String reqBody = ''; 
                if(account.Ledger_Type__c == 'Customer Ledger'){
                    reqBody = generateCustomerLedgerXML(account,childContact,ledgerParent);
                }else if(account.Ledger_Type__c == 'Sales Ledger'){
                    reqBody = generateSalesLedgerXML(account,childContact,ledgerParent);
                }else if(account.Ledger_Type__c == 'Tax Ledger'){
                    reqBody = generateTaxLedgerXML(account,childContact,ledgerParent);
                }
                reqBody = reqBody.replaceAll('&','&amp;');
                system.debug('string request'+reqBody);
                req.setHeader('Content-length', ''+reqBody.length());
                req.setTimeout(120000);
                req.setBody(reqBody);
                if(!Test.isRunningTest()){
                    res = http.send(req); 
                }else {
                    res.setStatusCode (statusCode);
                    res.setBody (responseBody);
                }
                system.debug(res);
                String responseBodyBefore = res.getBody();
                if (res.getStatusCode() == 200){
                    String success = 'Request Successful '+res.getStatus()+' Body: '+res.getBody();
                    String responseBody = res.getBody();
                    String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                    if(responseBody.contains('<CREATED>') && createdSuccessfully != '0'){
                        account.Tally_Response__c = 'Success'; 
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Account__c = account.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        insert log;
                        
                    }else{
                        String  alreadyExisted = '';
                        if(responseBody.contains('<LINEERROR>') ){
                            alreadyExisted = responseBody.substringBetween('<LINEERROR>','</LINEERROR>');
                        }else{
                            alreadyExisted = responseBody;
                        }
                        if(alreadyExisted.contains('already exists!')){
                            alreadyExisted = account.Name + ' already exists!';
                        }
                        account.Tally_Response__c = String.escapeSingleQuotes(alreadyExisted) ;  
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Account__c = account.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        insert log;
                    }
                }
                else if(responseBodyBefore.contains('ERR_CONNECT_FAIL') || (res.getStatusCode() == 503)){
                    if(!Test.isRunningTest()){
                        req.setEndpoint(credentials.Alternative_End_Point__c);
                        res = http.send(req); 
                    }else {
                        res.setStatusCode (statusCodeFor2ndEndPoint);
                        res.setBody (responseBodyFor2ndEndPoint);
                    }
                    if (res.getStatusCode() == 200){
                        String success = 'Request Successful '+res.getStatus()+' Body: '+res.getBody();
                        String responseBody = res.getBody();
                        String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                        if(responseBody.contains('<CREATED>') && createdSuccessfully != '0'){
                            account.Tally_Response__c = 'Success'; 
                            Tally_Logs__c log = new Tally_Logs__c();
                            log.Account__c = account.Id;
                            log.Request_Body__c = reqBody;
                            log.Response_Body__c = res.getBody();
                            insert log;
                            
                        }else{
                            System.debug(responseBody+'responseBody');
                            
                            String  alreadyExisted = '';
                            if(responseBody.contains('<LINEERROR>') ){
                                alreadyExisted = responseBody.substringBetween('<LINEERROR>','</LINEERROR>');
                            }else{
                                alreadyExisted = responseBody;
                            }
                            System.debug(alreadyExisted +'alreadyExisted ');
                            if(alreadyExisted.contains('already exists!')){
                                System.debug(alreadyExisted +'alreadyExisted ');
                                alreadyExisted = account.Name + ' already exists!';
                            }
                            account.Tally_Response__c = String.escapeSingleQuotes(alreadyExisted) ;  
                            Tally_Logs__c log = new Tally_Logs__c();
                            log.Account__c = account.Id;
                            log.Request_Body__c = reqBody;
                            log.Response_Body__c = res.getBody();
                            insert log;
                        }
                    }else{
                        account.Tally_Response__c = 'Error';  
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Account__c = account.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        insert log;
                    }
                }else{
                    account.Tally_Response__c = 'Error';  
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Account__c = account.Id;
                    log.Request_Body__c = reqBody;
                    log.Response_Body__c = res.getBody();
                    insert log;
                    
                }
                update account;
                return account.Tally_Response__c;
                
            }
            catch(Exception e)
            {
                System.debug(e.getLineNumber()+e.getMessage());
                Tally_Logs__c log = new Tally_Logs__c();
                log.Account__c = account.Id;
                log.Request_Body__c = e.getMessage();
                insert log;
                return 'Error';
            }
        }
        return 'Account already synced to tally';
    }
    public static String generateCustomerLedgerXML(Account account,Contact childContact,Ledger_Parent__mdt ledgerParent){
        String totalAddress = '';
        String shippingAddress = '';
        if(account.BillingStreet != null){
            totalAddress += account.BillingStreet;
        }
        if(account.BillingCity != null){
            if(totalAddress != ''){
                totalAddress = totalAddress + ','+account.BillingCity ;
            }else{
                totalAddress += account.BillingCity ;
            }
        }
        if( account.BillingState != null){
            if(totalAddress != ''){
                totalAddress = totalAddress + ','+account.BillingState ;
            }else{
                totalAddress += account.BillingState ;
            }
        }
        if(account.BillingPostalCode != null){
            if(totalAddress != ''){
                totalAddress = totalAddress + ','+account.BillingPostalCode ;
            }else{
                totalAddress += account.BillingPostalCode ;
            }
        }
        if(account.BillingCountry != null){
            if(totalAddress != ''){
                totalAddress = totalAddress + ','+account.BillingCountry ;
            }else{
                totalAddress += account.BillingCountry ;
            }
        }
        if(account.BillingPostalCode == null){
            account.BillingPostalCode = '';
        }
        
       if(account.ShippingStreet != null){
            shippingAddress += account.ShippingStreet;
        }
        if(account.ShippingCity != null){
            if(shippingAddress != ''){
                shippingAddress = shippingAddress + ','+account.ShippingCity ;
            }else{
                shippingAddress += account.ShippingCity ;
            }
        }
        if( account.ShippingState != null){
            if(shippingAddress != ''){
                shippingAddress = shippingAddress + ','+account.ShippingState ;
            }else{
                shippingAddress += account.ShippingState ;
            }
        }
        if(account.ShippingPostalCode != null){
            if(shippingAddress != ''){
                shippingAddress = shippingAddress + ','+account.ShippingPostalCode ;
            }else{
                shippingAddress += account.ShippingPostalCode ;
            }
        }
        if(account.ShippingCountry != null){
            if(shippingAddress != ''){
                shippingAddress = shippingAddress + ','+account.ShippingCountry ;
            }else{
                shippingAddress += account.ShippingCountry ;
            }
        }
        if(account.ShippingPostalCode == null){
            account.ShippingPostalCode = '';
        }
        

        String reqBody = '';
        reqBody += '<ENVELOPE>'
            +'<HEADER>'
            +'<TALLYREQUEST>Import Data</TALLYREQUEST>'
            +'</HEADER>'
            +'<BODY>'
            +'<IMPORTDATA>'
            +'<REQUESTDESC>'
            +'<REPORTNAME>All Masters</REPORTNAME>'
            +'<STATICVARIABLES>'
            +'<SVCURRENTCOMPANY>Sude Engineering Corporation-22-23</SVCURRENTCOMPANY>'       
            +'</STATICVARIABLES>'
            +'</REQUESTDESC>'
            +'<REQUESTDATA>'
            +'<TALLYMESSAGE xmlns:UDF="TallyUDF">'
            +'<LEDGER Action = "Create">'
            +'<ADDRESS.LIST TYPE="String">'
            +'<ADDRESS>'+totalAddress+'</ADDRESS>'
            +'</ADDRESS.LIST>'
            +'<MAILINGNAME.LIST TYPE="String">'
            +'<MAILINGNAME>'+account.Name+'</MAILINGNAME>'
            +'</MAILINGNAME.LIST>'
            +'<PINCODE>'+account.BillingPostalCode+'</PINCODE>';
        if(account.PAN_No__c == null){
            account.PAN_No__c = '';
        }
        if(account.GST_Number__c == null){
            account.GST_Number__c = '';
        }
        if(account.GST_Registration_Type__c == 'Regular' || account.GST_Registration_Type__c == 'Composition'){
            reqBody += '<INCOMETAXNUMBER>'+account.PAN_No__c+'</INCOMETAXNUMBER>';
            reqBody += '<PARTYGSTIN>'+account.GST_Number__c+'</PARTYGSTIN>';
        }
        if(account.Email__c == null){
            account.Email__c = '';
        }
        if(account.BillingCountry == null){
            account.BillingCountry = '';
        }
        if(account.GST_Registration_Type__c == null){
            account.GST_Registration_Type__c = '';
        }
        if(ledgerParent.Parent_Name__c == null){
            ledgerParent.Parent_Name__c = '';
        }
        if(account.Country_of_Residences__c == null){
            account.Country_of_Residences__c = '';
        }
        reqBody += '<EMAIL>'+account.Email__c+'</EMAIL>'
            +'<COUNTRYNAME>'+account.BillingCountry+'</COUNTRYNAME>'
            +'<GSTREGISTRATIONTYPE>'+account.GST_Registration_Type__c+'</GSTREGISTRATIONTYPE>'
            +'<VATDEALERTYPE>Regular</VATDEALERTYPE>'
            +'<PARENT>'+ledgerParent.Parent_Name__c  +'</PARENT>'
            +'<CREATEDBY>'+account.owner.Name+'</CREATEDBY>'
            +'<ALTEREDBY>'+account.owner.Name+'</ALTEREDBY>'
            +'<TAXTYPE>Others</TAXTYPE>'
            +'<COUNTRYOFRESIDENCE>'+account.Country_of_Residences__c+'</COUNTRYOFRESIDENCE>';
        if(account.Phone == null){
            account.Phone = '';
        }
        if(childContact.Salutation == null){
            childContact.Salutation = '';
        }
        if(childContact.MobilePhone == null){
            childContact.MobilePhone = '';
        }
        if(account.BillingState == null){
            account.BillingState = '';
        }
        if(account.Vendor_code__c == null){
            account.Vendor_code__c = '';
        }
        
        reqBody += '<LEDGERPHONE>'+account.Phone+'</LEDGERPHONE>'
            +'<LEDGERCONTACT>'+childContact.Salutation+' '+childContact.Name+'</LEDGERCONTACT>'
            +'<LEDGERMOBILE>'+childContact.MobilePhone+'</LEDGERMOBILE>'
            +'<LEDSTATENAME>'+account.BillingState+'</LEDSTATENAME>'
            +'<ISBILLWISEON>Yes</ISBILLWISEON>'
            +'<ISCHEQUEPRINTINGENABLED>Yes</ISCHEQUEPRINTINGENABLED>'
            +'<LANGUAGENAME.LIST>'
            +'<NAME.LIST TYPE="String">'
            +'<NAME>'+account.Name+'</NAME>'
            +'</NAME.LIST>'
            +'<LANGUAGEID> 1033</LANGUAGEID>'
            +'</LANGUAGENAME.LIST>'
            +'<OURCMPVNDRCD>'+account.Vendor_code__c+'</OURCMPVNDRCD>'
            +'</LEDGER>'
            +'</TALLYMESSAGE>'
            +'</REQUESTDATA>'
            +'</IMPORTDATA>'
            +'</BODY>'
            +'</ENVELOPE>';  
        return reqBody;  
    }
    public static String generateSalesLedgerXML(Account account,Contact childContact,Ledger_Parent__mdt ledgerParent){
        String reqBody = '';
        if(ledgerParent.Parent_Name__c == null){
            ledgerParent.Parent_Name__c = '';
        }
        reqBody +=' <Envelope>'
            +'<Header>'
            +'<Version>1</Version>'
            +'<TallyRequest>Export</TallyRequest>'
            +'<Type>Data</Type>'
            +'<ID>AllMasters</ID>'
            +'</Header>'
            +'<Body>'
            +'<Data>'
            +'<Tally Message>'
            +'<LEDGER Action = "Create">'
            +'<NAME>'+account.Name+'</Name>'
            +'<PARENT>'+ledgerParent.Parent_Name__c +'</PARENT>'
            +'<GSTAPPLICABLE>&#4; Applicable</GSTAPPLICABLE>'
            +'<TAXTYPE>Others</TAXTYPE>'
            +'<GSTTYPEOFSUPPLY>Goods</GSTTYPEOFSUPPLY>'
            +'<AFFECTSSTOCK>Yes</AFFECTSSTOCK>'
            +'<ISCHEQUEPRINTINGENABLED>Yes</ISCHEQUEPRINTINGENABLED>'
            +'<LANGUAGENAME.LIST>'
            +'<NAME.LIST TYPE="String">'
            +'<NAME>'+account.Name+'</NAME>'
            +'</NAME.LIST>'
            +'<LANGUAGEID> 1033</LANGUAGEID>'
            +'</LANGUAGENAME.LIST>'
            +'</LEDGER>'
            +'</Tally Message>'
            +'</Data>'
            +'</Body>'
            +'</Envelope>';
        return reqBody;  
    }
    public static String generateTaxLedgerXML(Account account,Contact childContact,Ledger_Parent__mdt ledgerParent){
        String reqBody = '';
        if(ledgerParent.Parent_Name__c == null){
            ledgerParent.Parent_Name__c = '';
        }
        reqBody +='<Envelope>'
            +'<Header>'
            +'<Version>1</Version>'
            +'<TallyRequest>Export</TallyRequest>'
            +'<Type>Data</Type>'
            +'<ID>AllMasters</ID>'
            +'</Header>'
            +'<Body>'
            +'<Data>'
            +'<Tally Message>'
            +'<LEDGER Action = "Create">'
            +'<NAME>'+account.Name+'</NAME>'
            +'<PARENT>'+ledgerParent.Parent_Name__c +'</PARENT>'
            +'<TAXTYPE>GST</TAXTYPE>'
            +'<GSTDUTYHEAD>Central Tax</GSTDUTYHEAD>'
            +'<ROUNDINGMETHOD>Normal Rounding</ROUNDINGMETHOD>'
            +'<RATEOFTAXCALCULATION> 9</RATEOFTAXCALCULATION>'
            +'<LANGUAGENAME.LIST>'
            +'<NAME.LIST TYPE="String">'
            +'<NAME>'+account.Name+'</NAME>'
            +'</NAME.LIST>'
            +'<LANGUAGEID> 1033</LANGUAGEID>'
            +'</LANGUAGENAME.LIST>'
            +'</LEDGER>'
            +'</Tally Message>'
            +'</Data>'
            +'</Body>'
            +'</Envelope>';
        return reqBody; 
    }
    
   
    @InvocableMethod
    public static void tallyServiceForQuoteInvoked(List<QuoteWrapper> recordIds){
        if(recordIds != null && !recordIds.isEmpty()){
            syncQuoteToTally(recordIds[0].quoteId);
        }
    }
    @future(callout= true)
    public static void syncQuoteToTally(Id quoteId ){
        quoteCreationOnTally(quoteId);
    }
      
    
    @AuraEnabled
    public static String tallyServiceForQuoteAction(Id recordId){
        String idPrifix = String.valueOf(recordId);
        if(idPrifix.startsWith('001')){
            String result = accountCreationOnTally(recordId);
            return result ;
        }else if(idPrifix.startsWith('006')){
            String result = quoteCreationOnTally(recordId);
            return result ;
        }else {
            String result = sendStockItemToTally (recordId);
            return result ;
        }
    }
    
    public static String quoteCreationOnTally(Id oppId){
        List<String> termsAndConditons = new List<String>();
        Bank_Details__mdt bankDetails = [SELECT Account_Name__c,Account_No__c,Bank_AD_Code__c,BANK_NAME__c,BRANCH__c,GST_No__c,IFSC_Code__c,HSN_CODE__c,
                               IEC_No__c,MICR_Code__c,PAN_No__c,RTGS__c,SSI__c,Swift_Code_For_Commercial_Invoice__c,Udyam_No__c,UDYOG_AADHAR__c,
                               Commercial_Invoice_Terms_And_Conditons__c ,Swift_Code__c  
                               FROM Bank_Details__mdt LIMIT 1];
        if(bankDetails.Commercial_Invoice_Terms_And_Conditons__c != null){
            termsAndConditons = bankDetails.Commercial_Invoice_Terms_And_Conditons__c.split('>>');
            termsAndConditons.remove(0);

        }
        Opportunity parentOpportunity = [SELECT Name,SyncedQuoteId,Order_Acknowledgement_Number__c,Order_Acknowledgement_Number2__c,AccountId,Tally_Response__c,StageName,CloseDate,Order_Reference_Date__c,Order_Reference_Number__c FROM Opportunity WHERE Id =: oppId];
        if(parentOpportunity.StageName == 'Order Acknowledgement'){
            Account parentAccount = [SELECT Ledger_Type__c,GST_Number__c,ShippingPostalCode,owner.Name,Name,BillingStreet,BillingState,ShippingState,BillingCountry,BillingPostalCode,BillingAddress,Phone,BillingCity,Email__c,Tally_Response__c,
                                     ShippingCountry,ShippingCity,ShippingStreet,ShippingAddress,
                                     GST_Registration_Type__c,Country_of_Residences__c,Vendor_code__c,(SELECT Salutation,Name,MobilePhone FROM Contacts)
                                     FROM Account WHERE ID =: parentOpportunity.AccountId];
            Id quoteId = parentOpportunity.SyncedQuoteId;
            if(quoteId != null){
                Quote newQuote = [SELECT Validity__c,Freight_Insurance__c,Delivery_Terms__c,Extra_P_F__c,Warranty__c, Prices__c,Id,AccountId,Currency_Rate__c,CurrencyIsoCode,Inquiry_Number__c,ShippingCountry,ShippingPostalCode,Round_Off__c,Inquiry_Reference_Date__c ,Opportunity.Order_Reference_Number__c,Name,QuoteNumber,ExpirationDate,GrandTotal,Tally_Response__c,Effective_Date__c,CGST__c ,CGST_Value__c,SGST__c 
                                  ,Delivery_Period__c,Destination__c,Despatch_Through__c,Payment_Terms__c,SGST_Value__c,IGST__c ,IGST_Value__c,Insurance__c,Subtotal,Opportunity.Account.Country_of_Residences__c,Grand_Total_P_T__c,
                                  Discount,Freight__c,Packing__c,Packing_Value__c FROM Quote WHERE Id =: quoteId ];
                List<QuoteLineItem> childLineItems = [SELECT product2.Name,product2.Tally_Response__c ,UnitPrice ,Discount ,LineNumber,TotalPrice ,Quantity,ServiceDate,product2.Product_Name__c,product2.Description FROM QuoteLineItem WHERE QuoteId =: quoteId];
                String mailBody = 'Quote \''+newQuote.Name+'\' With quoteNumber '+newQuote.QuoteNumber+' failed to sync and error is below<br/>';            
                String Tally_Response = '';
                if(parentAccount.Tally_Response__c != null){
                    Tally_Response = parentAccount.Tally_Response__c;
                }
                if(parentAccount.Tally_Response__c != null && (parentAccount.Tally_Response__c == 'Success' || Tally_Response.contains(' already exists!'))){
                    if(childLineItems != null && !childLineItems.isEmpty()){
                        String isSyncedToTally = '';
                        Tally_Response = '';
                        for(QuoteLineItem eachItem : childLineItems){
                            if(eachItem.product2 != null && eachItem.product2.Tally_Response__c != null){
                                Tally_Response = eachItem.product2.Tally_Response__c;
                            }
                            if(eachItem.product2 != null && (eachItem.product2.Tally_Response__c != 'Success' && Tally_Response.contains(' already exists!') == false)){
                                isSyncedToTally = 'All/Some Products are not synced to tally';
                            }
                        }
                        if(isSyncedToTally == '' || Test.isRunningTest()){
                            try{
                                String dateFormated = '';
                                String dueDate = '';
                                String inquiryReferenceDate = '';
                                if(newQuote.Inquiry_Reference_Date__c != null){
                                    Date datobj = newQuote.Inquiry_Reference_Date__c ;
                                    Integer dy = datobj.day();
                                    Integer mon = datobj.month();
                                    Integer yr = datobj.year();
                                    String monStr = '';
                                    String dyStr = '';
                                    if(mon < 10){
                                        monStr =  '0'+String.valueOf(mon);  
                                    }else{
                                        monStr =  String.valueOf(mon);  
                                    }
                                    if(dy < 10){
                                        dyStr = '0'+String.valueOf(dy); 
                                    }else{
                                        dyStr =  String.valueOf(dy);  
                                    }
                                    inquiryReferenceDate = String.valueOf(yr)+monStr+dyStr;
                                }
                                if(newQuote.Effective_Date__c != null){
                                    Date datobj = newQuote.Effective_Date__c;
                                    Integer dy = datobj.day();
                                    Integer mon = datobj.month();
                                    Integer yr = datobj.year();
                                    String monStr = '';
                                    String dyStr = '';
                                    if(mon < 10){
                                        monStr =  '0'+String.valueOf(mon);  
                                    }else{
                                        monStr =  String.valueOf(mon);  
                                    }
                                    if(dy < 10){
                                        dyStr = '0'+String.valueOf(dy); 
                                    }else{
                                        dyStr =  String.valueOf(dy);  
                                    }
                                    dateFormated = String.valueOf(yr)+monStr+dyStr;
                                }else{
                                    Date datobj = parentOpportunity.CloseDate;
                                    Integer dy = datobj.day();
                                    Integer mon = datobj.month();
                                    Integer yr = datobj.year();
                                    String monStr = '';
                                    String dyStr = '';
                                    if(mon < 10){
                                        monStr =  '0'+String.valueOf(mon);  
                                    }else{
                                        monStr =  String.valueOf(mon);  
                                    }
                                    if(dy < 10){
                                        dyStr = '0'+String.valueOf(dy); 
                                    }else{
                                        dyStr =  String.valueOf(dy);  
                                    }
                                    dateFormated = String.valueOf(yr)+monStr+dyStr;
                                }
                                String OrderReferenceDate = '';
                                String OrderAckDate = '';
                                if(parentOpportunity.CloseDate != null){
                                    DateTime datobj = parentOpportunity.CloseDate;
                                    OrderAckDate = datobj.format('d-MMM-YYYY');
                                }
                                if(newQuote.ExpirationDate != null){
                                    DateTime datobj = newQuote.ExpirationDate;
                                    dueDate = datobj.format('d-MMM-YYYY');
                                    System.debug('dueDate :: '+dueDate);
                                }else{
                                    DateTime datobj = parentOpportunity.CloseDate;
                                    dueDate = datobj.format('d-MMM-YYYY');
                                    System.debug('dueDate :: '+dueDate);                            
                                }
                                if(parentOpportunity.Order_Reference_Date__c != null){
                                    DateTime datobj = parentOpportunity.Order_Reference_Date__c;
                                    OrderReferenceDate = datobj.format('d-MMM-YYYY');
                                }
                                Contact childContact = new Contact();
                                if(parentAccount.Contacts != null && parentAccount.Contacts.size() > 0){
                                    childContact = parentAccount.Contacts[0];   
                                }
                                Date currentDate = Date.today();
                                Integer dy = currentDate.day();
                                Integer mon = currentDate.month();
                                Integer yr = currentDate.year();
                                String monStr = '';
                                String dyStr = '';
                                if(mon < 10){
                                    monStr =  '0'+String.valueOf(mon);  
                                }else{
                                    monStr =  String.valueOf(mon);  
                                }
                                if(dy < 10){
                                    dyStr = '0'+String.valueOf(dy); 
                                }else{
                                    dyStr =  String.valueOf(dy);  
                                }
                                String today = String.valueOf(yr)+monStr+dyStr;
                                TallyCredentials__c credentials = [SELECT End_Point__c,Alternative_End_Point__c,Company__c FROM TallyCredentials__c];                       
                                Ledger_Parent__mdt ledgerParent = [SELECT Parent_Name__c  FROM Ledger_Parent__mdt WHERE MasterLabel =: parentAccount.Ledger_Type__c];
                                Http http = new Http();
                                HttpResponse res = new HttpResponse();
                                HttpRequest req = new HttpRequest();
                                req.setMethod('POST');
                                req.setHeader('Content-Type','text/xml');
                                req.setEndpoint(credentials.End_Point__c);  
                                String totalAddress = '';
                                        String shippingAddress = '';

                                if(parentAccount.BillingStreet != null){
                                    totalAddress += parentAccount.BillingStreet;
                                }
                                if(parentAccount.BillingCity != null){
                                    if(totalAddress != ''){
                                        totalAddress = totalAddress + ','+parentAccount.BillingCity ;
                                    }else{
                                        totalAddress += parentAccount.BillingCity ;
                                    }
                                }
                                if( parentAccount.BillingState != null){
                                    if(totalAddress != ''){
                                        totalAddress = totalAddress + ','+parentAccount.BillingState ;
                                    }else{
                                        totalAddress += parentAccount.BillingState ;
                                    }
                                }
                                if(parentAccount.BillingPostalCode != null){
                                    if(totalAddress != ''){
                                        totalAddress = totalAddress + ','+parentAccount.BillingPostalCode ;
                                    }else{
                                        totalAddress += parentAccount.BillingPostalCode ;
                                    }
                                }
                                if(parentAccount.BillingCountry != null){
                                    if(totalAddress != ''){
                                        totalAddress = totalAddress + ','+parentAccount.BillingCountry ;
                                    }else{
                                        totalAddress += parentAccount.BillingCountry ;
                                    }
                                }
                                
                                
                                 if(parentAccount.ShippingStreet != null){
                                    shippingAddress += parentAccount.ShippingStreet;
                                }
                                if(parentAccount.ShippingCity != null){
                                    if(shippingAddress != ''){
                                        shippingAddress = shippingAddress + ','+parentAccount.ShippingCity ;
                                    }else{
                                        shippingAddress += parentAccount.ShippingCity ;
                                    }
                                }
                                if( parentAccount.ShippingState != null){
                                    if(shippingAddress != ''){
                                        shippingAddress = shippingAddress + ','+parentAccount.ShippingState ;
                                    }else{
                                        shippingAddress += parentAccount.ShippingState ;
                                    }
                                }
                                if(parentAccount.ShippingPostalCode != null){
                                    if(shippingAddress != ''){
                                        shippingAddress = shippingAddress + ','+parentAccount.ShippingPostalCode ;
                                    }else{
                                        shippingAddress += parentAccount.ShippingPostalCode ;
                                    }
                                }
                                if(parentAccount.BillingCountry != null){
                                    if(shippingAddress != ''){
                                        shippingAddress = shippingAddress + ','+parentAccount.ShippingCountry ;
                                    }else{
                                        shippingAddress += parentAccount.ShippingCountry ;
                                    }
                                }
                                
                                
                                
                                
                                
                                
                                if(parentAccount.Email__c == null){
                                    parentAccount.Email__c = '';
                                }
                                if(parentAccount.BillingCountry == null){
                                    parentAccount.BillingCountry = '';
                                }
                                
                                if(ledgerParent.Parent_Name__c == null){
                                    ledgerParent.Parent_Name__c = '';
                                }
                                if(parentAccount.Country_of_Residences__c == null){
                                    parentAccount.Country_of_Residences__c = '';
                                }
                                if(parentAccount.Phone == null){
                                    parentAccount.Phone = '';
                                }
                                if(childContact.Salutation == null){
                                    childContact.Salutation = '';
                                }
                                if(childContact.MobilePhone == null){
                                    childContact.MobilePhone = '';
                                }
                                if(parentAccount.BillingState == null){
                                    parentAccount.BillingState = '';
                                }
                                if(parentAccount.Vendor_code__c == null){
                                    parentAccount.Vendor_code__c = '';
                                }
                                if(parentAccount.GST_Registration_Type__c == null){
                                    parentAccount.GST_Registration_Type__c = '';
                                }
                                if(parentAccount.BillingPostalCode == null){
                                    parentAccount.BillingPostalCode = '';
                                }
                                if(parentOpportunity.Order_Reference_Number__c == null){
                                    parentOpportunity.Order_Reference_Number__c = '';
                                }
                                if(parentAccount.GST_Number__c == null){
                                    parentAccount.GST_Number__c = '';
                                }
                                if(newQuote.ShippingCountry == null){
                                    newQuote.ShippingCountry = '';
                                }
                                if(parentAccount.ShippingState == null){
                                    parentAccount.ShippingState = '';
                                }
                                if(parentAccount.ShippingPostalCode == null){
                                    parentAccount.ShippingPostalCode = '';
                                }
                                if(newQuote.Destination__c == null){
                                    newQuote.Destination__c = '';
                                }
                                if(newQuote.Payment_Terms__c == null){
                                    newQuote.Payment_Terms__c = '';
                                }
                                if(newQuote.Despatch_Through__c == null){
                                    newQuote.Despatch_Through__c = '';
                                }
                                if(newQuote.Delivery_Period__c == null){
                                    newQuote.Delivery_Period__c = '';
                                }
                                if(newQuote.Inquiry_Number__c == null){
                                    newQuote.Inquiry_Number__c = '';
                                }
                                
                                String reqBody = '';
                                Decimal totalAmount = 0;
                                totalAmount = totalAmount - newQuote.GrandTotal;
                                reqBody += '<ENVELOPE>'
                                    +'<HEADER>'
                                    +'<TALLYREQUEST>Import Data</TALLYREQUEST>'
                                    +'</HEADER>'
                                    +'<BODY>'
                                    +'<IMPORTDATA>'
                                    +'<REQUESTDESC>'
                                    +'<REPORTNAME>All Masters</REPORTNAME>'
                                    +'<STATICVARIABLES>'
                                    +'<SVCURRENTCOMPANY>Sude Engineering Corporation-22-23</SVCURRENTCOMPANY>'       
                                    +'</STATICVARIABLES>'
                                    +'</REQUESTDESC>'
                                    +'<REQUESTDATA>'
                                    +'<TALLYMESSAGE xmlns:UDF="TallyUDF">';
                                    
                                   /* +'<LEDGER NAME="'+parentAccount.Name+'" RESERVEDNAME="">'
                                    +'<ADDRESS.LIST TYPE="String">'
                                    +'<ADDRESS>'+totalAddress +'</ADDRESS>'
                                    +'</ADDRESS.LIST>'
                                    +'<MAILINGNAME.LIST TYPE="String">'
                                    +'<MAILINGNAME>'+parentAccount.Name+'</MAILINGNAME>'
                                    +'</MAILINGNAME.LIST>'
                                    +'<EMAIL>'+parentAccount.Email__c+'</EMAIL>'
                                    +'<COUNTRYNAME>'+parentAccount.BillingCountry+'</COUNTRYNAME>'
                                    +'<GSTREGISTRATIONTYPE>'+parentAccount.GST_Registration_Type__c+'</GSTREGISTRATIONTYPE>'
                                    +'<PARENT>'+ledgerParent.Parent_Name__c+'</PARENT>'
                                    +'<CREATEDBY>'+parentAccount.owner.Name+'</CREATEDBY>'
                                    +'<ALTEREDBY>'+parentAccount.owner.Name+'</ALTEREDBY>'
                                    +'<TAXTYPE>other</TAXTYPE>'
                                    +'<COUNTRYOFRESIDENCE>'+parentAccount.Country_of_Residences__c+'</COUNTRYOFRESIDENCE>'
                                    +'<LEDGERPHONE>'+parentAccount.Phone+'</LEDGERPHONE>'
                                    +'<LEDGERCONTACT>'+childContact.Salutation+' '+childContact.Name+'</LEDGERCONTACT>'
                                    +'<LEDGERMOBILE>'+childContact.MobilePhone+'</LEDGERMOBILE>'
                                    +'<LEDSTATENAME>'+parentAccount.BillingState+'</LEDSTATENAME>'
                                    +'<OURCMPVNDRCD>'+parentAccount.Vendor_code__c+'</OURCMPVNDRCD>'
                                    +'<ISBILLWISEON>Yes</ISBILLWISEON>'
                                    +'<NAME>'+parentAccount.Name+'</NAME>'
                                    +'</LEDGER>';*/
                                    
                                       /*** Sales Order Creation Code ***/ 
                                   String orderStatus = Label.Order_Creation_Updation;
                                   if(newQuote.Tally_Response__c == null){
                                       newQuote.Tally_Response__c = '';
                                   }
                                   if(newQuote.Tally_Response__c == ''){
                                       reqBody += '<VOUCHER VCHTYPE="Sales Order" ACTION="Create" OBJVIEW="Invoice Voucher View">';
                                   }else{
                                      reqBody +='<VOUCHER DATE="'+OrderAckDate+'" TAGNAME = "Voucher Number" TAGVALUE="'+newQuote.Name+'" VCHTYPE="Sales Order" ACTION="Alter" OBJVIEW="Invoice Voucher View">';                                       
                                   }
                                    reqBody +='<ADDRESS.LIST TYPE="String">'
                                    +'<ADDRESS>'+totalAddress +'</ADDRESS>'
                                    +'</ADDRESS.LIST>'
                                    +'<BASICBUYERADDRESS.LIST TYPE="String">'
                                    +'<BASICBUYERADDRESS>'+shippingAddress+'</BASICBUYERADDRESS>'
                                    +'</BASICBUYERADDRESS.LIST>'
                                    
                                    +'<DATE>'+OrderAckDate+'</DATE>'
                                    +'<GSTREGISTRATIONTYPE>'+parentAccount.GST_Registration_Type__c+'</GSTREGISTRATIONTYPE>'
                                    +'<STATENAME>'+parentAccount.BillingState+'</STATENAME>'
                                    +'<COUNTRYOFRESIDENCE>'+parentAccount.Country_of_Residences__c+'</COUNTRYOFRESIDENCE>'
                                    +'<PARTYGSTIN>'+parentAccount.GST_Number__c+'</PARTYGSTIN>'
                                    +'<PLACEOFSUPPLY>'+parentAccount.BillingState+'</PLACEOFSUPPLY>'
                                    +'<PARTYMAILINGNAME>'+parentAccount.Name+'</PARTYMAILINGNAME>'
                                    +'<PARTYPINCODE>'+parentAccount.BillingPostalCode+'</PARTYPINCODE>'
                                    
                                    +'<PARTYNAME>'+parentAccount.Name+'</PARTYNAME>'
                                    +'<VOUCHERTYPENAME>Sales Order</VOUCHERTYPENAME>'
                                    +'<REFERENCE>'+parentOpportunity.Order_Reference_Number__c+'</REFERENCE>'
                                    +'<VOUCHERNUMBER>'+newQuote.Name+'</VOUCHERNUMBER>'
                                    +'<PARTYLEDGERNAME>'+parentAccount.Name+'</PARTYLEDGERNAME>'
                                    +'<BASICBASEPARTYNAME>'+parentAccount.Name+'</BASICBASEPARTYNAME>'
                                    +'<FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>'
                                    +'<PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>'
                                    +'<BASICBUYERNAME>'+parentAccount.Name+'</BASICBUYERNAME>'
                                    
                                    +'<CONSIGNEEGSTIN>'+parentAccount.GST_Number__c+'</CONSIGNEEGSTIN>'
                                    +'<BASICBUYERNAME>'+parentAccount.Name+'</BASICBUYERNAME>'
                                    +'<CONSIGNEEMAILINGNAME>'+parentAccount.Name+'</CONSIGNEEMAILINGNAME>'
                                    +'<CONSIGNEECOUNTRYNAME>'+newQuote.ShippingCountry+'</CONSIGNEECOUNTRYNAME>'
                                    +'<BUYERPINNUMBER>'+parentAccount.BillingPostalCode+'</BUYERPINNUMBER>';
                                    if(parentAccount.ShippingPostalCode != null && parentAccount.ShippingPostalCode != ''){
                                        reqBody +='<CONSIGNEEPINNUMBER>'+parentAccount.ShippingPostalCode+'</CONSIGNEEPINNUMBER>';
                                    }else{
                                        reqBody +='<CONSIGNEEPINNUMBER>'+parentAccount.BillingPostalCode+'</CONSIGNEEPINNUMBER>';
                                    }
                                    if(parentAccount.ShippingState != null && parentAccount.ShippingState != ''){
                                        reqBody +='<CONSIGNEESTATENAME>'+parentAccount.ShippingState+'</CONSIGNEESTATENAME>';
                                    }else{
                                        reqBody +='<CONSIGNEESTATENAME>'+parentAccount.BillingState+'</CONSIGNEESTATENAME>';
                                    }
                                    reqBody +='<CONSIGNEEPINCODE>'+parentAccount.ShippingPostalCode+'</CONSIGNEEPINCODE>';
                                   
                                    if(newQuote.Discount != null && newQuote.Discount > 0){
                                        reqBody +='<HASDISCOUNTS>Yes</HASDISCOUNTS>'; 
                                    }else{
                                        reqBody +='<HASDISCOUNTS>No</HASDISCOUNTS>'; 
                                    
                                    }
                                    reqBody += '<ENTEREDBY>'+parentAccount.owner.Name+'</ENTEREDBY>'
                                    +'<EFFECTIVEDATE>'+OrderReferenceDate+'</EFFECTIVEDATE>'
                                    +'<ISVATDUTYPAID>Yes</ISVATDUTYPAID>'
                                    +'<BASICFINALDESTINATION>'+newQuote.Destination__c+'</BASICFINALDESTINATION>'
                                    +'<BASICDUEDATEOFPYMT>'+newQuote.Payment_Terms__c+'</BASICDUEDATEOFPYMT>'
                                    +'<BASICSHIPPEDBY>'+newQuote.Despatch_Through__c+'</BASICSHIPPEDBY>'
                                    +'<BASICORDERTERMS.LIST TYPE="String">'
                                    +' <BASICORDERTERMS>'+newQuote.Delivery_Period__c+'</BASICORDERTERMS>'
                                    +'</BASICORDERTERMS.LIST>';
                            reqBody +='<BKNm>'+bankDetails.BANK_NAME__c+'</BKNm>'
                                    +'<BKBrNm>'+bankDetails.BRANCH__c+'</BKBrNm>'
                                    +'<BkIFSC>'+bankDetails.IFSC_Code__c+'</BkIFSC>'
                                    +'<BkAcNo>'+bankDetails.Account_No__c+'</BkAcNo>'
                                    +'<BkAcNm>'+bankDetails.Account_Name__c+'</BkAcNm>'
                                    +'<BkSwiftCd>'+bankDetails.Swift_Code__c+'</BkSwiftCd>';
                          
                           reqBody += '<PriceTrm>'+newQuote.Prices__c+'</PriceTrm>'
                                    +'<WarrantyTrm>'+newQuote.Warranty__c+'</WarrantyTrm>'
                                    +'<ExtraPnFTrm>'+newQuote.Extra_P_F__c+'</ExtraPnFTrm>'
                                    +'<ValidityTrm>'+newQuote.Validity__c+'</ValidityTrm>'
                                    +'<FrghtInsTrm>'+newQuote.Freight_Insurance__c+'</FrghtInsTrm>'
                                    +'<DelvryTrm>'+newQuote.Delivery_Terms__c+'</DelvryTrm>';       
                                    
                                    for(String cond : termsAndConditons){  
                                      reqBody += '<QtnTrmsColln>'
                                                +'<TrmsCndn>'+cond+'</TrmsCndn>'
                                                +'</QtnTrmsColln>';
                                    }
                                    reqBody +='<VIEnqNo>'+newQuote.Inquiry_Number__c+'</VIEnqNo>'; // Inquiry Reference number
                                    reqBody +='<VIValidity>'+dueDate+'</VIValidity>';
                                    reqBody +='<SOCntNm>'+parentAccount.Name+'</SOCntNm>';
                                    reqBody +='<VIQtnNo>'+newQuote.Name+'</VIQtnNo>';
                                    System.debug( 'reqBody'+ reqBody);
                                    reqBody +='<OurCmpVndrCd>'+parentAccount.Vendor_code__c+'</OurCmpVndrCd>';
                                   if(parentOpportunity.Order_Acknowledgement_Number__c != null){
                                        reqBody +='<OANum>'+parentOpportunity.Order_Acknowledgement_Number__c+'</OANum>';
                                    }
                                    /*if(parentOpportunity.Order_Acknowledgement_Number2__c != null){
                                        reqBody +='<OANum>'+parentOpportunity.Order_Acknowledgement_Number2__c+'</OANum>';
                                    }*/
                                   reqBody +='<VIEnqDt>'+inquiryReferenceDate +'</VIEnqDt>'; // 
                                    reqBody +='<VIQtnDt>'+dateFormated+'</VIQtnDt>';  // QuotePreparedDate EffectiveDate__c
                                    reqBody +='<OADt>'+OrderAckDate+'</OADt>';
                                    reqBody +='<OrdrRcvdDt>'+orderReferenceDate+'</OrdrRcvdDt>';
                            reqBody +='<LEDGERENTRIES.LIST>'
                                    +'<LEDGERNAME>'+parentAccount.Name+'</LEDGERNAME>'
                                    +'<ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>'
                                    +'<ISPARTYLEDGER>Yes</ISPARTYLEDGER>'
                                    +'<ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>';
                                    Decimal currencyRate = 0;
                                    String currencyCode = '';
                                    if(newQuote.Currency_Rate__c != null){
                                        currencyRate = newQuote.Currency_Rate__c;
                                    }
                                    if(newQuote.CurrencyIsoCode != 'INR' || Test.isRunningTest()){
                                       currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                        Decimal grandTotal = newQuote.Grand_Total_P_T__c;
                                        Decimal convertedAmount = 0;
                                        convertedAmount = newQuote.Grand_Total_P_T__c * currencyRate ;
                                        currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                        reqBody += '<AMOUNT>-'+currencyCode +newQuote.Grand_Total_P_T__c+' @ INR'+ currencyRate +'/'+currencyCode +' = -INR'+ convertedAmount +'</AMOUNT>';
                                    }else{
                                        reqBody += '<AMOUNT>-'+newQuote.Grand_Total_P_T__c+'</AMOUNT>';
                                    }
                                reqBody += '</LEDGERENTRIES.LIST>';
                                
                                /*    -----------Tax Ledgers-----------    */
                                
                                if(newQuote.Packing_Value__c != null){
                                    reqBody += '<LEDGERENTRIES.LIST>';
                                    if(newQuote.Packing__c != null){
                                    reqBody += ' <BASICRATEOFINVOICETAX.LIST TYPE="Number">'
                                        +' <BASICRATEOFINVOICETAX>'+newQuote.Packing__c+'</BASICRATEOFINVOICETAX>'
                                        +'</BASICRATEOFINVOICETAX.LIST>';
                                    }
                                    reqBody +='<ROUNDTYPE>Normal Rounding</ROUNDTYPE>'
                                        +'<LEDGERNAME>Packing and Forwarding</LEDGERNAME>'
                                        +'<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>'
                                        +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                        if(newQuote.CurrencyIsoCode != 'INR'  || Test.isRunningTest()){
                                            currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                            Decimal grandTotal = newQuote.Packing_Value__c;
                                            Decimal convertedAmount = 0;
                                            convertedAmount = newQuote.Packing_Value__c* currencyRate ;
                                            currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                            reqBody += '<AMOUNT>'+currencyCode +newQuote.Packing_Value__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>'
                                                    + '<VATEXPAMOUNT>'+currencyCode +newQuote.Packing_Value__c+' @ INR'+ currencyRate +'/'+currencyCode +' =INR' + convertedAmount +'</VATEXPAMOUNT>';
                                        }else{
                                            reqBody += '<AMOUNT>'+newQuote.Packing_Value__c+'</AMOUNT>'
                                            +'<VATEXPAMOUNT>'+newQuote.Packing_Value__c+'</VATEXPAMOUNT>';
                                        }
                                        reqBody +='</LEDGERENTRIES.LIST>';
                                }
                                if(newQuote.Freight__c != null){
                                    
                                    reqBody += '<LEDGERENTRIES.LIST>'
                                        + '<ROUNDTYPE>Normal Rounding</ROUNDTYPE>'
                                        +'<LEDGERNAME>Freight Charges</LEDGERNAME>'
                                        +'<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>'
                                        +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                        if(newQuote.CurrencyIsoCode != 'INR'  || Test.isRunningTest()){
                                            currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                            Decimal grandTotal = newQuote.Freight__c;
                                            Decimal convertedAmount = 0;
                                            convertedAmount = newQuote.Freight__c* currencyRate ;
                                            currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                            reqBody += '<AMOUNT>'+currencyCode +newQuote.Freight__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>'
                                                    + '<VATEXPAMOUNT>'+currencyCode +newQuote.Freight__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</VATEXPAMOUNT>';
                                        }else{
                                            reqBody += '<AMOUNT>'+newQuote.Freight__c+'</AMOUNT>'
                                            +'<VATEXPAMOUNT>'+newQuote.Freight__c+'</VATEXPAMOUNT>';
                                        }
                                        reqBody += '</LEDGERENTRIES.LIST>';
                                }
                                if(newQuote.Insurance__c != null){
                                    reqBody += '<LEDGERENTRIES.LIST>'
                                        + '<ROUNDTYPE>Normal Rounding</ROUNDTYPE>'
                                        +'<LEDGERNAME>Insurance</LEDGERNAME>'
                                        +'<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>'
                                        +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                        if(newQuote.CurrencyIsoCode != 'INR'  || Test.isRunningTest()){
                                            currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                            Decimal grandTotal = newQuote.Insurance__c;
                                            Decimal convertedAmount = 0;
                                            convertedAmount = newQuote.Insurance__c * currencyRate ;
                                            currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                            reqBody += '<AMOUNT>'+currencyCode +newQuote.Insurance__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>'
                                                    + '<VATEXPAMOUNT>'+currencyCode +newQuote.Insurance__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount+'</VATEXPAMOUNT>';
                                        }else{
                                            reqBody += '<AMOUNT>'+newQuote.Insurance__c+'</AMOUNT>'
                                            +'<VATEXPAMOUNT>'+newQuote.Insurance__c+'</VATEXPAMOUNT>';
                                        }
                                        reqBody += '</LEDGERENTRIES.LIST>';
                                        
                                }
                                if(newQuote.CGST__c != null && newQuote.CGST__c != 0.00){
                                    String cgstVal = '';
                                    if(newQuote.CGST__c == 9.00){
                                        cgstVal = '9';
                                    }else if(newQuote.CGST__c == 14.00){
                                        cgstVal = '14';
                                    }else{
                                        cgstVal = String.valueOf(newQuote.CGST__c);
                                    }
                                    reqBody += '<LEDGERENTRIES.LIST>';
                                    reqBody += ' <BASICRATEOFINVOICETAX.LIST TYPE="Number">'
                                        +' <BASICRATEOFINVOICETAX>'+newQuote.CGST__c+'</BASICRATEOFINVOICETAX>'
                                        +'</BASICRATEOFINVOICETAX.LIST>'
                                        +'<ROUNDTYPE>Normal Rounding</ROUNDTYPE>'
                                        +'<LEDGERNAME>CGST '+cgstVal+'%</LEDGERNAME>'
                                        +'<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>'
                                        +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                        if(newQuote.CurrencyIsoCode != 'INR'  || Test.isRunningTest()){
                                            currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                            Decimal grandTotal = newQuote.CGST_Value__c;
                                            Decimal convertedAmount = 0;
                                            convertedAmount = newQuote.CGST_Value__c* currencyRate ;
                                            currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                            reqBody += '<AMOUNT>'+currencyCode +newQuote.CGST_Value__c+' @ INR'+ currencyRate+'/'+currencyCode +' = INR'+ convertedAmount+'</AMOUNT>'
                                                    + '<VATEXPAMOUNT>'+currencyCode +newQuote.CGST_Value__c+' @ INR'+ currencyRate +'/$ = INR'+ convertedAmount +'</VATEXPAMOUNT>';
                                        }else{
                                            reqBody += '<AMOUNT>'+newQuote.CGST_Value__c+'</AMOUNT>'
                                            +'<VATEXPAMOUNT>'+newQuote.CGST_Value__c+'</VATEXPAMOUNT>';
                                        }
                                        reqBody += '</LEDGERENTRIES.LIST>';
                                        
                                }
                                
                                if(newQuote.SGST__c != null && newQuote.SGST__c != 0.00){
                                    String gstVal = '';
                                    if(newQuote.SGST__c == 9.00){
                                        gstVal = '9';
                                    }else if(newQuote.SGST__c == 14.00){
                                        gstVal = '14';
                                    }else{
                                        gstVal = String.valueOf(newQuote.SGST__c);
                                    }
                                    reqBody += '<LEDGERENTRIES.LIST>';
                                    reqBody += ' <BASICRATEOFINVOICETAX.LIST TYPE="Number">'
                                        +' <BASICRATEOFINVOICETAX>'+newQuote.SGST__c+'</BASICRATEOFINVOICETAX>'
                                        +'</BASICRATEOFINVOICETAX.LIST>'
                                        +'<ROUNDTYPE>Normal Rounding</ROUNDTYPE>'
                                        +'<LEDGERNAME>SGST '+gstVal+'%</LEDGERNAME>'
                                        +'<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>'
                                        +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                        if(newQuote.CurrencyIsoCode != 'INR'  || Test.isRunningTest()){
                                            currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                            Decimal grandTotal = newQuote.SGST_Value__c;
                                            Decimal convertedAmount = 0;
                                            convertedAmount = newQuote.SGST_Value__c* currencyRate ;
                                            currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                            reqBody += '<AMOUNT>'+currencyCode +newQuote.SGST_Value__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>'
                                                    + '<VATEXPAMOUNT>'+currencyCode +newQuote.SGST_Value__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</VATEXPAMOUNT>';
                                        }else{
                                            reqBody += '<AMOUNT>'+newQuote.SGST_Value__c+'</AMOUNT>'
                                            +'<VATEXPAMOUNT>'+newQuote.SGST_Value__c+'</VATEXPAMOUNT>';
                                        }
                                        reqBody += '</LEDGERENTRIES.LIST>';
                                        
                                }
                                if(newQuote.IGST__c != null && newQuote.IGST__c != 0.00){
                                    String gstVal = '';
                                    if(newQuote.IGST__c == 18.00){
                                        gstVal = '18';
                                    }else if(newQuote.IGST__c == 0.10){
                                        gstVal = '0.1';
                                    }else if(newQuote.IGST__c == 28.00){
                                        gstVal = '28';
                                    }
                                    else{
                                        gstVal = String.valueOf(newQuote.IGST__c);
                                    }
                                    reqBody += '<LEDGERENTRIES.LIST>';
                                    reqBody += ' <BASICRATEOFINVOICETAX.LIST TYPE="Number">'
                                        +' <BASICRATEOFINVOICETAX>'+newQuote.IGST__c+'</BASICRATEOFINVOICETAX>'
                                        +'</BASICRATEOFINVOICETAX.LIST>'
                                        +'<ROUNDTYPE>Normal Rounding</ROUNDTYPE>'
                                        +'<LEDGERNAME>IGST '+gstVal+'%</LEDGERNAME>'
                                        +'<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>'
                                        +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                        if(newQuote.CurrencyIsoCode != 'INR' || Test.isRunningTest()){
                                            currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                            Decimal grandTotal = newQuote.IGST_Value__c;
                                            Decimal convertedAmount = 0;
                                            convertedAmount = newQuote.IGST_Value__c* currencyRate ;
                                            currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                            reqBody += '<AMOUNT>'+currencyCode +newQuote.IGST_Value__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>'
                                                    + '<VATEXPAMOUNT>'+currencyCode +newQuote.IGST_Value__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount+'</VATEXPAMOUNT>';
                                        }else{
                                            reqBody += '<AMOUNT>'+newQuote.IGST_Value__c+'</AMOUNT>'
                                            +'<VATEXPAMOUNT>'+newQuote.IGST_Value__c+'</VATEXPAMOUNT>';
                                        }
                                        reqBody += '</LEDGERENTRIES.LIST>';
                                        
                                        
                                }
                                if(newQuote.Round_Off__c != null && newQuote.Round_Off__c != 0.00){
                                    reqBody += '<LEDGERENTRIES.LIST>'
                                             +'<LEDGERNAME>Round Off</LEDGERNAME>'
                                             +'<ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>'
                                             +'<ISPARTYLEDGER>No</ISPARTYLEDGER>'
                                             +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                             if(newQuote.CurrencyIsoCode != 'INR'  || Test.isRunningTest()){
                                                 currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                                Decimal grandTotal = newQuote.Round_Off__c;
                                                Decimal convertedAmount = 0;
                                                convertedAmount = newQuote.Round_Off__c* currencyRate ;
                                                currencyRate = currencyRate.setScale(2);
                                        convertedAmount = convertedAmount.setScale(2);
                                                reqBody += '<AMOUNT>'+currencyCode +newQuote.Round_Off__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>'
                                                        + '<VATEXPAMOUNT>'+currencyCode +newQuote.Round_Off__c+' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount+'</VATEXPAMOUNT>';
                                            }else{
                                                reqBody += '<AMOUNT>'+newQuote.Round_Off__c+'</AMOUNT>'
                                                +'<VATEXPAMOUNT>'+newQuote.Round_Off__c+'</VATEXPAMOUNT>';
                                            }
                                            reqBody += '</LEDGERENTRIES.LIST>';
                                }

                                /*    ----------- Tax Ledgers-----------    */

                                if(childLineItems != null && !childLineItems .isEmpty()){
                                    for(QuoteLineItem item : childLineItems ){
                                        String Product_Name = '';
                                        String Description = '';
                                        if(item.product2.Product_Name__c != null){
                                            Product_Name = item.product2.Product_Name__c;
                                        }
                                        if(item.product2.Description != null){
                                            Description = item.product2.Description;
                                        
                                        }
                                        if(item.UnitPrice == null){
                                            item.UnitPrice = 0;
                                        }
                                        
                                        reqBody += '<ALLINVENTORYENTRIES.LIST>'
                                            +'<STOCKITEMNAME>'+item.product2.Name+'</STOCKITEMNAME>'
                                            +'<BASICUSERDESCRIPTION.LIST TYPE="String">'
                                            
                                            +'<BASICUSERDESCRIPTION>'+Product_Name+'</BASICUSERDESCRIPTION>'
                                           // +'<BASICUSERDESCRIPTION>'+Description+'</BASICUSERDESCRIPTION>'
                                            +'</BASICUSERDESCRIPTION.LIST>'
                                            +'<ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>'
                                            +'<ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>';
                                            if(newQuote.CurrencyIsoCode != 'INR' || Test.isRunningTest()){
                                                currencyCode = newQuote.CurrencyIsoCode;
                                                    
                                                Decimal grandTotal = item.TotalPrice ;
                                                Decimal convertedAmount = 0;
                                                convertedAmount = item.TotalPrice * currencyRate ;
                                                Decimal convertedRateAmount = 0;
                                                convertedRateAmount = item.UnitPrice * currencyRate ;
                                                currencyRate = currencyRate.setScale(2);
                                                convertedAmount = convertedAmount.setScale(2);
                                                convertedRateAmount = convertedRateAmount.setScale(2);
                                                reqBody += '<RATE> '+currencyCode+item.UnitPrice+' =  INR'+ convertedRateAmount +'/Nos</RATE>'
                                                        +'<AMOUNT>'+currencyCode +item.TotalPrice +' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>';
                                            }else{
                                                reqBody += '<RATE>'+ item.UnitPrice +'/Nos</RATE>'
                                                 +'<AMOUNT>'+item.TotalPrice +'</AMOUNT>';
                                            }
                                            
                                            
                                            
                                            if(item.Discount != null){
                                                reqBody += '<DISCOUNT>'+item.Discount.setScale(2)+'</DISCOUNT>';
                                            }else{
                                                reqBody += '<DISCOUNT>0</DISCOUNT>';
                                            
                                            }
                                            reqBody += '<ACTUALQTY>'+item.Quantity+' Nos</ACTUALQTY>'
                                            +'<BILLEDQTY> '+item.Quantity+' Nos</BILLEDQTY>'
                                            +'<BATCHALLOCATIONS.LIST>';
                                            if(newQuote.CurrencyIsoCode != 'INR' || Test.isRunningTest()){
                                                currencyCode = newQuote.CurrencyIsoCode;
                                                Decimal grandTotal = item.TotalPrice ;
                                                Decimal convertedAmount = 0;
                                                convertedAmount = item.TotalPrice * currencyRate ;
                                                currencyRate = currencyRate.setScale(2);
                                                convertedAmount = convertedAmount.setScale(2);
                                                reqBody += '<AMOUNT>'+currencyCode +item.TotalPrice +' @ INR'+ currencyRate +'/'+currencyCode+' = INR'+ convertedAmount +'</AMOUNT>';
                                            }else{
                                                reqBody +='<AMOUNT>'+item.TotalPrice +'</AMOUNT>';
                                            }
                                            if(item.Discount != null){
                                                reqBody += '<DISCOUNT>'+item.Discount.setScale(2)+'</DISCOUNT>';
                                            }else{
                                                reqBody += '<DISCOUNT>0</DISCOUNT>';
                                            
                                            }
                                            reqBody += '<ACTUALQTY> '+item.Quantity+' Nos</ACTUALQTY>'
                                            
                                            +'<BILLEDQTY> '+item.Quantity+' Nos</BILLEDQTY>'
                                            +'<ORDERNO>'+parentOpportunity.Order_Reference_Number__c+'</ORDERNO>'
                                            +'<ORDERDUEDATE JD="43555" P="'+dueDate+'">'+dueDate+'</ORDERDUEDATE>'
                                            //+'<GODOWNNAME>&#4; ANY</GODOWNNAME>'
                                            +'<BATCHNAME>&#4; ANY</BATCHNAME>'
                                            +'</BATCHALLOCATIONS.LIST>';
                                        if(newQuote.CGST__c != null && newQuote.SGST__c != null){
                                            reqBody += '<ACCOUNTINGALLOCATIONS.LIST>';
                                            if(newQuote.CGST__c == 9 && newQuote.SGST__c == 9){
                                                reqBody += '<LEDGERNAME>Local Sales</LEDGERNAME>';
                                            }else if(newQuote.CGST__c == 0.05 && newQuote.SGST__c == 0.05){
                                                reqBody += '<LEDGERNAME>Deemed Export Local</LEDGERNAME>';
                                            }else if(newQuote.CGST__c == 0 && newQuote.SGST__c == 0){
                                                if(newQuote.IGST__c == 18){
                                                    reqBody += '<LEDGERNAME>Interstate Sales</LEDGERNAME>';
                                                }else if(newQuote.IGST__c == 0.1){
                                                    reqBody += '<LEDGERNAME>Deemed Export Interstate</LEDGERNAME>';
                                                }else if(newQuote.IGST__c == 0){
                                                    if(newQuote.Opportunity.Account.Country_of_Residences__c == 'India'){
                                                        reqBody += '<LEDGERNAME>SEZ Sales</LEDGERNAME>';
                                                    }else{
                                                        reqBody += '<LEDGERNAME>Export Sales</LEDGERNAME>';
                                                    }
                                                }
                                            }
                                            reqBody += '<ISDEEMEDPOSITIVE>no</ISDEEMEDPOSITIVE>';
                                            if(newQuote.CurrencyIsoCode != 'INR' || Test.isRunningTest()){
                                                currencyCode = newQuote.CurrencyIsoCode;
                                                Decimal grandTotal = item.TotalPrice ;
                                                Decimal convertedAmount = 0;
                                                convertedAmount = item.TotalPrice * currencyRate ;
                                                currencyRate = currencyRate.setScale(2);
                                                convertedAmount = convertedAmount.setScale(2);
                                                reqBody += '<AMOUNT>'+currencyCode +item.TotalPrice +' @ INR'+ currencyRate +'/'+currencyCode +' = INR'+ convertedAmount +'</AMOUNT>';
                                            }else{
                                                reqBody +='<AMOUNT>'+item.TotalPrice +'</AMOUNT>';
                                            }
                                            reqBody +='</ACCOUNTINGALLOCATIONS.LIST>';
                                        }
                                        reqBody +='</ALLINVENTORYENTRIES.LIST>';
                                    }
                                }
                                    

                                reqBody += '<UDF:OADT.LIST DESC="OADt" ISLIST="YES" TYPE="Date" INDEX="5402">'
                                    +'<UDF:OADT DESC="OADt">'+OrderAckDate+'</UDF:OADT>'
                                    +'</UDF:OADT.LIST>'
                                    +'<UDF:ORDRRCVDDT.LIST DESC="OrdrRcvdDt" ISLIST="YES" TYPE="Date" INDEX="5404">'
                                    +'<UDF:ORDRRCVDDT DESC="OrdrRcvdDt">'+orderReferenceDate+'</UDF:ORDRRCVDDT>'
                                    +'</UDF:ORDRRCVDDT.LIST>'
                                    +'<UDF:OANUM.LIST DESC="OANum" ISLIST="YES" TYPE="String" INDEX="5414">'
                                    +'<UDF:OANUM DESC="OANum">'+parentOpportunity.Order_Acknowledgement_Number__c+'</UDF:OANUM>'
                                    +'</UDF:OANUM.LIST>';
                                reqBody +='</VOUCHER>'
                                    +'</TALLYMESSAGE>'
                                    +'</REQUESTDATA>'
                                    +'</IMPORTDATA>'
                                    +'</BODY>'
                                    +'</ENVELOPE>';
                                reqBody = reqBody.replaceAll('&','&amp;');
                                reqBody = reqBody.replace('&amp;#4;','&#4;');
                                
                                system.debug('string request'+reqBody);
                                req.setHeader('Content-length', ''+reqBody.length());
                                req.setTimeout(120000);
                                req.setBody(reqBody);
                                if(!Test.isRunningTest()){
                                    res = http.send(req);  
                                }else {
                                    res.setStatusCode (statusCode);
                                    res.setBody (responseBody);
                                }
                                String responseBodyBefore = res.getBody();
                                system.debug(res);
                                if (res.getStatusCode() == 200){
                                    String responseBody = res.getBody();
                                    String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                                    if(responseBody.contains('<CREATED>') && createdSuccessfully != '0'){
                                        parentOpportunity.Tally_Response__c = 'Success';
                                        update parentOpportunity;
                                        newQuote.Tally_Response__c = 'Success';
                                        update newQuote;
                                        Tally_Logs__c log = new Tally_Logs__c();
                                        log.Opportunity__c = parentOpportunity.Id;
                                        log.Request_Body__c = reqBody;
                                        log.Response_Body__c = responseBody ;
                                        insert log;
                                        return 'Success';
                                    }else if(responseBody.contains('<LINEERROR>')){                            
                                        String message = '';
                                        String  alreadyExisted = '';
                                        if(responseBody.contains('<LINEERROR>') ){
                                            alreadyExisted = responseBody.substringBetween('<LINEERROR>','</LINEERROR>');
                                        }else{
                                            alreadyExisted = responseBody;
                                        }
                                        if(alreadyExisted.contains('Voucher Number') && alreadyExisted.contains('already exists!')){
                                            alreadyExisted = 'Quote with Voucher Number '+newQuote.QuoteNumber+' already exists!';
                                            message = alreadyExisted ;
                                        }
                                        if(message != ''){
                                            parentOpportunity.Tally_Response__c = alreadyExisted ; 
                                            newQuote.Tally_Response__c = 'Success';
                                            update newQuote;
                                        }else{
                                            parentOpportunity.Tally_Response__c = 'Sync not successfull';
                                        } 
                                        Tally_Logs__c log = new Tally_Logs__c();
                                        log.Opportunity__c = parentOpportunity.Id;
                                        log.Request_Body__c = reqBody;
                                        log.Response_Body__c = responseBody ;
                                        insert log;
                                        update parentOpportunity;
                                        if(message != ''){
                                            return alreadyExisted ;
                                        }else{
                                            return 'Sync not successfull';
                                        }
                                    }else{
                                        Tally_Logs__c log = new Tally_Logs__c();
                                        log.Opportunity__c = parentOpportunity.Id;
                                        log.Request_Body__c = reqBody;
                                        log.Response_Body__c = responseBody ;
                                        insert log;
                                        parentOpportunity.Tally_Response__c = 'Altered';
                                        update parentOpportunity;
                                        return 'Altered';
                                    }
                                }else if(responseBodyBefore.contains('ERR_CONNECT_FAIL') || (res.getStatusCode() == 503)){
                                    if(!Test.isRunningTest()){
                                        req.setEndpoint(credentials.Alternative_End_Point__c);
                                        res = http.send(req); 
                                    }else {
                                        res.setStatusCode (statusCodeFor2ndEndPoint);
                                        res.setBody (responseBodyFor2ndEndPoint);
                                    }
                                    if (res.getStatusCode() == 200){
                                        String responseBody = res.getBody();
                                        String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                                        if(responseBody.contains('<CREATED>') && createdSuccessfully != '0'){
                                            parentOpportunity.Tally_Response__c = 'Success';
                                            update parentOpportunity;
                                            newQuote.Tally_Response__c = 'Success';
                                            update newQuote;
                                            Tally_Logs__c log = new Tally_Logs__c();
                                            log.Opportunity__c = parentOpportunity.Id;
                                            log.Request_Body__c = reqBody;
                                            log.Response_Body__c = responseBody ;
                                            insert log;
                                            return 'Success';
                                        }else if(responseBody.contains('<LINEERROR>')){                            
                                            String message = '';
                                            String  alreadyExisted = responseBody.substringBetween('<LINEERROR>','</LINEERROR>');
                                            if(alreadyExisted.contains('Voucher Number') && alreadyExisted.contains('already exists!')){
                                                alreadyExisted = 'Quote with Voucher Number '+newQuote.QuoteNumber+' already exists!';
                                                message = alreadyExisted ;
                                            }
                                            if(message != ''){
                                                parentOpportunity.Tally_Response__c = alreadyExisted ; 
                                            }else{
                                                parentOpportunity.Tally_Response__c = 'Sync not successfull';
                                            } 
                                            Tally_Logs__c log = new Tally_Logs__c();
                                            log.Opportunity__c = parentOpportunity.Id;
                                            log.Request_Body__c = reqBody;
                                            log.Response_Body__c = responseBody ;
                                            insert log;
                                            update parentOpportunity;
                                            if(message != ''){
                                                return alreadyExisted ;
                                            }else{
                                                return 'Sync not successfull';
                                            }
                                        }else{
                                            
                                            Tally_Logs__c log = new Tally_Logs__c();
                                            log.Opportunity__c = parentOpportunity.Id;
                                            log.Request_Body__c = reqBody;
                                            log.Response_Body__c = responseBody ;
                                            insert log;
                                            parentOpportunity.Tally_Response__c = 'Altered';  
                                            update parentOpportunity;
                                            return 'Altered';
                                        }
                                    }else {
                                        parentOpportunity.Tally_Response__c = 'error';  
                                        Tally_Logs__c log = new Tally_Logs__c();
                                        log.Opportunity__c = parentOpportunity.Id;
                                        log.Request_Body__c = reqBody;
                                        log.Response_Body__c = res.getBody();
                                        insert log;
                                        update parentOpportunity;
                                        return 'error';
                                    }
                                }else {
                                    parentOpportunity.Tally_Response__c = 'error';  
                                    Tally_Logs__c log = new Tally_Logs__c();
                                    log.Opportunity__c = parentOpportunity.Id;
                                    log.Request_Body__c = reqBody;
                                    log.Response_Body__c = res.getBody();
                                    insert log;
                                    update parentOpportunity;
                                    return 'error';
                                }
                            }
                            catch(Exception e)
                            {
                                Tally_Logs__c log = new Tally_Logs__c();
                                log.Opportunity__c = parentOpportunity.Id;
                                log.Request_Body__c = e.getMessage();
                                insert log;
                                return 'error';
                                
                            } 
                       }else{
                           Tally_Logs__c log = new Tally_Logs__c();
                            log.Opportunity__c = parentOpportunity.Id;
                            log.Request_Body__c = isSyncedToTally ;
                            insert log;  
                            parentOpportunity.Tally_Response__c = isSyncedToTally ;
                            update parentOpportunity;  
                            return isSyncedToTally ;
                       }  
                    }else{                   
                        String addProducts = label.AddProductsToQuote;
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Opportunity__c = parentOpportunity.Id;
                        log.Request_Body__c = addProducts ;
                        insert log;  
                        parentOpportunity.Tally_Response__c = addProducts ;
                        update parentOpportunity; 
                        return addProducts ;
                    }
                }else{
                    String syncAccount = label.SyncParentAccount;
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Opportunity__c = parentOpportunity.Id;
                    log.Request_Body__c = syncAccount ;
                    insert log; 
                    parentOpportunity.Tally_Response__c = syncAccount ;  
                    update parentOpportunity;
                    return syncAccount ;                 
                }
            }else{
                String syncQuote = label.SyncQuote;
                Tally_Logs__c log = new Tally_Logs__c();
                log.Opportunity__c = parentOpportunity.Id;
                log.Request_Body__c = syncQuote ;
                insert log; 
                parentOpportunity.Tally_Response__c = syncQuote ;  
                update parentOpportunity;
                String body = '\''+parentOpportunity.Name+'\'';
                return syncQuote ;
            } 
        }else{
            return 'Tally Sync is possible Only if stage equals to Order Acknowledgement';
        }
        
    }
    public class QuoteWrapper{
        @InvocableVariable
        public Id quoteId;
        public QuoteWrapper() {
            quoteId = null;
        }
    }
    
    public static String sendStockItemToTally (Id productId){
        
        Product2 product = [SELECT Name,Tally_Response__c,HSN_Code__c,Product_Name__c  FROM Product2 Where id =: productId];
        if(product.Tally_Response__c != 'Success'){
            String mailBody = 'Product \''+product.Name+'\' failed to sync and error is below<br/>';
            try{
                
                TallyCredentials__c credentials = [SELECT End_Point__c,Alternative_End_Point__c,Company__c FROM TallyCredentials__c];                       
                
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type','text/xml');
                req.setEndpoint(credentials.End_Point__c);
                String HSN_Code = '';
                String Product_Name = '';
                if(product.HSN_Code__c != null){
                    HSN_Code = product.HSN_Code__c;
                }
                if(product.Product_Name__c != null){
                     Product_Name = product.Product_Name__c;   
                }
                String reqBody = ''; 
                reqBody += '<ENVELOPE>'
                    +'<HEADER>'
                    +'<TALLYREQUEST>Import Data</TALLYREQUEST>'
                    +'</HEADER>'
                    +'<BODY>'
                    +'<IMPORTDATA>'
                    +'<REQUESTDESC>'
                    +'<REPORTNAME>All Masters</REPORTNAME>'
                    +'<STATICVARIABLES>'
                    +'<SVCURRENTCOMPANY>Sude Engineering Corporation-22-23</SVCURRENTCOMPANY>'       
                    +'</STATICVARIABLES>'
                    +'</REQUESTDESC>'
                    +'<REQUESTDATA>'
                    +'<TALLYMESSAGE xmlns:UDF="TallyUDF">'
                    +'<STOCKITEM Action = "Create">'
                    +'<Name>'+product.Name+'</Name>'
                    +'<PARENT>FINISHED GOODS</PARENT>'
                    +'<Description>'+Product_Name+'</Description>'
                    +'<GSTAPPLICABLE>&amp;#4; Applicable</GSTAPPLICABLE>'
                    +'<GSTTYPEOFSUPPLY>Goods</GSTTYPEOFSUPPLY>'
                    +'<COSTINGMETHOD>FIFO</COSTINGMETHOD>'
                    +'<VALUATIONMETHOD>Std. Price</VALUATIONMETHOD>'
                    +'<BASEUNITS>NOS</BASEUNITS>'
                    +'<ISBATCHWISEON>Yes</ISBATCHWISEON>'
                    +'<DENOMINATOR> 1</DENOMINATOR>'
                    +'<RATEOFVAT>0</RATEOFVAT>'
                    +'<GSTDETAILS.LIST>'
                    +'<APPLICABLEFROM>20170701</APPLICABLEFROM>'
                    +'<CALCULATIONTYPE>On Value</CALCULATIONTYPE>'
                    +'<HSNCODE>'+HSN_Code +'</HSNCODE>'
                    +'<HSNMASTERNAME/>'
                    +'<HSN>'+HSN_Code +'</HSN>'
                    +'<TAXABILITY>Taxable</TAXABILITY>'
                    +'<ISREVERSECHARGEAPPLICABLE>No</ISREVERSECHARGEAPPLICABLE>'
                    +'<ISNONGSTGOODS>No</ISNONGSTGOODS>'
                    +'<GSTINELIGIBLEITC>No</GSTINELIGIBLEITC>'
                    +'<INCLUDEEXPFORSLABCALC>No</INCLUDEEXPFORSLABCALC>'
                    +'<STATEWISEDETAILS.LIST>'
                    +'<STATENAME>&amp;#4; Any</STATENAME>'
                    +'<RATEDETAILS.LIST>'
                    +'<GSTRATEDUTYHEAD>Central Tax</GSTRATEDUTYHEAD>'
                    +'<GSTRATEVALUATIONTYPE>Based on Value</GSTRATEVALUATIONTYPE>'
                    +'<GSTRATE> 9</GSTRATE>'
                    +'</RATEDETAILS.LIST>'
                    +'<RATEDETAILS.LIST>'
                    +'<GSTRATEDUTYHEAD>State Tax</GSTRATEDUTYHEAD>'
                    +'<GSTRATEVALUATIONTYPE>Based on Value</GSTRATEVALUATIONTYPE>'
                    +'<GSTRATE> 9</GSTRATE>'
                    +'</RATEDETAILS.LIST>'
                    +'<RATEDETAILS.LIST>'
                    +'<GSTRATEDUTYHEAD>Integrated Tax</GSTRATEDUTYHEAD>'
                    +'<GSTRATEVALUATIONTYPE>Based on Value</GSTRATEVALUATIONTYPE>'
                    +'<GSTRATE> 18</GSTRATE>'
                    +'</RATEDETAILS.LIST>'
                    +'<RATEDETAILS.LIST>'
                    +'<GSTRATEDUTYHEAD>Cess</GSTRATEDUTYHEAD>'
                    +'<GSTRATEVALUATIONTYPE>Based on Value</GSTRATEVALUATIONTYPE>'
                    +'</RATEDETAILS.LIST>'
                    +'<GSTSLABRATES.LIST>'
                    +'</GSTSLABRATES.LIST>'
                    +'</STATEWISEDETAILS.LIST>'
                    +'<TEMPGSTDETAILSLABRATES.LIST>'
                    +'</TEMPGSTDETAILSLABRATES.LIST>'
                    +'</GSTDETAILS.LIST>'
                    +'<LANGUAGENAME.LIST>'
                    +'<NAME.LIST TYPE="String">'
                    +'<NAME>'+product.Name+'</NAME>'
                    +'</NAME.LIST>'
                    +'<LANGUAGEID> 1033</LANGUAGEID>'
                    +'</LANGUAGENAME.LIST>'
                    +'</STOCKITEM>'
                    +'</TALLYMESSAGE>'
                    +'</REQUESTDATA>'
                    +'</IMPORTDATA>'
                    +'</BODY>'
                    +'</ENVELOPE>';
                //reqBody = reqBody.replaceAll('&','&amp;');
                reqBody = reqBody.replace('&amp;#4;','&#4;');
                system.debug('string request'+reqBody);
                req.setHeader('Content-length', ''+reqBody.length());
                req.setTimeout(120000);
                req.setBody(reqBody);
                if(!Test.isRunningTest()){
                    res = http.send(req); 
                }else {
                    res.setStatusCode (statusCode);
                    res.setBody (responseBody);
                }
                system.debug(res);
                String responseBodyBefore = res.getBody();
                if (res.getStatusCode() == 200){
                    String success = 'Request Successful '+res.getStatus()+' Body: '+res.getBody();
                    String responseBody = res.getBody();
                    String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                    if(responseBody.contains('<CREATED>') && createdSuccessfully != '0'){
                        product.Tally_Response__c = 'Success'; 
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Product__c = product.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        insert log;
                        
                    }else{
                        String  alreadyExisted = '';
                        if(responseBody.contains('<LINEERROR>') ){
                            alreadyExisted = responseBody.substringBetween('<LINEERROR>','</LINEERROR>');
                        }else{
                            alreadyExisted = responseBody;
                        }
                        if(alreadyExisted.contains('already exists!')){
                            alreadyExisted = account.Name + ' already exists!';
                        }
                        product.Tally_Response__c = String.escapeSingleQuotes(alreadyExisted) ;  
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Product__c = Product.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        insert log;
                    }
                }else if(responseBodyBefore.contains('ERR_CONNECT_FAIL') || (res.getStatusCode() == 503)){
                    if(!Test.isRunningTest()){
                        req.setEndpoint(credentials.Alternative_End_Point__c);
                        res = http.send(req); 
                    }else {
                        res.setStatusCode (statusCodeFor2ndEndPoint);
                        res.setBody (responseBodyFor2ndEndPoint);
                    }
                    if (res.getStatusCode() == 200){
                        String success = 'Request Successful '+res.getStatus()+' Body: '+res.getBody();
                        String responseBody = res.getBody();
                        String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                        if(responseBody.contains('<CREATED>') && createdSuccessfully != '0'){
                            product.Tally_Response__c = 'Success'; 
                            Tally_Logs__c log = new Tally_Logs__c();
                            log.Product__c = Product.Id;
                            log.Request_Body__c = reqBody;
                            log.Response_Body__c = res.getBody();
                            insert log;
                            
                        }else{
                            System.debug(responseBody+'responseBody');
                            
                            String  alreadyExisted = '';
                            if(responseBody.contains('<LINEERROR>') ){
                                alreadyExisted = responseBody.substringBetween('<LINEERROR>','</LINEERROR>');
                            }else{
                                alreadyExisted = responseBody;
                            }
                            System.debug(alreadyExisted +'alreadyExisted ');
                            if(alreadyExisted.contains('already exists!')){
                                System.debug(alreadyExisted +'alreadyExisted ');
                                alreadyExisted = Product.Name + ' already exists!';
                            }
                            product.Tally_Response__c = String.escapeSingleQuotes(alreadyExisted) ;  
                            Tally_Logs__c log = new Tally_Logs__c();
                            log.Product__c = Product.Id;
                            log.Request_Body__c = reqBody;
                            log.Response_Body__c = res.getBody();
                            insert log;
                        }
                    }else{
                        product.Tally_Response__c = 'Error';  
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Product__c = Product.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        insert log;
                        
                    }
                }else{
                    product.Tally_Response__c = 'Error';  
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.product__c = Product.Id;
                    log.Request_Body__c = reqBody;
                    log.Response_Body__c = res.getBody();
                    insert log;
                    
                }
                update product;
                return product.Tally_Response__c;
            }catch(Exception e){
                System.debug(e.getLineNumber()+e.getMessage());
                Tally_Logs__c log = new Tally_Logs__c();
                log.Product__c = Product.Id;
                log.Request_Body__c = e.getMessage();
                insert log;
                return 'Error';
            }
        }
        return 'Product already synced to tally';
    }
    
}