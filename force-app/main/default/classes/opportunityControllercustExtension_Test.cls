@isTest
public class opportunityControllercustExtension_Test {
    @isTest
    static void test1() {
        // arrange
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Id accountId = AccountTestDataFactory.create();
        Id siteId = SiteTestDataFactory.create(accountId);
        Id opportunityId = OpportunityTestDataFactory.create(accountId, siteId);

        EstimateCheckListTestDataFactory.create(opportunityId, 'Electricity');
        EstimateCheckListTestDataFactory.create(opportunityId, 'Gas');
        EstimateCheckListTestDataFactory.create(opportunityId, 'Water');
        EstimateCheckListTestDataFactory.create(opportunityId, 'Responsibilities');

        List<ContentVersion> toInsert = new List<ContentVersion>();

        ContentVersion cv1 = new ContentVersion();
        cv1.ContentLocation = 'S';
        cv1.VersionData = Blob.valueOf('UNIT.TEST');
        cv1.Title = 'filename1';
        cv1.PathOnClient = cv1.Title + '.pdf';
        cv1.Type__c = 'Estimate';
        cv1.Group__c = 'Estimate';
        cv1.FirstPublishLocationId = opportunityId;
        toInsert.add(cv1);

        ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        cv2.VersionData = Blob.valueOf('UNIT.TEST');
        cv2.Title = 'filename2';
        cv2.PathOnClient = cv2.Title + '.pdf';
        cv2.Type__c = 'Estimate';
        cv2.Group__c = 'Estimate';
        cv2.FirstPublishLocationId = opportunityId;
        toInsert.add(cv2);

        ContentVersion cv3 = new ContentVersion();
        cv3.ContentLocation = 'S';
        cv3.VersionData = Blob.valueOf('UNIT.TEST');
        cv3.Title = 'filename3';
        cv3.PathOnClient = cv3.Title + '.pdf';
        cv3.Type__c = 'Estimate';
        cv3.Group__c = 'Estimate';
        cv3.FirstPublishLocationId = opportunityId;
        toInsert.add(cv3);

        ContentVersion cv4 = new ContentVersion();
        cv4.ContentLocation = 'S';
        cv4.VersionData = Blob.valueOf('UNIT.TEST');
        cv4.Title = 'filename4';
        cv4.PathOnClient = cv4.Title + '.pdf';
        cv4.Type__c = 'Estimate';
        cv4.Group__c = 'Estimate';
        cv4.FirstPublishLocationId = opportunityId;
        toInsert.add(cv4);

        ContentVersion cv5 = new ContentVersion();
        cv5.ContentLocation = 'S';
        cv5.VersionData = Blob.valueOf('UNIT.TEST');
        cv5.Title = 'filename5';
        cv5.PathOnClient = cv5.Title + '.pdf';
        cv5.Type__c = 'Estimate';
        cv5.Group__c = 'Estimate';
        cv5.FirstPublishLocationId = opportunityId;
        toInsert.add(cv5);

        insert toInsert;

        Opportunity op = new Opportunity(Id = opportunityId);

        PageReference pageRef = Page.ConnectITQuoteFrontPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(opportunityId));
        System.debug('Test.startTest');
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        opportunityControllerCustomExtension ext = new opportunityControllerCustomExtension(sc);
        Test.stopTest();
        System.debug('Test.stopTest');
    }
}