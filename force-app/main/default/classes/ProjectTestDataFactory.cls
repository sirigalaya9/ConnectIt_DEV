@isTest
public class ProjectTestDataFactory {
    public static Id create(Id siteId) {
        CCMI__Milestone_Project__c project = new CCMI__Milestone_Project__c();
        project.Name = 'Test Project';
        project.Site__c = siteId;
        insert project;
        return project.Id;
    }

    public static CCMI__Milestone_Project__c create(Id siteId, Id accountId) {
        CCMI__Milestone_Project__c project = new CCMI__Milestone_Project__c();
        project.Name = 'Test Project';
        project.Site__c = siteId;
        project.CCMI__Account__c = accountId;
        insert project;
        return project;
    }
}