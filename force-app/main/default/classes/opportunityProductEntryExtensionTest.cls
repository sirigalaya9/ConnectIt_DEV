@isTest(SeeAllData=true)
public class opportunityProductEntryExtensionTest 
{
    @isTest static void testMethod1()
    {
        Test.StartTest();
        
        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Contestable');
        insert prod;
        Product2 prod2 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Charger', Adopter__c = 'SSE', work_zone__c = 'Offsite');
        insert prod2;
        Product2 prod3 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Engenie', Implementor__c = 'Subcontractor', Labour_Cost__c = 25 );
        insert prod3;
        Product2 prod4 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Street Lighting', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,                                     Adopter__c = 'SSE', work_zone__c = 'Offsite');
        insert prod4;
        Product2 prod5 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Gas', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
                                     Adopter__c = 'SGN', work_zone__c = 'Offsite');
        insert prod5;
        Product2 prod6 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Electric', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
                                     Adopter__c = 'SSE', work_zone__c = 'Offsite');
        insert prod6;
     //   Product2 prod7 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Water', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
     //                                Adopter__c = 'Bristol Water', work_zone__c = 'Offsite');
     //   insert prod7;
        
        // ensure there are no existing pricebookEntries (there is a process in production that adds default entries!)
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE (Product2Id = :prod.Id OR Product2Id = :prod2.Id OR Product2Id = :prod3.Id 
                                     OR Product2Id = :prod4.Id OR Product2Id = :prod5.Id OR Product2Id = :prod6.Id ) AND Pricebook2Id = :pricebookId];
        if(!pbes.isEmpty())
            delete pbes;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true );
        insert pbEntry;
        
        //Create your pricebook entry
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry2;
        
        //Create your pricebook entry
        PricebookEntry pbEntry3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id, UnitPrice = 100.00, IsActive = false);
        insert pbEntry3;
       
        //Create your pricebook entry
        PricebookEntry pbEntry4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod4.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry4;
        
        //Create your pricebook entry
        PricebookEntry pbEntry5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod5.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry5;

        //Create your pricebook entry
        PricebookEntry pbEntry6 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod6.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry6;
       
        //Create your pricebook entry
    //    PricebookEntry pbEntry7 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod7.Id, UnitPrice = 100.00, IsActive = true);
    //    insert pbEntry7;
       
        Opportunity opp=new Opportunity();
        opp.Name = 'test Opp';
        opp.Type = 'CR';
        opp.LeadSource = 'Email';
        opp.CloseDate = system.today();
        opp.StageName = 'Discovery';
        opp.charger_point_Provider__c = 'Instavolt';
        //opp.Water_Provider__c = 'Bristol Water';
        opp.pricebook2id = pricebookid;
        insert opp;
         
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            Material_Cost__c = 200,
            Material_sell__c = 100,
            TotalPrice = 10000
            );
        insert oli;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli5 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            Material_Cost__c = 200,
            Material_sell__c = 100,
            TotalPrice = 10000
            );
        insert oli5;

        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry2.Id,
            Labour_Cost__c = 100,
            TotalPrice = 10000
        );
        oli2.ServiceDate = system.today();
        insert oli2;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli3 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry2.Id,
            Plant_Cost__c = 100,
            TotalPrice = 10000
        );
        insert oli3;
        
        
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ChargerRecordType = SiteSchemeTypeInfo.get('Charger').getRecordTypeId();
        Id StreetLightingRecordType = SiteSchemeTypeInfo.get('StreetLighting').getRecordTypeId();
        Id GasRecordType = SiteSchemeTypeInfo.get('Gas').getRecordTypeId();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        Id WaterRecordType = SiteSchemeTypeInfo.get('Water').getRecordTypeId();
        
        //create siteschemes
        // Charger
         site_scheme__c ssch = new site_scheme__c(
         Estimate__c = opp.Id,
         Charger_Provider__c = 'Engenie',
         DNO__c = 'SSE',
         IDNO__c = 'ESP',
         RecordTypeId = ChargerRecordType
         );
         insert ssch;


         // Street Light
         site_scheme__c ssch2 = new site_scheme__c(
         Estimate__c = opp.Id,
         DNO__c = 'SSE',
         IDNO__c = 'ESP',
         RecordTypeId = StreetLightingRecordType
         );
         insert ssch2;
                   
         // Gas
         site_scheme__c ssch3 = new site_scheme__c(
         Estimate__c = opp.Id,
         GT__c = 'SGN',
         RecordTypeId = GasRecordType
         );
         insert ssch3;
        
        // Water
         site_scheme__c ssch4 = new site_scheme__c(
         Estimate__c = opp.Id,
         Water_Provider__c = 'Affinity Water',
         RecordTypeId = WaterRecordType
         );
         insert ssch4;
         
         // Electric
         site_scheme__c ssch5 = new site_scheme__c(
         Estimate__c = opp.Id,
         DNO__c = 'SSE',
         RecordTypeId = ElectricRecordType
         );
         insert ssch5;
        

        ApexPages.StandardController sc = new ApexPages.StandardController(Opp);
        opportunityProductEntryExtension oppobject = new opportunityProductEntryExtension(sc);
        
        PageReference pageRef = Page.OpportunityProductentry;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        oppobject.searchString='WFO Apps Tech Lead';
        oppobject.toSelect=oli.id;
        oppobject.Total=0;
        oppobject.overLimit=FALSE;
        oppobject.addToShoppingCart();
        oppobject.Beginning();
        oppobject.getDisablePrevious();
        oppobject.sortDir='ASC';
        oppobject.displayEditMode();
        oppobject.hideCostsMode();
        oppobject.showCostsMode();
        oppobject.sortDir='DESC'; 
        oppobject.Next();
        oppobject.Previous();
        oppobject.End();
        oppobject.getChosenCurrency();
        oppobject.getDisableNext();
        oppobject.getPageNumber();
        oppobject.getSortDirection();
        oppobject.getTotal_size();
        oppobject.getTotalPages();
        oppobject.onCancel();
        oppobject.onSave();
        oppobject.selectedRowId = '0';
        oppobject.deleteRow();
        oppobject.toggleSort();
        oppobject.updateAvailableList();
        oppobject.ViewData();
        oppobject.changePricebook();
        oppobject.priceBookCheck();
        oppobject.addElectric();
        oppobject.addGas();
        oppobject.addWater();
        oppobject.addStreetLighting();
        oppobject.addChargePoints();
        oppobject.addThirdPartyCosts();
        oppobject.addCivils();
        oppobject.updateToMaterialSellValue();
        oppobject.updateToMaterialCostValue();
        oppobject.updateToPlantSellValue();
        oppobject.updateToPlantCostValue();
        oppobject.updateToLabourSellValue();
        oppobject.updateToLabourCostValue();
        oppobject.updateCostValue();
        oppobject.viewData();
        oppobject.priceBookCheck();
        test.stopTest();       
    }
}