public class NewQuoteEstimateController {
    public static List<Site_Scheme__c> ElectricSiteSchemes {get; set;}
    public static List<Site_Scheme__c> GasSiteSchemes {get; set;}
    public static List<Site_Scheme__c> WaterSiteSchemes {get; set;}
    public static List<Site_Scheme__c> ChargerPointSiteSchemes {get; set;}
    public static List<Site_Scheme__c> StreetLightningSiteSchemes {get; set;}
    public static List<Site_Scheme__c> siteSchemes {get; set;}
    public static Map<Id,Decimal> coreProductQuantityMap = new Map<Id,Decimal>();
    public static Map<Id,Decimal> defaultProductQuantityMap = new Map<Id,Decimal>();
    
    @AuraEnabled
    public static List<sObject> query(String q)
    {
        system.debug(q);
        return Database.query(q);
    }
    
    
    @AuraEnabled
    public static List<LookupSearchResult> searchRule(String searchKeyWord, String utilityType, Integer numberOfPlot)
    {
        system.debug('searchKeyWord '+searchKeyWord);
        system.debug('utilityType '+utilityType);
        system.debug('numberOfPlot '+numberOfPlot);
        List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
        if (searchKeyWord == null) searchKeyWord ='';
        String searchKey = '%'+ searchKeyword + '%';
        if(utilityType == 'Electric') utilityType = 'Electricity';
        List<Rule__c> rules = [SELECT Id, Name, Utility_Type__c, Active__c, Number_of_Plots_Lower_Band__c, Number_of_Plots_Higher_Band__c, Product_Family__c FROM Rule__c 
                               where Active__c = true and Product_Family__c = : utilityType
                               and Number_of_Plots_Lower_Band__c <=:numberOfPlot and Number_of_Plots_Higher_Band__c >=: numberOfPlot];
        
        if(!rules.isEmpty()){
            for (Rule__c rule : rules) 
            {
                searchResults.add(
                    new LookupSearchResult(
                        rule.Id,
                        'Rule__c',
                        'standard:product',
                        rule.Name,
                        rule.Utility_Type__c
                    )
                );
            }
        }
        
        return searchResults;
        
    }
    
    @AuraEnabled
    public static List<LookupSearchResult> searchProduct(String searchKeyWord, String utilityType)
    {
        //AND IS_KIT__C = true 
        List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
        if (searchKeyWord == null) searchKeyWord ='';
        String searchKey = '%'+ searchKeyword + '%';
        if(utilityType == 'Electric') utilityType = 'Electricity';
        String qString = 'SELECT Id, IsActive, Name, Sort__c, Family, boris_code__c, boris_voltage__c, Unit_Of_Measure__c,  ProductCode, Allow_Multiple_Products__c, Description, Kit_Sell__c, Labour_Sell__c, Labour_Cost__c,  Material_Sell__c, Plant_Sell__c, Plant_Cost__c, Implementor__c '+
            'FROM Product2 '+
            'WHERE IsActive = true AND Family = \''+utilityType+'\' AND '+
            '(Name LIKE \''+searchKey+'\''+' OR boris_code__c LIKE \''+searchKey+'\''+' OR ProductCode LIKE \''+searchKey+'\') LIMIT 10';
        system.debug(qString);
        List<Product2> results = Database.query(qString);
        
        if(!results.isEmpty()){
            for (Product2 product : results) 
            {
                searchResults.add(
                    new LookupSearchResult(
                        product.Id,
                        'Product2',
                        'standard:product',
                        product.Name,
                        product.boris_code__c
                    )
                );
            }
        }
        
        return searchResults;
        
    }
    
    /*@AuraEnabled
    public static List<UtilityAvailableRules> getNumberOfAvailableRules(Id oppId, List<String> selectedUtilityList)
    {
        List<UtilityAvailableRules> uars = new List<UtilityAvailableRules> ();
        
        UtilityAvailableRules uar = new UtilityAvailableRules();
        
        
        uar.NoOfAvailableRules = 0;
        uar.utilityType = '';
        
        return uar;
    }*/
    
    
    @AuraEnabled
    public static void queryAllSchemes(Id oppId)
    {
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByDeveloperName(); //getRecordTypeInfosByName
        String query;
        String objectName = 'site_scheme__c';
        List<String> sitSchemeFields = new List<String>(Site_Scheme__c.SObjectType.getDescribe().fields.getMap().keySet());
        sitSchemeFields.add('recordType.Developername');
        
        // get site electricity scheme...
        query = 'SELECT ' + string.join(sitSchemeFields, ',') + ' FROM ' + objectName + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Electric').getRecordTypeId() + '\' AND Estimate__c = \'' + oppId +'\' ORDER BY CreatedDate DESC';
        system.debug('CAS>>> Query = '+query);
        ElectricSiteSchemes = database.query(query);
        system.debug('ElectricSiteSchemes size '+ElectricSiteSchemes.size());
        
        // get site gas scheme...
        query = 'SELECT ' + string.join(sitSchemeFields, ',') + ' FROM ' + objectName + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Gas').getRecordTypeId() + '\' AND Estimate__c = \'' + oppId +'\' ORDER BY CreatedDate DESC';
        system.debug('CAS>>> Query = '+query);
        GasSiteSchemes = database.query(query);
        system.debug('GasSiteSchemes size '+GasSiteSchemes.size());
        
        // get site water scheme...
        query = 'SELECT ' + string.join(sitSchemeFields, ',') + ' FROM ' + objectName + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Water').getRecordTypeId() + '\' AND Estimate__c = \'' + oppId +'\' ORDER BY CreatedDate DESC';
        system.debug('CAS>>> Query = '+query);
        WaterSiteSchemes = database.query(query);
        system.debug('WaterSiteSchemes size '+WaterSiteSchemes.size());
        
        // get site charger point scheme...
        query = 'SELECT ' + string.join(sitSchemeFields, ',') + ' FROM ' + objectName + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Charger').getRecordTypeId() + '\' AND Estimate__c = \'' + oppId +'\' ORDER BY CreatedDate DESC';
        system.debug('CAS>>> Query = '+query);
        ChargerPointSiteSchemes = database.query(query);
        system.debug('ChargerPointSiteSchemes size '+ChargerPointSiteSchemes.size());
        
        // get site Street Lighting  scheme...
        query = 'SELECT ' + string.join(sitSchemeFields, ',') + ' FROM ' + objectName + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('StreetLighting').getRecordTypeId() + '\' AND Estimate__c = \'' + oppId +'\' ORDER BY CreatedDate DESC';
        system.debug('CAS>>> Query = '+query);
        StreetLightningSiteSchemes = database.query(query);
        system.debug('StreetLightningSiteSchemes size '+StreetLightningSiteSchemes.size());
        
        // All Site Schemes
        /*query = 'SELECT ' + string.join(sitSchemeFields, ',') + ' FROM ' + objectName + ' WHERE  Estimate__c = \'' + oppId +'\'';
        siteSchemes = database.query(query);*/
    }
    
    
    
    
    @AuraEnabled
    public static Map<Id,String> getExistingScheme(Id oppId, List<String> selectedUtilityList)
    {
        Map<Id,String> schemeIdMap = new Map<Id,String>();
        List<Site_Scheme__c> allRelatedScheme = [SELECT Id, RecordType.Name FROM Site_Scheme__c WHERE  Estimate__c =: oppId  ORDER BY CreatedDate DESC];
        
        for(String utility : selectedUtilityList)
        {
            for(Site_Scheme__c scheme : allRelatedScheme)
            {
                if(utility == scheme.RecordType.Name)
                {
                    schemeIdMap.put(scheme.Id,utility);
                    break;
                }
            }             
        }
        
        return schemeIdMap;
        
    }
    
