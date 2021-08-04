public class quote_helper 
{
    public static String getFieldList(String objectName)
    {
        String retStr = '';
        
        // get fields for object
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // list them in string
        for(String s : objectFields.keySet()) 
           retStr += s + ',';
        
        // remove last comma
        if (retStr.subString(retStr.Length()-1,retStr.Length()) == ',')
            retStr = retStr.subString(0,retStr.Length()-1);
        
        return retStr;
    }

}