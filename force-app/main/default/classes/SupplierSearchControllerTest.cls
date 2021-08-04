@isTest
public class SupplierSearchControllerTest {

    @testSetup
    public static void createTestData(){
        Account supplier =  new Account(Name='TheSupplier',Type='Supplier');
        insert supplier;
        Supplier_Product__c supplierProduct = new Supplier_Product__c (Name='SupplierProductName One', Supplier__c=supplier.Id);
        insert supplierProduct;        
    }
    @isTest
    public static void testWrapper(){
        Supplier_Product__c supplierProduct = [SELECT Id, Name, Supplier__c FROM Supplier_Product__c LIMIT 1];
        SupplierProductWrapper wrapper = new SupplierProductWrapper(supplierProduct.Id,'SupplierProductName One', 'TheSupplier');
        System.assertEquals(wrapper.SupplierProductId,supplierProduct.Id);
        System.assertEquals(wrapper.SupplierProductName,'SupplierProductName One');
        System.assertEquals(wrapper.SupplierName, 'TheSupplier');
        System.assertEquals(wrapper.isSelected, false);
    }
    
	@isTest
    public static void testfetchData(){
		
        Test.startTest();
        List <SupplierProductWrapper> recs = SupplierSearchController.fetchData('Supplier One');
        System.assertEquals(1,recs.size());
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateProduct(){
        Product2 product =  new Product2(Name='SalesforceProduct', Family='Gas', Implementor__c = 'Connect It');
        insert product;
		Supplier_Product__c supplierProduct = [SELECT Id, Name, Supplier__c FROM Supplier_Product__c LIMIT 1];
        List <SupplierProductWrapper> recs = SupplierSearchController.fetchData('Supplier');
        recs[0].isSelected =true;
        String json =System.JSON.serialize(recs);
        
        Test.startTest();
        SupplierSearchController.updateSalesforceProduct(product.Id, json);
        System.assertEquals(product.Id,[SELECT Salesforce_Product__c FROM Supplier_Product__c WHERE Id= :supplierProduct.Id].Salesforce_Product__c); 
        Test.stopTest();
    }
}