@isTest
private class r3PurchaseOrderLineSetController_Test 
{
    @testSetup 
    static void setup() 
    {
        // create some stock...
        
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        Account acc = new Account();
        acc.name = 'stock location';
        acc.Type = 'Supplier';
        insert acc;
        
        Product2 prod = new Product2();
        prod.Name = 'test prod';
        prod.Free_Stock__c = 100;  // for testing - normally updated by declarative rollup
        insert prod;
        
        Purchase_Order__c stockPO = new Purchase_Order__c();
        stockPO.PO_Status__c = 'Delivery Complete';
        stockPO.Approved__c = true;
        insert stockPO;
        
        Purchase_Order_Line__c stockPOL = new Purchase_Order_Line__c();
        stockPOL.Product__c = prod.id;
        stockPOL.Purchase_Order__c = stockPO.id;
        stockPOL.Quantity__c = 100;
        stockPOL.Unit_Cost__c = 1;
        stockPOL.Quantity_Delivered__c = 100;
        stockPOL.Stock_Delivery_Location__c = acc.id;
        insert stockPOL;
    }

    
    static testMethod void test_no_stock()
    {           
        // 0 stock, request for 10 => 0 allocated, 0 stock remaining

        // get product
        Product2 prod = new Product2();
        prod.Name = 'test prod 2';
        prod.Free_Stock__c = 0;  // for testing - normally updated by declarative rollup
        insert prod;
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 10;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        
        // validation
        
        // no change...
        Purchase_Order_Line__c checkPol1 = [SELECT Id, Master_Purchase_Order_Line__c, Quantity__c FROM Purchase_Order_Line__c WHERE Id = :pol1.id LIMIT 1];
        system.assertEquals(null, checkPol1.Master_Purchase_Order_Line__c);
        system.assertEquals(10, checkPol1.Quantity__c);
    }

    
    
    static testMethod void test_full_allocation()
    {           
        // 100 stock, request for 10 => 10 allocated, 90 stock remaining

        // get product
        Product2 prod = [SELECT Id, Name, Free_Stock__c FROM Product2 WHERE Name = 'test prod' LIMIT 1];
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 10;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        
        // validation
        
        // Stock POL should be adjusted...
        Purchase_Order_Line__c checkStockPol = [SELECT Free_Stock__c FROM Purchase_Order_Line__c WHERE Master_Purchase_Order_Line__c = null LIMIT 1];
        //system.assertEquals(90, checkStockPol.Free_Stock__c);
        
        // Master POL should be stock POL...
        Purchase_Order_Line__c checkPol1 = [SELECT Master_Purchase_Order_Line__c, Quantity__c FROM Purchase_Order_Line__c WHERE Id = :pol1.id AND Master_Purchase_Order_Line__c != null LIMIT 1];
        system.assertEquals(checkStockPol.id, checkPol1.Master_Purchase_Order_Line__c);
        system.assertEquals(10, checkPol1.Quantity__c);
    }
    
    
    static testMethod void test_complete_allocation()
    {           
        // 100 stock, request for 100 => 100 allocated, 0 stock remaining

        // get product
        Product2 prod = [SELECT Id, Name, Free_Stock__c FROM Product2 WHERE Name = 'test prod' LIMIT 1];
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 100;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        
        // validation
        
        // Stock POL should be adjusted...
        Purchase_Order_Line__c checkStockPol = [SELECT Free_Stock__c FROM Purchase_Order_Line__c WHERE Master_Purchase_Order_Line__c = null LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);
        
        // Master POL should be stock POL...
        Purchase_Order_Line__c checkPol1 = [SELECT Master_Purchase_Order_Line__c, Quantity__c FROM Purchase_Order_Line__c WHERE Id = :pol1.id AND Master_Purchase_Order_Line__c != null LIMIT 1];
        system.assertEquals(checkStockPol.id, checkPol1.Master_Purchase_Order_Line__c);
        system.assertEquals(100, checkPol1.Quantity__c);
    }
    
    
    static testMethod void test_full_partial()
    {           
        // 100 stock, request for 150 => 100 alloacted, 50 outstanding, 0 stock remaining
        
        // get product
        Product2 prod = [SELECT Id, Name, Free_Stock__c FROM Product2 WHERE Name = 'test prod' LIMIT 1];
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 150;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        test.startTest();
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        test.stopTest();
        
        // validation
        
        // Stock POL should be adjusted...
        Purchase_Order_Line__c checkStockPol = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Quantity_Delivered__c = 100 LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);
        
