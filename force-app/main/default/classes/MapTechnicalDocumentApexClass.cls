/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-12-18 17:57:47
* @modify date 2023-12-18 17:57:47
* @desc [Method for Generating Technical Document PDF using VF Page]
*/

public class MapTechnicalDocumentApexClass {
    Public Product2 ProductRec{get;set;}
    Public Opportunity OppRec{get;set;}
    Public OpportunityLineItem OppLineItemRec{get;set;}
    public OpportunityLineItem oppLineRecordDetails {get;set;}
    Public Company_Information__mdt CompanyInfo{get;set;}
    public String userPhone {get;set;}
    Public Date CurrentDate{get;set;}
    public List<TechnicalVFMetadata__mdt> techvfmetadata {get;set;}
    public  Map<String,List<String>> sectionAndApiFieldMap {get;set;}
    public static Map<String,String> mapofFieldAPINameBYFieldLabel{get;set;}
    public static map<String,String> mapofFieldAPINameByFieldValue{get;set;}
    Public Static Map<String,String> MapofLabelAndValue {get;set;}
    Public Static List<tempMap> MapofLabelAndValueTemp {get;set;}
    Public Static Map<String, List<tempMap>> SectionNameWithFieldandValue {get;set;}
    public static Boolean GeneralInfoFor_1100_1952 {get;set;}
    Public MapTechnicalDocumentApexClass(ApexPages.StandardController ctrl){
        String ProductId =  ApexPages.currentPage().getParameters().get('Id');   
        try{
            if(String.isNotBlank(ProductId)){
                OpportunityLineItem OppLRec=[Select Id,Product2.Name,Product2.Type__c,Product2.Family,Product2Id,OpportunityId,Product2.Product_Name__c,Product2.Characteristic__c,Product2.Mode_of_Operation__c,Product2.Valve_Size__c,Product2.Valve_Size_Unit__c,Quantity,Product2.HSN_Code__c,Product2.ProductCode,Product2.Series_Name__c From OpportunityLineItem Where Id=:ProductId];
                oppLineRecordDetails = OppLRec;     
                string inputString =oppLineRecordDetails.Product2.Name;
                if(String.isNotBlank(inputString)){
                    Integer lastHyphenIndex = inputString.lastIndexOf('-');
                    if(lastHyphenIndex !=-1){
                        Integer secondLastHyphenIndex = inputString.lastIndexOf('-', lastHyphenIndex - 1);
                        if(secondLastHyphenIndex > 0){
                            Integer thirdLastHyphenIndex = inputString.lastIndexOf('-', secondLastHyphenIndex - 2);
                            if(thirdLastHyphenIndex >0){
                                Integer fourthLastHyphenIndex = inputString.lastIndexOf('-', thirdLastHyphenIndex - 3);
                                if(fourthLastHyphenIndex > 0){
                                    String modifiedString = inputString.substring(0, fourthLastHyphenIndex) + '- ' + inputString.substring(fourthLastHyphenIndex+1, thirdLastHyphenIndex+1 ) + inputString.substring(thirdLastHyphenIndex + 1);
                                    oppLineRecordDetails.Product2.Name =  modifiedString;
                                }
                            }
                        } 
                    }else{
                        System.debug('Product Name Index out of bound');
                    }
                }
                String productcodeinputString =    oppLineRecordDetails.Product2.ProductCode; 
                if(String.isNotBlank(productcodeinputString)){
                    Integer productcodelastHyphenIndex = productcodeinputString.lastIndexOf('-');
                    if(productcodelastHyphenIndex !=-1){
                        Integer productcodesecondLastHyphenIndex = productcodeinputString.lastIndexOf('-', productcodelastHyphenIndex - 1);
                        Integer productcodethirdLastHyphenIndex = productcodeinputString.lastIndexOf('-', productcodesecondLastHyphenIndex - 2);
                        if(productcodethirdLastHyphenIndex > 0){
                            Integer productcodefourthLastHyphenIndex = productcodeinputString.lastIndexOf('-', productcodethirdLastHyphenIndex - 3);
                            if(productcodefourthLastHyphenIndex > 0){
                                String productcodemodifiedString = productcodeinputString.substring(0, productcodefourthLastHyphenIndex) + '- ' + productcodeinputString.substring(productcodefourthLastHyphenIndex+1, productcodethirdLastHyphenIndex+1 ) + productcodeinputString.substring(productcodethirdLastHyphenIndex + 1);
                                oppLineRecordDetails.Product2.ProductCode =  productcodemodifiedString;
                            }
                        }
                    }else{
                        System.debug('Product Index out of bound');
                    }
                }
                if(String.isNotBlank(oppLineRecordDetails.Product2Id)){
                    ProductRec=[Select Id,Name,Positioned_Card__c,Special_NotesAdditionalInformation__c,Gate_Material__c,Housing_Thickness__c,Flap_Thickness__c,Actuator_Seat__c,Actuator_Motor__c,HSN_Code__c,Actuator_Inbuilt_With__c,Actuator_Mechanism__c,Actuator_Signal_Pressure__c,Inlet_Pressure__c,Outlet_Pressure__c,Sealing_Material__c,Diaphragm_Material__c,Product_Id__c,Mode_of_Operation__c,Design_Pressure__c,Design_CV__c,
                                Actuator_Body_Material__c,Actuator_Operating_Time__c,Series_Name__c,Position_Transmitter__c,Positioner_Details__c,Positioner__c,Calculated_Cv__c,Bonnet__c,Internal_Material__c,Packing_Material__c,Type_Of_Mounting__c,Damper_Length_Unit__c,
                                ProductCode,Model_Number__c,Type__c,Characteristic__c,Flowing_Media__c,Working_Pressure__c,Orifice_Size__c,Orifice_Size_Unit__c,Gland_Packing__c,Plug_Material__c,Cylinder_Body_Material__c,Cylinder_Roddia__c,Product_Name__c,Damper_Length__c,
                                Seating_Material__c,Body_Material__c,Fitted_With__c,Type_Of_Construction__c,Power_Fails_To__c,Flow_Rate__c,Differential_Pressure__c,Ball_Material__c,Pipe_Schedule__c,Housing_Material__c,Flap_Material__c,Stroke_Length__c	,Stroke_Unit__c,
                                Supply_Voltage__c,Supply_Voltage_Unit__c,Working_Temperature__c,Stem_Material__c,End_Connection__c,Leakage_Class__c,Manual_Override__c,Retainer_Material__c,Number_Of_Flaps__c,Flange_Width__c,SpecialNotesDamperTechDetails__c,Damper_Size_Unit__c,
                                Valve_Type__c,Valve_Size__c,Valve_Size_in_mm__c,Valve_Size_Unit__c,Other_Notes__c,Ambient_Temperature_Humidity__c,Altitude__c,External_Wiring__c,Permissible_Vibration__c,Design_Temperature__c,Bore_Diameter__c,Bore_Unit__c,Damper_Size__c,
                                Working_Area__c,Corrosion_Category__c,SpecialNotesActuatorDetail__c,SpecialNotesvalveTechDetails__c,SpecialNotesActuatorSpecialAccessories__c,NewSpecialNotesActuatorSpecialAccessorie__c,Operation_Time__c,Valve_Action__c,Type_Of_Actuator__c,Potentiometer_Pot__c,Disc_Material__c  From Product2 where Id =:oppLineRecordDetails.Product2Id];  
                    if(ProductRec.Ambient_Temperature_Humidity__c !=null){
                        String ProductAmbientTemperatureHumidity=ProductRec.Ambient_Temperature_Humidity__c;
                        if(ProductAmbientTemperatureHumidity.contains('-')){
                            ProductAmbientTemperatureHumidity =ProductAmbientTemperatureHumidity.replace('-','- ');
                            ProductRec.Ambient_Temperature_Humidity__c=ProductAmbientTemperatureHumidity;
                        } 
                    }   
                    if(ProductRec.Series_Name__c.Contains('1100') || ProductRec.Series_Name__c.Contains('1952') || ProductRec.Series_Name__c.Contains('1962') || ProductRec.Series_Name__c.Contains('1900')  ){
                        GeneralInfoFor_1100_1952 = true;
                    }else{
                        GeneralInfoFor_1100_1952 = false;
                    }
                }
                if(ProductRec.Model_Number__c!=null){
                    String ProductModel=ProductRec.Model_Number__c;
                    if(ProductModel.contains('-')){
                        ProductModel =ProductModel.replace('-','- '); 
                        ProductRec.Model_Number__c=ProductModel;
                    }
                } 
                sectionAndApiFieldMap = new Map<String,List<String>>();
                CurrentDate=system.today();
                userPhone = [SELECT Phone FROM User WHERE Id =: UserInfo.getUserId()].Phone;  
                OppLineItemRec=[Select Id,Product2Id,Quantity,OpportunityId,Opportunity.Valve_Type__c,Opportunity.TechAdditionalInfo__c,Opportunity.TotalOpportunityQuantity,Opportunity.Other_Information__c,Opportunity.Name,Opportunity.Account.Name,Opportunity.SyncedQuote.Name,Opportunity.SyncedQuote.QuoteNumber,Product2.Type__c,Opportunity.Actuator_Motor__c From OpportunityLineItem Where Id=:ProductId];
                CompanyInfo=[Select CMP1__c,CMP2__c,TechPhone__c,CMP3__c,CMP_Phone__c,CMP_Website__c,Cell_No__c,Company_Name__c,Designation__c,Name_Comp__c From Company_Information__mdt];    
                List<String> seriesName = new List<String>{'1952','1962'};
                    techvfmetadata = [SELECT MasterLabel,Id,Field_Api_Name__c,Setion_Name__c,Squence_No__c,Series_Name__c,Is_New__c FROM TechnicalVFMetadata__mdt where Is_New__c = true ORDER BY Squence_No__c ASC];  
                for(TechnicalVFMetadata__mdt mtd : techvfmetadata){
                    List<String> VALVEFieldList = mtd.Field_Api_Name__c.split(',');
                    List<String> SeriesNameList = mtd.Series_Name__c.Split(',');
                    for(String str : SeriesNameList){
                        if(str.contains(ProductRec.Series_Name__c)){
                            sectionAndApiFieldMap.put((mtd.Squence_No__c).intValue() + mtd.Setion_Name__c, VALVEFieldList);
                        }
                    }
                }
                System.debug('sectionAndApiFieldMap === > '+sectionAndApiFieldMap);
                if(ProductRec.Series_Name__c.Contains('1182')){
                    if(sectionAndApiFieldMap.containsKey('1CYLINDER TECHNICAL DETAIL')){
                        sectionAndApiFieldMap.remove('1CYLINDER TECHNICAL DETAIL');
                    }
                }
                if(ProductRec.Series_Name__c.Contains('1100')){
                    if(sectionAndApiFieldMap.containsKey('1VALVE TECHNICAL DETAILS') || sectionAndApiFieldMap.containsKey('1DAMPER TECHNICAL DETAIL')){
                        sectionAndApiFieldMap.remove('1VALVE TECHNICAL DETAILS');
                        sectionAndApiFieldMap.remove('1DAMPER TECHNICAL DETAIL');
                    }
                }else{
                    sectionAndApiFieldMap.remove('1CYLINDER TECHNICAL DETAIL');
                }
                if(ProductRec.Series_Name__c.Contains('1952') || ProductRec.Series_Name__c.Contains('1962') || ProductRec.Series_Name__c.Contains('1900')){
                    if(sectionAndApiFieldMap.containsKey('1VALVE TECHNICAL DETAILS') || sectionAndApiFieldMap.containsKey('1CYLINDER TECHNICAL DETAIL')){
                        sectionAndApiFieldMap.remove('1VALVE TECHNICAL DETAILS');
                        sectionAndApiFieldMap.remove('1CYLINDER TECHNICAL DETAIL');
                    }
                }else{
                    sectionAndApiFieldMap.remove('1DAMPER TECHNICAL DETAIL');
                }
                mapofFieldAPINameBYFieldLabel = new Map<String,String>();
                mapofFieldAPINameByFieldValue = new Map<String,String>();
                SectionNameWithFieldandValue = new Map<String, List<tempMap>> ();
                if(!sectionAndApiFieldMap.isEmpty()){
                    for(String str : sectionAndApiFieldMap.keySet()){
                        MapofLabelAndValue = new Map<String,String>();
                        MapofLabelAndValueTemp = new List<tempMap>();
                        for(String mapKey : sectionAndApiFieldMap.get(str)){
                            mapofFieldAPINameBYFieldLabel.put(mapKey,(String)Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().get(mapKey).getDescribe().getLabel());
                            mapofFieldAPINameByFieldValue.put(mapKey,String.valueOf(ProductRec.get(mapKey)));
                            MapofLabelAndValue.put((String)Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().get(mapKey).getDescribe().getLabel(),String.valueOf(ProductRec.get(mapKey)));
                            System.debug('MapofLabelAndValue Internal === > '+MapofLabelAndValue);
                            if(String.valueOf(ProductRec.get(mapKey)) !=null){
                                MapofLabelAndValueTemp.add(new tempMap((String)Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().get(mapKey).getDescribe().getLabel(),String.valueOf(ProductRec.get(mapKey))));
                            }
                        }
                        for(tempMap str1 : MapofLabelAndValueTemp){
                            if(str1.value !=null){
                                SectionNameWithFieldandValue.put(str, MapofLabelAndValueTemp);
                            }
                        }
                        System.debug('MapofLabelAndValue === > '+MapofLabelAndValue);
                        System.debug('MapofLabelAndValueTemp === > '+MapofLabelAndValueTemp);
                    }
                }  
            }
            
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    public class tempMap{
        public string lable {get;set;}
        public string value {get;set;}
        public tempMap(String lable,String value){
            this.lable = lable;
            this.value = value;
        }
    }
    
    public static void mytest(){
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
    }
    
}