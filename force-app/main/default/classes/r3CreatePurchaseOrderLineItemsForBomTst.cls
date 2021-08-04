@isTest
public class r3CreatePurchaseOrderLineItemsForBomTst {
  @testSetup
  static void testSetup() {
    //
    // DATA SETUP
    //

    Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();

    // Perform our data preparation.
    Account acc = new Account(
      Name = 'test',
      recordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId(),
      Type = 'Customer'
    );
    insert acc;

    Account site = new Account(
      Name = 'Site Test',
      recordTypeId = AccountRecordTypeInfo.get('Site').getRecordTypeId(),
      Customer_Account__c = acc.id
    );
    insert site;

    Opportunity op = new Opportunity(
      Name = 'test',
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

    Id productKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Kit')
      .getRecordTypeId();
    Id productComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get('Product')
      .getRecordTypeId();

    // create BORIS code
    List<BORIS_Codes__c> bcs = new List<BORIS_Codes__c>();
    bcs.add(
      new BORIS_Codes__c(
        Name = 'boris code name',
        BORIS_Description__c = 'boris code description',
        Worksheets__c = '14104 : 3 Worksheet;14223 : 3 Worksheet - Multi Task',
        Labour_Cost__c = 10,
        Labour_Sell__c = 12
      )
    );
    insert bcs;

    //List<BORIS_Worksheet_Codes__c > bwcs = new List<BORIS_Worksheet_Codes__c >();
    //bwcs.add(new BORIS_Worksheet_Codes__c (Name = '14223 : 3 Worksheet - Multi Task', Worksheet_Code__c = '14223'));
    //bwcs.add(new BORIS_Worksheet_Codes__c (Name = '14104 : 3 Worksheet', Worksheet_Code__c = '14104'));
    //insert bwcs;

    //List<BORIS_Code_Worksheet_Code_Join__c > bcwcjs = new List<BORIS_Code_Worksheet_Code_Join__c >();
    //bcwcjs.add(new BORIS_Code_Worksheet_Code_Join__c(BORIS_Code__c  = bcs[0].Id, BORIS_Worksheet_Code__c = bwcs[0].Id));
    //bcwcjs.add(new BORIS_Code_Worksheet_Code_Join__c(BORIS_Code__c  = bcs[0].Id, BORIS_Worksheet_Code__c = bwcs[1].Id));
    //insert bcwcjs;

    // create kit product
    Product2 kitProd = new Product2();
    kitProd.Allow_Multiple_Products__c = false;
    kitProd.IsActive = true;
    kitProd.Name = 'kit product';
    kitProd.RecordTypeId = ProductKitRecordTypeId;
    kitProd.Material_Cost_override__c = 1;
    kitProd.BORIS_Codes__c = bcs[0].id;
    insert kitProd;

    // create component product
    List<Product2> compProdsToInsert = new List<Product2>();
    Product2 compProd1 = new Product2();
    compProd1.Allow_Multiple_Products__c = false;
    compProd1.IsActive = true;
    compProd1.Name = 'component product 1';
    compProd1.Material_Cost__c = 1;
    compProd1.Material_Sell__c = 6;
    compProd1.Plant_Cost__c = 3;
    compProd1.Plant_Sell__c = 6;
    compProd1.Labour_Cost__c = 3000;
    compProd1.Labour_Sell__c = 6000;
    compProd1.family = 'Electricity';
    compProd1.RecordTypeId = ProductComponentRecordTypeId;
    compProdsToInsert.add(compProd1);

    // create component product
    Product2 compProd2 = new Product2();
    compProd2.Allow_Multiple_Products__c = false;
    compProd2.IsActive = true;
    compProd2.Name = 'component product 2';
    compProd2.Material_Cost__c = 1;
    compProd2.Material_Sell__c = 4;
    compProd2.Plant_Cost__c = 2;
    compProd2.Plant_Sell__c = 4;
    compProd2.Labour_Cost__c = 2000;
    compProd2.Labour_Sell__c = 4000;
    compProd2.family = 'Electricity';
    compProd2.RecordTypeId = ProductComponentRecordTypeId;
    compProdsToInsert.add(compProd2);

    // create component product
    Product2 compProd3 = new Product2();
    compProd3.Dont_Create_POL__c = true;
    compProd3.Allow_Multiple_Products__c = false;
    compProd3.IsActive = true;
    compProd3.Name = 'component product 3';
    compProd3.Material_Cost__c = 2;
    compProd3.Material_Sell__c = 6;
    compProd3.Plant_Cost__c = 3;
    compProd3.Plant_Sell__c = 6;
    compProd3.Labour_Cost__c = 3000;
    compProd3.Labour_Sell__c = 6000;
    compProd3.family = 'Electricity';
    compProd3.RecordTypeId = ProductComponentRecordTypeId;
    compProdsToInsert.add(compProd3);
    insert compProdsToInsert;

    List<Product_Kit__c> pksToInsert = new List<Product_Kit__c>();
    Product_Kit__c pk1 = new Product_Kit__c();
    pk1.Parent_Product__c = kitProd.id;
    pk1.Salesforce_Product__c = compProdsToInsert[0].id;
    pk1.Quantity__c = 3;
    pksToInsert.add(pk1);

    Product_Kit__c pk2 = new Product_Kit__c();
    pk2.Parent_Product__c = kitProd.id;
    pk2.Salesforce_Product__c = compProdsToInsert[1].id;
    pk2.Quantity__c = 2;
    pksToInsert.add(pk2);
    insert pksToInsert;

    List<Product2> compProdsToUpdate = new List<Product2>();
    compProdsToUpdate.add(
      new Product2(Id = compProdsToInsert[1].Id, Material_Cost__c = 2)
    ); // update compProd2
    compProdsToUpdate.add(
      new Product2(Id = compProdsToInsert[0].Id, Material_Cost__c = 3)
    ); // update compProd1
    compProdsToUpdate.add(
      new Product2(Id = compProdsToInsert[2].Id, Material_Cost__c = 1)
    ); // update compProd3
    update compProdsToUpdate;

    List<OpportunityLineItem__c> olisToInsert = new List<OpportunityLineItem__c>();
    OpportunityLineItem__c oli1 = new OpportunityLineItem__c();
    oli1.OpportunityId__c = op.id;
    oli1.Quantity__c = 2;
    oli1.Product2Id__c = kitProd.id;
    oli1.UnitPrice__c = 1;
    olisToInsert.add(oli1);

    OpportunityLineItem__c oli2 = new OpportunityLineItem__c();
    oli2.OpportunityId__c = op.id;
    oli2.Quantity__c = 3;
    oli2.Product2Id__c = compProd3.id;
    oli2.UnitPrice__c = 1;
    olisToInsert.add(oli2);
    insert olisToInsert;

    List<Site_Asset__c> sasToInsert = new List<Site_Asset__c>();
    Site_Asset__c sa = new Site_Asset__c();
    sa.Site__c = site.Id;
    sa.Plot_Reference__c = 'Plot 1';
    sasToInsert.add(sa);

    Site_Asset__c sa2 = new Site_Asset__c();
    sa2.Site__c = site.Id;
    sa2.Plot_Reference__c = 'Plot 2';
    sasToInsert.add(sa2);
    insert sasToInsert;

    Site_Asset_Value_Estimate_Product_Join__c savEpj = new Site_Asset_Value_Estimate_Product_Join__c();
    savEpj.Estimate_Product__c = olisToInsert[0].Id;
    savEpj.Site_Asset__c = sasToInsert[0].Id;
    insert savEpj;

    Site_Asset_Value_Estimate_Product_Join__c savEpj2 = new Site_Asset_Value_Estimate_Product_Join__c();
    savEpj2.Estimate_Product__c = olisToInsert[0].Id;
    savEpj2.Site_Asset__c = sasToInsert[1].Id;
    insert savEpj2;

    // create project - this in turn will create the BOM items
    CCMI__Milestone_Project__c prj = new CCMI__Milestone_Project__c();
    prj.CCMI__Opportunity__c = op.id;
    prj.Name = 'test';
    insert prj;

    // create an extra manually inserted BOM item...
    Project_BOM_Item__c bom = new Project_BOM_Item__c();
    bom.Milestone_Project__c = prj.Id;
    bom.Product__c = kitProd.Id;
    bom.On_Order__c = 5;
    bom.Order_Qnty__c = 0;
    bom.Override_POL_Rules__c = true;
    insert bom;

    // set up schemes
    Map<String, Schema.RecordTypeInfo> siteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
    Id electricRecordType = SiteSchemeTypeInfo.get('Electric')
      .getRecordTypeId();

    //create siteschemes
    // Electric
    site_scheme__c electricScheme = new site_scheme__c();
    electricScheme.Project__c = prj.id;
    electricScheme.DNO__c = 'SSE';
    electricScheme.IDNO__c = 'ESP';
    electricScheme.RecordTypeId = ElectricRecordType;
    insert electricScheme;

    // create materials request
    Order_Request__c ordReq = new Order_Request__c();
    ordReq.Delivery_To_Site_Date__c = system.today();
    ordReq.Project_Job__c = prj.id;
    insert ordReq;
    
    // the batch job must run to update kit pricing...
    List<Product_Kit__c> kits = [
                SELECT
                Id,
                Delivery_Cost__c,
                Labour_Cost__c,
                Labour_Sell__c,
                Material_Cost__c,
                Material_Sell__c,
                Plant_Cost__c,
                Plant_Sell__c,
                BORIS_Code_Output__c,
                Quantity__c,
                Salesforce_Product__r.Delivery_Cost__c,
                Salesforce_Product__r.Labour_Cost__c,
                Salesforce_Product__r.Labour_Sell__c,
                Salesforce_Product__r.Material_Cost__c,
                Salesforce_Product__r.Material_Sell__c,
                Salesforce_Product__r.Plant_Cost__c,
                Salesforce_Product__r.Plant_Sell__c,
                Salesforce_Product__r.BORIS_Code_Output__c
                FROM Product_Kit__c
            ];
    r3ProductKitProcessor productKitProcessor = new r3ProductKitProcessor();
    productKitProcessor.execute(null, kits);
  }

  static testMethod void test() {
      
    // get setup data...
    CCMI__Milestone_Project__c prj = [
      SELECT id
      FROM CCMI__Milestone_Project__c
      LIMIT 1
    ];
    Order_Request__c ordReq = [
      SELECT id, Delivery_To_Site_Date__c
      FROM Order_Request__c
      LIMIT 1
    ];
    List<Site_Asset_BOM_Join__c> sabjs = [
      SELECT id
      FROM Site_Asset_BOM_Join__c
    ];
    List<Project_BOM_Item__c> pbis = [SELECT id FROM Project_BOM_Item__c];

    List<Id> sabjIds = new List<Id>();
    for (Site_Asset_BOM_Join__c sabj : sabjs)
      sabjIds.add(sabj.Id);

    //
    // TEST
    //

    test.startTest();

    // update BOM items to simulate an order being placed
    List<Project_BOM_Item__c> pbisToUpdate = new List<Project_BOM_Item__c>();
    List<r3CreatePurchaseOrderLineItemsForBom.request> reqLst = new List<r3CreatePurchaseOrderLineItemsForBom.request>();
    List<Id> bomIds = new List<Id>();
    system.debug('R3>>> pbis=' + pbis);
    for (Project_BOM_Item__c pbi : pbis) {
      pbi.Order_Qnty__c = 1;
      pbi.Order_Request__c = ordReq.id;
      pbi.Required_Date__c = ordReq.Delivery_To_Site_Date__c;
      pbisToUpdate.add(pbi);

      // add request...
      r3CreatePurchaseOrderLineItemsForBom.request req = new r3CreatePurchaseOrderLineItemsForBom.request();
      req.bomId = pbi.id;
      reqLst.add(req);
      bomIds.add(pbi.id);
    }
    system.debug('R3>>> pbisToUpdate=' + pbisToUpdate);
    update pbisToUpdate;

    system.debug('R3>>> reqLst=' + reqLst);
    //r3CreatePurchaseOrderLineItemsForBom.createBOMPurchaseOrderLines(reqLst);
    r3CreatePurchaseOrderLineItemsForBom.createProjectTasks(bomIds, sabjIds);
    r3CreatePurchaseOrderLineItemsForBom.createPurchaseOrderLines(bomIds);

    // check that POL items are created as expected...
    List<Purchase_Order_Line__c> pols1 = [
      SELECT
        id,
        name,
        Quantity__c,
        product__r.name,
        Project_BOM_Item__c,
        Product__c
      FROM Purchase_Order_Line__c
      WHERE Milestone_Project__c = :prj.id
    ];
    system.debug('R3>>> pols 1' + pols1);

    // make a second request
    pbisToUpdate.clear();
    reqLst.clear();
    bomIds.clear();
    system.debug('R3>>> pbis2=' + pbis);
    for (Project_BOM_Item__c pbi : pbis) {
      pbi.Order_Qnty__c = 1;
      pbi.Order_Request__c = ordReq.id;
      pbi.Required_Date__c = ordReq.Delivery_To_Site_Date__c;
      pbisToUpdate.add(pbi);

      // add request...
      r3CreatePurchaseOrderLineItemsForBom.request req = new r3CreatePurchaseOrderLineItemsForBom.request();
      req.bomId = pbi.id;
      reqLst.add(req);
      bomIds.add(pbi.id);
    }
    system.debug('R3>>> pbisToUpdate2=' + pbisToUpdate);
    update pbisToUpdate;

    // create POLs...
    system.debug('R3>>> reqLst=' + reqLst);
    //r3CreatePurchaseOrderLineItemsForBom.createBOMPurchaseOrderLines(reqLst);
    r3CreatePurchaseOrderLineItemsForBom.createProjectTasks(bomIds, sabjIds);
    r3CreatePurchaseOrderLineItemsForBom.createPurchaseOrderLines(bomIds);

    test.stopTest();

    //
    // VALIDATION
    //

    // check that POL items are created as expected...
    List<Purchase_Order_Line__c> pols = [
      SELECT
        id,
        name,
        Quantity__c,
        product__r.name,
        Project_BOM_Item__c,
        Product__c
      FROM Purchase_Order_Line__c
      WHERE Milestone_Project__c = :prj.id
    ];
    system.debug('R3>>> pols' + pols);
    for (Purchase_Order_Line__c pol : pols) {
      if (pol.product__r.name == 'component product 1')
        system.assertEquals(12, pol.Quantity__c);
      else if (pol.product__r.name == 'component product 2')
        system.assertEquals(8, pol.Quantity__c);
      else if (pol.product__r.name == 'component product 3')
        system.assertEquals(1, pol.Quantity__c);
      else
        system.assert(false, 'Invalid product found!');
    }
    system.assertEquals(4, pols.size()); // 2 are Manual so no POLs created

    List<CCMI__Milestone_Task__c> tasks = [
      SELECT
        Id,
        Name,
        CCMI__Start__c,
        CCMI__Duration__c,
        CCMI__End__c,
        Total_Labour_Cost__c,
        Total_Labour_Hours__c,
        BORIS_Codes__c
      FROM CCMI__Milestone_Task__c
      WHERE CCMI__Milestone_Project__c = :prj.id
    ];
    system.debug('R3>>> ' + tasks);
    system.assertEquals(1, tasks.size());
      
    system.debug('R3>>> Total_Labour_Cost__c '+tasks[0].Total_Labour_Cost__c);
    system.debug('R3>>> CCMI__Duration__c '+tasks[0].CCMI__Duration__c);
    system.debug('R3>>> Total_Labour_Hours__c '+tasks[0].Total_Labour_Hours__c);
    system.debug('R3>>> BORIS_Codes__c '+tasks[0].BORIS_Codes__c);
      
    system.assertEquals(40, tasks[0].Total_Labour_Cost__c); // WI-02777 Raised to fix this issue
    system.assertEquals(1, tasks[0].CCMI__Duration__c);// WI-02777 Raised to fix this issue
    system.assertEquals(1, tasks[0].Total_Labour_Hours__c);
    system.assertEquals(
      '"","boris code name","boris code description","14223,14104","Plot 1","boris code name","boris code description","14223,14104","Plot 2","boris code name","boris code description","14223,14104"',
      tasks[0].BORIS_Codes__c
    );
  }
}