@isTest
public class r3FileManagerController_test 
{
    @isTest static void ContentDocument_Test()
    {
        ContentVersion contentVersionInsert1 = new ContentVersion(
            Title = 'Test1',
            PathOnClient = 'Test1.jpg',
            VersionData = Blob.valueOf('Test Content Data 1'),
            Group__c = 'Estimate',
            Type__c = 'Enquiry',
            IsMajorVersion = true
        );
        insert contentVersionInsert1;
        
        ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test2.jpg',
            VersionData = Blob.valueOf('Test Content Data 2'),
            Group__c = 'Estimate',
            Type__c = 'Estimate',
            IsMajorVersion = true
        );
        insert contentVersionInsert2;
        
        String testFileFilter = '((LatestPublishedVersion.Group__c = \'Estimate\'and LatestPublishedVersion.Type__c = \'Estimate\') OR (LatestPublishedVersion.Group__c = \'Estimate\'and LatestPublishedVersion.Type__c = \'Enquiry\'))';
        
        // Test INSERT & SELECT
        List<ContentDocument> documents = r3FileManagerController.getRelatedFiles(UserInfo.getUserId(), testFileFilter);
        System.assertEquals(documents.size(), 2);

 
        // test groups
        List<String> groups = r3FileManagerController.getRelatedGroupList(UserInfo.getUserId());
       System.assertEquals(groups.size(), 1);
       System.assertEquals(groups[0], 'Estimate');

        
        // Test DELETE
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert1.Id LIMIT 1];
        r3FileManagerController.deleteContentDocument(contentVersionSelect.ContentDocumentId);
        documents = r3FileManagerController.getRelatedFiles(UserInfo.getUserId(), testFileFilter);
        System.assertEquals(documents.size(), 1);
    }
}