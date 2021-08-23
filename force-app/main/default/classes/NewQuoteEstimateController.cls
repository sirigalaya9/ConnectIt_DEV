public class NewQuoteEstimateController {
    public static List<Site_Scheme__c> ElectricSiteSchemes {get; set;}
    public static List<Site_Scheme__c> GasSiteSchemes {get; set;}
    public static List<Site_Scheme__c> WaterSiteSchemes {get; set;}
    public static List<Site_Scheme__c> ChargerPointSiteSchemes {get; set;}
    public static List<Site_Scheme__c> StreetLightningSiteSchemes {get; set;}
    public static List<Site_Scheme__c> siteSchemes {get; set;}
    public static Map<Id,Decimal> defaultProductQuantityMap = new Map<Id,Decimal>();
    
    @AuraEnabled
    public static List<sObject> query(String q)
    {
        system.debug(q);
        return Database.query(q);
    }
    
    
    @AuraEnabled
    public static List<LookupSearchResult> searchProduct(String searchKeyWord, String utilityType)
    {
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
    public static Map<String,Site_Scheme__c> getExistingScheme(Id oppId, List<String> selectedUtilityList)
    {
        Map<Id,String> schemeIdMap = new Map<Id,String>();
        Map<String,Site_Scheme__c> utilitySchemeMap = new Map<String,Site_Scheme__c>();
        List<Site_Scheme__c> allRelatedScheme = [SELECT Id, RecordType.Name,POC__c,Number_of_Substations__c,Number_of_Link_Boxes__c,No_of_Commercial__c,No_of_Landlord__c,Total_Number_of_plots__c
                                                 FROM Site_Scheme__c WHERE  Estimate__c =: oppId  ORDER BY CreatedDate DESC];
        
        for(String utility : selectedUtilityList)
        {
            for(Site_Scheme__c scheme : allRelatedScheme)
            {
                String rtName = utility;
                if(utility == 'Charge Points') rtName = 'Charger';
                else if(utility == 'Street Lighting') rtName = 'StreetLighting';
                
                if(rtName == scheme.RecordType.Name)
                {
                    //schemeIdMap.put(scheme.Id,utility);
                    utilitySchemeMap.put(rtName,scheme);
                    break;
                }
            }             
        }
        
        return utilitySchemeMap;
        
    }
    
    @AuraEnabled
    public static List<UtilityItem> getInitialLineItems(Id oppId, List<String> selectedUtilityList, String objectName, Boolean isNew) //Site_Scheme__c
    {
        Map<String, String> utilitySchemeMap = new Map<String, String>();
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByDeveloperName(); //getRecordTypeInfosByName
        String query;
        List<String> sitSchemeFields = new List<String>(Site_Scheme__c.SObjectType.getDescribe().fields.getMap().keySet());
        sitSchemeFields.add('recordType.Developername');
        
        Integer number_of_existing_Items = [Select count() FROM opportunityLineItem__c WHERE OpportunityId__c =: oppId];
        system.debug('number_of_existing_Items '+number_of_existing_Items);
        
        Map<String, String> fieldMap = new Map<String, String>();
        List<UtilityItem> UtilityItems = new List<UtilityItem>();
        List<Product2> defaultProducts = new List<Product2>();
        String schemeRTId;
        List<opportunityLineItem__c> customOppLineItems;
        Set<Id> selectedRuleIds ;
        system.debug('selectedUtilityList '+selectedUtilityList);
        
        for(String utility : selectedUtilityList)
        {
            system.debug('utility '+utility);
            selectedRuleIds = new Set<Id>();
            UtilityItem uItem = new UtilityItem();
            uItem.utilityType = utility;
            uItem.schemeRTId = schemeRTId;
            uItem.oppProducts = new List<OpportunityProduct>();
            
            if(number_of_existing_Items > 0)
            {
                customOppLineItems = [Select id, OpportunityId__c, Product_Text__c, BORIS_Code__c ,BORIS_Voltage__c, 
                                      Unit_Of_Measure_ref__c, Quantity__c,Implementor__c,
                                      Kit_Sell__c ,UnitPrice__c ,Labour_Cost__c ,Plant_Cost__c ,Material_Cost__c,Plant_Sell__c,
                                      Product2Id__c, Product2Id__r.ProductCode, Product2Id__r.Name, Product2Id__r.Family,
                                      Product2Id__r.Labour_Sell__c,Product2Id__r.Plant_Sell__c, Load_Source__c, Rule_Id__c, Rule_Name__c
                                      FROM opportunityLineItem__c WHERE OpportunityId__c =: oppId AND Utility_Type__c = : utility ORDER BY CreatedDate];
                
                if(!customOppLineItems.isEmpty())
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
                        pro.Labour_Sell__c = item.UnitPrice__c;
                        pro.Plant_Sell__c = item.Plant_Sell__c;
                        
                        oppLineItem.Product2Id__r = pro;
                        oppLineItem.Id = item.Id;
                        oppLineItem.Quantity__c = item.Quantity__c;
                        oppLineItem.Implementor__c = item.Implementor__c;
                        oppLineItem.Kit_Sell__c = item.Kit_Sell__c;
                        //oppLineItem.Material_Sell__c = item.Material_Sell__c;
                        //oppLineItem.Labour_Sell__c = item.Labour_Sell__c;
                        //oppLineItem.Plant_Sell__c = item.Plant_Sell__c;
                        oppLineItem.Material_Cost__c = item.Material_Cost__c;
                        oppLineItem.Plant_Cost__c = item.Plant_Cost__c;
                        oppLineItem.Load_Source__c = item.Load_Source__c;
                        oppLineItem.Rule_Id__c = item.Rule_Id__c;
                        oppLineItem.Rule_Name__c = item.Rule_Name__c;
                        if(item.Rule_Id__c != null) selectedRuleIds.add(item.Rule_Id__c);                    
                        oppProduct.oppLineItem = oppLineItem; 
                        uItem.oppProducts.add(oppProduct);
                    }
                    
                    uItem.selectedRuleIds = selectedRuleIds;
                }
            }
            else
            {
                system.debug('isNew TRUE');
                queryAllSchemes(oppId);
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
                else if(utility == 'Charge Points') 
                {
                    schemeRTId = SiteSchemeRecordTypeInfo.get('Charger').getRecordTypeId();
                    if(ChargerPointSiteSchemes.size() > 0)
                    {
                        defaultProducts = getDefaultProducts(ChargerPointSiteSchemes, utility);  // get Baseline Products from all Charge Points Schemes
                    }           
                }
                else if(utility == 'Street Lighting')
                {
                    schemeRTId = SiteSchemeRecordTypeInfo.get('StreetLighting').getRecordTypeId();
                    if(StreetLightningSiteSchemes.size() > 0)
                    {
                        defaultProducts = getDefaultProducts(StreetLightningSiteSchemes, utility);  // get Baseline Products from all Water Schemes
                    }
                }
                
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
                    oppProduct.oppLineItem = oppLineItem;  
                    uItem.oppProducts.add(oppProduct);
                }
            }
            
            system.debug('defaultProducts '+defaultProducts.size());
            uItem.rules = getrelatedRules(utility, oppId);

            utilityItems.add(uItem);
        }
        return utilityItems;
    }
    
    @AuraEnabled
    public static List<OpportunityProduct> getCoreProductsByRules(String oppId,String utilityType, List<String> selectedRuleIds)
    {
        List<UtilityItem> ui = new List<UtilityItem>();
        if(utilityType == 'Charge Points') utilityType = 'Charger';
        else if(utilityType == 'Street Lighting') utilityType = 'StreetLighting';
        
        system.debug('utilityType '+utilityType);
        system.debug('selectedRuleIds '+selectedRuleIds);
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        List<Product2> defaultProducts = new List<Product2>();
        List<OpportunityProduct> oppProducts = new List<OpportunityProduct>();
        
        Decimal noOf_LinkBoxes = 1 ;
        Decimal onsiteExcavation = 1 ;
        Decimal noOf_JointBays = 1 ;
        
        List<site_scheme__c> scheme = [SELECT Id, RecordType.Name, No_of_Units__c,Total_Number_of_plots__c,
                                       No_of_Commercial__c, No_of_Houses__c, No_of_Landlord__c, No_of_Flats__c, No_of_TBS__c,
                                       To_Boundary__c, Onsite_Excavation__c, No_of_Joint_Bays__c, Number_of_Link_Boxes__c,
                                       X5m__c,X6m__c,X6m_Hinged__c,X8m__c,X10m__c,X12m__c
                                       FROM site_scheme__c WHERE Estimate__c = :oppId AND RecordType.Name =: utilityType order by createddate desc];
        if(!scheme.isEmpty()) 
        {
            if(scheme[0].Number_of_Link_Boxes__c != null) noOf_LinkBoxes = scheme[0].Number_of_Link_Boxes__c;
            if(scheme[0].Onsite_Excavation__c != null) onsiteExcavation = scheme[0].Onsite_Excavation__c;
            if(scheme[0].No_of_Joint_Bays__c != null) noOf_JointBays = scheme[0].No_of_Joint_Bays__c;
            
            system.debug('noOf_LinkBoxes '+noOf_LinkBoxes);
            system.debug('onsiteExcavation '+onsiteExcavation);
            system.debug('noOf_JointBays '+noOf_JointBays);
            
            List<Core_Product_Rule__c> coreProducts = [SELECT Id, Rule__c, Rule__r.Name, Rule__r.Utility_Type__c, Rule__r.Units_Type__c,Product__c, Rule__r.Type_of_Street_Light__c,
                                                       Product__r.Name, Product__r.Family, Product__r.Kit_Sell__c,
                                                       Product__r.Labour_Sell__c, Product__r.Plant_Sell__c, Product__r.Implementor__c,Product__r.Material_Cost__c,
                                                       Quantity__c,To_Multiply__c, Qty_Multiplier_formula__c,Multiplier_Field__c, Plots_Per_Quantity__c 
                                                       FROM Core_Product_Rule__c WHERE Rule__c IN : selectedRuleIds order by createdDate];
            
            for(Core_Product_Rule__c corePro : coreProducts)
            {
                system.debug('Multiplier_Field__c '+corePro.Multiplier_Field__c);
                system.debug('Plots_Per_Quantity__c '+corePro.Plots_Per_Quantity__c);
                Product2 pro = new Product2(Id = corePro.Product__c, 
                                            Name = corePro.Product__r.Name,
                                            Family = corePro.Product__r.Family,
                                            Implementor__c = corePro.Product__r.Implementor__c,
                                            Material_Cost__c = corePro.Product__r.Material_Cost__c,
                                            Kit_Sell__c = corePro.Product__r.Kit_Sell__c,
                                            Labour_Sell__c = corePro.Product__r.Labour_Sell__c,
                                            Plant_Sell__c = corePro.Product__r.Plant_Sell__c);
                system.debug('add Core '+pro);
                
                OpportunityProduct oppProduct = new OpportunityProduct();
                OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c();
                oppLineItem.OpportunityId__c = oppId;
                oppLineItem.Rule_Id__c = corePro.Rule__c;
                oppLineItem.Rule_Name__c = corePro.Rule__r.Name;
                oppLineItem.Product2Id__r = pro;
                oppLineItem.Implementor__c = pro.Implementor__c;
                oppLineItem.Material_Cost__c = pro.Material_Cost__c;
                if(pro.Kit_Sell__c == null) oppLineItem.Kit_Sell__c = 0; else oppLineItem.Kit_Sell__c = pro.Kit_Sell__c;
                
                Decimal value = 1;
                if(corePro.Qty_Multiplier_formula__c == 'To Multiply') 
                {
                    system.debug('To Multiply');
                    if(corePro.Multiplier_Field__c == 'Total Number of Plots')
                    {   
                        value = getNoOfPlots(corePro, utilityType, scheme);
                    }
                    else if(corePro.Multiplier_Field__c == 'No of Joint Bays')
                    {
                        value = noOf_JointBays ;
                    }
                    else if(corePro.Multiplier_Field__c == 'Number of Link Boxes')
                    {
                        value = noOf_LinkBoxes ;
                    }
                    else if(corePro.Multiplier_Field__c == 'Onsite Excavation')
                    {
                        value = onsiteExcavation ;
                    }
                    
                    oppLineItem.Quantity__c = corePro.Quantity__c * value ;
                    
                    system.debug('corePro.Quantity__c '+corePro.Quantity__c);
                    system.debug('value '+value);
                    
                    system.debug('oppLineItem.Quantity--Multiply--- '+oppLineItem.Quantity__c);
                    
                }
                else if(corePro.Qty_Multiplier_formula__c == 'To Divide')
                {
                    system.debug('To Divide');
                    
                    value = getNoOfPlots(corePro, utilityType, scheme);
                    
                    oppLineItem.Quantity__c = value * corePro.Quantity__c / corePro.Plots_Per_Quantity__c ;
                    
                    system.debug('corePro.Quantity__c '+corePro.Quantity__c);
                    system.debug('value '+value);
                    
                    system.debug('oppLineItem.Quantity--Divide--- '+oppLineItem.Quantity__c);
                }
                else oppLineItem.Quantity__c  =  corePro.Quantity__c;
                
                oppProduct.oppLineItem = oppLineItem;  
                oppProducts.add(oppProduct);
                
            }
            
        }
        
        system.debug('oppProducts '+oppProducts.size());
        
        return oppProducts;
    }
    
    private static Decimal getNoOfPlots(Core_Product_Rule__c corePro, String utilityType, List<site_scheme__c> scheme)
    {
        Decimal value = 1;
        
        if(utilityType == 'Electric' || utilityType == 'Water' || utilityType == 'Gas')
        {
            if(corePro.Rule__r.Units_Type__c == 'Commercial' && scheme[0].No_of_Commercial__c != null) value = scheme[0].No_of_Commercial__c;
            if(corePro.Rule__r.Units_Type__c == 'Flats' && scheme[0].No_of_Flats__c != null) value = scheme[0].No_of_Flats__c ;
            if(corePro.Rule__r.Units_Type__c == 'Landlord' && scheme[0].No_of_Landlord__c != null) value = scheme[0].No_of_Landlord__c ;
            if(corePro.Rule__r.Units_Type__c == 'Houses' && scheme[0].No_of_Houses__c != null) value = scheme[0].No_of_Houses__c ;
            if(corePro.Rule__r.Units_Type__c == 'TBS' && scheme[0].No_of_TBS__c != null) value = scheme[0].No_of_TBS__c ;
            if(corePro.Rule__r.Units_Type__c == 'Applicable for all' && scheme[0].Total_Number_of_plots__c != null) value = scheme[0].Total_Number_of_plots__c ;
            
        }
        else if(utilityType == 'StreetLighting')
        {
            if(corePro.Rule__r.Type_of_Street_Light__c == '5m' && scheme[0].X5m__c != null) value = scheme[0].X5m__c;
            if(corePro.Rule__r.Type_of_Street_Light__c == '6m' && scheme[0].X6m__c != null) value = scheme[0].X6m__c ;
            if(corePro.Rule__r.Type_of_Street_Light__c == '6m Hinged' && scheme[0].X6m_Hinged__c != null) value = scheme[0].X6m_Hinged__c ;
            if(corePro.Rule__r.Type_of_Street_Light__c == '8m' && scheme[0].X8m__c != null) value = scheme[0].X8m__c ;
            if(corePro.Rule__r.Type_of_Street_Light__c == '10m' && scheme[0].X10m__c != null) value = scheme[0].X10m__c ;
            if(corePro.Rule__r.Type_of_Street_Light__c == '12m' && scheme[0].X12m__c != null) value = scheme[0].X12m__c ;
            if(corePro.Rule__r.Type_of_Street_Light__c == 'Applicable for all' && scheme[0].Total_Number_of_plots__c != null) value = scheme[0].Total_Number_of_plots__c ;
            
        }
        
        return value;
    }
    
    @AuraEnabled
    public static List<Scheme_Type_Breakdown__c> saveSchemeBreakdown(String parentId, List<Scheme_Type_Breakdown__c> schemeBreakdown, String recordTypeName, String utilityType, Integer numberOfPlot)
    {
        
        try
        {
            system.debug(schemeBreakdown);
            Set<Id> Ids = new Set<Id>();
            for(Scheme_Type_Breakdown__c stb : schemeBreakdown)
            {
                Ids.add(stb.Id);
            }
            
            Integer existingCount = [SELECT COUNT() FROM Scheme_Type_Breakdown__c WHERE Site_Scheme__c =: parentId AND RecordType.Name =: recordTypeName AND Utility_Type__c =: utilityType];
            
            List<Scheme_Type_Breakdown__c> schemeBreakdownToDelete = [SELECT Id FROM Scheme_Type_Breakdown__c WHERE Site_Scheme__c =: parentId 
                                                                      AND RecordType.Name =: recordTypeName
                                                                      AND Utility_Type__c =: utilityType
                                                                      AND Id NOT IN: Ids];
            
            if(existingCount > schemeBreakdown.size() && recordTypeName != 'Landlords') 
            {
                delete schemeBreakdownToDelete;
            }
            
            upsert schemeBreakdown;
            
            
            Site_Scheme__c schemeToUpdate = new Site_Scheme__c();
            schemeToUpdate.Id = parentId;
            if(recordTypeName == 'Commercial') schemeToUpdate.No_of_Commercial__c = numberOfPlot;
            else if(recordTypeName == 'Substation') schemeToUpdate.Number_of_Substations__c = numberOfPlot;
            else if(recordTypeName == 'Landlords') schemeToUpdate.No_of_Landlord__c = numberOfPlot;
            update schemeToUpdate;
            
            return schemeBreakdown;
            
        }
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<OpportunityLineItem__c> saveUtilityProducts(Id oppId, List<UtilityItem> utilityProducts, List<sObject> deleteLineItems)
    {
        
        try
        {
            List<OpportunityLineItem__c> oppLineItems = new List<OpportunityLineItem__c>(); 
            
            for (UtilityItem uItem : utilityProducts)
            {
                for (OpportunityProduct oppProduct : uItem.oppProducts)
                {                
                    oppLineItems.add(oppProduct.oppLineItem);             
                }
                
                system.debug('oppLineItems '+oppLineItems);
            }
            
            system.debug('deleteLineItems '+deleteLineItems);
            
            
            if(!deleteLineItems.isEmpty() && deleteLineItems != null) delete deleteLineItems;
            if(!oppLineItems.isEmpty()) upsert oppLineItems;
            
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
            //System.debug('pdfBase64Data '+pdfBase64Data);
            String pricebookId;
            if(!Test.isRunningTest())
            {
                pricebookId = [SELECT Id, Name, IsActive FROM PriceBook2 WHERE IsStandard= True LIMIT 1].Id;
                //pricebookId = pb.id;
            }
            else
                pricebookId = Test.getStandardPricebookId();
            
            Map<String,Id> pbEntryMap = new Map<String,Id>();
            Set<Id> product2Ids = new Set<Id>();
            Set<Id> successQLineItemsId = new Set<Id>();

            List<OpportunityLineItem__c> oppLineItemsExisting = [SELECT Id, Name, OpportunityId__c, Material_Cost__c, Labour_Cost__c, Plant_Cost__c, Cost_Price__c, Kit_Sell__c, 
                                                                 UnitPrice__c, Quantity__c, Implementor__c, Product2Id__c, Total_Sell__c, Total_Cost__c, Sell_Price__c, Plant_Sell__c
                                                                 FROM OpportunityLineItem__c WHERE OpportunityId__c =: oppId];
            
            for (OpportunityLineItem__c item : oppLineItemsExisting)
            {
                product2Ids.add(item.Product2Id__c);
            }
            
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id =: oppId];
            for(PricebookEntry pbEntry : [SELECT Id, Name, Pricebook2Id, Product2Id
                                          FROM PricebookEntry WHERE IsActive = true AND Product2Id IN: product2Ids])
            {
                pbEntryMap.put(pbEntry.Product2Id, pbEntry.id);
            }
            
            Quote q = new Quote();
            q.Name = 'Estimate for '+opp.Name;
            q.OpportunityId = oppId;
            q.Pricebook2Id = pricebookId;
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
                //qItem.Labour_Sell__c = oppItem.UnitPrice__c;
                qItem.Plant_Sell__c = oppItem.Plant_Sell__c;
                qItem.Material_Cost__c = oppItem.Material_Cost__c;
                qItem.Plant_Cost__c = oppItem.Plant_Cost__c;
                //System.debug('qItem: ' + qItem);
                quoteLineItems.add(qItem);
            }
            
            insert quoteLineItems;
            
            opp.SyncedQuoteId  = q.Id;
            update opp;
            
            Blob myBlob = EncodingUtil.base64Decode(pdfBase64Data);
            String cvRTId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('Estimator').getRecordTypeId();
            
            ContentVersion cv = new ContentVersion();
            cv.versionData = myBlob;
            cv.title = 'Estimate' + '_' + String.valueof(DateTime.now().getTime()) + '.pdf';
            cv.pathOnClient = 'Estimate' + '_' + String.valueof(DateTime.now().getTime()) + '.pdf';
            cv.Type__c = 'BT';
            cv.Group__c = 'Estimate';
            cv.RecordTypeId = cvRTId;
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

    @AuraEnabled
    public static List<Rule__c> getrelatedRules(String utility, String oppId)
    {
        String query; 
        List<Rule__c> rules = new List<Rule__c>();
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByDeveloperName(); //getRecordTypeInfosByName
        List<String> sitSchemeFields = new List<String>(Site_Scheme__c.SObjectType.getDescribe().fields.getMap().keySet());
        String objectName = 'site_scheme__c';
        site_scheme__c scheme;
        //List<UtilityAvailableRules> uars = new List<UtilityAvailableRules> ();
        
        // get site scheme...
        queryAllSchemes(oppId);
        
        system.debug(utility);
        if(utility == 'Electric' && !ElectricSiteSchemes.isEmpty()) scheme = ElectricSiteSchemes[0];
        else if(utility == 'Gas' && !GasSiteSchemes.isEmpty()) scheme = GasSiteSchemes[0];
        else if(utility == 'Water' && !WaterSiteSchemes.isEmpty()) scheme = WaterSiteSchemes[0];
        else if(utility == 'Charge Points' && !WaterSiteSchemes.isEmpty()) scheme = WaterSiteSchemes[0];
        else if(utility == 'Street Lighting' && !StreetLightningSiteSchemes.isEmpty()) scheme = StreetLightningSiteSchemes[0];
        system.debug(scheme);
        
        
        if(scheme != null)
        {
            String qString = 'SELECT Id, Name, Active__c, Description__c FROM Rule__c WHERE Active__c = true ';
            if(utility != null && utility != '') 
                qString += ' AND Utility_Type__c = \''+utility+'\' ';
            if(scheme.Product_Family__c != null && scheme.Product_Family__c != '') 
                qString += ' AND Product_Family__c = \''+scheme.Product_Family__c+'\' ';
            
            if(scheme.Total_Number_of_plots__c >= 0 )
            {
                if(utility == 'Electric' || utility == 'Gas' ||utility == 'Water')
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
                    if(scheme.No_of_Landlord__c != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Units_Type__c = \'Landlord\' ';
                        qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Landlord__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Landlord__c+')) ';
                        if(first == true) first = false;
                    }
                    if(scheme.No_of_Flats__c  != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Units_Type__c = \'Flats\' ';
                        qString += ' AND (Number_of_Plots_Lower_Band__c = null OR Number_of_Plots_Lower_Band__c <= '+scheme.No_of_Flats__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.No_of_Flats__c+')) ';
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
                else if(utility == 'Street Lighting')
                {
                    Boolean first = true;
                    qString += ' AND ( ';
                    
                    qString += ' ( Type_of_Street_Light__c = \'Applicable for all\' ';
                    qString += ' AND (Number_of_Street_Lights_Lower_Band__c  = null OR Number_of_Street_Lights_Lower_Band__c  <= '+scheme.Total_Number_of_plots__c+') and (Number_of_Street_Lights_Higher_Band__c  = null OR Number_of_Street_Lights_Higher_Band__c  >= '+scheme.Total_Number_of_plots__c+')) ';
                    if(first == true) first = false;
                    
                    if(scheme.X5m__c != null) {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Type_of_Street_Light__c  = \'5m\' ';
                        qString += ' AND (Number_of_Street_Lights_Lower_Band__c = null OR Number_of_Street_Lights_Lower_Band__c <= '+scheme.X5m__c+') and (Number_of_Street_Lights_Higher_Band__c = null OR Number_of_Street_Lights_Higher_Band__c >= '+scheme.X5m__c+')) ';
                        if(first == true) first = false;
                    }
                    if(scheme.X6m__c != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Type_of_Street_Light__c  = \'6m\' ';
                        qString += ' AND (Number_of_Street_Lights_Lower_Band__c = null OR Number_of_Street_Lights_Lower_Band__c <= '+scheme.X6m__c+') and (Number_of_Street_Lights_Higher_Band__c = null OR Number_of_Street_Lights_Higher_Band__c >= '+scheme.X6m__c+')) ';
                        if(first == true) first = false;
                    }
                    if(scheme.X6m_Hinged__c != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Type_of_Street_Light__c  = \'6m Hinged\' ';
                        qString += ' AND (Number_of_Street_Lights_Lower_Band__c = null OR Number_of_Street_Lights_Lower_Band__c <= '+scheme.X6m_Hinged__c+') and (Number_of_Street_Lights_Higher_Band__c = null OR Number_of_Street_Lights_Higher_Band__c >= '+scheme.X6m_Hinged__c+')) ';
                        if(first == true) first = false;
                    }
                    if(scheme.X8m__c != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Type_of_Street_Light__c  = \'8m\' ';
                        qString += ' AND (Number_of_Street_Lights_Lower_Band__c = null OR Number_of_Street_Lights_Lower_Band__c <= '+scheme.X8m__c+') and (Number_of_Street_Lights_Higher_Band__c = null OR Number_of_Street_Lights_Higher_Band__c >= '+scheme.X8m__c+')) ';
                        if(first == true) first = false;
                    }
                    if(scheme.X10m__c != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Type_of_Street_Light__c  = \'10m\' ';
                        qString += ' AND (Number_of_Street_Lights_Lower_Band__c = null OR Number_of_Street_Lights_Lower_Band__c <= '+scheme.X10m__c+') and (Number_of_Street_Lights_Higher_Band__c = null OR Number_of_Street_Lights_Higher_Band__c >= '+scheme.X10m__c+')) ';
                        if(first == true) first = false;
                    }
                    if(scheme.X12m__c != null) 
                    {
                        if(first == false) qString += ' OR ';
                        qString += ' ( Type_of_Street_Light__c  = \'12m\' ';
                        qString += ' AND (Number_of_Street_Lights_Lower_Band__c = null OR Number_of_Street_Lights_Lower_Band__c <= '+scheme.X12m__c+') and (Number_of_Plots_Higher_Band__c = null OR Number_of_Plots_Higher_Band__c >= '+scheme.X12m__c+')) ';
                        if(first == true) first = false;
                    }
                    
                    qString += ' ) '; 
                }
                
            }
            
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
                qString += ' AND Water_Provider__c  = \''+scheme.Water_Provider__c+'\' '; // Water
            if(scheme.Pipe_type__c != null && scheme.Pipe_type__c != '') 
                qString += ' AND Pipe_type__c  = \''+scheme.Pipe_type__c+'\' '; // Water
            if(scheme.Host_Water_Adopter__c != null && scheme.Host_Water_Adopter__c != '') 
                qString += ' AND Host_Water_Adopter__c  = \''+scheme.Host_Water_Adopter__c+'\' '; // Water    
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
        }
        
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
        @AuraEnabled
        public List<Rule__c> rules { get; set; }
        @AuraEnabled
        public Set<Id> selectedRuleIds { get; set; }
    }
    
    public class OpportunityProduct
    {
        @AuraEnabled
        public OpportunityLineItem__c oppLineItem { get; set; }        
    }
    
    /*public class SiteScheme
    {
        @AuraEnabled
        public Site_Scheme__c schemeItem { get; set; }        
    }
    
    public class UtilityAvailableRules
    {
        @AuraEnabled
        public String utilityType { get; set; }
        @AuraEnabled
        public List<Rule__c> rules { get; set; }
    }*/
    
}