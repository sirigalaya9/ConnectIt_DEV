/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Site_Asset_BOM_JoinTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Site_Asset_BOM_JoinTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Site_Asset_BOM_Join__c());
    }
}