    @AuraEnabled
    public static List<UtilityItem> getInitialLineItems(Id oppId, List<String> selectedUtilityList, String objectName, Boolean isNew) //Site_Scheme__c
    {
        Map<String, String> utilitySchemeMap = new Map<String, String>();
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByDeveloperName(); //getRecordTypeInfosByName
        String query;
        List<String> sitSchemeFields = new List<String>(Site_Scheme__c.SObjectType.getDescribe().fields.getMap().keySet());
        sitSchemeFields.add('recordType.Developername');
        List<OpportunityLineItem> oppLineItems = [Select Id,Quantity,Kit_Sell__c,Material_Sell__c,Plant_Sell__c,Material_Cost__c,Plant_Cost__c,OpportunityId,Implementor__c,
                                                  //Labour_Sell__c, Labour_Cost__c,
                                                  Product2.Id, Product2.ProductCode, Product2.Name, Product2.Family
                                                  FROM OpportunityLineItem WHERE OpportunityId =: oppId];
        
        List<opportunityLineItem__c> customOppLineItems = [Select id, OpportunityId__c, Product_Text__c, BORIS_Code__c ,BORIS_Voltage__c, 
                                                           Unit_Of_Measure_ref__c, Quantity__c,Implementor__c
                                                           ,Kit_Sell__c ,UnitPrice__c ,Labour_Cost__c ,Plant_Cost__c ,Material_Cost__c,
                                                           Product2Id__c, Product2Id__r.ProductCode, Product2Id__r.Name, Product2Id__r.Family
                                                           FROM opportunityLineItem__c WHERE OpportunityId__c =: oppId];
        
        queryAllSchemes(oppId);

        Map<String, String> fieldMap = new Map<String, String>();
        List<UtilityItem> UtilityItems = new List<UtilityItem>();
        List<Product2> defaultProducts = new List<Product2>();
        String schemeRTId;
        system.debug('selectedUtilityList '+selectedUtilityList);
        for(String utility : selectedUtilityList)
        {
            system.debug('utility '+utility);
            String DNO = '';
            String ruleId = '';
            defaultProducts = new List<Product2>();
            if(utility == 'Electric') {
                schemeRTId = SiteSchemeRecordTypeInfo.get('Electric').getRecordTypeId();
                if(ElectricSiteSchemes.size() > 0)
                {
                    defaultProducts = getDefaultProducts(ElectricSiteSchemes, utility); // get Baseline Products from all Electric Schemes
                }
            }
            else if(utility == 'Gas') {
                schemeRTId = SiteSchemeRecordTypeInfo.get('Gas').getRecordTypeId();
                if(GasSiteSchemes.size() > 0)
                {
                    defaultProducts = getDefaultProducts(GasSiteSchemes, utility);  // get Baseline Products from all Gas Schemes
                }
            }
            else if(utility == 'Water') {
                schemeRTId = SiteSchemeRecordTypeInfo.get('Water').getRecordTypeId();
                if(WaterSiteSchemes.size() > 0)
                {
                    defaultProducts = getDefaultProducts(WaterSiteSchemes, utility);  // get Baseline Products from all Water Schemes
                }
            }
            else if(utility == 'Charge Points') schemeRTId = SiteSchemeRecordTypeInfo.get('Charger').getRecordTypeId();
            
            UtilityItem uItem = new UtilityItem();
            uItem.utilityType = utility;
            uItem.schemeRTId = schemeRTId;
            uItem.oppProducts = new List<OpportunityProduct>();
            
            //fieldMap.put('Adopter__c', DNO);
            //system.debug('fieldMap '+fieldMap);
            //List<Product2> defaultProducts = RuleController.getProducts(utility,'',null, fieldMap); // Get defaultProducts from Rule Items
            
            
            /*List<Core_Product_Rule__c> coreProducts = [SELECT Id, Rule__c, Rule__r.Utility_Type__c, Product__c, Product__r.Name, Product__r.Family, Quantity__c, To_Multiply__c 
                                                       FROM Core_Product_Rule__c WHERE Rule__c =: ruleId order by name];
            
            for(Core_Product_Rule__c corePro : coreProducts)
            {
                
                Product2 pro = new Product2(Id = corePro.Product__c, 
                                            Name = corePro.Product__r.Name,
                                            Family = corePro.Product__r.Family);
                system.debug('add Core '+pro);
                defaultProducts.add(pro);
                
                if(corePro.To_Multiply__c == true)
                    coreProductQuantityMap.put(corePro.Product__c, corePro.Quantity__c * ElectricSiteSchemes[0].No_of_Units__c);
                else
                    coreProductQuantityMap.put(corePro.Product__c, corePro.Quantity__c);
            }
            
            system.debug('coreProductQuantityMap '+coreProductQuantityMap);*/
            
            //system.debug('defaultProducts size BEFORE '+defaultProducts.size());
            //defaultProducts = addCoreProducts(utility,defaultProducts);
            //system.debug('defaultProducts size AFTER '+defaultProducts.size());
            
            
            system.debug('customOppLineItems size ' +customOppLineItems.size());
            if(isNew == False && !customOppLineItems.isEmpty())
            {
                system.debug('isNew FALSE');
                for (OpportunityLineItem__c item : customOppLineItems)
                {
                    OpportunityProduct oppProduct = new OpportunityProduct();
                    OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c();
                    oppLineItem.OpportunityId__c = item.OpportunityId__c;
                    
                    Product2 pro = new Product2();
                    pro.Id = item.Product2Id__c;
                    pro.Name = item.Product2Id__r.Name;
                    pro.ProductCode = item.Product2Id__r.ProductCode;
                    pro.Family = item.Product2Id__r.Family;
                    oppLineItem.Product2Id__r = pro;
                    oppLineItem.Id = item.Id;
                    oppLineItem.Quantity__c = item.Quantity__c;
                    oppLineItem.Implementor__c = item.Implementor__c;
                    oppLineItem.Kit_Sell__c = item.Kit_Sell__c;
                    //oppLineItem.Material_Sell__c = item.Material_Sell__c;
                    //oppLineItem.Plant_Sell__c = item.Plant_Sell__c;
                    oppLineItem.Material_Cost__c = item.Material_Cost__c;
                    oppLineItem.Plant_Cost__c = item.Plant_Cost__c;
                    
                    oppProduct.oppLineItem = oppLineItem;  
                    uItem.oppProducts.add(oppProduct);
                }
            }
            else
            {
                system.debug('isNew TRUE');
                for (Product2 pro : defaultProducts)
                {
                    OpportunityProduct oppProduct = new OpportunityProduct();
                    opportunityLineItem__c oppLineItem = new opportunityLineItem__c();
                    oppLineItem.OpportunityId__c = oppId;
                    oppLineItem.Product2Id__r = pro;
                    oppLineItem.Implementor__c = pro.Implementor__c;
                    if(pro.Kit_Sell__c == null) oppLineItem.Kit_Sell__c = 0; else oppLineItem.Kit_Sell__c = pro.Kit_Sell__c;
                    //if(pro.Material_Sell__c == null) oppLineItem.Material_Sell__c = 0; else oppLineItem.Material_Sell__c = pro.Material_Sell__c;
                    //oppLineItem.Plant_Sell__c = pro.Plant_Sell__c;
                    oppLineItem.Material_Cost__c = pro.Material_Cost__c;
                    oppLineItem.Plant_Cost__c = pro.Plant_Cost__c;
                    oppLineItem.Quantity__c = 1;
                    if(coreProductQuantityMap.containsKey(pro.Id))
                        oppLineItem.Quantity__c = coreProductQuantityMap.get(pro.Id);
                    
                    oppProduct.oppLineItem = oppLineItem;  
                    uItem.oppProducts.add(oppProduct);
                }
            }
            
            system.debug('defaultProducts '+defaultProducts.size());
            uItem.rules = getrelatedRules(utility, oppId);
            system.debug('uItem.rules '+uItem.rules.size());
            /*uItem.siteSchemes = new List<SiteScheme>();            
            for (Site_Scheme__c scheme : siteSchemes)
            {
                SiteScheme siteScheme = new SiteScheme();
                siteScheme.schemeItem = scheme; 
                if(utility == 'Electric' && scheme.RecordType.Developername == 'Electric') uItem.siteSchemes.add(siteScheme);
                else if(utility == 'Gas' && scheme.RecordType.Developername == 'Gas') uItem.siteSchemes.add(siteScheme);
                else if(utility == 'Water' && scheme.RecordType.Developername == 'Water') uItem.siteSchemes.add(siteScheme);
                else if(utility == 'Charge Points' && scheme.RecordType.Developername == 'Charge Points') uItem.siteSchemes.add(siteScheme);
                
            }*/
            utilityItems.add(uItem);
        }
        return utilityItems;
        
        
    }
    
