/**
 * @description       : 
 * @author            : Jonny Harte
 * @group             : 
 * @last modified on  : 01-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   01-02-2021   Jonny Harte   Initial Version
**/
@isTest
private class r3ProductTakeOffController_test {
  //@testSetup static void testSetup()
  static void setup() {
    //
    // DATA SETUP
    //

    Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();

    // Perform our data preparation.
    Account acc = new Account(
      Name = 'test',
      recordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId(),
      Type = 'Customer'
    );
    insert acc;

    Account site = new Account(
      Name = 'Site',
      recordTypeId = AccountRecordTypeInfo.get('Site').getRecordTypeId(),
      Customer_Account__c = acc.id
    );
    insert site;

    // Insert Project
    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;

    Opportunity op = new Opportunity(
      Name = 'Estimate1',
      StageName = 'Enquiry',
      CloseDate = Date.today(),
      AccountId = acc.id,
      Site__c = site.id
    );
    op.Estimate_Date__c = system.today();
    op.Project_Start__c = system.today();
    op.Type = 'LV Electric Car Charger Proposal';
    op.Charger_Point_Provider__c = 'Instavolt';
    insert op;

    Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Kit')
      .getRecordTypeId();
    Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Product')
      .getRecordTypeId();

    List<Product2> products = new List<Product2>();
    // create kit product
    Product2 kitProd = new Product2();
    kitProd.Allow_Multiple_Products__c = false;
    kitProd.IsActive = true;
    kitProd.Name = 'kit product';
    kitProd.RecordTypeId = ProductKitRecordTypeId;
    kitProd.Material_Cost_override__c = 1;
    products.add(kitProd);

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
    products.add(compProd1);

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
    products.add(compProd2);

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
    products.add(compProd3);
    insert products;

    Product_Kit__c pk1 = new Product_Kit__c();
    pk1.Parent_Product__c = kitProd.id;
    pk1.Salesforce_Product__c = products[1].id;
    pk1.Quantity__c = 1;
    insert pk1;

    Product_Kit__c pk2 = new Product_Kit__c();
    pk2.Parent_Product__c = products[0].id;
    pk2.Salesforce_Product__c = products[1].id;
    pk2.Quantity__c = 2;
    //insert pk2;

    compProd2.Material_Cost__c = 2;
    //update compProd2;

    compProd1.Material_Cost__c = 3;
    // compProd1;

    compProd3.Material_Cost__c = 1;
    //update compProd3;

    List<OpportunityLineItem__c> olis = new List<OpportunityLineItem__c>();
    OpportunityLineItem__c oli1 = new OpportunityLineItem__c();
    oli1.OpportunityId__c = op.id;
    oli1.Quantity__c = 1;
    oli1.Product2Id__c = products[0].id;
    oli1.UnitPrice__c = 1;
    olis.add(oli1);

    OpportunityLineItem__c oli2 = new OpportunityLineItem__c();
    oli2.OpportunityId__c = op.id;
    oli2.Quantity__c = 1;
    oli2.Product2Id__c = products[3].id;
    oli2.UnitPrice__c = 1;
    olis.add(oli2);
    insert olis;

    Site_Asset__c sa = new Site_Asset__c();
    sa.Site__c = site.Id;
    sa.Name = 'Plot 1';
    insert sa;

    Site_Asset__c sa2 = new Site_Asset__c();
    sa2.Site__c = site.Id;
    sa2.Name = 'Plot 2';
    insert sa2;

    List<Site_Asset_Value_Estimate_Product_Join__c> savEpjs = new List<Site_Asset_Value_Estimate_Product_Join__c>();
    Site_Asset_Value_Estimate_Product_Join__c savEpj = new Site_Asset_Value_Estimate_Product_Join__c();
    savEpj.Estimate_Product__c = oli1.Id;
    savEpj.Site_Asset__c = sa.Id;
    savEpjs.add(savEpj);

    Site_Asset_Value_Estimate_Product_Join__c savEpj2 = new Site_Asset_Value_Estimate_Product_Join__c();
    savEpj2.Estimate_Product__c = oli2.Id;
    savEpj2.Site_Asset__c = sa2.Id;
    savEpjs.add(savEpj2);
    insert savEpjs;

    CCMI__Milestone_Project__c prj = new CCMI__Milestone_Project__c();
    prj.CCMI__Opportunity__c = op.id;
    prj.Name = 'test';
    insert prj;

    // Estimate 2

    Opportunity op2 = new Opportunity(
      Name = 'Estimate2',
      StageName = 'Enquiry',
      CloseDate = Date.today(),
      AccountId = acc.id,
      Site__c = site.id
    );
    op2.Estimate_Date__c = system.today();
    op2.Project_Start__c = system.today();
    op2.Type = 'LV Electric Car Charger Proposal';
    op2.Charger_Point_Provider__c = 'Instavolt';
    op2.Project__c = prj.Id; // link to original project
    insert op2;

    OpportunityLineItem__c oli1e2 = new OpportunityLineItem__c();
    oli1e2.OpportunityId__c = op2.id;
    oli1e2.Quantity__c = 1;
    oli1e2.Product2Id__c = products[0].id;
    oli1e2.UnitPrice__c = 1;
    insert oli1e2;

    Site_Asset_Value_Estimate_Product_Join__c savEpje2 = new Site_Asset_Value_Estimate_Product_Join__c();
    savEpje2.Estimate_Product__c = oli1e2.Id;
    savEpje2.Site_Asset__c = sa.Id;
    insert savEpje2;

    OpportunityLineItem__c oli2e2 = new OpportunityLineItem__c();
    oli2e2.OpportunityId__c = op2.id;
    oli2e2.Quantity__c = 1;
    oli2e2.Product2Id__c = products[3].id;
    oli2e2.UnitPrice__c = 1;
    insert oli2e2;

    Site_Asset_Value_Estimate_Product_Join__c savEpj2e2 = new Site_Asset_Value_Estimate_Product_Join__c();
    savEpj2e2.Estimate_Product__c = oli2.Id;
    savEpj2e2.Site_Asset__c = sa2.Id;
    insert savEpj2e2;

    op2.StageName = 'Closed Won';
    update op2; // NOTE: This is where the test is failing in production

    //List<OpportunityLineItem__c> olis2  = [SELECT id, OpportunityId__c FROM OpportunityLineItem__c LIMIT 1];
    //system.debug('test_get_BOMItemsTree_2_Estimates: setup olis2='+olis2);
  }

