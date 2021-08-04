@isTest(seeAllData=true)
private class r3UserListEdit_test
{
    static testMethod void test1()
    {
        List<User> users = [SELECT Id, Name FROM User LIMIT 10];
        
        PageReference pageRef = Page.r3UserListEdit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(users);
        r3UserListEdit ext = new r3UserListEdit(ssc);
        ext.getSortDirection();
        ext.onCancel();
        ext.onSave();      
        ext.onEdit();       
    }
}