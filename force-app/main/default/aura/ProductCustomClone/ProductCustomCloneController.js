({
    doInit : function(component, event, helper) {
        debugger;
       var recordData = [];
        var action = component.get("c.getRecordSectionNameWihFieldApi_Value");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
             var datalist = [];
            var state = response.getState();
            if(state === "SUCCESS"){
                var myMapData = response.getReturnValue();
                var myMapObject = [];
                for (var key in myMapData) {
                    if (myMapData != null) {
                        var localArray = [];
                        var localstring = key;
                    var localobject = myMapData[key];
                        for (var key in localobject) {
                            if (key != 'Id' && key != 'Product_Id__c') {
                                if(key === 'Product_Name__c'){
                                    localArray.push({ key: key, value:'' });
                                }else
                                if(key === 'Name'){
                                     localArray.push({ key: key, value:'' });
                                }else 
                                if(key === 'IsActive'){
                                    localArray.push({ key: key, value:true });
                                }else{
                                     localArray.push({ key: key, value:localobject[key] });  
                                }                       
                        }
                    }
                    myMapObject.push({ key: localstring, value : localArray});
                    //myMapObject[key] = myMapData[key];
                    }
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
    
    
    handleSuccess : function(component, event, helper) {
        debugger;
        var params = event.getParams(); //get event params
        var recordId = params.response.id; //get record id
        if (recordId != null) {
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'SUCCESS',
            message: 'Product Created Successfully !',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
            toastEvent.fire();
            window.location.href = '/lightning/r/Product2/' +recordId + '/view';
        }
    },
    handleError: function (cmp, event, helper) {
		debugger;
		var error = event.getParams(); 
        var errorMessage = event.getParam("message"); 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'ERROR',
            message:'Error info : '+errorMessage,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
	 },
    CancelEdit: function (component, event, helper) { 
        debugger;
        var recordId = component.get("v.recordId");
        window.location.href = '/lightning/r/Product2/' +recordId + '/view';
    },

})