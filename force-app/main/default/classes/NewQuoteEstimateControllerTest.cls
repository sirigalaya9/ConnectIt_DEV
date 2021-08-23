@isTest
public class NewQuoteEstimateControllerTest 
{
    @testSetup
    static void setupData()
    {
        Opportunity opp=new Opportunity();
        opp.Name = 'test Opp';
        opp.CloseDate = system.today();
        opp.StageName = 'Enquiry';
        opp.Utilities__c = 'Electric';
        insert opp;
        
        Map<String,Schema.RecordTypeInfo> Product2TypeInfo = Schema.SObjectType.Product2.getRecordTypeInfosByName();
        Id KitRecordType = Product2TypeInfo.get('Kit').getRecordTypeId();
        
        Product2 ElectricPro = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Electricity', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
                                      Adopter__c = 'SSE', work_zone__c = 'Offsite', RecordTypeId = KitRecordType);
        insert ElectricPro;
        
        Product2 corPro = new Product2(Name = 'Core Product1', IsActive = true, Family = 'Gas', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
                                      Adopter__c = 'SSE', work_zone__c = 'Offsite', RecordTypeId = KitRecordType);
        insert corPro;
        
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ChargerRecordType = SiteSchemeTypeInfo.get('Charger').getRecordTypeId();
        Id StreetLightingRecordType = SiteSchemeTypeInfo.get('StreetLighting').getRecordTypeId();
        Id GasRecordType = SiteSchemeTypeInfo.get('Gas').getRecordTypeId();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        Id WaterRecordType = SiteSchemeTypeInfo.get('Water').getRecordTypeId();
        
        //create siteschemes
        // Charger
        List<site_scheme__c> sschList = new List<site_scheme__c>();
        site_scheme__c ssch = new site_scheme__c(
            Estimate__c = opp.Id,
            Charger_Provider__c = 'Engenie',
            DNO__c = 'SSE',
            IDNO__c = 'ESP',
            RecordTypeId = ChargerRecordType
        );
        sschList.add(ssch);
        
        // Street Light
        site_scheme__c ssch2 = new site_scheme__c(
            Estimate__c = opp.Id,
            DNO__c = 'SSE',
            IDNO__c = 'ESP',
            X5m__c = 5,
            X6m__c = 5,
            X6m_Hinged__c = 5,
            X8m__c = 5,
            X10m__c = 5,
            X12m__c = 5,
            RecordTypeId = StreetLightingRecordType
        );
        sschList.add(ssch2);
        
        // Gas
        site_scheme__c ssch3 = new site_scheme__c(
            Estimate__c = opp.Id,
            GT__c = 'SGN',
            RecordTypeId = GasRecordType
        );
        sschList.add(ssch3);
        
        // Water
        site_scheme__c ssch4 = new site_scheme__c(
            Estimate__c = opp.Id,
            Water_Provider__c = 'Affinity Water',
            RecordTypeId = WaterRecordType
        );
        sschList.add(ssch4);
        
        // Electric
        site_scheme__c ssch5 = new site_scheme__c(
            Estimate__c = opp.Id,
            DNO__c = 'SSE',
            No_of_Commercial__c = 5,
            No_of_Landlord__c = 5,
            No_of_Flats__c = 5,
            No_of_Houses__c = 5,
            No_of_TBS__c = 5,
            RecordTypeId = ElectricRecordType
        );
        sschList.add(ssch5);
        insert sschList;
        
        
        Rule__c electricRule = new Rule__c();
        electricRule.Name = 'Rule1';
        electricRule.Active__c = true;
        electricRule.Utility_Type__c = 'Electric';
        electricRule.Product_Family__c = 'Electricity';
        electricRule.Units_Type__c = 'Applicable for all';
        insert electricRule;
        
