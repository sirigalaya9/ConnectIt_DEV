@isTest
public class ContentVersionTrigger_Test 
{
    @isTest
    static void test1()
    {
        execute_update_with_project('Design', 'Legal Site Plan');
    }
    
    @isTest static void test2(){execute_update_with_project('Design', 'Legal Site Plan');}
    @isTest static void test3(){execute_update_with_project('Design', 'PDF & DWGs');}
    @isTest static void test4(){execute_update_with_project('Design', 'Electric PDF & DWGs');}
    @isTest static void test5(){execute_update_with_project('Design', 'Fibre PDF & DWGs');}
    @isTest static void test6(){execute_update_with_project('Design', 'Gas PDF & DWGs');}
    @isTest static void test7(){execute_update_with_project('Design', 'Water PDF & DWGs');}
    @isTest static void test8(){execute_update_with_project('Design', 'Street Lighting');}
    @isTest static void test9(){execute_update_with_project('Design', 'CIUS Material Schedule');}
    @isTest static void test10(){execute_update_with_project('Design', 'Ducts & Excavation');}
    //@isTest static void test11(){execute_update_with_project('Existing Services', 'Existing Services');}
    @isTest static void test17(){execute_update_with_project('Highway TM Plans', 'Highway Extent Plan');}
    @isTest static void test18(){execute_update_with_project('Highway TM Plans', 'Traffic Management Plans');}
    @isTest static void test19(){execute_update_with_project('Highway TM Plans', 'Highway TM Take Off');}
    @isTest static void test20(){execute_update_with_project('Highway TM Plans', 'Notices and Permits');}
    @isTest static void test21(){execute_update_with_project('Photos', 'Estimate Photos');}
    @isTest static void test22(){execute_update_with_project('Photos', 'Estimate Pre Start Photos');}
    @isTest static void test23(){execute_update_with_project('Risk Assessment', 'Pre Commencement Risk Assessment');}
    @isTest static void test24(){execute_update_with_project('Risk Assessment', 'Residual Design Risk Register');}
    @isTest static void test25(){execute_update_with_project('Risk Assessment', 'Site Specific');}
    @isTest static void test26(){execute_update_with_project('Work Instruction', 'Work Instruction');}
    @isTest static void test27(){execute_update_with_project('Scope', 'Overview');}
    @isTest static void testNoBorisOutFile(){execute_update_with_project('Estimate', 'Estimate',0);}

    private static void execute_update_with_project(String filegroup, String filetype) 
    {
        execute_update_with_project(filegroup, filetype, 1);
    }
    
    private static void execute_update_with_project(String filegroup, String filetype, Integer count) 
    {
        // arrange
        Id site1Id = SiteTestDataFactory.create();
        Id site2Id = SiteTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(site1Id);
        Id contentVersionId = ContentVersionTestDataFactory.create(projectId, filegroup, filetype);

        // set a new site ID
        CCMI__Milestone_Project__c project = new CCMI__Milestone_Project__c(Id = projectId);
        project.Site__c = site2Id;
        update project;

        // make a change to the target record
        ContentVersion doc = new ContentVersion(Id = contentVersionId);
        doc.Title = 'Update Title';

        // act
        Test.startTest();
        update doc;
        Test.stopTest();

        // assert
        doc = [SELECT site__c, project__c, estimate__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(site2Id, doc.site__c);
        System.assertEquals(project.id, doc.project__c);
        System.assertEquals(null, doc.estimate__c);
        
        List<BORIS_File_Update_OUT__c > bfuList = [SELECT Status__c, Content_Version_Id__c FROM BORIS_File_Update_OUT__c];
        System.debug('R3>>> '+bfuList);
        System.assertEquals(count, bfuList.size());
        if(count != 0)
            System.assertEquals(contentVersionId, bfuList[0].Content_Version_Id__c);
    }
    
    @isTest 
    private static void execute_insert_with_project() 
    {
        // arrange
        Id site1Id = SiteTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(site1Id);

        // act
        Test.startTest();
        Id contentVersionId = ContentVersionTestDataFactory.create(projectId, 'Design', 'Legal Site Plan');
        Test.stopTest();

        // assert
        ContentVersion cv = [SELECT site__c, project__c, estimate__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(site1Id, cv.site__c);
        System.assertEquals(projectId, cv.project__c);
        System.assertEquals(null, cv.estimate__c);
        
        List<BORIS_File_Update_OUT__c > bfuList = [SELECT Status__c, Content_Version_Id__c FROM BORIS_File_Update_OUT__c];
        System.assertEquals(1, bfuList.size());
        System.assertEquals(contentVersionId, bfuList[0].Content_Version_Id__c);
    }
}