    @AuraEnabled
    public static List<UtilityItem> addCoreToUtilityProducts(String oppId,String utilityType, List<UtilityItem> utilityProducts, List<String> selectedRuleIds)
    {
        List<UtilityItem> ui = new List<UtilityItem>();
        
        system.debug('utilityType '+utilityType);
        system.debug('utilityProducts '+utilityProducts);
        system.debug('selectedRuleIds '+selectedRuleIds);
        List<OpportunityLineItem__c> oppLineItems = new List<OpportunityLineItem__c>();
        
        List<Product2> defaultProducts = new List<Product2>();
        for (UtilityItem uItem : utilityProducts)
        {
            //system.debug('uItem '+uItem);
            
            if(utilityType == uItem.utilityType)
            {
                for (OpportunityProduct oppProduct : uItem.oppProducts)
                {                
                    system.debug('oppProduct '+oppProduct);
                    oppLineItems.add(oppProduct.oppLineItem);
                    defaultProducts.add(oppProduct.oppLineItem.Product2Id__r);
                    defaultProductQuantityMap.put(oppProduct.oppLineItem.Product2Id__c, oppProduct.oppLineItem.Quantity__c);
                    //product2Ids.add(oppProduct.oppLineItem.Product2Id);                
                }
            }
            
            system.debug('defaultProductQuantityMap '+defaultProductQuantityMap);
            system.debug('oppLineItems '+oppLineItems);
            system.debug('defaultProducts '+defaultProducts);
        }
        
        system.debug('defaultProducts size BEFORE '+defaultProducts.size());
        defaultProducts = addCoreProducts(selectedRuleIds,defaultProducts);
        system.debug('defaultProducts size AFTER '+defaultProducts.size());
        
        List<OpportunityProduct> oppProducts = new List<OpportunityProduct>();
        
        for (Product2 pro : defaultProducts)
        {
            OpportunityProduct oppProduct = new OpportunityProduct();
            OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c();
            oppLineItem.OpportunityId__c = oppId;
            oppLineItem.Product2Id__r = pro;
            oppLineItem.Implementor__c = pro.Implementor__c;
            if(pro.Kit_Sell__c == null) oppLineItem.Kit_Sell__c = 0; else oppLineItem.Kit_Sell__c = pro.Kit_Sell__c;
            //if(pro.Material_Sell__c == null) oppLineItem.Material_Sell__c = 0; else oppLineItem.Material_Sell__c = pro.Material_Sell__c;
            //oppLineItem.Plant_Sell__c = pro.Plant_Sell__c;
            oppLineItem.Material_Cost__c = pro.Material_Cost__c;
            oppLineItem.Plant_Cost__c = pro.Plant_Cost__c;
            oppLineItem.Quantity__c = 0;
            if(defaultProductQuantityMap.containsKey(pro.Id))
                oppLineItem.Quantity__c = defaultProductQuantityMap.get(pro.Id);
            system.debug('defaultProductQuantity  '+oppLineItem.Quantity__c);
        
            if(coreProductQuantityMap.containsKey(pro.Id))
                oppLineItem.Quantity__c += coreProductQuantityMap.get(pro.Id);
            system.debug('plus coreProductQuantity  '+oppLineItem.Quantity__c);
            oppProduct.oppLineItem = oppLineItem;
            oppProducts.add(oppProduct);
            
        }
        
        system.debug('oppProducts '+oppProducts.size());
        
        //system.debug('oppProduct xx '+oppProduct);
        
        for (UtilityItem uItem : utilityProducts)
        {
            //system.debug('uItem '+uItem);
            //List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            if(utilityType == uItem.utilityType)
            {
                uItem.oppProducts = oppProducts; 
                system.debug('uItem.oppProducts '+uItem.oppProducts.size());
            }
        }
        
 
        return utilityProducts;
    }
    
