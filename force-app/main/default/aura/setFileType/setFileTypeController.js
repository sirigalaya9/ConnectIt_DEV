({
    handleSave: function(component, event, helper) 
    {
        component.find("recordEditor").saveRecord(function(saveResult) 
        {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") 
            {
                // Reload the view so components not using force:recordData are updated
                //$A.get("e.force:refreshView").fire();
            }
            else if (saveResult.state === "INCOMPLETE") 
            {
                console.log("User is offline, device doesn't support drafts.");
            }
            else if (saveResult.state === "ERROR") 
            {
                console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
            }
            else 
            {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
    },
})