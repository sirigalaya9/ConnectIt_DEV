({
    handleRecordChange : function(cmp, evt, hlp){
        console.log('handleRecordChange');
        cmp.find('lwc').getProductItems();
    },
})