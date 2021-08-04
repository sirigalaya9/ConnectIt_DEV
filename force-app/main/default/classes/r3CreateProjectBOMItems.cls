public class r3CreateProjectBOMItems 
{ 
    @InvocableMethod
    public static void createBOMItems(Request[] requests)
    {
        Map<Id,Product2> productMap = new Map<Id,Product2>();  // to store products...
        List<Project_BOM_Item__c> bomInsertLst = new List<Project_BOM_Item__c>();

        for(Request request :requests) 
        {
            Id projectId = request.projectId;
            Id estimateId = request.estimateId;

            //Map<Id, Project_BOM_Item__c> lookupBOMbyOLI = new Map<Id, Project_BOM_Item__c> ();

            // top level does not necessarily have to be a kit product...
            List<OpportunityLineItem__c> olis = [SELECT Cost_Price__c,Id,product2Id__c, Quantity__c, free_issue_materials__c
                                                FROM OpportunityLineItem__c WHERE OpportunityId__c = :EstimateId];
            Map<Id,Id> oliToProductMap = new Map<Id,Id>();
            
            // get list of product ids to query...
            List<Id> oliIds = new List<Id>();
            for(OpportunityLineItem__c oli :olis) {
                if(oli.Quantity__c != null && oli.Quantity__c > 0) {
                    oliToProductMap.put(oli.id,oli.product2Id__c);
                }  
                oliIds.add(oli.id);
            }

            // get top level product (mostly kits, of which we need to get the component products)...
            List<Product2> topLevelProductLst = [SELECT Id, Name, Is_Kit__c, Material_Cost__c, Material_Sell__c, Free_Issue_Materials__c FROM Product2 WHERE Id IN :oliToProductMap.values()];
            for(Product2 prod :topLevelProductLst)
            {
                ProductMap.put(prod.id,prod);   // store product...
            }

            // Create a BOM Item for each estimate product...
            for(OpportunityLineItem__c oli :olis)
            {

                if(oli.Quantity__c == null || oli.Quantity__c <= 0) {
                    continue;  // skip if zero quantity!
                }
                
                // singular (material) product, create BOM item for product
                Product2 prod = productMap.get(oli.product2Id__c);
                System.debug('prodMap.get('+oli.product2Id__c+')= '+prod);
                System.debug('prod.Material_Cost__c:'+prod.Material_Cost__c);                
                if((prod != null && prod.Material_Cost__c != null && prod.Material_Cost__c > 0) || (prod != null && prod.Free_Issue_Materials__c == TRUE))
                {
                    Project_BOM_Item__c pbi = createBOMItem(oli, prod, null, projectId, 1);  // component quantity of 1 - as single product instance
                    bomInsertLst.add(pbi);
                        
                }

            }

            System.debug('bomInsertLst size:'+bomInsertLst.size());
            System.debug('bomInsertLst:'+bomInsertLst);            
            if (!bomInsertLst.isEmpty()) {
                insert bomInsertLst;
            }    
            Map<Id, Id> lookupBomItemUsingEstimateProduct = new Map<Id, Id>();
            List<Id> validOliIds = new List<Id>();   
            for(Project_BOM_Item__c bom :bomInsertLst)  {
                validOliIds.add(bom.Estimate_Product_Id__c);
                lookupBomItemUsingEstimateProduct.put(bom.Estimate_Product_Id__c,bom.Id);
            }
            System.debug('validOliIds size:'+validOliIds.size());

            // create a map to lookup Site Asset
            
            List<Site_Asset_Value_Estimate_Product_Join__c> siteAssetValueEstimateProductJoins = [SELECT Estimate_Product__c,Id,
                                                                                                        Product_Kit_Name__c,Quantity__c,Site_Asset__c
                                                                                                        FROM Site_Asset_Value_Estimate_Product_Join__c 
                                                                                                        WHERE Estimate_Product__c IN :validOliIds];

            // Create a Site Asset Bom Join for each Site_Asset_Value_Estimate_Product Join ...            
            List<Site_Asset_BOM_Join__c> siteAssetBOMJoins = new List<Site_Asset_BOM_Join__c>();        
            for(Site_Asset_Value_Estimate_Product_Join__c savEpj :siteAssetValueEstimateProductJoins)  {

                // only add if there is a Site Asset
                    Site_Asset_BOM_Join__c siteAssetBOMJoin = new Site_Asset_BOM_Join__c();
                    siteAssetBOMJoin.On_Order__c = 0; // set to  0 initially
                    siteAssetBOMJoin.Site_Asset__c = savEpj.Site_Asset__c; //lookupSiteAssetEstProdJoinByEstProd.get(bom.Estimate_Product_Id__c).Site_Asset__c; 
                    siteAssetBOMJoin.Project_BOM_Item__c = lookupBomItemUsingEstimateProduct.get(savEpj.Estimate_Product__c); // bom.Id; // todo
                    siteAssetBOMJoin.Quantity__c = savEpj.Quantity__c; // pick up qty from Site Asset Estimate Product
                    
                    siteAssetBOMJoins.add(siteAssetBOMJoin);

            }
            System.debug('siteAssetBOMJoins size:'+siteAssetBOMJoins.size());
            System.debug('siteAssetBOMJoins:'+siteAssetBOMJoins);
            if (!siteAssetBOMJoins.isEmpty()) {
                insert siteAssetBOMJoins;
                
            }    

    }

} 

    private static Project_BOM_Item__c createBOMItem(OpportunityLineItem__c oli, Product2 prod, Id prodKitId, Id projectId, Decimal componentQuantity)
    {
        Project_BOM_Item__c pbi = new Project_BOM_Item__c();
        if(componentQuantity != null)
            pbi.Take_Off_Quantity__c = oli.quantity__c * componentQuantity;
        else
            pbi.Take_Off_Quantity__c = oli.quantity__c;  // assume component quantity of one!
        if(prod.Material_Sell__c != null)
            pbi.Cost_Price__c = prod.Material_Cost__c * pbi.Take_Off_Quantity__c;  // cost should be correct, as cannot be adjusted at the opp prod level...
        else
            pbi.Cost_Price__c = 0;
        if(prod.Material_Sell__c != null)
            pbi.Sell_Price__c = prod.Material_Sell__c * pbi.Take_Off_Quantity__c;  // Not relevant?  This is unlikely to match the estimate price as can be adjusted at opp prod kit level, and the margin is applied, etc...
        else
            pbi.Sell_Price__c = 0;
        pbi.Estimate_Product_Id__c  = oli.Id;
        pbi.Milestone_Project__c = projectId;
        pbi.Quantity__c = pbi.Take_Off_Quantity__c;
        pbi.Product__c = prod.Id;
        pbi.Product_Kit__c = prodKitId;
        pbi.Product_Name__c = prod.Name;
        pbi.Approved_checkbox__c = false;
        pbi.Order_Status__c = 'New';   
        pbi.On_Order__c = 0;
        pbi.On_Order_Other__c = 0;
        pbi.On_Order_Site_Assets__c = 0;               

        return pbi;
    }
    
    public class request 
    {
        @InvocableVariable(label='Estimate ID' required=true)
        public Id estimateId;

        @InvocableVariable(label='Project ID' required=true)
        public Id projectId;
    }
}