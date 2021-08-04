/**
 * @description       :
 * @author            : Jonny Harte
 * @group             :
 * @last modified on  : 01-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   01-02-2021   Jonny Harte   Initial Version
 **/
@isTest
public class r3ProductKitProcessor_Test {
  @testSetup
  static void setup() {
    List<Product2> products = new List<Product2>();
    List<Product_Kit__c> productKits = new List<Product_Kit__c>();

    // insert 200 products
    for (Integer i = 0; i < 200; i++) {
      // Values need to be greater than 0 to pass as truthy.
      Integer count = i + 1;

      products.add(
        new Product2(
          Name = 'Product ' + count,
          Delivery_Cost__c = count,
          Labour_Cost__c = count,
          Labour_Sell__c = count,
          Material_Cost__c = count,
          Material_Sell__c = count,
          Plant_Cost__c = count,
          Plant_Sell__c = count
        )
      );
    }

    insert products;

    for (Integer i = 0; i < 200; i++) {
      Product_Kit__c productKit = new Product_Kit__c(
        Salesforce_Product__c = products[i].ID
      );

      // if even number set kit values the same as product values.
      if (math.mod(i, 2) == 0) {
        Double quantity = 2.0;

        productKit.put('Quantity__c', quantity);
        productKit.put(
          'Delivery_Cost__c',
          products[i].Delivery_Cost__c * quantity
        );
        productKit.put('Labour_Cost__c', products[i].Labour_Cost__c * quantity);
        productKit.put('Labour_Sell__c', products[i].Labour_Sell__c * quantity);
        productKit.put(
          'Material_Cost__c',
          products[i].Material_Cost__c * quantity
        );
        productKit.put(
          'Material_Sell__c',
          products[i].Material_Sell__c * quantity
        );
        productKit.put('Plant_Cost__c', products[i].Plant_Cost__c * quantity);
        productKit.put('Plant_Sell__c', products[i].Plant_Sell__c * quantity);
      }

      system.debug('TEST PRODUCT ' + i + ': ' + products[i]);
      system.debug('TEST KIT ' + i + ': ' + productKit);

      productKits.add(productKit);
    }

    insert productKits;
  }

  static testMethod void r3ProductKitProcessorCountTest() {
    Test.startTest();
    r3ProductKitProcessor productKitProcessor = new r3ProductKitProcessor();
    Id batchId = Database.executeBatch(productKitProcessor);
    Test.stopTest();

    System.assertEquals(
      200,
      [SELECT COUNT() FROM Product_Kit__c WHERE Has_Updated_Prices__c = TRUE],
      'Not all ProductKits have Updated Prices'
    );

    System.assertEquals(
      200,
      [SELECT COUNT() FROM Product_Kit__c],
      'Total amount of ProductKits doesn\'t match test records inserted'
    );
  }
}