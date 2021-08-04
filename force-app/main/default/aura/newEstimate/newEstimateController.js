({
	fireGlobal: function (cmp, event, helper) {
        var actionAPI = cmp.find("quickActionAPI");
        var fields = { 
                       Name : { value : "Sets by lightning:quickActionAPI component" }
                     };
        var args = { actionName : "NewOpportunity", 
                     entityName : "Opportunity",
                     targetFields : fields 
                   };
        actionAPI.setActionFieldValues(args).then(function() {
            actionAPI.invokeAction(args);
        }).catch(function(e) {
            console.error(e.errors);
        });
    }
})