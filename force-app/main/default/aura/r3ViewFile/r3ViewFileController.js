({
    init : function (component,event,helper)
    {    
        console.log("r3ViewFile init");
    },
    
    openSingleFile : function (component,event,helper)
    {    
        console.log("r3ViewFile openSingleFile");
        var recId = component.get("v.recordId");
        var fireEvent = $A.get("e.lightning:openFiles");
        //fireEvent.fire({recordIds: [recId]});    
        fireEvent.fire({
            recordIds : [recId],
            selectedRecordId : recId
        });
    }
});