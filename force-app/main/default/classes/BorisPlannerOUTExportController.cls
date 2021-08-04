public with sharing class BorisPlannerOUTExportController {

    @AuraEnabled
    public static Boolean doExport(String dateFrom, String dateTo, String filterStr) {
        System.debug('R3 ==> BorisPlannerOUTExportController filterStr ' + filterStr);
        if (dateFrom != '' && dateTo != '') {

            BorisPlannerOUTExportBatch b = new BorisPlannerOUTExportBatch(Date.valueOf(dateFrom), Date.valueOf(dateTo), filterStr);
            Id batchProcessId = Database.executeBatch(b, 100);
        }
        return true;
    }
}