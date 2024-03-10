({
    doInit : function(cmp,event,helper) {
        var objName = cmp.get("v.sObjectName");
        var action = cmp.get('c.tallyServiceForQuoteAction');
        var quoteId = cmp.get('v.recordId');
        console.log('quoteId'+quoteId);
        action.setParams({"recordId":quoteId});                
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                var returnValue=  response.getReturnValue();
                console.log(returnValue);
                if(returnValue === "Success"){  
                    if(objName == 'Opportunity'){
                        objName = 'Quote';
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: objName+' Synced to tally',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    if(returnValue == 'Altered'){
                        if(objName == 'Opportunity'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success Message',
                                message: 'Altered',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message: returnValue,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }else{
                console.log('entered in else last');
                let errors = response.getError();
                console.log(errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: errors,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})