@isTest
public class ContentDocumentLinkSetBorisIdTest {
    ////////////
    // INSERT //
    ////////////

    @isTest
    static void execute_insert_with_opportunity() {
        // arrange
        Id accountId = AccountTestDataFactory.create();
        Id siteId = SiteTestDataFactory.create();
        Id opportunityId = OpportunityTestDataFactory.create(accountId, siteId);

        // act
        Test.startTest();
        Id contentVersionId = ContentVersionTestDataFactory.create(opportunityId);
        Test.stopTest();

        // assert
        ContentVersion doc = [SELECT site__c, project__c, estimate__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(siteId, doc.Site__c);
        System.assertEquals(null, doc.project__c);
        System.assertEquals(opportunityId, doc.estimate__c);

        List<BORIS_File_Update_OUT__c> bfuos = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        System.assertEquals(0, bfuos.size());   // no project no BORIS record
    }

    @isTest
    static void execute_insert_with_site_account() {
        // arrange
        Id siteId = SiteTestDataFactory.create();

        // act
        Test.startTest();
        Id contentVersionId = ContentVersionTestDataFactory.create(siteId);
        Test.stopTest();

        // assert
        ContentVersion doc = [SELECT site__c, project__c, estimate__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(siteId, doc.Site__c);
        System.assertEquals(null, doc.project__c);
        System.assertEquals(null, doc.estimate__c);

        List<BORIS_File_Update_OUT__c> bfuos = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        System.assertEquals(0, bfuos.size());    // no project no BORIS record
    }

    @isTest
    static void execute_insert_with_project() {
        // arrange
        Id siteId = SiteTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(siteId);

        // act
        Test.startTest();
        Id contentVersionId = ContentVersionTestDataFactory.create(projectId);
        Test.stopTest();

        // assert
        ContentVersion doc = [SELECT site__c, project__c, estimate__c, group__c, Type__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(siteId, doc.Site__c);
        System.assertEquals(projectId, doc.project__c);
        System.assertEquals(null, doc.estimate__c);

        List<BORIS_File_Update_OUT__c> bfuos = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        System.assertEquals(1, bfuos.size());
    }
}