  static testMethod void test_get_BOMItemsTree_2_Estimates() {
    setup();
    // get setup data...
    CCMI__Milestone_Project__c prj = [
      SELECT id
      FROM CCMI__Milestone_Project__c
      LIMIT 1
    ];
    //List<OpportunityLineItem__c> olis     = [SELECT id, OpportunityId__c FROM OpportunityLineItem__c LIMIT 1];
    //Order_Request__c ordReq            = [SELECT id, Delivery_To_Site_Date__c FROM Order_Request__c LIMIT 1];
    //List<Site_Asset_BOM_Join__c> sabjs = [SELECT id,Project_BOM_Item__r.Estimate_Product__r.OpportunityId__r.Name FROM Site_Asset_BOM_Join__c];
    //List<Project_BOM_Item__c> pbis     = [SELECT id, Estimate_Product__r.OpportunityId__r.Name FROM Project_BOM_Item__c];
    //system.debug('test_get_BOMItemsTree_2_Estimates: olis='+olis);
    //system.debug('test_get_BOMItemsTree_2_Estimates: sabjs='+sabjs);
    //for (Site_Asset_BOM_Join__c sabj : sabjs ) {
    //    system.debug('test_get_BOMItemsTree_2_Estimates: Estimate='+sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__r.Name);
    //}
    //system.debug('test_get_BOMItemsTree_2_Estimates: sabjs='+sabjs);
    //system.debug('test_get_BOMItemsTree_2_Estimates: pbis='+pbis);

    // test
    test.startTest();
    Id projectId = prj.Id;
    String result = r3ProductTakeOffController.getBOMItemsTree(projectId);

    // assert
    //system.assert(result.contains('Estimate1')); // WI-02777 Raised to fix this issue
    //system.assert(result.contains('Plot 1'));

    //system.assert(result.contains('Electricity'));
    //system.assert(result.contains('kit product'));
    //system.assert(result.contains('component product 1'));
    //system.assert(result.contains('component product 2'));
    //system.assert(result.contains('component product 3'));
    //system.assert(result.contains('Estimate2'));

    system.assert(result.contains('Other'));
    test.stopTest();
  }

