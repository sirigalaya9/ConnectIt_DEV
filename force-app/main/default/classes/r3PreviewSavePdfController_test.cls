@isTest
private class r3PreviewSavePdfController_test 
{
    static testMethod void test1()
    {
        // Perform our data preparation.
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Account acc = new Account(Name = 'test', RecordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId());
        insert acc;
        
        r3PreviewSavePdfController.savePDF('ConnectITQuoteFrontPage', acc.id, 'filename', 'Estimate', 'Enquiry');

        // check that the PDF file has been generated...
        List<ContentDocumentLink> cdls = [SELECT id FROM ContentDocumentLink WHERE 
            LinkedEntityId = :acc.id AND 
            ContentDocument.LatestPublishedVersion.title = 'filename' AND
            ContentDocument.LatestPublishedVersion.Type__c = 'Enquiry' AND
            ContentDocument.LatestPublishedVersion.Group__c = 'Estimate'];
        system.assertEquals(1, cdls.size());
    }
}