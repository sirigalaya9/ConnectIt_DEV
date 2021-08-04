public class CaptureLastViewedMaterialsRequestCtrl {
    @AuraEnabled(cacheable=false)
    public static Boolean captureMatReqId( String matReqId ) {
        Last_Viewed_MatReq__c lvmr = Last_Viewed_MatReq__c.getInstance( UserInfo.getUserId() );
        
        if( lvmr.MatReqId__c != matReqId ) {
            lvmr.SetupOwnerId = UserInfo.getUserId();
            lvmr.MatReqId__c  = matReqId;
            
            UPSERT lvmr Id;

            return true;
        }
        else {
            return false;
        }
    }
}