@isTest
public class RuleTest 
{
    @TestSetup
    static void setupData()
    {
        Rule__c rule = new Rule__c();
        rule.Name = 'Test';
        rule.Active__c = true;
        rule.Condition_Requirements__c = 'AND';        
        rule.Utility_Type__c = 'Electric';
        insert rule;
        Rule_Item__c item = new Rule_Item__c();
        item.Rule__c = rule.Id;
        item.Field__c = 'Family';
        item.Operator__c = '=';
        item.Value_Type__c = 'Manual';
        item.Value2__c = 'Electricity';
        insert item;

        Rule__c rule2 = new Rule__c();
        rule2.Name = 'Test2';
        rule2.Active__c = true;
        rule2.Condition_Requirements__c = 'Custom';
        rule2.Condition_Logic__c = '1 AND 2 AND (3 OR 4)';
        rule2.Utility_Type__c = 'Electric';
        insert rule2;
        Rule_Item__c item1 = new Rule_Item__c();
        item1.Rule__c = rule2.Id;
        item1.Field__c = 'Family';
        item1.Operator__c = '=';
        item1.Value_Type__c = 'Manual';
        item1.Value2__c = 'Electricity';
        insert item1;
        Rule_Item__c item2 = new Rule_Item__c();
        item2.Rule__c = rule2.Id;
        item2.Field__c = 'IsActive';
        item2.Operator__c = '=';
        item2.Value_Type__c = 'Manual';
        item2.Value2__c = 'TRUE';
        insert item2;      
        Rule_Item__c item3 = new Rule_Item__c();
        item3.Rule__c = rule2.Id;
        item3.Field__c = 'Labour_Sell__c';
        item3.Operator__c = '>';
        item3.Value_Type__c = 'Manual';
        item3.Value2__c = '1200';
        insert item3;    
        Rule_Item__c item4 = new Rule_Item__c();
        item4.Rule__c = rule2.Id;
        item4.Field__c = 'Adopter__c';
        item4.Operator__c = 'Contains';
        item4.Value_Type__c = 'Field';
        item4.Value__c = 'dno__c';
        insert item4;
    }

    @isTest
    static void testRule()
    {
        List<Product2> products = RuleController.getProducts('Electric', null, null, null);
        System.assertEquals(0, products.size(), '0 products should be returned');
    }
}