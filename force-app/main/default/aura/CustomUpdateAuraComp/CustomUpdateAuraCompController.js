({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getGetRecordDetailsBasedOnSeriesNo");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var myMapData = response.getReturnValue();
                var myMapObject = [];
                for (var key in myMapData) {
                    myMapObject.push({ key: key, value:(myMapData)[key] });
                    //myMapObject[key] = myMapData[key];
                }
                component.set("v.myMap", myMapObject);
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });
        $A.enqueueAction(action);
    },

    handleOnSuccess: function (component, event, helper) { 
		debugger;
		var params = event.getParams(); 
		var recordId = params.response.id;
		if (recordId != null) {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
			    title : 'SUCCESS',
			    message: 'Product Updated Successfully !',
			    duration:' 5000',
			    key: 'info_alt',
			    type: 'success',
			    mode: 'pester'
			});
			toastEvent.fire();
			window.location.href='/lightning/r/Product2/'+recordId+'/view';
		}

	},

	handleError: function (cmp, event, helper) {
		alert("ERROR")
		debugger;
		var error = event.getParams(); 
		var errorMessage = event.getParam("message"); 
	 },

	 CancelEdit: function (component, event, helper) {
		var recordId = component.get("v.recordId");
		debugger;
		window.location.href='/lightning/r/Product2/'+recordId+'/view';
	}
})