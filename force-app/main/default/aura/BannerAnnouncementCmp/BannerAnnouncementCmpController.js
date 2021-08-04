({
    init:function(component,event,helper){
        var attcolorBackGround = component.get("v.colorVariant");
        var atttextColor = component.get("v.textHeaderMessageColor");
        if(attcolorBackGround == 'Velvet Red'){
            component.set("v.backgroundColor", "#C40001") 
        }
    }
})