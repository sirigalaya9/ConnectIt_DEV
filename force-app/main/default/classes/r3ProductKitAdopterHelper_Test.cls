@isTest
private class r3ProductKitAdopterHelper_Test 
{  
 
    static testMethod void testGetComponentProducts()
    {
        // Insert Project
        CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
        insert milestoneProject;

        // set up schemes
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ChargerRecordType = SiteSchemeTypeInfo.get('Charger').getRecordTypeId();
        Id StreetLightingRecordType = SiteSchemeTypeInfo.get('StreetLighting').getRecordTypeId();
        Id GasRecordType = SiteSchemeTypeInfo.get('Gas').getRecordTypeId();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        Id WaterRecordType = SiteSchemeTypeInfo.get('Water').getRecordTypeId();
        
        //create siteschemes
        
        // Charger scheme
        site_scheme__c chargerScheme = new site_scheme__c();
        chargerScheme.Project__c = milestoneProject.id;
        chargerScheme.Charger_Provider__c = 'Engenie';
        chargerScheme.DNO__c = 'SSE';
        chargerScheme.IDNO__c = 'ESP';
        chargerScheme.RecordTypeId = ChargerRecordType;
        insert chargerScheme;

        // Street Light
        site_scheme__c streetLightScheme = new site_scheme__c();
        streetLightScheme.Project__c = milestoneProject.id;
        streetLightScheme.DNO__c = 'SSE';
        streetLightScheme.IDNO__c = 'ESP';
        streetLightScheme.RecordTypeId = StreetLightingRecordType;
        insert streetLightScheme;
                   
        // Gas
        site_scheme__c gasScheme = new site_scheme__c();
        gasScheme.Project__c = milestoneProject.id;
        gasScheme.GT__c = 'SGN';
        gasScheme.IGT__c = '';
        gasScheme.RecordTypeId = GasRecordType;
        insert gasScheme;
        
        // Water
        site_scheme__c waterScheme = new site_scheme__c();
        waterScheme.Project__c = milestoneProject.id;
        waterScheme.Water_Provider__c = 'Affinity Water';
        waterScheme.RecordTypeId = WaterRecordType;
        insert waterScheme;
         
        // Electric
        site_scheme__c electricScheme = new site_scheme__c();
        electricScheme.Project__c = milestoneProject.id;
        electricScheme.DNO__c = 'SSE';
        electricScheme.IDNO__c = 'ESP';
        electricScheme.RecordTypeId = ElectricRecordType;
        insert electricScheme;
        
        Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Kit').getRecordTypeId();
        Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        
        // create product kits
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
        List<Product2> prods = new List<Product2>();
        prods.add(newComponentProduct('Test Product 0', 'SSE', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 1', '', '', 'Electricity'));
        prods.add(newComponentProduct('Test Product 2', 'ESP', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 3', 'ESP', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 4', 'ESP', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 5', 'Affinity Water', '', 'Water'));
        insert prods;

        // setup BOMs
        Project_BOM_Item__c bom1 = new Project_BOM_Item__c();
        bom1.Milestone_Project__c = milestoneProject.Id; 
        bom1.Product__c = pk1.Id;            
        bom1.On_Order__c = 5;
        bom1.Order_Qnty__c = 0;
        insert bom1;
        
        Project_BOM_Item__c bom2 = new Project_BOM_Item__c();
        bom2.Milestone_Project__c = milestoneProject.Id;
        bom2.Product__c = pk2.Id;          
        bom2.On_Order__c = 5;
        bom2.Order_Qnty__c = 0;
        insert bom2;

        // setup Product Kit Links
        List<Product_Kit__c> pks = new List<Product_Kit__c>();
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[0].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[1].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[2].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[3].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[4].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[5].Id, Quantity__c = 1));
        insert pks;
        
        // get list of kit product ids to feed to function under test
        List<Id> pkIds = new List<Id>();
		pkIds.add(pk1.id);
		pkIds.add(pk2.id);        
        system.debug('CAS>> pkIds = '+pkIds);
        
        // run test...
        test.startTest();
        List<Product_Kit__c> pksCheck = r3ProductKitAdopterHelper.getComponentProducts(milestoneProject.id, null, pkIds);
        test.stopTest();
        
        // validation...
        for(Product_Kit__c pkCheck :pksCheck)
	        system.debug('CAS>> product name = '+pkCheck.Salesforce_Product__r.name);
        system.assertEquals(3, pksCheck.size());
    }
    
    static testMethod void testGetComponentProductsAll()
    {
        // Insert Project
        CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
        insert milestoneProject;

        // set up schemes
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ChargerRecordType = SiteSchemeTypeInfo.get('Charger').getRecordTypeId();
        Id StreetLightingRecordType = SiteSchemeTypeInfo.get('StreetLighting').getRecordTypeId();
        Id GasRecordType = SiteSchemeTypeInfo.get('Gas').getRecordTypeId();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        Id WaterRecordType = SiteSchemeTypeInfo.get('Water').getRecordTypeId();
        
        //create siteschemes
        
        // Charger scheme
        site_scheme__c chargerScheme = new site_scheme__c();
        chargerScheme.Project__c = milestoneProject.id;
        chargerScheme.Charger_Provider__c = 'Engenie';
        chargerScheme.DNO__c = 'SSE';
        chargerScheme.IDNO__c = 'ESP';
        chargerScheme.RecordTypeId = ChargerRecordType;
        insert chargerScheme;

        // Street Light
        site_scheme__c streetLightScheme = new site_scheme__c();
        streetLightScheme.Project__c = milestoneProject.id;
        streetLightScheme.DNO__c = 'SSE';
        streetLightScheme.IDNO__c = 'ESP';
        streetLightScheme.RecordTypeId = StreetLightingRecordType;
        insert streetLightScheme;
                   
        // Gas
        site_scheme__c gasScheme = new site_scheme__c();
        gasScheme.Project__c = milestoneProject.id;
        gasScheme.GT__c = 'SGN';
        gasScheme.IGT__c = '';
        gasScheme.RecordTypeId = GasRecordType;
        insert gasScheme;
        
        // Water
        site_scheme__c waterScheme = new site_scheme__c();
        waterScheme.Project__c = milestoneProject.id;
        waterScheme.Water_Provider__c = 'Affinity Water';
        waterScheme.RecordTypeId = WaterRecordType;
        insert waterScheme;
         
        // Electric
        site_scheme__c electricScheme = new site_scheme__c();
        electricScheme.Project__c = milestoneProject.id;
        electricScheme.DNO__c = 'SSE';
        electricScheme.IDNO__c = 'ESP';
        electricScheme.RecordTypeId = ElectricRecordType;
        insert electricScheme;
        
        Id ProductKitRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Kit').getRecordTypeId();
        Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        
        // create product kits
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
        List<Product2> prods = new List<Product2>();
        prods.add(newComponentProduct('Test Product 0', 'SSE', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 1', '', '', 'Electricity'));
        prods.add(newComponentProduct('Test Product 2', 'ESP', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 3', 'ESP', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 4', 'ESP', 'Offsite', 'Electricity'));
        prods.add(newComponentProduct('Test Product 5', 'Affinity Water', '', 'Water'));
        insert prods;

        // setup BOMs
        Project_BOM_Item__c bom1 = new Project_BOM_Item__c();
        bom1.Milestone_Project__c = milestoneProject.Id; 
        bom1.Product__c = pk1.Id;            
        bom1.On_Order__c = 5;
        bom1.Order_Qnty__c = 0;
        bom1.Override_POL_Rules__c = true;
        insert bom1;
        
        Project_BOM_Item__c bom2 = new Project_BOM_Item__c();
        bom2.Milestone_Project__c = milestoneProject.Id;
        bom2.Product__c = pk2.Id;          
        bom2.On_Order__c = 5;
        bom2.Order_Qnty__c = 0;
        bom2.Override_POL_Rules__c = true;
        insert bom2;

        // setup Product Kit Links
        List<Product_Kit__c> pks = new List<Product_Kit__c>();
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[0].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[1].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[2].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[3].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[4].Id, Quantity__c = 1));
        pks.add(new Product_Kit__c(Parent_Product__c = pk1.Id, Salesforce_Product__c = prods[5].Id, Quantity__c = 1));
        insert pks;
        
        // get list of kit product ids to feed to function under test
        List<Id> pkIds = new List<Id>();
		pkIds.add(pk1.id);
		pkIds.add(pk2.id);        
        system.debug('CAS>> pkIds = '+pkIds);
        
        // run test...
        test.startTest();
        List<Product_Kit__c> pksCheck = r3ProductKitAdopterHelper.getAllComponentProducts(pkIds);
        test.stopTest();
        
        // validation...
        for(Product_Kit__c pkCheck :pksCheck)
	        system.debug('CAS>> product name = '+pkCheck.Salesforce_Product__r.name);
        system.assertEquals(6, pksCheck.size());
    }
    
    private static Product2 newComponentProduct(String prodName, String adopter, String workZone, String prodFamily)
    {
        Id ProductComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        return new Product2(Name = prodName, isActive = true, RecordTypeId = ProductComponentRecordTypeId, Allow_Multiple_Products__c = false, Adopter__c = adopter, Work_Zone__c = workZone, family = prodFamily);
    }
}