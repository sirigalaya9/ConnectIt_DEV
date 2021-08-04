/**
 * @description       :
 * @author            : Jonny Harte
 * @group             :
 * @last modified on  : 17-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   17-02-2021   Jonny Harte   Initial Version
 **/
@isTest
private class BorisCodesTrigger_Test {
  static testMethod void test_insert() {
    // create Boris Codes
    BORIS_Codes__c borisCodes = new BORIS_Codes__c(
      Name = 'Test BorisCode 1',
      Worksheets__c = '14122 : 3 Worksheet - Electric Main Test Results'
    );

    test.startTest();
    insert borisCodes;
    test.stopTest();

    BORIS_Codes__c updateBorisCodes = [
      SELECT Worksheet_Codes__c
      FROM BORIS_Codes__c
      WHERE Id = :borisCodes.Id
    ];
    system.assertEquals('14122', updateBorisCodes.Worksheet_Codes__c);
  }

  static testMethod void test_update() {
    // create Boris Codes
    BORIS_Codes__c borisCodes = new BORIS_Codes__c(
      Name = 'Test BorisCode 1',
      Worksheets__c = '14123 : 3 Worksheet - Valve Installation Details'
    );
    insert borisCodes;

    BORIS_Codes__c updateBorisCodes = [
      SELECT Worksheet_Codes__c
      FROM BORIS_Codes__c
      WHERE Id = :borisCodes.Id
    ];
    system.assertEquals('14123', updateBorisCodes.Worksheet_Codes__c);

    test.startTest();
    borisCodes.Worksheets__c = '14122 : 3 Worksheet - Electric Main Test Results';
    update borisCodes;

    test.stopTest();

    BORIS_Codes__c updateBorisCodes2 = [
      SELECT Worksheet_Codes__c
      FROM BORIS_Codes__c
      WHERE Id = :borisCodes.Id
    ];
    system.assertEquals('14122', updateBorisCodes2.Worksheet_Codes__c);
  }

  static testMethod void test_productUpdate() {
    // create Boris Codes
    BORIS_Codes__c borisCodes = new BORIS_Codes__c(
      Name = 'Test BorisCode 1',
      Worksheets__c = '14123 : 3 Worksheet - Valve Installation Details',
      Labour_Cost__c = 5,
      Labour_Sell__c = 10
    );
    insert borisCodes;

    Product2 product = new Product2(
      Name = 'Test Product',
      BORIS_Codes__c = borisCodes.id,
      IsActive = true,
      Pack_Quantity__c = 1
      //   Labour_Cost_override__c = null,
      //   Labour_Sell_override__c = null
    );

    insert product;

    test.startTest();
    borisCodes.Labour_Cost__c = 10;
    borisCodes.Labour_Sell__c = 20;

    update borisCodes;
    test.stopTest();

    Product2 updatedProduct = [
      SELECT Id, Labour_Cost__c, Labour_Sell__c
      FROM Product2
      WHERE Id = :product.Id
    ];

    system.assertEquals(
      borisCodes.Labour_Cost__c,
      updatedProduct.Labour_Cost__c,
      'Labour cost doesn\'t Match BORIS Code.'
    );

    system.assertEquals(
      borisCodes.Labour_Sell__c,
      updatedProduct.Labour_Sell__c,
      'Labour sell doesn\'t Match BORIS Code.'
    );
  }
}