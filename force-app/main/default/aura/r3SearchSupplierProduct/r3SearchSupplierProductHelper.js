({
    searchHelper: function(component, event) {
    // show spinner message
     component.find("Id_spinner").set("v.class" , 'slds-show');
     var action = component.get("c.fetchData");
    	 action.setParams({ 'searchKeyWord': component.get("v.searchKeyword")});
    	 action.setCallback(this, function(response) {
       
         	// hide spinner when response coming from server 
         	component.find("Id_spinner").set("v.class" , 'slds-hide');
         	var state = response.getState();
         	if (state === "SUCCESS") {		
            	var storeResponse = response.getReturnValue();
            	// if storeResponse size is 0 ,display no record found message on screen.
            	if (storeResponse.length == 0) {
                	component.set("v.Message", true);
            	} else{
                	component.set("v.Message", false);
            	}

            // set searchResult list with return value from server.
            component.set("v.searchResult", storeResponse); 

        	}else if (state === "INCOMPLETE") {
            	alert('Response is Incompleted');
        	}else if (state === "ERROR") {
            	var errors = response.getError();
            	if (errors) {
                	if (errors[0] && errors[0].message) {
                    alert("Error message: " + errors[0].message);
                	}
            	} else {
                	alert("Unknown error");
           		}
        	}
    	});
    	$A.enqueueAction(action);
	},
	doHandleSubmit  :function(component){ 
        var searchResult = JSON.stringify(component.get("v.searchResult"));
        var action = component.get("c.updateSalesforceProduct");
        action.setParams({"parentId": component.get("v.recordId"),
                          "supplierProducts": searchResult
                         })
        action.setCallback(this, function(response) {
            $A.get('e.force:refreshView').fire(); 
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.searchKeyword", '');
                component.set("v.searchResult", []);
   				var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({"title": "Success",
                                      "message": "Supplier Product(s) added successfully.",
                                      "type": "success"});
    			toastEvent.fire();               
            } else {
                console.log('Error while updating records : ' + state);                
            }
        });
        $A.enqueueAction(action); 
    }
})