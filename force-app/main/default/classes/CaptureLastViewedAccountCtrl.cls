public class CaptureLastViewedAccountCtrl {
    @AuraEnabled
    public static Boolean captureAccId( String accId ) {
        Last_Viewed_Account__c lva = Last_Viewed_Account__c.getInstance( UserInfo.getUserId() );
        
        if( lva.Account_Id__c != accId ) {
            lva.SetupOwnerId    = UserInfo.getUserId();
            lva.Account_Id__c   = accId;
            
            UPSERT lva Id;

            return true;
        }
        else {
            return false;
        }
    }
}