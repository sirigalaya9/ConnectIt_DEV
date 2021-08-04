public class UsersListController {

    
public List<User> getUsers() {
    
    List<User> results = Database.query(
        'SELECT Name, ManagerId, title, Structure_Chart_Include__c ' +
        'FROM User ' +
        'WHERE Structure_Chart_Include__c = true'
    );
    return results;
}
}