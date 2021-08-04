@isTest
    private class OpportunityTriggerHandlerTest {
        @isTest
        static void test_addFiles() {
            // Perform our data preparation...
            // Account acc = new Account(Name = 'test');
            // insert acc;
    
            Id siteId = SiteTestDataFactory.create();
            Id accountId = AccountTestDataFactory.create();
            Id projectId = ProjectTestDataFactory.create(siteId);
    
            Opportunity op = new Opportunity(Name = 'test', StageName = 'Qualification', CloseDate = Date.today(), AccountId = accountId);
            insert op;
    
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = Blob.valueOf('UNIT.TEST');
            cv.Title = 'filename1';
            cv.PathOnClient = cv.Title + '.pdf';
            cv.Type__c = 'Estimate';
            cv.Group__c = 'Estimate';
            insert cv;
    
   
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            cdl.LinkedEntityId = op.ID;
            cdl.ShareType = 'V';
      
            ContentDocumentLink cdl_acc = new ContentDocumentLink();
            cdl_acc.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            cdl_acc.LinkedEntityId = accountId;
            cdl_acc.ShareType = 'V';
    
            test.startTest();
            insert cdl;
    
            // validation
            op = [SELECT File_Names__c, File_Count__c FROM Opportunity WHERE Id = :op.Id LIMIT 1];
            System.debug('File_Names__c = ' + op.File_Names__c);
            System.assert(op.File_Names__c == 'filename1.pdf');
            System.debug('File_Count__c = ' + op.File_Count__c);
            System.assert(op.File_Count__c == 1);
    
            // Update the Estimate to Closed Won
            op.StageName = 'Closed Won';
            op.Estimate_Date__c = Date.today();
            op.Project_Start__c = Date.today();
            op.Project__c = projectId;
            op.Site__c = siteId;
            op.Type = 'LV Electric Car Charger Proposal';
            
            update op;
            test.stopTest();
    
            List<ContentVersion> cv1 = [SELECT Id, Project__c FROM ContentVersion ];
            System.debug('cv1 = ' + cv1);
            System.assertEquals(projectId, cv1[0].Project__c) ;
    
        }
    }