    @AuraEnabled
    public static List<OpportunityProduct> getCoreProductsByRules(String oppId,String utilityType, List<String> selectedRuleIds)
    {
        List<UtilityItem> ui = new List<UtilityItem>();
        if(utilityType == 'Electric') utilityType = 'Electricity';
        Decimal noOf_Commercial = 1 ;
        Decimal noOf_CommercialEssentia = 1 ;
        Decimal noOf_CommercialNonEssential = 1 ;
        Decimal noOf_Detached = 1 ;
        Decimal noOf_Flats = 1 ;
        Decimal noOf_Landlord = 1 ;
        Decimal noOf_PumpStation = 1 ;
        Decimal noOf_Residential = 1 ;
        Decimal noOf_Semi = 1 ;
        
        List<site_scheme__c> scheme = [SELECT Id, No_of_Units__c,No_of_Commercial__c, No_of_Residential__c, Total_Number_of_plots__c, No_of_Commercial_Essential__c, 
                                       No_of_Commercial_Non_Essential__c, No_of_Landlord__c, No_of_Detached__c, No_of_Flats__c, No_of_Semi__c, No_of_Pump_Station__c 
                                       FROM site_scheme__c WHERE Estimate__c = :oppId AND Product_Family__c =: utilityType order by createddate desc];
        if(!scheme.isEmpty()) 
        {
            noOf_Commercial = scheme[0].No_of_Commercial__c;
            noOf_CommercialEssentia = scheme[0].No_of_Commercial_Essential__c;
            noOf_CommercialNonEssential = scheme[0].No_of_Commercial_Non_Essential__c;
            noOf_Detached = scheme[0].No_of_Detached__c;
            noOf_Flats = scheme[0].No_of_Flats__c;
            noOf_Landlord = scheme[0].No_of_Landlord__c;
            noOf_PumpStation = scheme[0].No_of_Pump_Station__c;
            noOf_Residential = scheme[0].No_of_Residential__c;
            noOf_Semi = scheme[0].No_of_Semi__c;
            system.debug('noOf_Commercial '+noOf_Commercial);
        }
        system.debug('utilityType '+utilityType);
        system.debug('selectedRuleIds '+selectedRuleIds);
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        List<Product2> defaultProducts = new List<Product2>();

        List<Core_Product_Rule__c> coreProducts = [SELECT Id, Rule__c, Rule__r.Utility_Type__c, Rule__r.Units_Type__c,Product__c,Product__r.Name,Product__r.Family, Product__r.Kit_Sell__c,
                                                   Quantity__c,Product__r.Implementor__c,Product__r.Material_Cost__c,To_Multiply__c, Qty_Multiplier_formula__c
                                                   FROM Core_Product_Rule__c WHERE Rule__c IN : selectedRuleIds order by createdDate];
        
        List<OpportunityProduct> oppProducts = new List<OpportunityProduct>();
        for(Core_Product_Rule__c corePro : coreProducts)
        {

            Product2 pro = new Product2(Id = corePro.Product__c, 
                                        Name = corePro.Product__r.Name,
                                        Family = corePro.Product__r.Family,
                                        Implementor__c = corePro.Product__r.Implementor__c,
                                        Material_Cost__c = corePro.Product__r.Material_Cost__c,
                                        Kit_Sell__c = corePro.Product__r.Kit_Sell__c);
            system.debug('add Core '+pro);

            OpportunityProduct oppProduct = new OpportunityProduct();
            OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c();
            oppLineItem.OpportunityId__c = oppId;
            oppLineItem.Product2Id__r = pro;
            oppLineItem.Implementor__c = pro.Implementor__c;
            oppLineItem.Material_Cost__c = pro.Material_Cost__c;
            if(pro.Kit_Sell__c == null) oppLineItem.Kit_Sell__c = 0; else oppLineItem.Kit_Sell__c = pro.Kit_Sell__c;
            if(corePro.Qty_Multiplier_formula__c == 'To Multiply') 
            {
                system.debug('To Multiply');
                if(corePro.Rule__r.Units_Type__c == 'Commercial') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_Commercial;
                if(corePro.Rule__r.Units_Type__c == 'Commercial Essential') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_CommercialEssentia ;
                if(corePro.Rule__r.Units_Type__c == 'Commercial Non-Essential') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_CommercialNonEssential ;
                if(corePro.Rule__r.Units_Type__c == 'Detached') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_Detached ;
                if(corePro.Rule__r.Units_Type__c == 'Flats') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_Flats ;
                if(corePro.Rule__r.Units_Type__c == 'Landlord') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_Landlord ;
                if(corePro.Rule__r.Units_Type__c == 'PumpStation') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_PumpStation ;
                if(corePro.Rule__r.Units_Type__c == 'Residentia') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_Residential ;
                if(corePro.Rule__r.Units_Type__c == 'Semi') oppLineItem.Quantity__c = corePro.Quantity__c * noOf_Semi ;
                system.debug('oppLineItem.Quantity '+oppLineItem.Quantity__c);
                system.debug('corePro.Quantity__c '+corePro.Quantity__c);
                
            }
            else if(corePro.Qty_Multiplier_formula__c == 'To Divide')
            {
                system.debug('To Divide');
                if(corePro.Rule__r.Units_Type__c == 'Commercial') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_Commercial;
                if(corePro.Rule__r.Units_Type__c == 'Commercial Essential') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_CommercialEssentia ;
                if(corePro.Rule__r.Units_Type__c == 'Commercial Non-Essential') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_CommercialNonEssential ;
                if(corePro.Rule__r.Units_Type__c == 'Detached') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_Detached ;
                if(corePro.Rule__r.Units_Type__c == 'Flats') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_Flats ;
                if(corePro.Rule__r.Units_Type__c == 'Landlord') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_Landlord ;
                if(corePro.Rule__r.Units_Type__c == 'PumpStation') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_PumpStation ;
                if(corePro.Rule__r.Units_Type__c == 'Residentia') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_Residential ;
                if(corePro.Rule__r.Units_Type__c == 'Semi') oppLineItem.Quantity__c = corePro.Quantity__c / noOf_Semi ;
                system.debug('oppLineItem.Quantity '+oppLineItem.Quantity__c);
                system.debug('corePro.Quantity__c '+corePro.Quantity__c);
            }
            else oppLineItem.Quantity__c  =  corePro.Quantity__c;
            
            oppProduct.oppLineItem = oppLineItem;  
            oppProducts.add(oppProduct);
            
        }
        
        system.debug('oppProducts '+oppProducts.size());
 
        return oppProducts;
    }
    
       
    private static List<Product2> addCoreProducts(List<String> selectedRuleIds, List<Product2> defaultProducts)
    {
        //List<Product2> defaultProducts;
        List<Core_Product_Rule__c> coreProducts = [SELECT Id, Rule__c, Rule__r.Utility_Type__c, Product__c,Product__r.Name,Product__r.Family, 
                                                   Quantity__c,Product__r.Implementor__c,Product__r.Material_Cost__c,To_Multiply__c
                                                   FROM Core_Product_Rule__c WHERE Rule__c IN : selectedRuleIds order by createdDate];
        
        for(Core_Product_Rule__c corePro : coreProducts)
        {
            Boolean found = false;
            for(Product2 defaultPro : defaultProducts)
            {
                if(corePro.Product__c == defaultPro.Id)
                {
                    found = true;
                }
            }
            
            if(found == false)
            {
                Product2 pro = new Product2(Id = corePro.Product__c, 
                                            Name = corePro.Product__r.Name,
                                            Family = corePro.Product__r.Family,
                                            Implementor__c = corePro.Product__r.Implementor__c,
                                            Material_Cost__c = corePro.Product__r.Material_Cost__c);
                system.debug('add Core '+pro);
                defaultProducts.add(pro);
            }
            
            coreProductQuantityMap.put(corePro.Product__c, corePro.Quantity__c);
            /*if(corePro.To_Multiply__c == true)
                coreProductQuantityMap.put(corePro.Product__c, corePro.Quantity__c * ElectricSiteSchemes[0].No_of_Units__c);
            else
                coreProductQuantityMap.put(corePro.Product__c, corePro.Quantity__c);*/
        }
        
        system.debug('coreProductQuantityMap '+coreProductQuantityMap);
        
        return defaultProducts;
        
    }
    
    
    
