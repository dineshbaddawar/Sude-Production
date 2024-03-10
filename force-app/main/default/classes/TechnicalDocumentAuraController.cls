/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-12-18 17:57:47
* @modify date 2023-12-18 17:57:47
* @desc [Method for Generating Technical Document from Opportunity Record]
*/

public class TechnicalDocumentAuraController {
    
    @AuraEnabled
    public static void attachFileToOppLineItem(Id OppId) {
        try{
            system.debug('OppId ==>'+OppId);
            if(OppId !=null){
                List<Attachment> AttachedFiles = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId =:OppId];
                delete AttachedFiles;
                List<OpportunityLineItem> OppLineItemRec=[Select Id,Product2.Name,Product2.Product_Name__c,Product2Id,OpportunityId From OpportunityLineItem Where OpportunityId=:OppId];
                system.debug('OppLineItemRec == >'+OppLineItemRec);
                List<Attachment> attachList = new List<Attachment>();
                for(OpportunityLineItem oppLitem:OppLineItemRec){
                    callGeneratePDF(oppLitem.id);
                } 
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());  
        }
    }
    
    @future(callout=true)
    public static void callGeneratePDF(Id opplineItemId){
        try{
            system.debug('opplineItemId ===>'+opplineItemId);
            List<Attachment> attachList = new List<Attachment>();
            if(opplineItemId !=null){
                OpportunityLineItem oppLitem = [SELECT Id,Name,Product2.Product_Name__c,Product2.Model_Number__c,OpportunityId,Opportunity.Account.Name,createdDate FROM OpportunityLineItem WHERE Id=:opplineItemId];
                DateTime currentDateTime = DateTime.now();
                String formattedCurrentDate = currentDateTime.format('MMddyyyy');
                System.debug('Formatted Current Date ==> ' + formattedCurrentDate);
                
                PageReference pdfPage = Page.TechnicalMapVfPage; //   TechnicalMapVfPageUpdated
                pdfPage.getParameters().put('id',oppLitem.Id);
                blob pdfBody;
                pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Test content'));
                Attachment attach = new Attachment(); 
                attach.Body = pdfBody;
                attach.Name = 'Technical Datasheet-' + oppLitem.Opportunity.Account.Name + '-' + oppLitem.Product2.Model_Number__c + '-' + formattedCurrentDate + '.pdf';
                attach.IsPrivate = false;
                attach.ParentId = oppLitem.OpportunityId;
                attach.ContentType = 'application/pdf';
                insert attach;
                System.debug('attach Record === >'+attach);
            }   
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }  
}