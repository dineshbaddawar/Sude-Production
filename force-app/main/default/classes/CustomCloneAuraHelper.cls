/**
* @author [Dinesh Baddawar]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-04-20 17:35:38
* @modify date 2023-04-20 17:35:38
* @desc [description]
*/

public class CustomCloneAuraHelper {
    
    // Apex Class for Section Wise Data Showing Update : EDIT BUTTON
    @AuraEnabled
    Public Static Map<String,List<String>> getGetRecordDetailsBasedOnSeriesNo(String recordId){
        try{
            Product2 prodRec = new Product2();
            List<Section_SeriesWiseFieldsData__mdt> SectionWithSeriesDataList = new List<Section_SeriesWiseFieldsData__mdt>();
            Map<String,String> MapOfSection_Field = new Map<string,String>();
            List<String> SeriesNoIdSet = new List<String>();
            Map<String,List<String>> MapOfSectionName_WithFieldList = new Map<String,List<String>>();
            if(!String.isBlank(recordId)){
                prodRec = [SELECT Id,Name,Series_Name__c,Special_NotesAdditionalInformation__c,Gate_Material__c,Housing_Thickness__c,Flap_Thickness__c,Actuator_Body_Material__c,Actuator_Inbuilt_With__c,Actuator_Mechanism__c,Actuator_Motor__c,Actuator_Operating_Time__c,Actuator_Seat__c,Actuator_Signal_Pressure__c,Air_Filter_Regulator_FRL_Unit__c,Air_Lock_Relay__c,Altitude__c,Ambient_Temperature_Humidity__c,Amend_Date__c,Amount__c,Auto_Number_For_Acknowledgement__c,Ball_Material__c,Body_Material__c,Bonnet__c,Bore_Diameter__c,Bore_Unit__c,Budget_Confirmed__c,Calculated_Cv__c,Characteristic__c,Consistency__c,Corrosion_Category__c,Cylinder_Body_Material__c,Cylinder_Roddia__c,Damper_Length__c,Damper_Length_Unit__c,Damper_Size__c,Damper_Size_Unit__c,Data_Source__c,Dependent__c,Design_CV__c,Design_Pressure__c,Design_Pressure_Maximum_in_Kg_cm2__c,Design_Temperature__c,Design_Temperature_Minim_Degrees_Celcius__c,Diaphragm_Material__c,Differential_Pressure__c,Disc_Material__c,Discovery_Completed__c,End_Connection__c,External_Wiring__c,Fitted_With__c,Flange_Width__c,Flap_Material__c,Flowing_Media__c,Flowing_Media_Passing_Through_Valve__c,Flow_Rate__c,Flow_Rate_Minimum_in_m3_hour__c,Gear_Box__c,Gland_Packing__c,Has_Opportunity_been_synced_to_Tally__c,Has_Techno_Commerical_Been_Sent__c,Housing_Material__c,HSN_Code__c,Inlet_Pressure__c,Internal_Material__c,Is_Order_Acknowledged__c,Leakage__c,Leakage_Class__c,Limit_Switch_Box__c,Limit_Switch_Indicator__c,Loss_Reason__c,Manual_Override__c,Media_Phase__c,Product_Name__c,Model_Number__c,Valve_Type__c,Model_Number_Text__c,Mode_of_Operation__c,Mode_of_Operation_Sub_Type__c,Molecular_Weight__c,Number_Of_Flaps__c,Operation_Time__c,Order_Acknowledgement_Number2__c,Order_Reference_Date__c,Order_Reference_Number__c,Orifice_Size__c,Orifice_Size_Unit__c,Other_Notes__c,Outlet_Pressure__c,Packing_Material__c,Permissible_Vibration__c,Pipe_Schedule__c,Plug_Material__c,Positioner__c,Positioner_Details__c,Position_Transmitter__c,Potentiometer_Pot__c,Power_Fails_To__c,Pressure_Drop__c,Primary_Product_Interest__c,Product_Id__c,Proximity_Sensor__c,Retainer_Material__c,ROI_Analysis_Completed__c,Sealing_Material__c,Seating_Material__c,Shut_Off_Pressure__c,Sound_Level__c,Sound_Level_Unit__c,SpecialNotesActuatorDetail__c,SpecialNotesvalveTechDetails__c,Stem_Material__c,Stroke_Length__c,Stroke_Unit__c,Supplied_With__c,Supply_Voltage__c,Supply_Voltage_Unit__c,Tally_Order_Number__c,Tally_Response__c,Technical_Specifications__c,Temperator_Controller_With_PT_100_Sensor__c,Type__c,Type_Of_Actuator__c,Type_Of_Construction__c,Type_Of_Mounting__c,Valve_Action__c,Valve_Size_in_mm__c,Valve_Size__c,Valve_Size_Unit__c,Volume_Booster__c,Wall_Mounting_Control_Panel__c,Working_Area__c,Working_Pressure__c,Working_Temperature__c,Yoke__c FROM Product2 WHERE Id=:recordId];
                if(!String.isBlank(prodRec.Series_Name__c)){
                    String recordSeriesNo = prodRec.Series_Name__c;
                    SectionWithSeriesDataList = [SELECT Id,MasterLabel,Fields__c,Series_Name__c,Name_Series__c,Sequence_Order__c FROM Section_SeriesWiseFieldsData__mdt order by Sequence_Order__c];
                    if(SectionWithSeriesDataList.size()>0){
                        for(Section_SeriesWiseFieldsData__mdt str : SectionWithSeriesDataList){
                            SeriesNoIdSet = str.Name_Series__c.split(',');
                            if(SeriesNoIdSet.contains(recordSeriesNo)){
                                MapOfSectionName_WithFieldList.put(str.MasterLabel,str.Fields__c.split(','));
                            }
                        }
                        if(!MapOfSectionName_WithFieldList.isEmpty()){
                            System.debug('MapOfSectionName_WithFieldList Map Data == >'+MapOfSectionName_WithFieldList);
                            return MapOfSectionName_WithFieldList;
                        }   
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // =============================================================================================================================
    // Apex Method for Custom Clone Record : CLONE RECORD
    @AuraEnabled
    Public Static Map<String,Map<String,String>> getRecordSectionNameWihFieldApi_Value(String recordId){
        try{
            Product2 prodRec = new Product2();
            List<Section_SeriesWiseFieldsData__mdt> SectionWithSeriesDataList = new List<Section_SeriesWiseFieldsData__mdt>();
            Map<String,Map<String,String>> MapOfSection_FiedlApi_FieldValue = new Map<String,Map<String,String>>();
            Map<List<String>,List<String>> MapOfFieldApi_FieldValue = new Map<List<String>,List<String>>();
            List<String> SeriesNumberList = new List<String>();
            Map<String,String> MapOf_FieldAPI_FieldValue = new Map<String,String>();
            List<String> FieldApiNameList = new List<String>();
            Map<String,String> MapOfApiField_SectionName = new Map<String,String>();
            
            if(!String.isBlank(recordId)){
                prodRec = [SELECT Id,Name,Series_Name__c,Special_NotesAdditionalInformation__c,Positioned_Card__c,Actuator_Body_Material__c,SpecialNotesDamperTechDetails__c,SpecialNotesActuatorSpecialAccessories__c,NewSpecialNotesActuatorSpecialAccessorie__c,CurrencyIsoCode,ProductCode,Family,IsActive,Actuator_Inbuilt_With__c,Actuator_Mechanism__c,Actuator_Motor__c,Actuator_Operating_Time__c,Actuator_Seat__c,Actuator_Signal_Pressure__c,Air_Filter_Regulator_FRL_Unit__c,Air_Lock_Relay__c,Altitude__c,Ambient_Temperature_Humidity__c,Amend_Date__c,Amount__c,Auto_Number_For_Acknowledgement__c,Ball_Material__c,Body_Material__c,Bonnet__c,Bore_Diameter__c,Bore_Unit__c,Budget_Confirmed__c,Calculated_Cv__c,Characteristic__c,Consistency__c,Corrosion_Category__c,Cylinder_Body_Material__c,Cylinder_Roddia__c,Damper_Length__c,Damper_Length_Unit__c,Damper_Size__c,Damper_Size_Unit__c,Data_Source__c,Dependent__c,Design_CV__c,Design_Pressure__c,Design_Pressure_Maximum_in_Kg_cm2__c,Design_Temperature__c,Design_Temperature_Minim_Degrees_Celcius__c,Diaphragm_Material__c,Differential_Pressure__c,Disc_Material__c,Discovery_Completed__c,End_Connection__c,External_Wiring__c,Fitted_With__c,Flange_Width__c,Flap_Material__c,Flowing_Media__c,Flowing_Media_Passing_Through_Valve__c,Flow_Rate__c,Flow_Rate_Minimum_in_m3_hour__c,Gear_Box__c,Gland_Packing__c,Has_Opportunity_been_synced_to_Tally__c,Has_Techno_Commerical_Been_Sent__c,Housing_Material__c,HSN_Code__c,Inlet_Pressure__c,Internal_Material__c,Is_Order_Acknowledged__c,Leakage__c,Leakage_Class__c,Limit_Switch_Box__c,Limit_Switch_Indicator__c,Loss_Reason__c,Manual_Override__c,Media_Phase__c,Product_Name__c,Model_Number__c,Valve_Type__c,Model_Number_Text__c,Mode_of_Operation__c,Mode_of_Operation_Sub_Type__c,Molecular_Weight__c,Number_Of_Flaps__c,Operation_Time__c,Order_Acknowledgement_Number2__c,Order_Reference_Date__c,Order_Reference_Number__c,Orifice_Size__c,Orifice_Size_Unit__c,Other_Notes__c,Outlet_Pressure__c,Packing_Material__c,Permissible_Vibration__c,Pipe_Schedule__c,Plug_Material__c,Positioner__c,Positioner_Details__c,Position_Transmitter__c,Potentiometer_Pot__c,Power_Fails_To__c,Pressure_Drop__c,Primary_Product_Interest__c,Product_Id__c,Proximity_Sensor__c,Retainer_Material__c,ROI_Analysis_Completed__c,Sealing_Material__c,Seating_Material__c,Shut_Off_Pressure__c,Sound_Level__c,Sound_Level_Unit__c,SpecialNotesActuatorDetail__c,SpecialNotesvalveTechDetails__c,Stem_Material__c,Stroke_Length__c,Stroke_Unit__c,Supplied_With__c,Supply_Voltage__c,Supply_Voltage_Unit__c,Tally_Order_Number__c,Tally_Response__c,Technical_Specifications__c,Temperator_Controller_With_PT_100_Sensor__c,Type__c,Type_Of_Actuator__c,Type_Of_Construction__c,Type_Of_Mounting__c,Valve_Action__c,Valve_Size_in_mm__c,Valve_Size__c,Valve_Size_Unit__c,Volume_Booster__c,Wall_Mounting_Control_Panel__c,Working_Area__c,Working_Pressure__c,Working_Temperature__c,Yoke__c,Housing_Thickness__c,Flap_Thickness__c FROM Product2 WHERE Id=:recordId];
                System.debug('prodRec === >'+prodRec);
                if(!String.isBlank(prodRec.Series_Name__c)){
                    String SeriesNo = prodRec.Series_Name__c;
                    SectionWithSeriesDataList = [SELECT Id,MasterLabel,Fields__c,Series_Name__c,Name_Series__c,Sequence_Order__c FROM Section_SeriesWiseFieldsData__mdt order by Sequence_Order__c];
                    if(SectionWithSeriesDataList.size() > 0){
                        for(Section_SeriesWiseFieldsData__mdt mdt : SectionWithSeriesDataList){
                            SeriesNumberList = mdt.Name_Series__c.split(',');
                            if(SeriesNumberList.contains(SeriesNo)){
                                List<String> LocalFieldApiNameList = mdt.Fields__c.split(',');
                                for(String str : LocalFieldApiNameList){
                                    MapOfApiField_SectionName.put(str,mdt.MasterLabel);
                                }
                                FieldApiNameList.addall(LocalFieldApiNameList);
                            }
                        }
                    }
                }
            }
            if (!FieldApiNameList.isEmpty() && FieldApiNameList.size() >0) {                
                for (String str : FieldApiNameList) {
                    if (MapOfApiField_SectionName.containsKey(str)) {
                        string Sectionname = MapOfApiField_SectionName.get(str);
                        if (MapOfSection_FiedlApi_FieldValue.containskey(Sectionname)) {
                            map<String, string> ExistLocalmapforAPINameWithValue = new Map<String, string>();
                            ExistLocalmapforAPINameWithValue = MapOfSection_FiedlApi_FieldValue.get(Sectionname);
                            if (String.valueof(prodRec.get(str)) != null) {
                                ExistLocalmapforAPINameWithValue.put(str, String.valueof(prodRec.get(str)));                                
                            }else {
                                ExistLocalmapforAPINameWithValue.put(str, '');
                            }
                            MapOfSection_FiedlApi_FieldValue.put(Sectionname, ExistLocalmapforAPINameWithValue);
                        }else {
                            map<String, string> NewLocalmapforAPINameWithValue = new Map<String, string>();
                            if (String.valueof(prodRec.get(str)) != null) {
                                NewLocalmapforAPINameWithValue.put(str, String.valueof(prodRec.get(str)));                                
                            }else {
                                NewLocalmapforAPINameWithValue.put(str, '');
                            }   
                            MapOfSection_FiedlApi_FieldValue.put(Sectionname, NewLocalmapforAPINameWithValue);
                        }                        
                    }
                }
            }
            System.debug('MapOfSection_FiedlApi_FieldValue ====>' + MapOfSection_FiedlApi_FieldValue);
            return MapOfSection_FiedlApi_FieldValue;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    
}