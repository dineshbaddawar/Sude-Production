({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getQuoteIdFormOpportunity");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                if(data !=null && data !="ERROR"){
                    var label = $A.get("$Label.c.SudeBLRSheet");
                    component.set('v.siteURL',label+data);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'No Quote Found',
                        message:'Please create Quote Record First',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    SavePDF : function(component, event, helper){
        debugger;
        var action = component.get("c.insertQuoteFromOpportunity");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var result = response.getReturnValue();
                if(result !=null ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Quote Invoice PDF Generated Successfully !',
                        duration:' 6000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Something went Wrong !',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})