    @AuraEnabled
    public static List<OpportunityLineItem__c> saveUtilityProducts(Id oppId, List<UtilityItem> utilityProducts)
    {
        
        try
        {
            Map<String,Id> pbEntryMap = new Map<String,Id>();
            Set<Id> product2Ids = new Set<Id>();
            Set<Id> successQLineItemsId = new Set<Id>();
            //Opp Line Items
            List<OpportunityLineItem__c> oppLineItems = new List<OpportunityLineItem__c>(); 
            
            List<OpportunityLineItem__c> oppLineItemsToDelete = [SELECT Id FROM OpportunityLineItem__c WHERE OpportunityId__c =: oppId];
            
            for (UtilityItem uItem : utilityProducts)
            {
                //system.debug('uItem '+uItem);
                for (OpportunityProduct oppProduct : uItem.oppProducts)
                {                
                    oppLineItems.add(oppProduct.oppLineItem);
                    //product2Ids.add(oppProduct.oppLineItem.Product2Id__c);                
                }
                
                system.debug('oppLineItems '+oppLineItems);
            }
            
            
            if(!oppLineItemsToDelete.isEmpty()) delete oppLineItemsToDelete;
            if(!oppLineItems.isEmpty()) insert oppLineItems;
            
            return oppLineItems;
            
        }
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    
    @AuraEnabled
    public static saveReturnValue createEstimate(Id oppId, String pdfBase64Data)
    {
        try
        {
            System.debug('pdfBase64Data '+pdfBase64Data);
            
            Map<String,Id> pbEntryMap = new Map<String,Id>();
            Set<Id> product2Ids = new Set<Id>();
            Set<Id> successQLineItemsId = new Set<Id>();
            //Opp Line Items
            //List<OpportunityLineItem__c> oppLineItems = new List<OpportunityLineItem__c>(); 
            
            //List<OpportunityLineItem__c> oppLineItemsToDelete = [SELECT Id FROM OpportunityLineItem__c WHERE OpportunityId__c =: oppId];
            
            List<OpportunityLineItem__c> oppLineItemsExisting = [SELECT Id, Name, OpportunityId__c, Material_Cost__c, Labour_Cost__c, Plant_Cost__c, Cost_Price__c, Kit_Sell__c, 
                                                                 UnitPrice__c, Quantity__c, Implementor__c, Product2Id__c, Total_Sell__c, Total_Cost__c, Sell_Price__c 
                                                                 FROM OpportunityLineItem__c WHERE OpportunityId__c =: oppId];
            
            for (OpportunityLineItem__c item : oppLineItemsExisting)
            {
                product2Ids.add(item.Product2Id__c);
            }
            
            /*for (UtilityItem uItem : utilityProducts)
            {
                //system.debug('uItem '+uItem);
                for (OpportunityProduct oppProduct : uItem.oppProducts)
                {                
                    //oppProduct.oppLineItem.Parent_Product__c = coupledProduct.parentProduct.Id;    
                    //system.debug('oppProduct '+oppProduct);
                    oppLineItems.add(oppProduct.oppLineItem);
                    product2Ids.add(oppProduct.oppLineItem.Product2Id__c);                
                }
                
                system.debug('oppLineItems '+oppLineItems);
            }
            
            for (OpportunityLineItem__c item : labourSellItems)
            {
                oppLineItems.add(item);
                product2Ids.add(item.Product2Id__c);    
            }
            
            for (OpportunityLineItem__c item : plantSellItems)
            {
                oppLineItems.add(item);
                product2Ids.add(item.Product2Id__c);
            }
            
            delete oppLineItemsToDelete;
            
            insert oppLineItems;*/
            
            
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id =: oppId];
            for(PricebookEntry pbEntry : [SELECT Id, Name, Pricebook2Id, Product2Id
                                          FROM PricebookEntry WHERE IsActive = true AND Product2Id IN: product2Ids])
            {
                pbEntryMap.put(pbEntry.Product2Id, pbEntry.id);
            }
            
            Quote q = new Quote();
            q.Name = 'Estimate for '+opp.Name;
            q.OpportunityId = oppId;
            insert q;
            
            List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
            for(OpportunityLineItem__c oppItem :oppLineItemsExisting)
            {
                QuoteLineItem qItem = new QuoteLineItem();
                qItem.QuoteId = q.Id;
                if(pbEntryMap.containsKey(oppItem.Product2Id__c)) qItem.PricebookEntryId = pbEntryMap.get(oppItem.Product2Id__c);
				qItem.OpportunityLineItem__c  = oppItem.Id;
                qItem.Product2Id = oppItem.Product2Id__c;
                qItem.Quantity = oppItem.Quantity__c;
                qItem.UnitPrice  = oppItem.UnitPrice__c;
                qItem.Implementor__c = oppItem.Implementor__c;
                qItem.Kit_Sell__c = oppItem.Kit_Sell__c;
                //qItem.Material_Sell__c = oppItem.Material_Sell__c;
                //qItem.Plant_Sell__c = oppItem.Plant_Sell__c;
                qItem.Material_Cost__c = oppItem.Material_Cost__c;
                qItem.Plant_Cost__c = oppItem.Plant_Cost__c;
                //System.debug('qItem: ' + qItem);
                quoteLineItems.add(qItem);
            }
            
            insert quoteLineItems;
            
            opp.SyncedQuoteId  = q.Id;
            update opp;
            
            Blob myBlob = EncodingUtil.base64Decode(pdfBase64Data);
            //String cvRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Estimator').getRecordTypeId();
            
            ContentVersion cv = new ContentVersion();
            cv.versionData = myBlob;
            cv.title = 'Estimate' + '_' + String.valueof(DateTime.now().getTime()) + '.pdf';
            cv.pathOnClient = 'Estimate' + '_' + String.valueof(DateTime.now().getTime()) + '.pdf';
            cv.Type__c = 'BT';
            cv.Group__c = 'Estimate';
            cv.RecordTypeId = '0124J000000hNK3QAM';
            cv.IsMajorVersion = true;
            system.debug(cv);
            insert cv;
            
            String ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = ContentDocumentId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = q.Id;
            insert cdl;
            
            saveReturnValue returnVal = new saveReturnValue();
            returnVal.quoteId = q.Id;
            returnVal.contentVersionId = cv.Id;
            returnVal.ContentDocumentId = ContentDocumentId;
            
            return returnVal;
            
            
        }
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
        
    private static List<Product2> getDefaultProducts(List<site_scheme__c> siteSchemes, String utility)
    {
        List<Product2> DefaultProducts = new List<Product2>();
        Set<Id> DefaultProductIds = new Set<Id>();

        system.debug('utility : '+utility);
        system.debug('SiteSchemes size : '+siteSchemes.size());
        for(site_scheme__c scheme :siteSchemes)
        {
			if(utility == 'Electric')
            {
                for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                    Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                    work_zone__c, Adopter__c
                                    FROM Product2
                                    WHERE IsActive = true
                                    AND IS_KIT__C = true
                                    AND Core_Product__c = true
                                    AND Family = 'Electricity'
                                    AND ((Adopter__c = :scheme.idno__c AND work_zone__c = 'Onsite') OR
                                         (Adopter__c = :scheme.dno__c   AND work_zone__c = 'Offsite') OR 
                                         (Adopter__c = :scheme.idno__c  AND work_zone__c = 'Both') OR
                                         (Adopter__c = :scheme.dno__c   AND work_zone__c = 'Both') OR
                                         (Adopter__c = :scheme.idno__c  AND work_zone__c = '') OR
                                         (Adopter__c = :scheme.dno__c   AND work_zone__c = '') OR
                                         (Adopter__c = ''))     
                                    ORDER BY Sort__c ])   
                {
                    //system.debug(pro);
                    //DefaultProducts.add(pro);
                    DefaultProductIds.add(pro.Id);
                }
            }
            else if(utility == 'Gas')
            {
                for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'Gas'
                                      AND ((Adopter__c = :scheme.IGT__c AND work_zone__c = 'Onsite') OR
                                           (Adopter__c = :scheme.GT__c  AND work_zone__c = 'Offsite') OR 
                                           (Adopter__c = :scheme.IGT__c AND work_zone__c = 'Both') OR
                                           (Adopter__c = :scheme.GT__c  AND work_zone__c = 'Both') OR
                                           (Adopter__c = :scheme.GT__c  AND work_zone__c = '') OR 
                                           (Adopter__c = :scheme.IGT__c AND work_zone__c = '') OR 
                                           (Adopter__c = ''))                                                  
                                    ORDER BY Sort__c ])
                    
