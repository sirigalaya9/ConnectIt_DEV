/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Supplier_ProductTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Supplier_ProductTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Supplier_Product__c());
    }
}