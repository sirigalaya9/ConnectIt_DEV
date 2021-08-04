@isTest
public class ContentVersionTestDataFactory 
{
    public static Id create(Id firstPublishLocationId, String filegroup, String filetype) 
    {
        ContentVersion doc = new ContentVersion();
        doc.Title = 'Test Document';
        doc.PathOnClient = '/test.txt';
        doc.VersionData = Blob.valueOf('content');
        doc.FirstPublishLocationId = firstPublishLocationId;
        doc.Group__c = filegroup;
        doc.Type__c = filetype;
        insert doc;
        return doc.Id;
    }
    
    public static Id create(Id firstPublishLocationId) 
    {
        return create(firstPublishLocationId, 'Design', 'Legal Site Plan');
    }

}