        Rule__c streetRule = new Rule__c();
        streetRule.Name = 'Rule2';
        streetRule.Active__c = true;
        streetRule.Utility_Type__c = 'Street Lighting';
        streetRule.Product_Family__c = 'Street Lighting';
        streetRule.Type_of_Street_Light__c = 'Applicable for all';
        insert streetRule;
        
        
        List<Core_Product_Rule__c> coreProducts = new List<Core_Product_Rule__c>();
        Core_Product_Rule__c coreProductMultiply = new Core_Product_Rule__c();
        coreProductMultiply.Rule__c = electricRule.Id;
        coreProductMultiply.Product__c = corPro.Id;
        coreProductMultiply.Quantity__c = 1;
        coreProductMultiply.Qty_Multiplier__c  = 'To Multiply';
        coreProductMultiply.Multiplier_Field__c = 'Total Number of Plots';
        coreProducts.add(coreProductMultiply);
        
        Core_Product_Rule__c coreProductDivide= new Core_Product_Rule__c();
        coreProductDivide.Rule__c = electricRule.Id;
        coreProductDivide.Product__c = corPro.Id;
        coreProductDivide.Quantity__c = 1;
        coreProductDivide.Qty_Multiplier__c  ='To Divide';
        coreProductDivide.Plots_Per_Quantity__c  = 2;
        coreProducts.add(coreProductDivide);
        
        Core_Product_Rule__c coreStreetProductDivide= new Core_Product_Rule__c();
        coreStreetProductDivide.Rule__c = streetRule.Id;
        coreStreetProductDivide.Product__c = corPro.Id;
        coreStreetProductDivide.Quantity__c = 1;
        coreStreetProductDivide.Qty_Multiplier__c  ='To Divide';
        coreStreetProductDivide.Plots_Per_Quantity__c  = 2;
        coreProducts.add(coreStreetProductDivide);        
        insert coreProducts;
        