                {
                    DefaultProductIds.add(pro.Id);
                }
            }
			else if(utility == 'Water')   
            {
                for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, Family, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'Water'
                                      AND ((Adopter__c = :scheme.Water_Provider__c AND work_zone__c = :scheme.Pipe_type__c) OR
                                           (Adopter__c = '' AND work_zone__c = :scheme.Pipe_type__c) OR
                                           (Adopter__c = :scheme.Water_Provider__c AND work_zone__c = '') OR                                         
                                           (Adopter__c = '' AND work_zone__c = '')) 
                                    ORDER BY Sort__c ])
                    
                {
                    
                    DefaultProductIds.add(pro.Id);
                }
            }
            else if(utility == 'Charge Points')
            {
                for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                    Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                    work_zone__c, Adopter__c                         
                                    FROM Product2 
                                    WHERE IsActive = true
                                    AND IS_KIT__C = true
                                    AND Core_Product__c = true
                                    AND Family = :scheme.charger_provider__c
                                    AND ((Adopter__c = :scheme.idno__c AND work_zone__c = 'Onsite') OR
                                         (Adopter__c = :scheme.dno__c  AND work_zone__c = 'Offsite') OR 
                                         (Adopter__c = :scheme.idno__c AND work_zone__c = 'Both') OR
                                         (Adopter__c = :scheme.dno__c  AND work_zone__c = 'Both') OR
                                         (Adopter__c = :scheme.idno__c AND work_zone__c = '') OR
                                         (Adopter__c = :scheme.dno__c  AND work_zone__c = '') OR                                           
                                         (Adopter__c = ''))                                                                             
                                    ORDER BY Sort__c ])
                    
                {
                    DefaultProductIds.add(pro.Id);
                }
            }
            else if(utility == 'Street Lighting')
            {
                for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                    Kit_Sell__c, Labour_Sell__c, Labour_Cost__c,  Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                    work_zone__c, Adopter__c
                                    FROM Product2 
                                    WHERE IsActive = true
                                    AND IS_KIT__C = true
                                    AND Core_Product__c = true
                                    AND Family = 'Street Lighting'
                                    AND ((Adopter__c = :scheme.idno__c AND work_zone__c = 'Onsite') OR
                                         (Adopter__c = :scheme.dno__c  AND work_zone__c = 'Offsite') OR 
                                         (Adopter__c = :scheme.idno__c AND work_zone__c = 'Both') OR
                                         (Adopter__c = :scheme.dno__c  AND work_zone__c = 'Both') OR
                                         (Adopter__c = :scheme.idno__c AND work_zone__c = '') OR
                                         (Adopter__c = :scheme.dno__c  AND work_zone__c = '') OR
                                         (Adopter__c = ''))              
                                    ORDER BY Sort__c ])
                    
                {
                    DefaultProductIds.add(pro.Id);
                }
            }
        }
        
        system.debug('DefaultProductIds size : '+DefaultProductIds.size());
        
        DefaultProducts = [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                           Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                           work_zone__c, Adopter__c FROM Product2 WHERE Id IN: DefaultProductIds];
        
        system.debug('DefaultProducts size : '+DefaultProducts.size());
        
        return DefaultProducts;
    }
    
    private static String getFieldList(String objectName)
    {
        String retStr = '';
        
        // get fields for object
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // list them in string
        for(String s : objectFields.keySet()) 
            retStr += s + ',';
        
        // remove last comma
        if (retStr.subString(retStr.Length()-1,retStr.Length()) == ',')
            retStr = retStr.subString(0,retStr.Length()-1);
        
        return retStr;
    }
    
    @AuraEnabled
    public static List<Rule__c> getrelatedRules(String utility, String oppId)
    {
        String query; 
        List<Rule__c> rules;
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByDeveloperName(); //getRecordTypeInfosByName
        List<String> sitSchemeFields = new List<String>(Site_Scheme__c.SObjectType.getDescribe().fields.getMap().keySet());
        String objectName = 'site_scheme__c';
        site_scheme__c scheme = new site_scheme__c() ;
        List<UtilityAvailableRules> uars = new List<UtilityAvailableRules> ();
        
        // get site scheme...
        queryAllSchemes(oppId);
       /* system.debug('getrelatedRules');
        system.debug(selectedUtilityList);
        for(String utility : selectedUtilityList)
        {*/
			
            system.debug(utility);
            if(utility == 'Electric' && !ElectricSiteSchemes.isEmpty()) scheme = ElectricSiteSchemes[0];
            else if(utility == 'Gas' && !GasSiteSchemes.isEmpty()) scheme = GasSiteSchemes[0];
            else if(utility == 'Water' && !WaterSiteSchemes.isEmpty()) scheme = WaterSiteSchemes[0];
            system.debug(scheme);
            
            String qString = 'SELECT Id, Name, Active__c, Description__c FROM Rule__c WHERE Active__c = true ';
            if(utility != null && utility != '') 
                qString += ' AND Utility_Type__c = \''+utility+'\' ';
            if(scheme.Product_Family__c != null && scheme.Product_Family__c != '') 
                qString += ' AND Product_Family__c = \''+scheme.Product_Family__c+'\' ';
            
            if(scheme.Total_Number_of_plots__c >= 0 )
            {
                Boolean first = true;
                qString += ' AND ( ';
                
                qString += ' ( Units_Type__c = \'Applicable for all\' ';
                qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.Total_Number_of_plots__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.Total_Number_of_plots__c+')) ';
                if(first == true) first = false;
                
                if(scheme.No_of_Commercial__c != null) {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Commercial\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Commercial__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Commercial__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Residential__c != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Residential\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Residential__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Residential__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_Of_Commercial_Essential__c  != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Commercial Essential\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_Of_Commercial_Essential__c +') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_Of_Commercial_Essential__c +')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Commercial_Non_Essential__c  != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Commercial Non Essential\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Commercial_Non_Essential__c +') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Commercial_Non_Essential__c +')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Landlord__c != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Landlord\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Landlord__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Landlord__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Detached__c != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Detached\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Detached__c +') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Detached__c +')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Flats__c  != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Flats\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Flats__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Flats__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Semi__c  != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Semi\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Semi__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Semi__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Pump_Station__c  != null)
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Pump Station\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Pump_Station__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Pump_Station__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_Houses__c  != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'Houses\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Houses__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Houses__c+')) ';
                    if(first == true) first = false;
                }
                if(scheme.No_of_TBS__c  != null) 
                {
                    if(first == false) qString += ' OR ';
                    qString += ' ( Units_Type__c = \'TBS\' ';
                    qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_TBS__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_TBS__c+')) ';
                    if(first == true) first = false;
                }
                
                qString += ' ) '; 
                
            }
        
        /*if(scheme.Units_Type__c != null && scheme.Units_Type__c != '') 
qString += ' AND Units_Type__c = \''+scheme.Units_Type__c+'\' ';*/
        /*if(scheme.No_of_Units__c != null)
qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Units__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Units__c+') ';*/
        if(scheme.Total_Load_kVA__c != null)
            qString += ' AND (Total_Load_kVA_Lower_Band__c = null OR Total_Load_kVA_Lower_Band__c <= '+scheme.Total_Load_kVA__c+') and (Total_Load_kVA_Higher_Band__c = null OR Total_Load_kVA_Higher_Band__c >= '+scheme.Total_Load_kVA__c+') ';
        if(scheme.Metering_Voltage__c != null && scheme.Metering_Voltage__c != '') 
            qString += ' AND Metering_Voltage__c = \''+scheme.Metering_Voltage__c+'\' ';
        if(scheme.POC__c != null && scheme.POC__c != '') 
            qString += ' AND POC__c = \''+scheme.POC__c+'\' ';
        if(scheme.DNO__c != null && scheme.DNO__c != '') 
            qString += ' AND DNO__c = \''+scheme.DNO__c+'\' ';
        if(scheme.IDNO__c != null && scheme.IDNO__c != '') 
            qString += ' AND IDNO__c = \''+scheme.IDNO__c+'\' ';
        if(scheme.GT__c != null && scheme.GT__c != '') 
            qString += ' AND GT__c = \''+scheme.GT__c+'\' '; // Gas
        if(scheme.IGT__c != null && scheme.IGT__c != '') 
            qString += ' AND IGT__c  = \''+scheme.IGT__c+'\' '; // Gas
        if(scheme.Water_Provider__c != null && scheme.Water_Provider__c != '') 
            qString += ' AND Pipe_type__c  = \''+scheme.Pipe_type__c+'\' '; // Water
        if(scheme.Pipe_type__c != null && scheme.Pipe_type__c != '') 
            qString += ' AND Water_Provider__c  = \''+scheme.Water_Provider__c+'\' '; // Water
        if(scheme.DNO_Reference__c != null && scheme.DNO_Reference__c != '') 
            qString += ' AND DNO_Reference__c = \''+scheme.DNO_Reference__c+'\' ';
        if(scheme.IDNO_Reference__c != null && scheme.IDNO_Reference__c != '') 
            qString += ' AND IDNO_Reference__c = \''+scheme.IDNO_Reference__c+'\' ';
        if(scheme.Number_of_Substations__c != null)
            qString += ' AND (Number_of_Substations_Lower_Band__c = null OR Number_of_Substations_Lower_Band__c <= '+scheme.Number_of_Substations__c+') and (Number_of_Substations_Higher_Band__c = null OR Number_of_Substations_Higher_Band__c >= '+scheme.Number_of_Substations__c+') ';
        if(scheme.Substation_Enclosure_Type__c != null && scheme.Substation_Enclosure_Type__c != '') 
            qString += ' AND Substation_Enclosure_Type__c = \''+scheme.Substation_Enclosure_Type__c+'\' ';
        if(scheme.Work_Zone__c != null && scheme.Work_Zone__c != '') 
            qString += ' AND Work_Zone__c = \''+scheme.Work_Zone__c+'\' ';
        if(scheme.Substation_Size__c != null && scheme.Substation_Size__c != '') 
            qString += ' AND Substation_Size__c = \''+scheme.Substation_Size__c+'\' ';
        
        if(scheme.To_Boundary__c != null)
            qString += ' AND (Boundary_Lower_Band__c = null OR Boundary_Lower_Band__c  <= '+scheme.To_Boundary__c +') and (Boundary_Higher_Band__c  = null OR Boundary_Higher_Band__c  >= '+scheme.To_Boundary__c +') ';
        if(scheme.Onsite_Excavation__c  != null)
            qString += ' AND (Onsite_Excavation_Lower_Band__c = null OR Onsite_Excavation_Lower_Band__c   <= '+scheme.Onsite_Excavation__c  +') and (Onsite_Excavation_Higher_Band__c = null OR Onsite_Excavation_Higher_Band__c >= '+scheme.Onsite_Excavation__c  +') ';
        if(scheme.No_of_Joint_Bays__c  != null)
            qString += ' AND (Number_of_Joint_Bays_Lower_Band__c = null OR Number_of_Joint_Bays_Lower_Band__c   <= '+scheme.No_of_Joint_Bays__c  +') and (Number_of_Joint_Bays_Higher_Band__c = null OR Number_of_Joint_Bays_Higher_Band__c >= '+scheme.No_of_Joint_Bays__c  +') ';
        
        
            system.debug(qString);
            rules = database.query(qString);
            system.debug('rules size '+rules.size());

            /*UtilityAvailableRules uar = new UtilityAvailableRules();
            uar.utilityType = utility;
            uar.rules = rules;
            uars.add(uar);*/

        
        /*List<Rule__c> rules = [SELECT Id, Name, Active__c, Description__c  FROM Rule__c 
                               where Active__c = true AND
                               Utility_Type__c = : utilityType AND
                               Product_Family__c = : ElectricSiteSchemes[0].Product_Family__c AND
                               Units_Type__c =: ElectricSiteSchemes[0].Units_Type__c AND
                               Number_of_Plots_Lower_Band__c <=: ElectricSiteSchemes[0].No_of_Units__c and Number_of_Plots_Higher_Band__c >=: ElectricSiteSchemes[0].No_of_Units__c AND
                               Total_Load_kVA_Lower_Band__c <=: ElectricSiteSchemes[0].Total_Load_kVA__c and Total_Load_kVA_Higher_Band__c >=: ElectricSiteSchemes[0].Total_Load_kVA__c AND
                               Metering_Voltage__c =: ElectricSiteSchemes[0].Metering_Voltage__c AND 
                               POC__c =: ElectricSiteSchemes[0].POC__c AND
                               DNO__c =: ElectricSiteSchemes[0].DNO__c AND
                               IDNO__c =: ElectricSiteSchemes[0].IDNO__c AND
                               DNO_Reference__c =: ElectricSiteSchemes[0].DNO_Reference__c AND
                               IDNO_Reference__c =: ElectricSiteSchemes[0].IDNO_Reference__c AND
                               Number_of_Substations_Lower_Band__c <=: ElectricSiteSchemes[0].Number_of_Substations__c and Number_of_Substations_Higher_Band__c >=: ElectricSiteSchemes[0].Number_of_Substations__c AND
                               Substation_Enclosure_Type__c =: ElectricSiteSchemes[0].Substation_Enclosure_Type__c AND
                               Substation_Size__c =: ElectricSiteSchemes[0].Substation_Size__c AND
                               Work_Zone__c =: ElectricSiteSchemes[0].Work_Zone__c 
                              ];*/
        
        
        return rules;
    }

    public class saveReturnValue
    {
        @AuraEnabled
        public String quoteId { get; set; }
        @AuraEnabled
        public String contentVersionId { get; set; }
        @AuraEnabled
        public String contentDocumentId { get; set; }  

    }
    
    public class UtilityItem
    {
        @AuraEnabled
        public String utilityType { get; set; }
        @AuraEnabled
        public String schemeRTId { get; set; }     
        @AuraEnabled
        public List<OpportunityProduct> oppProducts { get; set; }
        /*@AuraEnabled
        public List<SiteScheme> siteSchemes { get; set; }*/
        @AuraEnabled
        public List<Rule__c> rules { get; set; }
    }
    
    public class OpportunityProduct
    {
        @AuraEnabled
        public OpportunityLineItem__c oppLineItem { get; set; }        
    }
    
    public class SiteScheme
    {
        @AuraEnabled
        public Site_Scheme__c schemeItem { get; set; }        
    }
    
    public class UtilityAvailableRules
    {
        @AuraEnabled
        public String utilityType { get; set; }
        /*@AuraEnabled
        public Integer NoOfAvailableRules { get; set; }*/
        @AuraEnabled
        public List<Rule__c> rules { get; set; }
    }
    
    /* @AuraEnabled //Backup
    public static saveReturnValue saveUtilityProducts(Id oppId, List<UtilityItem> utilityProducts, List<OpportunityLineItem__c> labourSellItems, 
                                                      List<OpportunityLineItem__c> plantSellItems, String pdfBase64Data)
    {
        
        try
        {
            System.debug('pdfBase64Data '+pdfBase64Data);
            System.debug('labourSellItems size '+labourSellItems.size());
            System.debug('plantSellItems size '+plantSellItems.size());
            
            Map<String,Id> pbEntryMap = new Map<String,Id>();
            Set<Id> product2Ids = new Set<Id>();
            Set<Id> successQLineItemsId = new Set<Id>();
            //Opp Line Items
            List<OpportunityLineItem__c> oppLineItems = new List<OpportunityLineItem__c>(); 
            
            List<OpportunityLineItem__c> oppLineItemsToDelete = [SELECT Id FROM OpportunityLineItem__c WHERE OpportunityId__c =: oppId];
            
            for (UtilityItem uItem : utilityProducts)
            {
                for (OpportunityProduct oppProduct : uItem.oppProducts)
                {                
                    oppLineItems.add(oppProduct.oppLineItem);
                    product2Ids.add(oppProduct.oppLineItem.Product2Id__c);                
                }
                
                system.debug('oppLineItems '+oppLineItems);
            }
            
            for (OpportunityLineItem__c item : labourSellItems)
            {
                oppLineItems.add(item);
                product2Ids.add(item.Product2Id__c);    
            }
            
            for (OpportunityLineItem__c item : plantSellItems)
            {
                oppLineItems.add(item);
                product2Ids.add(item.Product2Id__c);
            }
            
            delete oppLineItemsToDelete;
            
            insert oppLineItems;
            
            
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id =: oppId];
            for(PricebookEntry pbEntry : [SELECT Id, Name, Pricebook2Id, Product2Id
                                          FROM PricebookEntry WHERE IsActive = true AND Product2Id IN: product2Ids])
            {
                pbEntryMap.put(pbEntry.Product2Id, pbEntry.id);

            }
            
            Quote q = new Quote();
            q.Name = 'Estimate for '+opp.Name;
            q.OpportunityId = oppId;
            insert q;
            
            List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
            for(OpportunityLineItem__c oppItem :oppLineItems)
            {
                QuoteLineItem qItem = new QuoteLineItem();
                qItem.QuoteId = q.Id;
                if(pbEntryMap.containsKey(oppItem.Product2Id__c)) qItem.PricebookEntryId = pbEntryMap.get(oppItem.Product2Id__c);
				qItem.OpportunityLineItem__c  = oppItem.Id;
                qItem.Product2Id = oppItem.Product2Id__c;
                qItem.Quantity = oppItem.Quantity__c;
                qItem.UnitPrice  = oppItem.UnitPrice__c;
                qItem.Implementor__c = oppItem.Implementor__c;
                qItem.Kit_Sell__c = oppItem.Kit_Sell__c;
                //qItem.Material_Sell__c = oppItem.Material_Sell__c;
                //qItem.Plant_Sell__c = oppItem.Plant_Sell__c;
                qItem.Material_Cost__c = oppItem.Material_Cost__c;
                qItem.Plant_Cost__c = oppItem.Plant_Cost__c;
                //System.debug('qItem: ' + qItem);
                quoteLineItems.add(qItem);
            }
            
            insert quoteLineItems;
            
            opp.SyncedQuoteId  = q.Id;
            update opp;
            
            Blob myBlob = EncodingUtil.base64Decode(pdfBase64Data);
            //String cvRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Estimator').getRecordTypeId();
            
            ContentVersion cv = new ContentVersion();
            cv.versionData = myBlob;
            cv.title = 'Estimate' + '_' + String.valueof(DateTime.now().getTime()) + '.pdf';
            cv.pathOnClient = 'Estimate' + '_' + String.valueof(DateTime.now().getTime()) + '.pdf';
            cv.Type__c = 'BT';
            cv.Group__c = 'Estimate';
            cv.RecordTypeId = '0124J000000hNK3QAM';
            cv.IsMajorVersion = true;
            system.debug(cv);
            insert cv;
            
            String ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = ContentDocumentId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = q.Id;
            insert cdl;
            
            saveReturnValue returnVal = new saveReturnValue();
            returnVal.quoteId = q.Id;
            returnVal.contentVersionId = cv.Id;
            returnVal.ContentDocumentId = ContentDocumentId;
            
            return returnVal;
            
            
        }
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }*/
    
}