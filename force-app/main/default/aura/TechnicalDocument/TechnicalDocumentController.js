({
    doInit : function(cmp, event, helper) {
        debugger;
        var recordId = cmp.get('v.recordId');
        var action = cmp.get('c.attachFileToOppLineItem'); 
        action.setParams({
            "OppId" : recordId
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Tecnical Document Downloaded Successfully !',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                window.setTimeout(
                    function() { 
                        window.location.reload();}, 
                    500
                );   
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error message',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            console.log(state);
        }); 
        $A.enqueueAction(action);  
    }
    ,
    
})