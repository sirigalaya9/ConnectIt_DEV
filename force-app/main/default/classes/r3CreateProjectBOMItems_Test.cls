@isTest(seeAllData=false)
public class r3CreateProjectBOMItems_Test 
{
    static testMethod void test()
    {
        //
        // DATA SETUP
        //
        
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        // Perform our data preparation.
        Account acc = new Account(Name = 'test', recordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId(), Type = 'Customer');
        insert acc;        

        Account site = new Account(Name = 'Site Test', recordTypeId = AccountRecordTypeInfo.get('Site').getRecordTypeId(), Customer_Account__c = acc.id);
        insert site;        
                
        Opportunity op = new Opportunity(Name = 'test', StageName = 'Enquiry', CloseDate = Date.today(), AccountId = acc.id, Site__c = site.id);
        op.Estimate_Date__c = system.today();
        op.Project_Start__c = system.today();
        op.Type = 'LV Electric Car Charger Proposal';
        op.Charger_Point_Provider__c = 'Instavolt';
        insert op;
        
        Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Kit').getRecordTypeId();
        Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();

        // create kit product
        Product2 kitProd = new Product2();
        kitProd.Allow_Multiple_Products__c = false;
        kitProd.IsActive = true;
        kitProd.Name = 'kit product';
        kitProd.RecordTypeId = ProductKitRecordTypeId;
        kitProd.Material_Cost_override__c = 1;
        insert kitProd;

        // create component product
        Product2 compProd1 = new Product2();
        compProd1.Allow_Multiple_Products__c = false;
        compProd1.IsActive = true;
        compProd1.Name = 'component product 1';
        compProd1.Material_Cost__c = 1;
        compProd1.Material_Sell__c = 6;
        compProd1.Plant_Cost__c = 3;
        compProd1.Plant_Sell__c = 6;        
        compProd1.Labour_Cost__c = 3;
        compProd1.Labour_Sell__c = 6; 
        compProd1.RecordTypeId = ProductComponentRecordTypeId;
        insert compProd1;

        // create component product
        Product2 compProd2 = new Product2();
        compProd2.Allow_Multiple_Products__c = false;
        compProd2.IsActive = true;
        compProd2.Name = 'component product 2';
        compProd2.Material_Cost__c = 1;
        compProd2.Material_Sell__c = 4;
        compProd2.Plant_Cost__c = 2;
        compProd2.Plant_Sell__c = 4;        
        compProd2.Labour_Cost__c = 2;
        compProd2.Labour_Sell__c = 4;        
        compProd2.RecordTypeId = ProductComponentRecordTypeId;
        insert compProd2;

        // create component product
        Product2 compProd3 = new Product2();
        compProd3.Allow_Multiple_Products__c = false;
        compProd3.IsActive = true;
        compProd3.Name = 'component product 3';
        compProd3.Material_Cost__c = 0;
        compProd3.Material_Sell__c = 6;
        compProd3.Plant_Cost__c = 3;
        compProd3.Plant_Sell__c = 6;        
        compProd3.Labour_Cost__c = 3;
        compProd3.Labour_Sell__c = 6; 
        compProd3.RecordTypeId = ProductComponentRecordTypeId;
        insert compProd3;
        
        Product_Kit__c pk1 = new Product_Kit__c();
        pk1.Parent_Product__c = kitProd.id;
        pk1.Salesforce_Product__c = compProd1.id;
        pk1.Quantity__c = 1;
        insert pk1;

        Product_Kit__c pk2 = new Product_Kit__c();
        pk2.Parent_Product__c = kitProd.id;
        pk2.Salesforce_Product__c = compProd2.id;
        pk2.Quantity__c = 2;
        insert pk2;

        compProd2.Material_Cost__c = 2;
        update compProd2;
        
        compProd1.Material_Cost__c = 3;
        update compProd1;

        compProd3.Material_Cost__c = 1;
        update compProd3;
        
        OpportunityLineItem__c oli1 = new OpportunityLineItem__c();
        oli1.OpportunityId__c = op.id;
        oli1.Quantity__c = 1;
        oli1.Product2Id__c = kitProd.id;
        oli1.UnitPrice__c = 1;
        insert oli1;

        Site_Asset__c sa = new Site_Asset__c();
        sa.Site__c = site.Id;
        insert sa;
        
        Site_Asset__c sa2 = new Site_Asset__c();
        sa2.Site__c = site.Id;
        insert sa2;

        Site_Asset_Value_Estimate_Product_Join__c savEpj = new Site_Asset_Value_Estimate_Product_Join__c();
        savEpj.Estimate_Product__c = oli1.Id;
        savEpj.Site_Asset__c = sa.Id;
        insert savEpj;

        OpportunityLineItem__c oli2 = new OpportunityLineItem__c();
        oli2.OpportunityId__c = op.id;
        oli2.Quantity__c = 1;
        oli2.Product2Id__c = compProd3.id;
        oli2.UnitPrice__c = 1;
        insert oli2;

        Site_Asset_Value_Estimate_Product_Join__c savEpj2 = new Site_Asset_Value_Estimate_Product_Join__c();
        savEpj2.Estimate_Product__c = oli2.Id;
        savEpj2.Site_Asset__c = sa2.Id;
        insert savEpj2;


        //
        // TEST
        // 
        
        test.startTest();

        CCMI__Milestone_Project__c prj = new CCMI__Milestone_Project__c();
        prj.CCMI__Opportunity__c = op.id;
        prj.Name = 'test';
        insert prj;                
        
        // call invokable method... 
        /*List<r3CreateProjectBOMItems.request> reqs = new List<r3CreateProjectBOMItems.request>();
        r3CreateProjectBOMItems.request req = new r3CreateProjectBOMItems.request();
        req.projectId = prj.id;
        req.estimateId = op.id;        
        reqs.add(req);
        r3CreateProjectBOMItems.createBOMItems(reqs);*/
        
        test.stopTest();
        
        //
        // VALIDATION
        // 
        
        // check that BOM items are created as expected...
        List<Project_BOM_Item__c> pbis = [SELECT id, name, cost_price__c, Estimate_Product_Id__c FROM Project_BOM_Item__c WHERE Milestone_Project__c = :prj.id];
        system.assertEquals(2, pbis.size());
        system.debug('CAS>>> '+pbis);


        // check that BOM item Joins are created as expected...
        List<Site_Asset_BOM_Join__c> allBjs = [SELECT id, name, Site_Asset__c, Project_BOM_Item__c FROM Site_Asset_BOM_Join__c ];
        system.assertEquals(2, allBjs.size());

        List<Site_Asset_BOM_Join__c> bjs = [SELECT id, name, Site_Asset__c, Project_BOM_Item__c FROM Site_Asset_BOM_Join__c WHERE Project_BOM_Item__c = :pbis[0].Id];
        system.assertEquals(1, bjs.size());
        system.assertEquals(sa.Id, bjs[0].Site_Asset__c);
        system.assertEquals(pbis[0].Id, bjs[0].Project_BOM_Item__c);
        system.debug('CAS>>> '+bjs);

    }
}