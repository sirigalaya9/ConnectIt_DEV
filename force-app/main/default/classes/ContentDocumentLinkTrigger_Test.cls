@isTest
private class ContentDocumentLinkTrigger_Test {
    @isTest
    static void test_addFiles() {
        // Perform our data preparation...
        // Account acc = new Account(Name = 'test');
        // insert acc;

        Id siteId = SiteTestDataFactory.create();
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(siteId);

        Opportunity op = new Opportunity(Name = 'test', StageName = 'Qualification', CloseDate = Date.today(), AccountId = accountId, Project__c = projectId);
        insert op;

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('UNIT.TEST');
        cv.Title = 'filename1';
        cv.PathOnClient = cv.Title + '.pdf';
        cv.Type__c = 'Estimate';
        cv.Group__c = 'Estimate';
        insert cv;

        ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        cv2.VersionData = Blob.valueOf('UNIT.TEST');
        cv2.Title = 'filename2';
        cv2.PathOnClient = cv2.Title + '.pdf';
        cv2.Type__c = 'Estimate';
        cv2.Group__c = 'Estimate';
        insert cv2;

        ContentVersion cv3 = new ContentVersion();
        cv3.ContentLocation = 'S';
        cv3.VersionData = Blob.valueOf('UNIT.TEST');
        cv3.Title = 'filename3';
        cv3.PathOnClient = cv3.Title + '.pdf';
        cv3.Type__c = 'Estimate';
        cv3.Group__c = 'Estimate';
        insert cv3;

        ContentVersion cv4 = new ContentVersion();
        cv4.ContentLocation = 'S';
        cv4.VersionData = Blob.valueOf('UNIT.TEST');
        cv4.Title = 'filename4';
        cv4.PathOnClient = cv4.Title + '.pdf';
        cv4.Type__c = 'Estimate';
        cv4.Group__c = 'Estimate';
        insert cv4;

        ContentDocument cd4 = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv4.Id) LIMIT 1];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
        cdl.LinkedEntityId = op.ID;
        cdl.ShareType = 'V';

        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id LIMIT 1].ContentDocumentId;
        cdl2.LinkedEntityId = op.ID;
        cdl2.ShareType = 'V';

        ContentDocumentLink cdl4 = new ContentDocumentLink();
        cdl4.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv4.Id LIMIT 1].ContentDocumentId;
        cdl4.LinkedEntityId = op.ID;
        cdl4.ShareType = 'V';

        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv3.Id LIMIT 1].ContentDocumentId;
        cdl3.LinkedEntityId = op.ID;
        cdl3.ShareType = 'V';

        ContentDocumentLink cdl_acc = new ContentDocumentLink();
        cdl_acc.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
        cdl_acc.LinkedEntityId = accountId;
        cdl_acc.ShareType = 'V';

        test.startTest();
        insert cdl;
        insert cdl2;
        insert cdl3;
        insert cdl4;
        insert cdl_acc;
        delete cdl3; // unshare (only ContentDocumentLink is deleted not ContentDocument)
        delete cd4; // delete the content document (full delete, does not trigger ContentDocumentLinkTrigger, rather ContentDocumentTrigger...)
        test.stopTest();

        // validation
        op = [SELECT File_Names__c, File_Count__c FROM Opportunity WHERE Id = :op.Id LIMIT 1];
        System.debug('File_Names__c = ' + op.File_Names__c);
        System.assert(op.File_Names__c == 'filename1.pdf; filename2.pdf');
        System.debug('File_Count__c = ' + op.File_Count__c);
        System.assert(op.File_Count__c == 2);

        List<ContentVersion> cv1 = [SELECT Id, Project__c FROM ContentVersion ];
        System.debug('cv1 = ' + cv1);
        System.assertEquals(projectId, cv1[0].Project__c) ;

        
    }
}