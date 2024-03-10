({
	getProductList : function(component,event,helper) {
		debugger;
        var action = component.get('c.getProductList'); 
        action.setParams({
            "OppId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
             }); 
        $A.enqueueAction(action);
	}
})