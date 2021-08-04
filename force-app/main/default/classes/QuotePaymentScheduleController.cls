public with sharing class QuotePaymentScheduleController {

    public class PaymentSchedule {
        @AuraEnabled
        public Decimal total { get; set; }
        @AuraEnabled 
        public List<Estimate_Client_Payment_Schedule__c> items { get; set; }
    }

    @AuraEnabled
    public static PaymentSchedule getItems(Id recordId)
    {
        List<Estimate_Client_Payment_Schedule__c> items = [SELECT Trigger__c, Payment__c FROM Estimate_Client_Payment_Schedule__c WHERE Estimate__c = :recordId ORDER BY CreatedDate ASC];        
        PaymentSchedule schedule = new PaymentSchedule();
        schedule.items = items;
        Opportunity opp = [SELECT Subtotal_Construction_Custom__c FROM Opportunity WHERE Id = :recordId];
        schedule.total = opp.Subtotal_Construction_Custom__c;
        return schedule;
    }

    @AuraEnabled
    public static PaymentSchedule saveItems(String recordId, List<Estimate_Client_Payment_Schedule__c> items, List<Id> idsToDelete)
    {
        List<Estimate_Client_Payment_Schedule__c> itemsToInsert = new List<Estimate_Client_Payment_Schedule__c>();
        List<Estimate_Client_Payment_Schedule__c> itemsToUpdate = new List<Estimate_Client_Payment_Schedule__c>();        
        List<Estimate_Client_Payment_Schedule__c> itemsToDelete = new List<Estimate_Client_Payment_Schedule__c>();

        for (Estimate_Client_Payment_Schedule__c item : items)
        {
            String id = (String) item.Id;
            if (id instanceof Id)
            {                
                itemsToUpdate.add(item);
            }
            else
            {
                item.Id = null;
                item.Estimate__c = recordId;                
                itemsToInsert.add(item);                
            }
        }
        for (String id : idsToDelete)
        {
            if (id instanceof Id)
            {
                Estimate_Client_Payment_Schedule__c item = new Estimate_Client_Payment_Schedule__c(Id = id);
                itemsToDelete.add(item);
            }
        }            

        insert itemsToInsert;
        update itemsToUpdate;        
        delete itemsToDelete;

        return getItems(recordId);
    }   

    
}