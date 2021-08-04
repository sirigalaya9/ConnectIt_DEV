public class r3ProductKitAdopterHelper 
{
    static public List<Product_Kit__c> getComponentProducts(Id projectId, Id estimateId, List<Id> productKitIds)
    {
        System.debug('R3>>> r3ProductKitAdopterHelper.getComponentProducts: productKitIds sz:'+productKitIds.size());
        System.debug('R3>>> r3ProductKitAdopterHelper.getComponentProducts: projectId:'+projectId);
        System.debug('R3>>> r3ProductKitAdopterHelper.getComponentProducts: estimateId:'+estimateId);        
        List<Product_Kit__c> pkChildren = new List<Product_Kit__c>();   
        
        // get record types for site schemes (map name to record type info)
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        
        // map from id to name
        Map<Id,String> SiteSchemeRecordTypeIdToName = new Map<Id,String>();
        for(String recordTypeName :SiteSchemeTypeInfo.keySet())
            SiteSchemeRecordTypeIdToName.put(SiteSchemeTypeInfo.get(recordTypeName).getRecordTypeId(),recordTypeName);

        // get all site schemes for project
        List<site_scheme__c> siteSchemes;
        if(ProjectId != null)
        {
            siteSchemes = [SELECT Project__c, charger_provider__c, dno__c, idno__c, gt__c, igt__c, Water_Provider__c, recordTypeId, Pipe_Type__c 
                           FROM site_scheme__c 
                           WHERE Project__c = :projectId];
        }
        else if(EstimateId != null)
        {
            siteSchemes = [SELECT charger_provider__c, dno__c, idno__c, gt__c, igt__c, Water_Provider__c, recordTypeId, Pipe_Type__c
                           FROM site_scheme__c 
                           WHERE Estimate__c = :estimateId];
        }
        else
        {
            System.debug('R3>>> r3ProductKitAdopterHelper.getComponentProducts: Both estimate and project id are null!');
            return pkChildren;   // return empty list
        }
        System.debug('r3ProductKitAdopterHelper.getComponentProducts: siteSchemes sz:'+siteSchemes.size());
        
        List<Product_Kit__c> pkChildenAll = getProductKitComponents(productKitIds);
        System.debug('r3ProductKitAdopterHelper.getComponentProducts: pkChildenAll sz:'+pkChildenAll.size());

        // add items with no specific adopter...
        for(Product_Kit__c pk :pkChildenAll)
        {
            String prodAdopter  = pk.Salesforce_Product__r.Adopter__c;
            String prodWorkzone = pk.Salesforce_Product__r.work_zone__c;
            
            System.debug('R3>>> pk.Salesforce_Product__r.Name='+pk.Salesforce_Product__r.Name);
            System.debug('R3>>>     pk.Id='+pk.Id);
            System.debug('R3>>>     pk.Salesforce_Product__c='+pk.Salesforce_Product__c);
            System.debug('R3>>>     pk.Salesforce_Product__r.family='+pk.Salesforce_Product__r.family);
            System.debug('R3>>>     prodAdopter='+prodAdopter);
            System.debug('R3>>>     prodWorkzone='+prodWorkzone);
            
            if(prodAdopter == null)
                pkChildren.add(pk);
        }
        
        // work through schemes
        for(site_scheme__c siteScheme :siteSchemes)
        {
            String adopterOnsite;
            String adopterOffsite;
            String family;
            switch on SiteSchemeRecordTypeIdToName.get(siteScheme.RecordTypeId)
            {
                when 'Charger' 
                {		
                    adopterOnsite = siteScheme.IDNO__c;
                    adopterOffsite = siteScheme.DNO__c;
                    family = siteScheme.Charger_Provider__c;
                }	
                when 'Electric' 
                {	
                    adopterOnsite = siteScheme.IDNO__c;
                    adopterOffsite = siteScheme.DNO__c;
                    family = 'Electricity';
                }
                when 'Gas' 
                {	
                    adopterOnsite = siteScheme.IGT__c;
                    adopterOffsite = siteScheme.GT__c;
                    family = 'Gas';
                }
                when 'StreetLighting' 
                {	
                    adopterOnsite = siteScheme.IDNO__c;
                    adopterOffsite = siteScheme.DNO__c;
                    family = 'StreetLighting';
                }
                when 'Water' 
                {		
                    adopterOnsite = siteScheme.Water_Provider__c;
                    adopterOffsite = siteScheme.Water_Provider__c;
                    family = 'Water';
                }
                when else 
                {
                    system.assert(false, 'Unsupported site scheme record type!');
                }
            }
           
            // filter all product kit component products according to adopter...
            for(Product_Kit__c pk :pkChildenAll)
            {
                String prodAdopter  = pk.Salesforce_Product__r.Adopter__c;
                String prodWorkzone = pk.Salesforce_Product__r.work_zone__c;
                
                System.debug('R3>>> pk.Salesforce_Product__r.Name='+pk.Salesforce_Product__r.Name);
                System.debug('R3>>>     pk.Id='+pk.Id);
                System.debug('R3>>>     pk.Salesforce_Product__c='+pk.Salesforce_Product__c);
                System.debug('R3>>>     pk.Salesforce_Product__r.family='+pk.Salesforce_Product__r.family);
                System.debug('R3>>>     prodAdopter='+prodAdopter);
                System.debug('R3>>>     prodWorkzone='+prodWorkzone);
                System.debug('R3>>> family='+family);
                System.debug('R3>>> adopterOnsite='+adopterOnsite);
                System.debug('R3>>> adopterOffsite='+adopterOffsite);

                if(SiteSchemeRecordTypeIdToName.get(siteScheme.RecordTypeId) == family)
                {
                    if(SiteSchemeRecordTypeIdToName.get(siteScheme.RecordTypeId) != 'Water')
                    {
                        if(prodAdopter == adopterOnsite && prodWorkzone == 'Onsite')
                            pkChildren.add(pk);
                        else if(prodAdopter == adopterOffsite && prodWorkzone == 'Offsite')               
                            pkChildren.add(pk);
                        else if(prodAdopter == adopterOnsite && prodAdopter == adopterOffsite && (prodWorkzone == 'Both' || prodWorkzone == ''))
                            pkChildren.add(pk);
                        else
                            system.debug('R3>>> POL not created for '+pk.Salesforce_Product__r.Name+' (Non-Water)');
                    }
                    else  // water
                    {
                        if(prodAdopter == adopterOnsite && 
                           (prodWorkzone == siteScheme.Pipe_Type__c || prodWorkzone == null))
                            pkChildren.add(pk);
                        else
                            system.debug('R3>>> POL not created for '+pk.Salesforce_Product__r.Name+' (Water)');                   
                    }
                }
            }
        }

        return pkChildren;  // return list
    }
    
    static public List<Product_Kit__c> getAllComponentProducts(List<Id> productKitIds)
    {
        System.debug('R3>>> r3ProductKitAdopterHelper.getAllComponentProducts: productKitIds sz:'+productKitIds.size());
        return getProductKitComponents(productKitIds);
    }

	static private List<Product_Kit__c> getProductKitComponents(List<Id> productKitIds)  
    {
    	return [SELECT Id, Name, Quantity__c, Parent_Product__c,
                       Salesforce_Product__c, 
                       Salesforce_Product__r.Name,
                       Salesforce_Product__r.ProductCode,
                       Salesforce_Product__r.Allocated_Stock__c,
                       Salesforce_Product__r.Free_Stock__c,
                       Salesforce_Product__r.Lead_Time__c,
                       Salesforce_Product__r.Adopter__c,
                       Salesforce_Product__r.work_zone__c,
                       Salesforce_Product__r.family
                FROM Product_Kit__c 
                WHERE Parent_Product__c IN :productKitIds
                ORDER BY Salesforce_Product__r.Sort__c ];
    }

}