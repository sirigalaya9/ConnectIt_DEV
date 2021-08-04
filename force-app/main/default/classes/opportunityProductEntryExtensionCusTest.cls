@isTest(SeeAllData=true)
public class opportunityProductEntryExtensionCusTest 
{
    @isTest static void testMethod1()
    {   
   //    Id pricebookId = Test.getStandardPricebookId();

        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Contestable');
        prodList.add(prod);
        Product2 prod2 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Charger', Adopter__c = 'SSE', work_zone__c = 'Offsite');
        prodList.add(prod2);
        Product2 prod3 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Engenie', Implementor__c = 'Subcontractor', Labour_Cost__c = 25 );
        prodList.add(prod3);
        Product2 prod4 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Street Lighting', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,  Adopter__c = 'SSE', work_zone__c = 'Offsite');
        prodList.add(prod4);
        Product2 prod5 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Gas', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
                                     Adopter__c = 'SGN', work_zone__c = 'Offsite');
        prodList.add(prod5);
        Product2 prod6 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Electric', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true,
                                     Adopter__c = 'SSE', work_zone__c = 'Offsite');
        prodList.add(prod6);
        Product2 prod7 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'SSEN Connections', Implementor__c = 'Subcontractor', Labour_Cost__c = 25, Core_Product__c = true);
        prodList.add(prod7);
        
        insert prodList;
        
       
        Opportunity opp=new Opportunity();
        opp.Name = 'test Opp';
        opp.Type = 'CR';
        opp.LeadSource = 'Email';
        opp.CloseDate = system.today();
        opp.StageName = 'Discovery';
        opp.charger_point_Provider__c = 'Instavolt';
        opp.Utilities__c = 'Electric';
        opp.Utilities__c = 'Water';
        opp.Utilities__c = 'Gas';
        opp.Type = 'Multi Utility Tender';
        insert opp;
         
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
        OpportunityLineItem__c oli = new OpportunityLineItem__c(
            Product2Id__c = prod.id,
            OpportunityId__c = opp.Id,
            Quantity__c = 5,
            Material_Cost__c = 200
            );
       oppLineItemList.add(oli);
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem__c oli5 = new OpportunityLineItem__c(
            Product2Id__c = prod.id,
            OpportunityId__c = opp.Id,
            Quantity__c = 5,
            Material_Cost__c = 200
             );
        oppLineItemList.add(oli5);

        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem__c oli2 = new OpportunityLineItem__C(
            Product2Id__c = prod2.id,
            OpportunityId__C = opp.Id,
            Quantity__c = 5,
            Labour_Cost__c = 100
        );
        oli2.ServiceDate__c = system.today();
        oppLineItemList.add(oli2);
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem__c oli3 = new OpportunityLineItem__c(
            Product2Id__c = prod2.id,
            OpportunityId__c = opp.Id,
            Quantity__c = 5,
            Plant_Cost__c = 100
        );
        oppLineItemList.add(oli3);
        
        insert oppLineItemList;
        
        
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
         RecordTypeId = ElectricRecordType
         );
        sschList.add(ssch5);
        insert sschList;

        test.startTest();    
        ApexPages.StandardController sc = new ApexPages.StandardController(Opp);
        opportunityProductEntryCusExtension oppobject = new opportunityProductEntryCusExtension(sc);
        
        PageReference pageRef = Page.Opportunity_Product_Entry_custom;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        oppobject.searchString='WFO Apps Tech Lead';
        oppobject.toSelect=oli.Product2Id__c;
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
      //  oppobject.getChosenCurrency();
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
        // oppobject.changePricebook();
       // oppobject.priceBookCheck();
        oppobject.addElectric();
        oppobject.addGas();
        oppobject.addWater();
        oppobject.addStreetLighting();
        oppobject.addChargePoints();
        oppobject.addSSENConnections();
        oppobject.addSSENMinorWorks();
        oppobject.addSSENServiceAlterations();
        oppobject.addThirdPartyCosts();
        oppobject.addCivils();
        oppobject.updateToMaterialSellValue();
   //LDS to check     oppobject.updateToMaterialCostValue();
        oppobject.updateToPlantSellValue();
     //LDS to check     oppobject.updateToPlantCostValue();
        oppobject.updateToLabourSellValue();
        oppobject.updateToLabourCostValue();
       //LDS to check   oppobject.updateCostValue();
        oppobject.viewData();
       // oppobject.priceBookCheck();
        test.stopTest();       
    }
}