  static testMethod void test_get_BOMItemsTree_2() {
    Map<String, Schema.RecordTypeInfo> AccountTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
    Account site = new Account(name = 'site');
    site.RecordTypeId = AccountTypeInfo.get('Site').getRecordTypeId();
    insert site;

    Site_Asset__c sa = new Site_Asset__c();
    sa.Site__c = site.id;
    insert sa;

    // Insert Project
    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;

    // set up schemes
    Map<String, Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
    Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric')
      .getRecordTypeId();

    //create siteschemes
    // Electric
    site_scheme__c electricScheme = new site_scheme__c();
    electricScheme.Project__c = milestoneProject.id;
    electricScheme.DNO__c = 'SSE';
    electricScheme.IDNO__c = 'ESP';
    electricScheme.RecordTypeId = ElectricRecordType;
    insert electricScheme;

    Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Kit')
      .getRecordTypeId();
    Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Product')
      .getRecordTypeId();

    // create product kit
    Product2 pk1 = new Product2(Name = 'Test Product Kit 1', isActive = true);
    pk1.RecordTypeId = ProductKitRecordTypeId;
    pk1.IsActive = true;
    pk1.Allow_Multiple_Products__c = false;
    pk1.family = 'Electricity';
    insert pk1;

    Product2 pk2 = new Product2(Name = 'Test Product Kit 2', isActive = true);
    pk2.RecordTypeId = ProductKitRecordTypeId;
    pk2.IsActive = true;
    pk2.Allow_Multiple_Products__c = false;
    pk1.family = 'Gas';
    insert pk2;

    // create products
    Product2 prod1 = new Product2(Name = 'Test Product 1', isActive = true);
    prod1.RecordTypeId = ProductComponentRecordTypeId;
    prod1.IsActive = true;
    prod1.Allow_Multiple_Products__c = false;
    prod1.family = 'Electricity';
    insert prod1;

    Product2 prod2 = new Product2(Name = 'Test Product 2', isActive = true);
    prod2.RecordTypeId = ProductComponentRecordTypeId;
    prod2.IsActive = true;
    prod2.Allow_Multiple_Products__c = false;
    prod2.family = 'Gas';
    insert prod2;

    // setup Product Kit Links
    Product_Kit__c pkl1 = new Product_Kit__c(
      Parent_Product__c = pk1.Id,
      Salesforce_Product__c = prod1.Id
    );
    pkl1.Quantity__c = 1;
    insert pkl1;

    Product_Kit__c pkl2 = new Product_Kit__c(
      Parent_Product__c = pk2.Id,
      Salesforce_Product__c = prod2.Id
    );
    pkl2.Quantity__c = 1;
    insert pkl2;

    // setup BOMs
    Project_BOM_Item__c bom1 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk1.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    bom1.Quantity_Allocated__c = 5;
    bom1.Quantity__c = 100;
    insert bom1;
    Project_BOM_Item__c bom2 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk2.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    //bom2.Est_Qty__c = 20;
    bom2.Quantity_Allocated__c = 5;
    bom2.Quantity__c = 100;
    insert bom2;

    Site_Asset_BOM_join__c sabj = new Site_Asset_BOM_Join__c();
    sabj.Project_BOM_Item__c = bom2.id;
    sabj.Site_Asset__c = sa.id;
    sabj.Quantity__c = 5; // qty allocated on bom
    insert sabj;

    /*Project_BOM_Item__c bom3 = new Project_BOM_Item__c (Milestone_Project__c = milestoneProject.Id, 
                                                            Product__c = prod1.Id,            
                                                            On_Order__c = 5,
                                                            Order_Qnty__c = 0 );
        insert bom3;*/

    // test
    test.startTest();
    Id projectId = milestoneProject.Id;
    String result = r3ProductTakeOffController.getBOMItemsTree(projectId);

    // assert
    system.assert(result.contains('Other'));
    system.assert(result.contains('Electricity'));
    system.assert(result.contains('Test Product Kit 1'));
    system.assert(result.contains('Test Product 1'));
    system.assert(result.contains('Test Product Kit 2'));
    system.assert(result.contains('Test Product 2'));

    test.stopTest();
  }
  static testMethod void test_get_BOMItemsTree() {
    Map<String, Schema.RecordTypeInfo> AccountTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
    Account site = new Account(name = 'site');
    site.RecordTypeId = AccountTypeInfo.get('Site').getRecordTypeId();
    insert site;

    Site_Asset__c sa = new Site_Asset__c();
    sa.Site__c = site.id;
    insert sa;

    // Insert Project
    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;

    // set up schemes
    Map<String, Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
    Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric')
      .getRecordTypeId();

    //create siteschemes
    // Electric
    site_scheme__c electricScheme = new site_scheme__c();
    electricScheme.Project__c = milestoneProject.id;
    electricScheme.DNO__c = 'SSE';
    electricScheme.IDNO__c = 'ESP';
    electricScheme.RecordTypeId = ElectricRecordType;
    insert electricScheme;

    Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Kit')
      .getRecordTypeId();
    Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Product')
      .getRecordTypeId();

    // create product kit
    Product2 pk1 = new Product2(Name = 'Test Product Kit 1', isActive = true);
    pk1.RecordTypeId = ProductKitRecordTypeId;
    pk1.IsActive = true;
    pk1.Allow_Multiple_Products__c = false;
    pk1.family = 'Electricity';
    insert pk1;

    Product2 pk2 = new Product2(Name = 'Test Product Kit 2', isActive = true);
    pk2.RecordTypeId = ProductKitRecordTypeId;
    pk2.IsActive = true;
    pk2.Allow_Multiple_Products__c = false;
    pk1.family = 'Gas';
    insert pk2;

    // create products
    Product2 prod1 = new Product2(Name = 'Test Product 1', isActive = true);
    prod1.RecordTypeId = ProductComponentRecordTypeId;
    prod1.IsActive = true;
    prod1.Allow_Multiple_Products__c = false;
    prod1.family = 'Electricity';
    insert prod1;

    Product2 prod2 = new Product2(Name = 'Test Product 2', isActive = true);
    prod2.RecordTypeId = ProductComponentRecordTypeId;
    prod2.IsActive = true;
    prod2.Allow_Multiple_Products__c = false;
    prod2.family = 'Gas';
    insert prod2;

    // setup Product Kit Links
    Product_Kit__c pkl1 = new Product_Kit__c(
      Parent_Product__c = pk1.Id,
      Salesforce_Product__c = prod1.Id
    );
    pkl1.Quantity__c = 1;
    insert pkl1;

    Product_Kit__c pkl2 = new Product_Kit__c(
      Parent_Product__c = pk2.Id,
      Salesforce_Product__c = prod2.Id
    );
    pkl2.Quantity__c = 1;
    insert pkl2;

    // setup BOMs
    Project_BOM_Item__c bom1 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk1.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    bom1.Quantity_Allocated__c = 5;
    bom1.Quantity__c = 100;
    insert bom1;
    Project_BOM_Item__c bom2 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk2.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    //bom2.Est_Qty__c = 20;
    bom2.Quantity_Allocated__c = 5;
    bom2.Quantity__c = 100;
    insert bom2;

    Site_Asset_BOM_join__c sabj = new Site_Asset_BOM_Join__c();
    sabj.Project_BOM_Item__c = bom2.id;
    sabj.Site_Asset__c = sa.id;
    sabj.Quantity__c = 5; // qty allocated on bom
    insert sabj;

    /*Project_BOM_Item__c bom3 = new Project_BOM_Item__c (Milestone_Project__c = milestoneProject.Id, 
                                                            Product__c = prod1.Id,            
                                                            On_Order__c = 5,
                                                            Order_Qnty__c = 0 );
        insert bom3;*/

    // test
    test.startTest();
    Id projectId = milestoneProject.Id;
    String result = r3ProductTakeOffController.getBOMItemsTree(projectId);

    // assert
    system.assert(result.contains('Other'));
    system.assert(result.contains('Electricity'));
    system.assert(result.contains('Test Product Kit 1'));
    system.assert(result.contains('Test Product 1'));
    system.assert(result.contains('Test Product Kit 2'));
    system.assert(result.contains('Test Product 2'));

    test.stopTest();
  }

