public class SudeBLRSheetAuraController {
    
    @AuraEnabled
    public Static String insertQuotesAttachement(String quoteId){
        try{
            Quote quo = [SELECT Id,Name FROM Quote WHERE Id =:quoteId];
            System.debug('quo :: '+quo);
            List<Attachment> attachList = new List<Attachment>();
            PageReference pdfPage = Page.SudeBLRSheet;
            pdfPage.getParameters().put('id',quoteId);
            blob pdfBody;
            if(Test.isRunningTest()){
                pdfBody = Blob.valueOf('For Test Class'); 
            }else{
                pdfBody = pdfPage.getContent();
            }
            System.debug('pdfBody === >'+pdfBody);
            Attachment attach = new Attachment(); 
            attach.Body = pdfBody;
            String var = System.now().format();
            attach.Name = 'Quote Invoice.Pdf';
            attach.IsPrivate = false; 
            attach.ParentId = quoteId;
            attach.ContentType = 'application/pdf';
            attachList.add(attach);
            if(!attachList.isEmpty()){
                insert attachList;
            }
            system.debug('attachList === >'+attachList);
            return attachList[0].Id;
        }catch(Exception e){
            System.debug('Error :: '+e.getMessage() + ' AND Line :: '+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    Public Static String getQuoteIdFormOpportunity(String recordId){
        try{
            Quote quote = new Quote();
            if(!String.isBlank(recordId)){
                quote = [SELECT Id,Name,OpportunityId FROM Quote WHERE OpportunityId =: recordId];
                if(!string.isBlank(quote.id)){
                    System.debug('Quote ID FROM Opportunity == >'+quote.Id);
                    return quote.Id;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return 'ERROR';
    }
    
    @AuraEnabled
    public Static string insertQuoteFromOpportunity(String recordId){
        try{
            List<Attachment> attachmentsToDelete = [SELECT Id FROM Attachment WHERE ParentId =: recordId and Name LIKE 'Commercial%'];
            if(!attachmentsToDelete.isEmpty()){
                delete attachmentsToDelete;
                System.debug('Attachments deleted successfully.');
            }else{
                System.debug('Cant delete Attachments.');
            }
            List<Quote> quoteList = new List<Quote>();
            List<Attachment> attachList = new List<Attachment>();
            if(!String.isBlank(recordId)){
                quoteList = [SELECT Id,Name,createdDate,OpportunityId,Opportunity.AccountId,Opportunity.Account.Name FROM Quote WHERE OpportunityId =: recordId];
                Quote firstQuote = quoteList[0];
                String formattedCreatedDate = firstQuote.createdDate.format('MMddyyyy');
                if(quoteList.size() > 0){
                    for(Quote que : quoteList){
                        PageReference pdfPage = Page.SudeBLRSheet;
                        pdfPage.getParameters().put('id',que.id);
                        blob pdfBody;
                        if(Test.isRunningTest()){
                            pdfBody = Blob.valueOf('For Test Class'); 
                        }else{
                            pdfBody = pdfPage.getContent();
                        }
                        System.debug('pdfBody :::'+pdfBody);
                        Attachment attach = new Attachment(); 
                        attach.Body = pdfBody;
                        String var = System.now().format();
                        attach.Name = 'Commercial Offer-' + quoteList[0].Opportunity.Account.Name + '-' 
                            + formattedCreatedDate + '.pdf' ;
                        attach.IsPrivate = false; 
                        attach.ParentId = recordId;
                        attach.ContentType = 'application/pdf';
                        attachList.add(attach);
                        if(!attachList.isEmpty()){
                            insert attachList;
                        }
                    }
                }
                return 'SUCCESS Attachemet Inserted === > '+String.valueOf(attachList.size());
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
}