({
	onChangeSearchText: function (component, event, helper) {
        helper.searchHelper(component, event);
    },
    handleSubmit :function(component, event, helper){ 
        helper.doHandleSubmit(component);
    }
})