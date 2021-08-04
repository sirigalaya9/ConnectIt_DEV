({
	init : function(component, event, helper) {
		let action = component.get( "c.captureMatReqId" );
        
        action.setParams( { matReqId : component.get( "v.recordId" ) } );
        
        action.setCallback( this, ( response ) => { 
            if( response.getState() === "SUCCESS" && 
            	response.getReturnValue() ) {
            	//$A.get( "e.force:refreshView" ).fire();
            	location.reload();
        	}
        } );
        
        $A.enqueueAction( action );
	}
})