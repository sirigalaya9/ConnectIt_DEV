@isTest
public class quote_engenie_controller_test 
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

         Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Engenie',  Work_Type__c = 'DNO - ICP Works Only');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Engenie',  Work_Type__c = 'Charger Installation Costs');
        insert prod2;
        
        Product2 prod3 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Engenie',  Work_Type__c = 'DNO - ICP Works Only');
        insert prod3;
        
        
        // ensure there are no existing pricebookEntries (there is a process in production that adds default entries!)
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE (Product2Id = :prod.Id  OR Product2Id = :prod2.Id OR Product2Id = :prod3.Id) AND Pricebook2Id = :pricebookId]; 
        
        if(!pbes.isEmpty())
            delete pbes;

            
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry;
        
        //Create your pricebook entry
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry2;
        
        //Create your pricebook entry
        PricebookEntry pbEntry3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntry3;
        
        //Create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = op.Id, Quantity__c = 5, Quantity = 5,  PricebookEntryId = pbEntry.Id, TotalPrice = 10000); 
        insert oli;
        
        //Create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = op.Id, Quantity__c = 5, Quantity = 5, PricebookEntryId = pbEntry2.Id, TotalPrice = 10000); 
        insert oli2;
        
        //Create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = op.Id, Quantity__c = 5, Quantity = 5, PricebookEntryId = pbEntry3.Id, TotalPrice = 10000); 
        insert oli3;
        
       Test.startTest();
        quote_engenie_controller qsuc = new quote_engenie_controller();
        qsuc.setOppId(op.Id);
        qsuc.getOppId();
       Test.stopTest();
    }
    
}