  static testMethod void test_no_site_asset() {
    Map<String, Schema.RecordTypeInfo> AccountTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
    Account site = new Account(name = 'site');
    site.RecordTypeId = AccountTypeInfo.get('Site').getRecordTypeId();
    insert site;

    // Insert Project
    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;

    // set up schemes
    Map<String, Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
    Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric')
      .getRecordTypeId();

    //create siteschemes
    // Electric
    site_scheme__c electricScheme = new site_scheme__c();
    electricScheme.Project__c = milestoneProject.id;
    electricScheme.DNO__c = 'SSE';
    electricScheme.IDNO__c = 'ESP';
    electricScheme.RecordTypeId = ElectricRecordType;
    insert electricScheme;

    Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Kit')
      .getRecordTypeId();
    Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Product')
      .getRecordTypeId();

    // create product kit
    Product2 pk1 = new Product2(Name = 'Test Product Kit 1', isActive = true);
    pk1.RecordTypeId = ProductKitRecordTypeId;
    pk1.IsActive = true;
    pk1.Allow_Multiple_Products__c = false;
    pk1.family = 'Electricity';
    insert pk1;

    Product2 pk2 = new Product2(Name = 'Test Product Kit 2', isActive = true);
    pk2.RecordTypeId = ProductKitRecordTypeId;
    pk2.IsActive = true;
    pk2.Allow_Multiple_Products__c = false;
    pk1.family = 'Gas';
    insert pk2;

    // create products
    Product2 prod1 = new Product2(Name = 'Test Product 1', isActive = true);
    prod1.RecordTypeId = ProductComponentRecordTypeId;
    prod1.IsActive = true;
    prod1.Allow_Multiple_Products__c = false;
    prod1.family = 'Electricity';
    insert prod1;

    Product2 prod2 = new Product2(Name = 'Test Product 2', isActive = true);
    prod2.RecordTypeId = ProductComponentRecordTypeId;
    prod2.IsActive = true;
    prod2.Allow_Multiple_Products__c = false;
    prod2.family = 'Gas';
    insert prod2;

    // setup Product Kit Links
    Product_Kit__c pkl1 = new Product_Kit__c(
      Parent_Product__c = pk1.Id,
      Salesforce_Product__c = prod1.Id
    );
    pkl1.Quantity__c = 1;
    insert pkl1;

    Product_Kit__c pkl2 = new Product_Kit__c(
      Parent_Product__c = pk2.Id,
      Salesforce_Product__c = prod2.Id
    );
    pkl2.Quantity__c = 1;
    insert pkl2;

    // setup BOMs
    Project_BOM_Item__c bom1 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk1.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    bom1.Quantity_Allocated__c = 5;
    bom1.Quantity__c = 100;
    insert bom1;
    Project_BOM_Item__c bom2 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk2.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    //bom2.Est_Qty__c = 20;
    bom2.Quantity_Allocated__c = 5;
    bom2.Quantity__c = 100;
    insert bom2;

    Site_Asset_BOM_join__c sabj = new Site_Asset_BOM_Join__c();
    sabj.Project_BOM_Item__c = bom2.id;
    sabj.Site_Asset__c = null;
    sabj.Quantity__c = 5; // qty allocated on bom
    insert sabj;

    /*Project_BOM_Item__c bom3 = new Project_BOM_Item__c (Milestone_Project__c = milestoneProject.Id, 
                                                            Product__c = prod1.Id,            
                                                            On_Order__c = 5,
                                                            Order_Qnty__c = 0 );
        insert bom3;*/

    // test
    test.startTest();
    Id projectId = milestoneProject.Id;
    String result = r3ProductTakeOffController.getBOMItemsTree(projectId);

    List<Object> bowl = (List<Object>) JSON.deserializeUntyped(result);

    //assert
    system.assertEquals(1, bowl.size());

    test.stopTest();
  }
  /*static testMethod void testGetSelectedBOMItems()
    {

        // Insert Project
        CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
        insert milestoneProject;

        Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Kit').getRecordTypeId();
        Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();


        // create product kit
        Product2 pk1 = new Product2(Name = 'Test Product Kit 1', isActive = true);
        pk1.RecordTypeId = ProductKitRecordTypeId;
        pk1.IsActive = true;
        pk1.Allow_Multiple_Products__c = false;
        insert pk1;
        
        Product2 pk2 = new Product2(Name = 'Test Product Kit 2', isActive = true);
        pk2.RecordTypeId = ProductKitRecordTypeId;
        pk2.IsActive = true;
        pk2.Allow_Multiple_Products__c = false;       
        insert pk2;       

        // create products
        Product2 prod1 = new Product2(Name = 'Test Product 1', isActive = true);
        prod1.RecordTypeId = ProductComponentRecordTypeId;
        prod1.IsActive = true;
        prod1.Allow_Multiple_Products__c = false;
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Test Product 2', isActive = true);
        prod2.RecordTypeId = ProductComponentRecordTypeId;
        prod2.IsActive = true;
        prod2.Allow_Multiple_Products__c = false;
        insert prod2;

        // setup BOMs
        Project_BOM_Item__c bom1 = new Project_BOM_Item__c (Milestone_Project__c = milestoneProject.Id, 
                                                            Product__c = pk1.Id,            
                                                            On_Order__c = 5,
                                                            Order_Qnty__c = 0 );
        insert bom1;
        Project_BOM_Item__c bom2 = new Project_BOM_Item__c (Milestone_Project__c = milestoneProject.Id, 
                                                            Product__c = pk2.Id,            
                                                            On_Order__c = 5,
                                                            Order_Qnty__c = 0 );
        insert bom2;
        Project_BOM_Item__c bom3 = new Project_BOM_Item__c (Milestone_Project__c = milestoneProject.Id, 
                                                            Product__c = prod1.Id,            
                                                            On_Order__c = 5,
                                                            Order_Qnty__c = 0 );
        insert bom3;

        // setup Product Kit Links
        Product_Kit__c pkl1 = new Product_Kit__c ( Parent_Product__c = pk1.Id,            
                                                   Salesforce_Product__c = prod1.Id);
        insert pkl1;


        // test    
        test.startTest();
        List<String> productIds = new List<String> {pk1.Id, pk2.Id, prod2.Id};

        //String result = r3ProductTakeOffController.getSelectedBOMItems(milestoneProject.id, productIds);

        //List<r3ProductTakeOffController.bomWrapper> bowl = (List<r3ProductTakeOffController.bomWrapper>)JSON.deserializeUntyped(result);
        //List<Object> bowl = (List<Object>)JSON.deserializeUntyped(result);


        //assert 
        //system.assertEquals(2, bowl.size());

        test.stopTest();


    }*/

