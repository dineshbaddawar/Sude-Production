/* 
* @description  Batch Class is to send Accounts to Tally
* @author       Bigworks Team 
* @Date         03/02/2021
* @TestClass    TallyService_TC
* -----------------------------------------------------------------------
*/
public class TallyIntegrationForAccountsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public TallyCredentials__c credentials = new TallyCredentials__c();
    public List<Account> accountsToUpdate = new List<Account>();
    public List<Tally_Logs__c> tallyLogsToInsert = new List<Tally_Logs__c>();
    public Map<String,Ledger_Parent__mdt> parentLedgers = new Map<String,Ledger_Parent__mdt>();
    public Static String responseBody ;
    public Static Integer statusCode;
    public static String responseBodyFor2ndEndPoint ;
    public static Integer statusCodeFor2ndEndPoint ;

    public Database.QueryLocator start(Database.BatchableContext batchContext){
        credentials = [SELECT End_Point__c,Alternative_End_Point__c,Company__c FROM TallyCredentials__c];
        for(Ledger_Parent__mdt ledgerParent : [SELECT Parent_Name__c,MasterLabel FROM Ledger_Parent__mdt]){
            parentLedgers.put(ledgerParent.MasterLabel, ledgerParent);
        }
        String dataSource = Label.Migration_Data_Source;
        return Database.getQueryLocator([SELECT Id,Ledger_Type__c,PAN_No__c,Name,BillingStreet,Vendor_code__c,GST_Number__c,owner.Name,BillingState,
                                            BillingPostalCode,BillingAddress,BillingCountry,Email__c,Tally_Response__c,
                                            Country_of_Residences__c,GST_Registration_Type__c,Phone,BillingCity,
                                            (SELECT Salutation,Name,MobilePhone FROM Contacts) 
                                            FROM Account Where Tally_Response__c != 'Success' AND 
                                            (NOT(Tally_Response__c LIKE : '%already exists!')) AND Data_Source__c =: dataSource ]);
    }
    public void execute(Database.BatchableContext batchContext, List<Account> scope){
        for(Account account : scope){
            Contact childContact = new Contact();
            if(account.Contacts != null && account.Contacts.size() > 0){
                childContact = account.Contacts[0];   
            }
            String reqBody = ''; 
            Ledger_Parent__mdt ledgerParent = new Ledger_Parent__mdt();
            if(account.Ledger_Type__c != null && parentLedgers != null && parentLedgers.containsKey(account.Ledger_Type__c)){
                ledgerParent = parentLedgers.get(account.Ledger_Type__c);
            }
            if(account.Ledger_Type__c == 'Customer Ledger'){
                reqBody = TallyService.generateCustomerLedgerXML(account,childContact,ledgerParent);
            }else if(account.Ledger_Type__c == 'Sales Ledger'){
                reqBody = TallyService.generateSalesLedgerXML(account,childContact,ledgerParent);
            }else if(account.Ledger_Type__c == 'Tax Ledger'){
                reqBody = TallyService.generateTaxLedgerXML(account,childContact,ledgerParent);
            }
            reqBody = reqBody.replaceAll('&','&amp;'); 
            
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type','text/xml');
            req.setEndpoint(credentials.End_Point__c);
            
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
            if (res.getStatusCode() == 200){
                String success = 'Request Successful '+res.getStatus()+' Body: '+res.getBody();
                String responseBody = res.getBody();
                String createdSuccessfully = responseBody.substringBetween('<CREATED>','</CREATED>');
                if(responseBody.contains('<CREATED>') && createdSuccessfully == '1'){
                    account.Tally_Response__c = 'Success'; 
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Account__c = account.Id;
                    log.Request_Body__c = reqBody;
                    log.Response_Body__c = res.getBody();
                    tallyLogsToInsert.add(log);
                    
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
                    tallyLogsToInsert.add(log);
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
                    if(responseBody.contains('<CREATED>') && createdSuccessfully == '1'){
                        account.Tally_Response__c = 'Success'; 
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Account__c = account.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        tallyLogsToInsert.add(log);
                        
                    }else{                        
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
                        tallyLogsToInsert.add(log);
                    }
                }else{
                    account.Tally_Response__c = 'Error';  
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Account__c = account.Id;
                    log.Request_Body__c = reqBody;
                    log.Response_Body__c = res.getBody();
                    tallyLogsToInsert.add(log);                    
                }
            }else{
                account.Tally_Response__c = 'Error';  
                Tally_Logs__c log = new Tally_Logs__c();
                log.Account__c = account.Id;
                log.Request_Body__c = reqBody;
                log.Response_Body__c = res.getBody();
                tallyLogsToInsert.add(log);                
            }
            accountsToUpdate.add(account);
        }
    }
    public void finish(Database.BatchableContext BC){
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
        if(!tallyLogsToInsert.isEmpty()){
            insert tallyLogsToInsert;
        }
    }
    
}