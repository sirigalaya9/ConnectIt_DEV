@isTest
public class opportunityControllerExtension_Test {
    @isTest
    static void test1() {
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();

        // Perform our data preparation.
        Account acc = new Account(Name = 'test', recordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId(), Type = 'Customer');
        insert acc;

        Account site = new Account(Name = 'Site Test', recordTypeId = AccountRecordTypeInfo.get('Site').getRecordTypeId(), Customer_Account__c = acc.id);
        insert site;

        Opportunity op = new Opportunity(Name = 'test', StageName = 'Enquiry', CloseDate = Date.today(), AccountId = acc.id, Site__c = site.id);
        insert op;

        Estimate_Checklist__c ecl1 = new Estimate_Checklist__c(Estimate__c = op.id, Area__c = 'Electricity');
        insert ecl1;
        Estimate_Checklist__c ecl2 = new Estimate_Checklist__c(Estimate__c = op.id, Area__c = 'Gas');
        insert ecl2;
        Estimate_Checklist__c ecl3 = new Estimate_Checklist__c(Estimate__c = op.id, Area__c = 'Water');
        insert ecl3;
        Estimate_Checklist__c ecl4 = new Estimate_Checklist__c(Estimate__c = op.id, Area__c = 'Responsibilities');
        insert ecl4;

        ContentVersion cv1 = new ContentVersion();
        cv1.ContentLocation = 'S';
        cv1.VersionData = Blob.valueOf('UNIT.TEST');
        cv1.Title = 'filename1';
        cv1.PathOnClient = cv1.Title + '.pdf';
        cv1.Type__c = 'Estimate';
        cv1.Group__c = 'Estimate';
        cv1.FirstPublishLocationId = op.id;
        insert cv1;

        ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        cv2.VersionData = Blob.valueOf('UNIT.TEST');
        cv2.Title = 'filename2';
        cv2.PathOnClient = cv2.Title + '.pdf';
        cv2.Type__c = 'Estimate';
        cv2.Group__c = 'Estimate';
        cv2.FirstPublishLocationId = op.id;
        insert cv2;

        ContentVersion cv3 = new ContentVersion();
        cv3.ContentLocation = 'S';
        cv3.VersionData = Blob.valueOf('UNIT.TEST');
        cv3.Title = 'filename3';
        cv3.PathOnClient = cv3.Title + '.pdf';
        cv3.Type__c = 'Estimate';
        cv3.Group__c = 'Estimate';
        cv3.FirstPublishLocationId = op.id;
        insert cv3;

        ContentVersion cv4 = new ContentVersion();
        cv4.ContentLocation = 'S';
        cv4.VersionData = Blob.valueOf('UNIT.TEST');
        cv4.Title = 'filename4';
        cv4.PathOnClient = cv4.Title + '.pdf';
        cv4.Type__c = 'Estimate';
        cv4.Group__c = 'Estimate';
        cv4.FirstPublishLocationId = op.id;
        insert cv4;

        ContentVersion cv5 = new ContentVersion();
        cv5.ContentLocation = 'S';
        cv5.VersionData = Blob.valueOf('UNIT.TEST');
        cv5.Title = 'filename5';
        cv5.PathOnClient = cv5.Title + '.pdf';
        cv5.Type__c = 'Estimate';
        cv5.Group__c = 'Estimate';
        cv5.FirstPublishLocationId = op.id;
        insert cv5;

        PageReference pageRef = Page.ConnectITQuoteFrontPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(op.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        opportunityControllerExtension ext = new opportunityControllerExtension(sc);
    }
}