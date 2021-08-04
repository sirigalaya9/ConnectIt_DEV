public with sharing class r3UserListEdit 
{
    private string sortDirection='ASC';
    private string sortExp='Name';
    public List<User> users{get; set;}
    public String whereClause {get; set;}
    public Boolean EditMode{get; set;}//for enable/disable edit panel
    private ApexPages.StandardSetController setCon;
    
    // Initialize setCon and return a list of records
    public void getUsers() 
    {
        users = database.query(getUserQuery());
        setCon.setSelected(users);
    }


    public r3UserListEdit(ApexPages.StandardSetController controller) 
    {
        setCon = controller;
        EditMode=false;
        whereClause = '(isActive = true)';

        // get users...
        getUsers();
    }
    
    public string sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if(value == sortExp)
                sortDirection=(sortDirection=='ASC')?'DESC':'ASC';
            else 
                sortDirection='ASC';
            sortExp=value;
        }
    }


    public string getSortDirection()
    {
        //if not column is selected 
        if(sortExpression==null||sortExpression=='')
            return 'ASC';
        else 
            return sortDirection;
    }

    
    public PageReference onSave()
    {
        EditMode=false; 
        update(users);
        return null;
    }
    

    public PageReference onCancel()
    {
        EditMode=false; 
        getUsers();
        return null;
    }
        

    public void onEdit()
    {
        EditMode=true;
    }

    private String getUserQuery()
    {
        String obj = 'User';
        String query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE IsActive = true AND Name != \'Platform Integration User\' AND '+whereClause+' ORDER BY ' + sortExpression+' ' + sortDirection;
        system.debug('R3>>> Query = '+query);
        return query;
    }


    private String getFieldList(String objectName)
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