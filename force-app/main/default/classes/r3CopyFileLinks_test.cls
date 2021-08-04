@isTest
public class r3CopyFileLinks_test {
    @isTest
    static void test() {
        // DATA SETUP

        Account source = new Account(Name = 'source');
        insert source;

        Account target = new Account(Name = 'target');
        insert target;

        // TEST START

        // attach document to source record
        ContentVersion cv1 = new ContentVersion();
        cv1.ContentLocation = 'S';
        cv1.VersionData = Blob.valueOf('UNIT.TEST');
        cv1.Title = 'filename1';
        cv1.PathOnClient = cv1.Title + '.pdf';
        cv1.Type__c = 'Estimate';
        cv1.Group__c = 'Estimate';
        cv1.FirstPublishLocationId = source.id;
        insert cv1;

        // attach document to opp and link to source and target (should spot that the target is already linked!)
        ContentVersion cv4 = new ContentVersion();
        cv4.ContentLocation = 'S';
        cv4.VersionData = Blob.valueOf('UNIT.TEST');
        cv4.Title = 'filename2';
        cv4.PathOnClient = cv4.Title + '.pdf';
        cv4.Type__c = 'Estimate';
        cv4.Group__c = 'Estimate';
        cv4.FirstPublishLocationId = source.id;
        insert cv4;

        // get content document id, and create CDL against the target
        cv4 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv4.id LIMIT 1];
        ContentDocumentLink cdl1 = new ContentDocumentLink(ContentDocumentId = cv4.ContentDocumentId, linkedEntityId = target.id, ShareType = 'I');
        insert cdl1;

        // TEST

        List<r3CopyFileLinks.copyFileLinksRequest> requestList = new List<r3CopyFileLinks.copyFileLinksRequest>();
        r3CopyFileLinks.copyFileLinksRequest request = new r3CopyFileLinks.copyFileLinksRequest();
        request.sourceId = source.Id;
        request.targetId = target.Id;
        requestList.add(request);
        r3CopyFileLinks.copyFileLinks(requestList);

        // VALIDATION

        // get ContentDocument Ids...
        List<ContentDocumentLink> targetCdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE linkedEntityId = :target.id];
        system.assertEquals(2, targetCdls.size());
    }
}