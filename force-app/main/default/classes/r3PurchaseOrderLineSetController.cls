public without sharing class r3PurchaseOrderLineSetController 
{
    private ApexPages.StandardSetController standardController;
    private List<Purchase_Order_Line__c> stockPOLs;
    private List<Purchase_Order_Line__c> selectedPOLs;
    private Map<Id, Purchase_Order_Line__c> selectedPOLsMap;

    public r3PurchaseOrderLineSetController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference getItemsWithFreeStock()
    {       
        system.debug('R3>>> r3PurchaseOrderLineSetController.getItemsWithFreeStock');
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        selectedPOLs = (List<Purchase_Order_Line__c>) standardController.getSelected();
        try
        {
            // Get product set for allocation
            Set<Id> productIds = new Set<Id>();
            Set<Id> selectedPOLIds = new Set<Id>();
            for(Purchase_Order_Line__c pol : selectedPOLs)
            {
                selectedPOLIds.add(pol.Id);
                productIds.add(pol.Product__c);
            }
            
            // get available stock for products
            stockPOLs = [SELECT Id, 
                                Product__c, 
                                Product__r.name, 
                                Free_Stock__c, 
                                Master_Purchase_Order_Line__c,
                                Stock_Delivery_Location__c
                        FROM Purchase_Order_Line__c
                        WHERE Product__c IN :productIds
                        AND Free_Stock__c > 0
                        AND Master_Purchase_Order_Line__c = null
                        ORDER BY Product__r.name ASC, CreatedDate ASC];   // order by product, then created date
            selectedPOLsMap = new Map<Id, Purchase_Order_Line__c>([SELECT Id, Order_Request__c, Status__c, Product__c, Project_BOM_Item__c, Required_Delivery_Date__c FROM Purchase_Order_Line__c WHERE Id IN :selectedPOLIds]);
                    
            system.debug('R3>>> r3PurchaseOrderLineSetController:getItemsWithFreeStock:count = '+stockPOLs.size());
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            System.debug('R3>>> r3PurchaseOrderLineSetController.getItemsWithFreeStock: The following exception has occurred: ' + e.getMessage());
            System.debug('R3>>> r3PurchaseOrderLineSetController: StackTrace: '+ e.getStackTraceString() ); 
            return null;
        }

        return null;        
    }

    public PageReference allocateStock()
    { 
        system.debug('R3>>> r3PurchaseOrderLineSetController.allocateStock');

        List<Purchase_Order_Line__c>   polsToInsert = new List<Purchase_Order_Line__c>();          
        Map<Id,Purchase_Order_Line__c> polsToUpdate = new Map<Id,Purchase_Order_Line__c>();
        try
        { 
            // process the selected POLs
            for(Purchase_Order_Line__c pol : selectedPOLs)
            {
                // work through the stock items...
                for(Purchase_Order_Line__c stockPOL: stockPOLs)
                {
                    // correct product?
                    if(pol.Product__c == stockPOL.Product__c)
                    {
                        system.debug('R3>>> r3PurchaseOrderLineSetController:processing stock product:'+stockPOL.product__r.Name);

                        // found the correct product...
                        if(pol.Quantity__c <= stockPOL.Free_Stock__c)
                        {
                            system.debug('R3>>> r3PurchaseOrderLineSetController:allocate from free stock:'+stockPOL.product__r.Name+' ('+stockPOL.Free_Stock__c+')');
                            // enough free stock in this stock POL, so allocate this to pol...
                            pol.Master_Purchase_Order_Line__c = stockPOL.id;
                            pol.Quantity_Delivered__c = pol.Quantity__c;
                            pol.Stock_Delivery_Location__c = stockPOL.Stock_Delivery_Location__c;
                            polsToUpdate.put(pol.id,pol);
                        }
                        else
                        {
                            system.debug('R3>>> r3PurchaseOrderLineSetController:partial allocation from free stock:'+stockPOL.product__r.Name+' ('+stockPOL.Free_Stock__c+')');
                            // Need to clone and allocate partial stock, then adjust quantity remaining...
                            Purchase_Order_Line__c newPOL = new Purchase_Order_Line__c();
                            
                            // allocate remaining stock to newly cloned POL...
                            newPOL.Master_Purchase_Order_Line__c = stockPOL.id;
                            newPOL.Quantity__c = stockPOL.Free_Stock__c;
                            newPOL.Quantity_Delivered__c = stockPOL.Free_Stock__c;
                            newPOL.Stock_Delivery_Location__c = stockPOL.Stock_Delivery_Location__c;
                            
                            // copy over key fields...
                            newPOL.Milestone_Project__c = pol.Milestone_Project__c;
                            newPOL.Order_Request__c = selectedPOLsMap.get(pol.Id).Order_Request__c;
                            newPOL.POL_Status__c = selectedPOLsMap.get(pol.Id).Status__c;
                            newPOL.Product__c = selectedPOLsMap.get(pol.Id).Product__c;
                            newPOL.Project_BOM_Item__c = selectedPOLsMap.get(pol.Id).Project_BOM_Item__c;
                            newPOL.Required_Delivery_Date__c = selectedPOLsMap.get(pol.Id).Required_Delivery_Date__c;
                            polsToInsert.add(newPOL);
                            
                            // update pol for remaining quantity
                            pol.Quantity__c = pol.Quantity__c - newPOL.Quantity__c;
                            polsToUpdate.put(pol.id,pol);
                        }
                    }
                }
            }
 

            // insert new pols
            system.debug('R3>>> r3PurchaseOrderLineSetController:polsToInsert.size() = '+polsToInsert.size());
            if(!polsToInsert.isEmpty())
                insert polsToInsert;
        
            // update existing...
            system.debug('R3>>> r3PurchaseOrderLineSetController:polsToUpdate.size() = '+polsToUpdate.size());
            if(!polsToUpdate.isEmpty())
              update polsToUpdate.values();

        	//return standardController.save(); 
    	}
    	catch(DmlException ex)
        {
            System.debug('R3>>> r3PurchaseOrderLineSetController.allocateStock: The following DmlException has occurred: ' + ex.getMessage());
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            return null;
    	}
    	catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            System.debug('R3>>> r3PurchaseOrderLineSetController.allocateStock: The following exception has occurred: ' + e.getMessage());
            System.debug('R3>>> r3PurchaseOrderLineSetController: StackTrace: '+ e.getStackTraceString() );
            return null;
    	}
        
        return standardController.cancel();
    }

    
    public PageReference cancel()
    {   
        system.debug('R3>>> r3PurchaseOrderLineSetController.cancel');
        return standardController.cancel();
    }
}