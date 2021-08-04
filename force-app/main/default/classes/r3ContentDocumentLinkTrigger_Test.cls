@isTest
private class r3ContentDocumentLinkTrigger_Test
{
    @testSetup 
    static void setup()
    {
    }

    @isTest
    private static void test1()
    {
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        // DATA SETUP

        Account acc = new Account(Name = 'test', recordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId(), Type = 'Customer');
        insert acc;        

        Account site = new Account(Name = 'Site Test', recordTypeId = AccountRecordTypeInfo.get('Site').getRecordTypeId(), Customer_Account__c = acc.id);
        insert site;        
        
        Opportunity op = new Opportunity(Name = 'test', StageName = 'Enquiry', CloseDate = Date.today(), AccountId = acc.id, Site__c = site.id);
        insert op;
        
        Case cs = new Case(Subject = 'test', Estimate__c = op.id, AccountId = acc.id);
        insert cs;

        EmailMessage email1 = new EmailMessage(Subject = 'test', relatedToId = cs.id);
        insert email1;

        EmailMessage email2 = new EmailMessage(Subject = 'test', relatedToId = op.id);
        insert email2;
        
        // TEST START

        // attach document to case email (should then also be linked to case and opp) opp 1, case 1
        ContentVersion cv1 = new ContentVersion();
        cv1.ContentLocation = 'S';
        cv1.VersionData = Blob.valueOf('UNIT.TEST');
        cv1.Title = 'filename1';
        cv1.PathOnClient = cv1.Title + '.pdf';   
        cv1.Group__c = 'Estimate';     
        cv1.Type__c = 'Estimate';
        cv1.FirstPublishLocationId = email1.id;
        insert cv1;
        
        // attach document to opp email (should then also be linked to opp) opp 2 case 1
        ContentVersion cv3 = new ContentVersion();
        cv3.ContentLocation = 'S';
        cv3.VersionData = Blob.valueOf('UNIT.TEST');
        cv3.Title = 'filename1';
        cv3.PathOnClient = cv3.Title + '.pdf'; 
        cv3.Group__c = 'Estimate';       
        cv3.Type__c = 'Enquiry';
        cv3.FirstPublishLocationId = email2.id;
        insert cv3;

        // attach document to case (should then also be linked to opp) opp 3 case 2
        ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        cv2.VersionData = Blob.valueOf('UNIT.TEST');
        cv2.Title = 'filename2';
        cv2.PathOnClient = cv2.Title + '.pdf';  
        cv2.Group__c = 'Estimate';
        cv2.Type__c = 'Previous Estimates';
        cv2.FirstPublishLocationId = cs.id;
        insert cv2;

        // attach document to opp and link to case (should spot that the opp is already linked!) opp 4 case 2
        ContentVersion cv4 = new ContentVersion();
        cv4.ContentLocation = 'S';
        cv4.VersionData = Blob.valueOf('UNIT.TEST');
        cv4.Title = 'filename2';
        cv4.PathOnClient = cv4.Title + '.pdf';  
        cv4.Group__c = 'Estimate'; 
        cv4.Type__c = 'Estimate';
        cv4.FirstPublishLocationId = op.id;
        insert cv4;

        // get content document id, and create CDL against the case - opp 4 case 3
        cv4 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv4.id LIMIT 1];
        ContentDocumentLink cdl1 = new ContentDocumentLink(ContentDocumentId = cv4.ContentDocumentId, linkedEntityId = cs.id, ShareType = 'I');
        insert cdl1;

        // VALIDATION
        
        // get ContentDocument Ids...
        cv1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.id LIMIT 1];
        cv2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv2.id LIMIT 1];

        List<ContentDocumentLink> oppCdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE linkedEntityId = :op.id]; 
        system.assertEquals(4,oppCdls.size());

        List<ContentDocumentLink> caseCdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE linkedEntityId = :cs.id]; 
        system.assertEquals(3,caseCdls.size());
    }
    
}