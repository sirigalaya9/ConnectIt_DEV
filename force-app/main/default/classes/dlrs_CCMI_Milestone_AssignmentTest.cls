/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_CCMI_Milestone_AssignmentTest
{
    @IsTest
    private static void testTrigger()
    {
// Force the dlrs_CCMI_Milestone_AssignmentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
Account custAcc = new Account(Name = 'customer');
        insert custAcc;

        Id RecordTypeIdAccountSite = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Account siteAcc = new Account(Name = 'site', RecordTypeId = RecordTypeIdAccountSite);
        insert siteAcc;

        CCMI__Milestone_Project__c proj = new CCMI__Milestone_Project__c(Name = 'project', CCMI__Account__c = custAcc.id, Site__c = siteAcc.id);
        insert proj;

        CCMI__Milestone_Task__c task = new CCMI__Milestone_Task__c(
            Name = 'task 1', 
            CCMI__Milestone_Project__c = proj.id, 
            CCMI__Desired_Start__c = Date.newInstance(2019, 7, 3),
            CCMI__Duration__c = 1,
            Start__c = Date.newInstance(2019, 7, 3),
            End__c = Date.newInstance(2019, 7, 3),
            CCMI__Description__c = 'desc',
            BORIS_job__c = true);
        insert task;
        dlrs.RollupService.testHandler(new CCMI__Milestone_Assignment__c(CCMI__User__c = UserInfo.getUserId(),CCMI__Milestone_Task__c = task.id));
    }
}