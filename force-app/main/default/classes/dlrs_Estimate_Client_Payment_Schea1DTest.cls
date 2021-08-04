/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Estimate_Client_Payment_Schea1DTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Estimate_Client_Payment_Sa1DTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Estimate_Client_Payment_Schedule__c());
    }
}