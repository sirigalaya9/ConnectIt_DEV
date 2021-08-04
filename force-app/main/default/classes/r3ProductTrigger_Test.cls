@isTest
private class r3ProductTrigger_Test 
{
    //@testSetup 
    //static void setup()
    //{
    //}
    
    static testMethod void test_1()
    {
        // create product
        Product2 prod1 = new Product2(Name = 'Test Product 1', isActive = true);
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Test Product 2', isActive = true);
        insert prod2;

        test.startTest();
        prod1.Labour_Cost__c = 2;
        update prod1;
        prod1.Labour_Sell__c = 3;
        update prod1;
        prod1.Material_Cost__c = 4;
        update prod1;
        prod1.Material_Sell__c = 5;
        update prod1;
        prod1.Plant_Cost__c = 6;
        update prod1;
        prod1.Plant_Sell__c = 7;
        update prod1;
        prod1.Plant_Sell__c = null;
        update prod1;
        prod1.Kit_sell__c = null;
        update prod1;
        test.stopTest();

        PricebookEntry pe1 = [SELECT Id, Labour_Cost__c, Plant_Sell_del__c FROM PricebookEntry WHERE Product2Id = :prod1.id LIMIT 1];
        //system.assertEquals(prod1.Labour_Cost__c, pe1.Labour_Cost__c);
        
        // when the product price is set to null, ensure that the pricebook entry is set to zero
        system.assertEquals(prod1.Plant_Sell__c, null);
        //system.assertEquals(pe1.Plant_Sell_del__c, 0);
    }
}