@isTest
public class ContentDocumentSetBorisIdTest {
    @isTest
    static void execute_update_with_opportunity() {
        // arrange
        Id accountId = AccountTestDataFactory.create();
        Id site1Id = SiteTestDataFactory.create();
        Id site2Id = SiteTestDataFactory.create();
        Id opportunityId = OpportunityTestDataFactory.create(accountId, site1Id);
        Id contentVersionId = ContentVersionTestDataFactory.create(opportunityId);

        // set a new site ID
        Opportunity opportunity = new Opportunity(Id = opportunityId);
        opportunity.Site__c = site2Id;
        update opportunity;

        // make a change to the target record
        ContentVersion doc = new ContentVersion(Id = contentVersionId);
        doc.Title = 'Update Title';

        // act
        Test.startTest();
        update doc;
        Test.stopTest();

        // assert
        doc = [SELECT site__c, estimate__c, project__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(site2Id, doc.site__c);
        System.assertEquals(opportunity.id, doc.estimate__c);
        System.assertEquals(null, doc.project__c);

        List<BORIS_File_Update_OUT__c> bfuos = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        System.assertEquals(0, bfuos.size());   // no project no BORIS record
    }
    

    @isTest
    static void execute_update_with_project() {
        // arrange
        Id site1Id = SiteTestDataFactory.create();
        Id site2Id = SiteTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(site1Id);
        Id contentVersionId = ContentVersionTestDataFactory.create(projectId);

        // set a new site ID
        CCMI__Milestone_Project__c project = new CCMI__Milestone_Project__c(Id = projectId);
        project.Site__c = site2Id;
        update project;

        // make a change to the target record
        ContentVersion doc = new ContentVersion(Id = contentVersionId);
        doc.Title = 'Update Title';

        // act
        Test.startTest();
        update doc;
        Test.stopTest();

        // assert
        doc = [SELECT site__c, project__c, estimate__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(site2Id, doc.site__c);
        System.assertEquals(project.id, doc.project__c);
        System.assertEquals(null, doc.estimate__c);
              
        List<BORIS_File_Update_OUT__c> bfuos = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        System.assertEquals(1, bfuos.size());   // no project no BORIS record
    }
    
    
    @isTest
    static void execute_update_with_site() {
        // arrange
        Id site1Id = SiteTestDataFactory.create();
        Id site2Id = SiteTestDataFactory.create();
        Id contentVersionId = ContentVersionTestDataFactory.create(site2Id);

        // assert
        ContentVersion doc = [SELECT site__c, project__c, estimate__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(site2Id, doc.site__c);
        System.assertEquals(null, doc.project__c);
        System.assertEquals(null, doc.estimate__c);

        List<BORIS_File_Update_OUT__c> bfuos = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        System.assertEquals(0, bfuos.size());   // no project no BORIS record
    }
}