@isTest
public class WorkInstruction_controller_test 
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

        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Professional Services');
        prod.Work_Type__c = 'Road Class 1/2';
      insert prod;
        Product2 prod2 = new Product2(Name = 'SLA: Bronze', IsActive = true, Family = 'Managed Services');
        prod2.Work_Type__c = 'Footpath';
      insert prod2;
        
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
            Quantity = 5,
            PricebookEntryId = pbEntry2.Id,
            TotalPrice = 10000
        );
        oli2.ServiceDate = system.today();
    insert oli2;
        
    Test.startTest();
        WorkInstruction_controller qsuc = new WorkInstruction_controller();
        qsuc.setOppId(op.Id);
        qsuc.getOppId();
    Test.stopTest();
    }
    
}