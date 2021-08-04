({
    init : function(component,event,helper){
        var recordId = component.get("v.recordId");
        console.log(recordId);
        
    },
    
    goBack : function(component, event, helper)
    {
		var recordId = component.get("v.recordId");
        console.log(recordId);
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        };
        var navService = component.find("navService");  
        navService.navigate(pageReference);        
    }
})