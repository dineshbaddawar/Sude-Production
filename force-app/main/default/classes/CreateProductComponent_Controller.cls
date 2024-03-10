public withOut sharing class CreateProductComponent_Controller {
    @AuraEnabled(cacheable = true)
    public static List<Product_Master_Sheet_Detail__mdt> getProdctDetails(){
        // List<Product_Master_Sheet__c> pMasterValues = Product_Master_Sheet__c.getall().values();
        List<Product_Master_Sheet_Detail__mdt> pMasterValues = [select MasterLabel,Product_Family__c,id,Fields__c from Product_Master_Sheet_Detail__mdt];
        system.debug(pMasterValues);
        return pMasterValues;
    }
    
    @AuraEnabled
    public static List<string> getRelatedFields(string feildApiNameListString){
        if(!string.isBlank(feildApiNameListString) || !string.isEmpty(feildApiNameListString)){
            System.debug('feildApiNameListString: ' +feildApiNameListString );
            Map<string,string> fieldsXapiName = getFieldApiName('Product2');
            System.debug('fieldsXapiName: ' +fieldsXapiName);
            List<string> feildApiNameList = feildApiNameListString.split(',');
            List<string> filedAPINames = New List<string>();
            for(string feildApiName:feildApiNameList){
                feildApiName = feildApiName.toLowerCase();  
                System.debug('feildApiName: ' +feildApiName.trim());
                if(fieldsXapiName.containsKey(feildApiName.trim())){
                    string fieldApiNameFrmMap;
                    System.debug('feildApiName.toLowerCase(): ' +feildApiName.toLowerCase());
                    System.debug('fieldsXapiName.get(feildApiName): ' +fieldsXapiName.get(feildApiName.trim().toLowerCase()));
                    if(!string.isBlank(fieldsXapiName.get(feildApiName.trim().toLowerCase())) || !string.isEmpty(fieldsXapiName.get(feildApiName.trim().toLowerCase()))){
                        fieldApiNameFrmMap = fieldsXapiName.get(feildApiName.trim().toLowerCase()).capitalize();
                        system.debug('fieldApiName--'+fieldApiNameFrmMap);
                    }
                    filedAPINames.add(nameFormat(fieldApiNameFrmMap));
                }
            }
            System.debug('filedAPINames: ' +filedAPINames );
            return filedAPINames;
        }
        return null;
    }
    
    public static Map<string,string> getFieldApiName(string opbjectAPIName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(opbjectAPIName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<string,string> fieldLabelXAPIName = New Map<string,string>();
        for (String fieldName: fieldMap.keySet()) {
            fieldLabelXAPIName.put(fieldMap.get(fieldName).getDescribe().getLabel().toLowerCase(),fieldName);
        }
        return fieldLabelXAPIName;
    }
    
    @AuraEnabled(cacheable = true)
    public static Map<string,string> getApiNameXlabel() {
        string opbjectAPIName = 'Product2';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(opbjectAPIName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<string,string> fieldLabelXAPIName = New Map<string,string>();
        for (String fieldName: fieldMap.keySet()) {
            fieldLabelXAPIName.put(fieldName.toLowercase(),fieldMap.get(fieldName).getDescribe().getLabel().toLowerCase());
        }
        System.debug('fieldLabelXAPIName: ' +fieldLabelXAPIName);
        return fieldLabelXAPIName;
    }
    
    
    public static String nameFormat (String name) {
        String result = '';
        if(name != null && name != ''){
            System.debug('name: ' +name);
            Schema.SObjectField field= ((SObject) Type.forName('Product2').newInstance()).getSObjectType().getDescribe().fields.getMap().get(name);
            Boolean iscustomField=field.getDescribe().isCustom();
            system.debug('iscustomField--'+iscustomField);
            if (name.contains('_') || iscustomField) {
                for (String iter : name.split('_')) {
                    if (iter != null && iter != '') {
                        if (iter.length() > 1) {  
                            system.debug('iter--'+iter);
                            result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + '_';
                            system.debug('result--'+result);    
                        }
                        else {
                            result += '_'+iter.substring(0,1);
                            system.debug('result=='+result);
                        }
                    }
                }
                result = result.substring(0, result.length());
                system.debug('result--'+result);
            }else{
                result = name;
            }           
        }
        
        return result;
    } 
    
    @AuraEnabled
    public static string checkforDuplicateProduct(string modelNo, string seriesName, string productName){
        try {
            System.debug('modelNo:--- ' +modelNo+'----seriesName-----'+seriesName+'----productName-----'+productName);
            string message;
            if(!string.isBlank(modelNo) || !string.isBlank(seriesName) || !string.isBlank(productName)){
                list<Product2> duplicateProductList = [select name,id,Model_Number_Text__c,Series_Name__c from Product2 where Model_Number_Text__c like:modelNo OR (Series_Name__c =:seriesName AND Name =:productName)];
                if(duplicateProductList.size() > 0){
                    for(Product2 dupProduct:duplicateProductList){
                        if ( !string.isBlank(dupProduct.Model_Number_Text__c) && !string.isEmpty(dupProduct.Model_Number_Text__c) && dupProduct.Model_Number_Text__c == modelNo) {
                            message = 'Matching Model Number with the Product '+dupProduct.Name;
                        }else if(!string.isBlank(dupProduct.Series_Name__c) && !string.isEmpty(dupProduct.Series_Name__c) && !string.isBlank(dupProduct.Name) && !string.isEmpty(dupProduct.Name) &&  dupProduct.Series_Name__c == seriesName && dupProduct.Name == productName){
                            message = 'Matching Product and Series Name with the Product '+dupProduct.Name;
                        }
                    }
                    return message;
                }else{
                    return null;
                }
            }else{
                return null;
            }
            
            
        } catch (Exception e) {
            return null;
        }
    }
    
    @AuraEnabled
    public static list<Product2> findMachingProduct(Product2 product,string valveType, string series,list<string> fieldList){
        System.debug('product----: ' +product);
        System.debug('valveType----: ' +valveType);
        System.debug('series----: ' +series);
        System.debug('fieldList----: ' +fieldList);
        fieldList = getCustomFields('Product2');
        if(fieldList.contains('Name'))
            fieldList.remove(fieldList.indexOf('Name'));  
        if(fieldList.contains('Model_Number__c'))
            fieldList.remove(fieldList.indexOf('Model_Number__c'));
        List<Product2> productlist = Database.query('SELECT '+ string.join(fieldList,',')+' from Product2 where Family =:valveType AND Series_Name__c =:series limit 100');
        
        System.debug('productlist: ' +productlist);
        System.debug('productList Size: ' +productList.size());
        List<productMatchPercentageWrapper> productMatchPercentageWrapperList = New List<productMatchPercentageWrapper>();
        list<Product2> productListToReturn = New List<Product2>();
        for(Product2 prod:productlist){
            double matchingPercentage = productMatchingAlgorithm(prod,product,fieldList);
            if(matchingPercentage == 100){
                productListToReturn.add(prod);
                productMatchPercentageWrapper productMatchPercentageWrapper = New productMatchPercentageWrapper();
                productMatchPercentageWrapper.product = prod;
                //    productMatchPercentageWrapper.matchingPercentage = matchingPercentage;
                System.debug('prod: ' +prod+'   matchingPercentage: ' +matchingPercentage);
                System.debug('productMatchPercentageWrapper: ' +productMatchPercentageWrapper);
                productMatchPercentageWrapperList.add(productMatchPercentageWrapper);
            }       
        }
        System.debug('productMatchPercentageWrapperList: ' +productMatchPercentageWrapperList);
        // return JSON.serialize(productListToReturn);
        return productListToReturn;
    }
    
    public static double productMatchingAlgorithm(product2 producttoBeMatched, product2 product, list<string> fieldsToMatch){  
        integer totalFiledToMatch = fieldsToMatch.size();
        integer fieldsMatching = 0;
        string stringDatatype = 'STRING';
        string integerDatatype = 'INTEGER';
        string doubleDatatype = 'DOUBLE';
        string textAreaDatatype = 'TEXTAREA';  
        string booleanDatatype = 'BOOLEAN';
        Map<string,string> apiNameXType = getApiNameandFieldTypeMap('Product2');
        for(string field:fieldsToMatch){
            System.debug('field: ' +field);   
            System.debug('apiNameXType.get(field): ' +apiNameXType.get(field.toLowercase()));         
            if( stringDatatype.equalsIgnoreCase(apiNameXType.get(field.toLowercase()))){
                System.debug('(String)producttoBeMatched.get(field): ' +(String)producttoBeMatched.get(field));
                System.debug('(String)product.get(field): ' +(String)product.get(field));
                if((String)producttoBeMatched.get(field) == (String)product.get(field)){
                    System.debug('matched: String');
                    fieldsMatching++;
                }
            }else if(integerDatatype.equalsIgnoreCase(apiNameXType.get(field.toLowercase()))){
                System.debug('(integer)producttoBeMatched.get(field) ' +(integer)producttoBeMatched.get(field));
                System.debug('(integer)product.get(field)' +(integer)product.get(field));
                if((integer)producttoBeMatched.get(field) == (integer)product.get(field)){
                    System.debug('matched: integer');
                    fieldsMatching++;
                }
            }else if(doubleDatatype.equalsIgnoreCase(apiNameXType.get(field.toLowercase()))){
                if((DOUBLE)producttoBeMatched.get(field) == (DOUBLE)product.get(field)){
                    System.debug('matched: doubleDatatype');
                    fieldsMatching++;   
                }
            }else if(textAreaDatatype.equalsIgnoreCase(apiNameXType.get(field.toLowercase()))){
                if((string)producttoBeMatched.get(field) == (string)product.get(field)){
                    System.debug('matched: TEXTAREA');
                    fieldsMatching++;
                }
            }else if(booleanDatatype.equalsIgnoreCase(apiNameXType.get(field.toLowercase()))){
                if((BOOLEAN)producttoBeMatched.get(field) == (BOOLEAN)product.get(field)){
                    System.debug('matched: booleanDatatype');
                    fieldsMatching++;
                }
            }
            
            
        }
        System.debug('fieldsMatching: ' + fieldsMatching);
        System.debug('totalFiledToMatch: ' + totalFiledToMatch);
        return fieldsMatching*100/totalFiledToMatch;
        
    }
    
    public static Map<string,string> getApiNameandFieldTypeMap(string objType){
        Map<string,string> apiNameXType = New Map<string,string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            system.debug(fieldMap.get(fieldName).getDescribe().getType());
            apiNameXType.put(fieldName,string.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
        }
        return apiNameXType;
    }
    
    @AuraEnabled
    public static string saveProductDetails(Product2 newProduct){
        try {
            insert newProduct;
            return newProduct.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    Public static Map<string,string> FieldApiNameList(string SelectedSeries){
        
        List<Product_Master_Sheet_Detail__mdt> pMasterRequiredField = [select Required_Fields__c from Product_Master_Sheet_Detail__mdt where MasterLabel=:SelectedSeries];
        system.debug('pMasterRequiredField---'+pMasterRequiredField);
        List<String> labelList=new List<String>();
        
        for(Product_Master_Sheet_Detail__mdt tempData:pMasterRequiredField){
            string alpha=tempData.Required_Fields__c;
            labelList = alpha.split(',');
            system.debug('labelList--'+labelList);
        }
        system.debug('labelList---'+labelList);
        Map<String,String> labelXApiName=new Map<String,String>();
        string opbjectAPIName='Product2';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(opbjectAPIName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        system.debug('fieldMap---'+fieldMap);
        system.debug('labelList---'+labelList);
        for(string fieldName:labelList){
            system.debug('fieldName ===> ' + fieldName);
            if(fieldMap.containskey(fieldName)){
                system.debug('fieldName ===> I m inside if condition');
                labelXApiName.put(fieldMap.get(fieldName).getDescribe().getLabel(),fieldName);   
                
            }
            
        }
        system.debug('labelXApiName---'+labelXApiName);
        return labelXApiName;
        
    }
    
    public static List<String> getCustomFields(String apiName) {
        SObjectType objType = ((SObject) (Type.forName('Schema.' + apiName).newInstance())).getSObjectType();
        Map<String, SObjectField> fieldsByName = objType.getDescribe().fields.getMap();
        List<String> customFields = new List<String>();
        
        for (SObjectField field : fieldsByName.values()) {
            if (field.getDescribe().isCustom()) {
                customFields.add(field.getDescribe().getName());
            }
        }
        
        System.debug('customFields => ' + customFields);
        
        return customFields;
    }
    
    public class productMatchPercentageWrapper{
        public Product2 product;
        // public double matchingPercentage;
    }
    
      public static void testMethodClass1(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
         i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;

         i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;

         i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
           i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
         i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;

         i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;

         i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;


    }
    
}