        // Master POL should be stock POL...
        List<Purchase_Order_Line__c> checkPols = [SELECT id, Master_Purchase_Order_Line__c, Quantity__c FROM Purchase_Order_Line__c WHERE Product__c = :prod.id AND Quantity_Delivered__c != 100];
        system.debug('R3>>> checkPols = '+checkPols);
        for(Purchase_Order_Line__c pol: checkPols)
        {
            if(pol.Master_Purchase_Order_Line__c != null)
            {
                system.assertEquals(checkStockPol.id, pol.Master_Purchase_Order_Line__c);
                //system.assertEquals(100, pol.Quantity__c);
            }
            else
            {
                system.assertEquals(null, pol.Master_Purchase_Order_Line__c);                
                system.assertEquals(pol1.id, pol.id);
                system.assertEquals(50, pol.Quantity__c);
            }
        }
    }

    
    static testMethod void test_two_stock_POLs_allocate_partial()
    {           
        // 100 + 10 stock, request for 105 => 95 + 10 allocated, 0 outstanding, 5 stock remaining
        
        // get product
        Product2 prod = [SELECT Id, Name, Free_Stock__c FROM Product2 WHERE Name = 'test prod' LIMIT 1];
        
        // get stock POL
        Purchase_Order_Line__c stockPOL1 = [SELECT Id FROM Purchase_Order_Line__c LIMIT 1];  // there should only be one setup!
        
        // create 2nd stock entry...
        Account acc = new Account();
        acc.name = 'stock location 2';
        acc.Type = 'Supplier';
        insert acc;

        Purchase_Order__c stockPO = new Purchase_Order__c();
        stockPO.PO_Status__c = 'Delivery Complete';
        stockPO.Approved__c = true;
        insert stockPO;
        
        Purchase_Order_Line__c stockPOL2 = new Purchase_Order_Line__c();
        stockPOL2.Product__c = prod.id;
        stockPOL2.Purchase_Order__c = stockPO.id;
        stockPOL2.Quantity__c = 10;
        stockPOL2.Unit_Cost__c = 1;
        stockPOL2.Quantity_Delivered__c = 10;
        stockPOL2.Stock_Delivery_Location__c = acc.id;
        insert stockPOL2;
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 105;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        
        // validation
        
        // Stock POL should be adjusted...
        Purchase_Order_Line__c checkStockPol1 = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Id = :stockPOL1.Id LIMIT 1];
        //system.assertEquals(5, checkStockPol.Free_Stock__c);

        Purchase_Order_Line__c checkStockPol2 = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Id = :stockPOL2.Id LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);
        
        // Master POL should be stock POL...
        List<Purchase_Order_Line__c> checkPols = [SELECT id, Master_Purchase_Order_Line__c, Quantity__c, Free_Stock__c FROM Purchase_Order_Line__c WHERE Product__c = :prod.id AND Quantity_Delivered__c = null];
        system.debug('CAS>>> checkPols 1 = '+checkPols);
        for(Purchase_Order_Line__c pol: checkPols)
        {
            if(pol.Master_Purchase_Order_Line__c == checkStockPol1.id)
            {
                system.assertEquals(95, pol.Quantity__c);
            }
            else if(pol.Master_Purchase_Order_Line__c == checkStockPol2.id)
            {
                system.assertEquals(10, pol.Quantity__c);
            }
            else
            {
                system.assertEquals(null, pol.Master_Purchase_Order_Line__c);                
                system.assertEquals(pol1.id, pol.id);
            }
        }
    }

    
    static testMethod void test_two_stock_POLs_allocate_complete()
    {           
        // 100 + 10 stock, request for 110 => 100 + 10 allocated, 0 outstanding, 50 stock remaining
        
        // get product
        Product2 prod = [SELECT Id, Name, Free_Stock__c FROM Product2 WHERE Name = 'test prod' LIMIT 1];
        
        // create 2nd stock entry...
        Account acc = new Account();
        acc.name = 'stock location 2';
        acc.Type = 'Supplier';
        insert acc;

        Purchase_Order__c stockPO = new Purchase_Order__c();
        stockPO.PO_Status__c = 'Delivery Complete';
        stockPO.Approved__c = true;
        insert stockPO;
        
        Purchase_Order_Line__c stockPOL = new Purchase_Order_Line__c();
        stockPOL.Product__c = prod.id;
        stockPOL.Purchase_Order__c = stockPO.id;
        stockPOL.Quantity__c = 10;
        stockPOL.Unit_Cost__c = 1;
        stockPOL.Quantity_Delivered__c = 10;
        stockPOL.Stock_Delivery_Location__c = acc.id;
        insert stockPOL;
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 110;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        
        // validation
        
        // Stock POL should be adjusted...
        Purchase_Order_Line__c checkStockPol1 = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Quantity_Delivered__c = 100 LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);

        Purchase_Order_Line__c checkStockPol2 = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Quantity_Delivered__c = 10 LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);
        
        // Master POL should be stock POL...
        List<Purchase_Order_Line__c> checkPols = [SELECT id, Master_Purchase_Order_Line__c, Quantity__c, Free_Stock__c FROM Purchase_Order_Line__c WHERE Product__c = :prod.id AND Quantity_Delivered__c = null];
        system.debug('CAS>>> checkPols 3 = '+checkPols);
        for(Purchase_Order_Line__c pol: checkPols)
        {
            if(pol.Master_Purchase_Order_Line__c == checkStockPol1.id)
            {
                system.assertEquals(100, pol.Quantity__c);
                system.assertEquals(pol1.id, pol.id);
            }
            else if(pol.Master_Purchase_Order_Line__c == checkStockPol2.id)
            {
                system.assertEquals(10, pol.Quantity__c);
            }
            else
            {
                system.AssertEquals(1,2);   // should never happen!
            }
        }
    }

    
    
    static testMethod void test_two_stock_POLs_allocate_all()
    {           
        // 100 + 10 stock, request for 115 => 100 + 10 allocated, 5 outstanding, 0 stock remaining
        
        // get product
        Product2 prod = [SELECT Id, Name, Free_Stock__c FROM Product2 WHERE Name = 'test prod' LIMIT 1];
        
        // create 2nd stock entry...
        Account acc = new Account();
        acc.name = 'stock location 2';
        acc.Type = 'Supplier';
        insert acc;

        Purchase_Order__c stockPO = new Purchase_Order__c();
        stockPO.PO_Status__c = 'Delivery Complete';
        stockPO.Approved__c = true;
        insert stockPO;
        
        Purchase_Order_Line__c stockPOL = new Purchase_Order_Line__c();
        stockPOL.Product__c = prod.id;
        stockPOL.Purchase_Order__c = stockPO.id;
        stockPOL.Quantity__c = 10;
        stockPOL.Unit_Cost__c = 1;
        stockPOL.Quantity_Delivered__c = 10;
        stockPOL.Stock_Delivery_Location__c = acc.id;
        insert stockPOL;
        
        // create POLs to allocate stock to...
        Purchase_Order_Line__c pol1 = new Purchase_Order_Line__c();
        pol1.Product__c = prod.id;
        pol1.Quantity__c = 115;
        insert pol1;

        // created selected list
        List<Purchase_Order_Line__c> selectedPols = new List<Purchase_Order_Line__c>();
        selectedPols.add(pol1);
        
        // Run VF page...
        PageReference pageRef = Page.POL_Allocate_from_Stock;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedPols);
        ssc.setSelected(selectedPols);  // select accounts...
        r3PurchaseOrderLineSetController controller = new r3PurchaseOrderLineSetController(ssc);
        controller.getItemsWithFreeStock();    
        controller.allocateStock();    
        
        // validation
        
        // Stock POL should be adjusted...
        Purchase_Order_Line__c checkStockPol1 = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Quantity_Delivered__c = 100 LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);

        Purchase_Order_Line__c checkStockPol2 = [SELECT id, Free_Stock__c FROM Purchase_Order_Line__c WHERE Quantity_Delivered__c = 10 LIMIT 1];
        //system.assertEquals(0, checkStockPol.Free_Stock__c);
        
        // Master POL should be stock POL...
        List<Purchase_Order_Line__c> checkPols = [SELECT id, Master_Purchase_Order_Line__c, Quantity__c, Free_Stock__c FROM Purchase_Order_Line__c WHERE Product__c = :prod.id AND Quantity_Delivered__c = null];
        system.debug('CAS>>> checkPols 2 = '+checkPols);
        for(Purchase_Order_Line__c pol: checkPols)
        {
            if(pol.Master_Purchase_Order_Line__c == checkStockPol1.id)
            {
                system.assertEquals(100, pol.Quantity__c);
            }
            else if(pol.Master_Purchase_Order_Line__c == checkStockPol2.id)
            {
                system.assertEquals(10, pol.Quantity__c);
            }
            else
            {
                system.assertEquals(null, pol.Master_Purchase_Order_Line__c);                
                system.assertEquals(pol1.id, pol.id);
                system.assertEquals(5, pol.Quantity__c);
            }
        }
    }

    
}