({
    init : function (component) {
        component.set( "v.showModal", true );
        // Find the component whose aura:id is "flowId"
        var flow = component.find("flowId");
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("NewEstimate");
    },
})