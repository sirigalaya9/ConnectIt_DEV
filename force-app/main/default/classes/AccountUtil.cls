public with sharing class AccountUtil {
    public static Id getSiteAccountRecordTypeId {
        get {
            return getRecordTypeIdByName('Site');
        }
    }

    public static Id getStandardAccountRecordTypeId {
        get {
            return getRecordTypeIdByName('Standard');
        }
    }

    public static Id getRecordTypeIdByName(String name) {
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }
}