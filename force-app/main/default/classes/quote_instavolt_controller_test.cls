@isTest
public class quote_instavolt_controller_test 
{
    static testMethod void test()
    {
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        Account acc = new Account(Name = 'test', recordTypeId = AccountRecordTypeInfo.get('Standard').getRecordTypeId(), Type = 'Customer');
        insert acc;        

        Account site = new Account(Name = 'Site Test', recordTypeId = AccountRecordTypeInfo.get('Site').getRecordTypeId(), Customer_Account__c = acc.id);
        insert site;        
        
        Opportunity op = new Opportunity(Name = 'test', StageName = 'Enquiry', CloseDate = Date.today(), AccountId = acc.id, Site__c = site.id);
        insert op;
        
        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod.Work_Type__c = 'Site Setup - Including Permits';
      insert prod;
        Product2 prod2 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'Travel and Accommodation Costs';
      insert prod2;
              Product2 prod3 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'Feeder Pillar - Internal Installation (FORECOURT ONLY SITE)';
      insert prod3;
              Product2 prod4 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'DNO - ICP Works Only';
      insert prod4;
              Product2 prod5 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'Civil Costs for Charger Build';
      insert prod5;
              Product2 prod6 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'Civil Costs for Bases';
      insert prod6;
              Product2 prod7 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'DNO Civil Works';
      insert prod7;
              Product2 prod8 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'EV Rapid Charger Unit';
      insert prod8;
              Product2 prod9 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'On-Site DNO Civils Works';
      insert prod9;
               Product2 prod10 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Instavolt');
        prod2.Work_Type__c = 'Designated Parking Bays - Road Markings';
      insert prod10;
      
      
      
      
      
        
    // ensure there are no existing pricebookEntries (there is a process in production that adds default entries!)
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE (Product2Id = :prod.Id OR Product2Id = :prod2.Id) AND Pricebook2Id = :pricebookId];
        if(!pbes.isEmpty())
            delete pbes;
        
        //Create your pricebook entry
    PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
    insert pbEntry;
        
        //Create your pricebook entry
    PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 100.00, IsActive = true);
    insert pbEntry2;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 10000
        );
        insert oli;
                
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
            OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 10,
            PricebookEntryId = pbEntry2.Id,
            TotalPrice = 20000
        );
        oli2.ServiceDate = system.today();
    insert oli2;
        
    Test.startTest();
        quote_instavolt_controller qsuc = new quote_instavolt_controller();
        qsuc.setOppId(op.Id);
        qsuc.getOppId();
    Test.stopTest();

    
    
    }
    
}