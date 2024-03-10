({
    doInit : function(cmp,event,helper) {
        var action = cmp.get('c.validateSelectedOpportunity');
        var oppId = cmp.get('v.recordId');
        console.log('quoteId'+oppId);
        action.setParams({"recordId":oppId});                
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                var returnValue=  response.getReturnValue();
                console.log(returnValue);
                if(returnValue === "visible"){  
                	cmp.set("v.isVisible",true);   
                }else{
                	cmp.set("v.isVisible",false);   
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
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})