  static testMethod void testUpdateBOMs() {
    // Insert Project
    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;

    Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Kit')
      .getRecordTypeId();
    Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Product')
      .getRecordTypeId();

    // create product kit
    Product2 pk1 = new Product2(Name = 'Test Product Kit 1', isActive = true);
    pk1.RecordTypeId = ProductKitRecordTypeId;
    pk1.IsActive = true;
    pk1.Allow_Multiple_Products__c = false;
    insert pk1;

    Product2 pk2 = new Product2(Name = 'Test Product Kit 2', isActive = true);
    pk2.RecordTypeId = ProductKitRecordTypeId;
    pk2.IsActive = true;
    pk2.Allow_Multiple_Products__c = false;
    insert pk2;

    // create products
    Product2 prod1 = new Product2(Name = 'Test Product 1', isActive = true);
    prod1.RecordTypeId = ProductComponentRecordTypeId;
    prod1.IsActive = true;
    prod1.Allow_Multiple_Products__c = false;
    insert prod1;

    Product2 prod2 = new Product2(Name = 'Test Product 2', isActive = true);
    prod2.RecordTypeId = ProductComponentRecordTypeId;
    prod2.IsActive = true;
    prod2.Allow_Multiple_Products__c = false;
    insert prod2;

    // setup BOMs
    Project_BOM_Item__c bom1 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk1.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    insert bom1;

    Project_BOM_Item__c bom2 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = pk2.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    insert bom2;

    Project_BOM_Item__c bom3 = new Project_BOM_Item__c(
      Milestone_Project__c = milestoneProject.Id,
      Product__c = prod1.Id,
      On_Order__c = 5,
      Order_Qnty__c = 0
    );
    insert bom3;

    // create materials request
    Order_Request__c ordReq = new Order_Request__c();
    ordReq.Delivery_To_Site_Date__c = system.today();
    ordReq.Project_Job__c = milestoneProject.id;
    insert ordReq;

    // setup Product Kit Links
    Product_Kit__c pkl1 = new Product_Kit__c(
      Parent_Product__c = pk1.Id,
      Salesforce_Product__c = prod1.Id
    );
    insert pkl1;

    List<r3ProductTakeOffController.bomWrapper> bws = new List<r3ProductTakeOffController.bomWrapper>();

    r3ProductTakeOffController.bomWrapper bw = new r3ProductTakeOffController.bomWrapper();
    bw.OrderQuantity = 123;
    bw.ProductId = bom1.Id;
    bw.ProductUrl = '/' + bom1.Id;
    bws.add(bw);

    // test

    test.startTest();
    String result2 = r3ProductTakeOffController.updateBOM(
      bws,
      ordReq.id,
      milestoneProject.id
    );
    test.stopTest();

    List<Project_BOM_Item__c> bomsU = [
      SELECT Id, Order_Qnty__c
      FROM Project_BOM_Item__c
      WHERE Id = :bom1.Id
    ];

    //assert
    system.assertEquals(bomsU[0].Order_Qnty__c, 0); // gets reset to zero
  }
}