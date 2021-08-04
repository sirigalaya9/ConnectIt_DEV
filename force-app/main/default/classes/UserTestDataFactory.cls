@isTest
public class UserTestDataFactory {

    public static User createUser(String email, String lastname, String userProfile) {
        user u = new user(
            FirstName = 'firstName',
            LastName = lastname,
            Email = email,
            Alias = 'Alias',
            Username = getRandomNumber() + '@uniqueUsername.com',
            LocaleSidKey = 'en_GB',
            TimeZoneSidKey = 'Europe/London',
            profileId = getLoginProfile(userProfile),
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true
        );
        insert u;
        return u;
    }

    private static Id getLoginProfile(String profileName) {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];

        if (profiles.size() == 0) {
            throw new UserTestDataFactoryException('Unable to find profile: ' + profileName);
        }

        return profiles[0].Id;
    }

    private static String getRandomNumber() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        System.debug(guid);
        return guid;
    }

    public class UserTestDataFactoryException extends Exception {
    }

}