        List<Scheme_Type_Breakdown__c> breakdowns = new List<Scheme_Type_Breakdown__c>();
        String commercialBreakdownRTId = Schema.SObjectType.Scheme_Type_Breakdown__c.getRecordTypeInfosByDeveloperName().get('Commercial').getRecordTypeId ();
        Scheme_Type_Breakdown__c breakdown = new Scheme_Type_Breakdown__c();
        breakdown.RecordTypeId = commercialBreakdownRTId;
        //breakdown.Scheme_Type__c
        breakdown.Site_Scheme__c = ssch5.Id;
        breakdown.Utility_Type__c = 'Electric';
        breakdowns.add(breakdown);
        insert breakdowns;
    }

    @isTest
    static void testQuery()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        String q = 'SELECT Id FROM Opportunity';
        NewQuoteEstimateController.query(q);
    }
    
    @isTest
    static void testSearchProduct()
    {
        Product2 pro = [SELECT Id, Name, Family, boris_code__c FROM Product2 WHERE Name like '%SLA%'];
        List<LookupSearchResult> result = NewQuoteEstimateController.SearchProduct('SLA','Electric');
    }
    
    
    @isTest
    static void testqueryAllSchemes()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        NewQuoteEstimateController.queryAllSchemes(opp.Id);
    }
    
    @isTest
    static void testgetExistingScheme()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<String> selectedUtilityList = new List<String>();
        selectedUtilityList.add('Electric');
        Map<String,Site_Scheme__c> utilitySchemeMap =  NewQuoteEstimateController.getExistingScheme(opp.Id,selectedUtilityList);
    }
    
    
    @isTest
    static void testgetInitialLineItems_Existing()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        Product2 ElectricPro = [SELECT Id FROM Product2 Where Family = 'Electricity'];
        
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
        OpportunityLineItem__c oli1 = new OpportunityLineItem__c(
            Product2Id__c = ElectricPro.id,
            OpportunityId__c = opp.Id,
            Quantity__c = 5,
            Material_Cost__c = 200,
            Utility_Type__c = 'Electric'
        );
        oppLineItemList.add(oli1);
        insert oppLineItemList;
   
        List<String> selectedUtilityList = new List<String>();
        selectedUtilityList.add('Electric');
        
        
        List<NewQuoteEstimateController.UtilityItem> utilityItems = NewQuoteEstimateController.getInitialLineItems(opp.Id,selectedUtilityList,'Site_Scheme__c',true);
    }
    
    @isTest
    static void testgetInitialLineItems_New()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
  
        List<String> selectedUtilityList = new List<String>{'Electric','Water','Gas', 'Charge Points', 'Street Lighting'};
        
        List<NewQuoteEstimateController.UtilityItem> utilityItems = NewQuoteEstimateController.getInitialLineItems(opp.Id,selectedUtilityList,'Site_Scheme__c',true);
    }
    
    @isTest
    static void testgetCoreProductsByRules_Electric()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Rule__c> selectedRules = [SELECT Id FROM Rule__c WHERE Utility_Type__c = 'Electric' AND Active__c = true];
        List<String> selectedRuleIds = new List<String>();
        selectedRuleIds.add(selectedRules[0].Id);
        
        
        List<NewQuoteEstimateController.OpportunityProduct> OpportunityProducts = NewQuoteEstimateController.getCoreProductsByRules(opp.Id,'Electric',selectedRuleIds);
    }
    
    @isTest
    static void testgetCoreProductsByRules_StreetLight()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        List<Rule__c> selectedRules = [SELECT Id FROM Rule__c WHERE Utility_Type__c = 'Street Lighting' AND Active__c = true];
        List<String> selectedRuleIds = new List<String>();
        selectedRuleIds.add(selectedRules[0].Id);
        
        
        List<NewQuoteEstimateController.OpportunityProduct> OpportunityProducts = NewQuoteEstimateController.getCoreProductsByRules(opp.Id,'Street Lighting',selectedRuleIds);
    }
    
    
    @isTest
    static void testsaveUtilityProduct()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        Product2 ElectricPro = [SELECT Id FROM Product2 Where Family = 'Electricity'];
        
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
        OpportunityLineItem__c oli1 = new OpportunityLineItem__c(
            Product2Id__c = ElectricPro.id,
            OpportunityId__c = opp.Id,
            Quantity__c = 5,
            Material_Cost__c = 200,
            Utility_Type__c = 'Electric'
        );
        oppLineItemList.add(oli1);
        insert oppLineItemList;
        system.debug('oppLineItemList[0] '+oppLineItemList[0]);
        List<NewQuoteEstimateController.UtilityItem> utilityProducts = new List<NewQuoteEstimateController.UtilityItem>();
        
        NewQuoteEstimateController.UtilityItem utilityProduct = new NewQuoteEstimateController.UtilityItem();
        utilityProduct.oppProducts = new List<NewQuoteEstimateController.OpportunityProduct>();
        
        NewQuoteEstimateController.OpportunityProduct oppProduct = new NewQuoteEstimateController.OpportunityProduct();
        oppProduct.oppLineItem = oppLineItemList[0];
        utilityProduct.oppProducts.add(oppProduct);
        utilityProducts.add(utilityProduct);
        
        List<sObject> deleteLineItems = new List<sObject>();
        
        
        List<OpportunityLineItem__c> oppLineItems = NewQuoteEstimateController.saveUtilityProducts(opp.Id,utilityProducts,deleteLineItems);
    }
    
    @isTest
    static void testCreateEstimate()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        Product2 ElectricPro = [SELECT Id FROM Product2 Where Family = 'Electricity'];

        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
        OpportunityLineItem__c oli1 = new OpportunityLineItem__c(
            Product2Id__c = ElectricPro.id,
            OpportunityId__c = opp.Id,
            Quantity__c = 5,
            UnitPrice__c = 200,
            Utility_Type__c = 'Electric'
        );
        oppLineItemList.add(oli1);
        insert oppLineItemList;
        
        NewQuoteEstimateController.saveReturnValue result = NewQuoteEstimateController.createEstimate(opp.Id, 'Test PDF');
        
    }
    
    
     @isTest
    static void testSaveSchemeBreakdown()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        List<Scheme_Type_Breakdown__c> breakdowns = [SELECT Id, Site_Scheme__c FROM Scheme_Type_Breakdown__c];
        
        List<Scheme_Type_Breakdown__c> result = NewQuoteEstimateController.saveSchemeBreakdown(breakdowns[0].Site_Scheme__c,breakdowns, 'Commercial', 'Electric', 5);
        
    }
    
    
    
    
}