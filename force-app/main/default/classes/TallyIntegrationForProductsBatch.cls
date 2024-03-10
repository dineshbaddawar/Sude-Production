/* 
* @description  Batch Class is to send Products to Tally
* @author       Bigworks Team 
* @Date         03/02/2021
* @TestClass    TallyService_TC
* -----------------------------------------------------------------------
 */
public class TallyIntegrationForProductsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public TallyCredentials__c credentials = new TallyCredentials__c();
    public static String responseBody ;
    public static Integer statusCode;
    public static String responseBodyFor2ndEndPoint ;
    public static Integer statusCodeFor2ndEndPoint ;
  
    List<Product2> productsToUpdate = new List<Product2>();
    List<Tally_Logs__c> tallyLogsToInsert = new List<Tally_Logs__c>();
    public Database.QueryLocator start(Database.BatchableContext batchContext){
        credentials = [SELECT End_Point__c,Alternative_End_Point__c,Company__c FROM TallyCredentials__c];
        String dataSource = Label.Migration_Data_Source;
        return Database.getQueryLocator([SELECT Name,Tally_Response__c,HSN_Code__c,Product_Name__c FROM Product2 Where Tally_Response__c != 'Success' AND (NOT(Tally_Response__c LIKE : '%already exists!')) AND Data_Source__c =: dataSource ]);
    }
    public void execute(Database.BatchableContext batchContext, List<Product2> scope){
        for(Product2 product : scope){
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
                    +'<SVCURRENTCOMPANY>Sude Engineering Corporation-20-21</SVCURRENTCOMPANY>'       
                    +'</STATICVARIABLES>'
                    +'</REQUESTDESC>'
                    +'<REQUESTDATA>'
                    +'<TALLYMESSAGE xmlns:UDF="TallyUDF">'
                    +'<STOCKITEM Action = "Create">'
                    +'<Name>'+product.Name+'</Name>'
                    +'<Description>'+Product_Name+'</Description>'
                    +'<GSTAPPLICABLE>&#4; Applicable</GSTAPPLICABLE>'
                    +'<GSTTYPEOFSUPPLY>Goods</GSTTYPEOFSUPPLY>'
                    +'<COSTINGMETHOD>Avg. Cost</COSTINGMETHOD>'
                    +'<VALUATIONMETHOD>Avg. Price</VALUATIONMETHOD>'
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
                    +'<STATENAME>&#4; Any</STATENAME>'
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
                    product.Tally_Response__c = 'Success'; 
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Product__c = product.Id;
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
                    product.Tally_Response__c = String.escapeSingleQuotes(alreadyExisted) ;  
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Product__c = Product.Id;
                    log.Request_Body__c = reqBody;
                    log.Response_Body__c = res.getBody();
                    tallyLogsToInsert.add(log);
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
                    if(responseBody.contains('<CREATED>') && createdSuccessfully == '1'){
                        product.Tally_Response__c = 'Success'; 
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Product__c = Product.Id;
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
                            alreadyExisted = Product.Name + ' already exists!';
                        }
                        product.Tally_Response__c = String.escapeSingleQuotes(alreadyExisted) ;  
                        Tally_Logs__c log = new Tally_Logs__c();
                        log.Product__c = Product.Id;
                        log.Request_Body__c = reqBody;
                        log.Response_Body__c = res.getBody();
                        tallyLogsToInsert.add(log);
                    }
                }else{
                    product.Tally_Response__c = 'Error';  
                    Tally_Logs__c log = new Tally_Logs__c();
                    log.Product__c = Product.Id;
                    log.Request_Body__c = reqBody;
                    log.Response_Body__c = res.getBody();
                    tallyLogsToInsert.add(log);                   
                }
            }else{
                product.Tally_Response__c = 'Error';  
                Tally_Logs__c log = new Tally_Logs__c();
                log.product__c = Product.Id;
                log.Request_Body__c = reqBody;
                log.Response_Body__c = res.getBody();
                tallyLogsToInsert.add(log);               
            }
            productsToUpdate.add(product);
        }  
    }
    public void finish(Database.BatchableContext BC){
        if(!productsToUpdate.isEmpty()){
            update productsToUpdate;
        }
        if(!tallyLogsToInsert.isEmpty()){
            insert tallyLogsToInsert;
        }
    }
    
}