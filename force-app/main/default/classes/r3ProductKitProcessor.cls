/**
* @description       :
* @author            : Jonny Harte
* @group             :
* @last modified on  : 05-02-2021
* @last modified by  : Jonny Harte
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   01-02-2021   Jonny Harte   Initial Version
**/
public class r3ProductKitProcessor implements Database.Batchable<sObject> 
{
    
    // instance member to retain state across transactions
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        system.debug('R3>>> r3ProductKitProcessor START');
        return Database.getQueryLocator(
            [
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
                /*WHERE Has_Updated_Prices__c = FALSE*/ 
            ]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Product_Kit__c> kits) 
    {
        List<Product_Kit__c> updateKits = new List<Product_Kit__c>();
        system.debug('R3>>> r3ProductKitProcessor BATCH START');
        
        // process each batch of records
        for (Product_Kit__c kit : kits) 
        {
            system.debug('R3>>> BEFORE UPDATE: ' + kit);

            Double quantity = kit.Quantity__c;
            if (quantity == null) 
                quantity = 1.0;

            Product_Kit__c updateKit = new Product_Kit__c(Id = kit.Id);            
            updateKit.Delivery_Cost__c = nz(kit.Salesforce_Product__r.Delivery_Cost__c) * quantity;
            updateKit.Labour_Cost__c   = nz(kit.Salesforce_Product__r.Labour_Cost__c) * quantity;
            updateKit.Labour_Sell__c   = nz(kit.Salesforce_Product__r.Labour_Sell__c) * quantity;
            updateKit.Material_Cost__c = nz(kit.Salesforce_Product__r.Material_Cost__c) * quantity;
            updateKit.Material_Sell__c = nz(kit.Salesforce_Product__r.Material_Sell__c) * quantity;
            updateKit.Plant_Cost__c    = nz(kit.Salesforce_Product__r.Plant_Cost__c) * quantity;
            updateKit.Plant_Sell__c    = nz(kit.Salesforce_Product__r.Plant_Sell__c) * quantity;
            updateKit.BORIS_Code_Output__c = kit.Salesforce_Product__r.BORIS_Code_Output__c;
                        
            if(  kit.Delivery_Cost__c     != updateKit.Delivery_Cost__c
              || kit.Labour_Cost__c       != updateKit.Labour_Cost__c
              || kit.Labour_Sell__c       != updateKit.Labour_Sell__c
              || kit.Material_Cost__c     != updateKit.Material_Cost__c
              || kit.Material_Sell__c     != updateKit.Material_Sell__c
              || kit.Plant_Cost__c        != updateKit.Plant_Cost__c
              || kit.Plant_Sell__c        != updateKit.Plant_Sell__c
              || kit.BORIS_Code_Output__c != updateKit.BORIS_Code_Output__c
              )
            {
                // update record
                updateKits.add(updateKit);
            }
            
            system.debug('R3>>> AFTER UPDATE: ' + updateKit);            
        }
        
        update updateKits;
        
        system.debug('R3>>> r3ProductKitProcessor BATCH COMPLETE');
    }
    
    
    private Decimal nz(Decimal value)
    {
        if(value == null)
            return 0;
        return value;
    }
    
    
    public void finish(Database.BatchableContext bc) 
    {
        system.debug('R3>>> r3ProductKitProcessor COMPLETE');
    }
}