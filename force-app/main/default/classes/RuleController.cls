public class RuleController 
{
	@AuraEnabled
    public static List<Product2> getProducts(String utilityType, String name, Id ruleId, Map<String, String> fieldMap)
    {                
        List<Rule__c> rules = [SELECT Id, Condition_Requirements__c, Condition_Logic__c, 
        (SELECT Field__c, Operator__c, Value_Type__c, Value__c, Value2__c FROM Rule_Items__r ORDER BY Name ASC) 
        FROM Rule__c 
        WHERE Utility_Type__c = :utilityType
        AND Active__c = TRUE];

        if (rules.isEmpty())
        {
            return new List<Product2>();
        }


        SObjectType sobjType = ((SObject)(Type.forName('Schema.Product2').newInstance())).getSObjectType();        
        Map<String,Schema.SObjectField> fields = sobjType.getDescribe().fields.getMap();

        /*
        String query = 'SELECT Id, Name, IsActive, Sort__c, Family, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, '+
            ' ProductCode, Allow_Multiple_Products__c, Description, Kit_Sell__c, Labour_Sell__c, Labour_Cost__c,  Material_Cost__c, Material_Sell__c,'+
            ' Plant_Sell__c, Plant_Cost__c, Implementor__c FROM Product2 WHERE ';
        */

        String query = 'SELECT Id, Name, IsActive, Family, ProductCode, Description';
        for (String fieldName : fields.keySet())
        {
            Schema.SObjectField field = fields.get(fieldName);
            if (field.getDescribe().isCustom())
                query += ', ' + fieldName;
        }

        query += ' FROM Product2 WHERE ';


        if (fieldMap == null)
        {
            fieldMap = new Map<String, String>();
        }

        List<String> ruleExpressions = new List<String>();
        

        for (Rule__c rule : rules)
        {          
            List<String> expressions = new List<String>();
            String ruleExpression = '';

            if (ruleId == null || (ruleId != null && ruleId == rule.Id))
            {                                                
                for (Integer i=0; i<rule.Rule_Items__r.size(); i++)
                {                
                    String expression = '';
                    Rule_Item__c item = rule.Rule_Items__r.get(i);
                    //query += ' ' + item.Field__c;    
                    expression += ' ' + item.Field__c;                    
                    name = fieldMap.containsKey(item.Field__c) ? fieldMap.get(item.Field__c) : name;
                    if (item.Operator__c.equalsIgnoreCase('Contains'))
                    {
                        //query += ' LIKE ';
                        expression += ' LIKE ';
                        if (item.Value_Type__c.equalsIgnoreCase('Manual'))
                        {
                            //query += '\'%' + item.Value2__c + '%\'';
                            expression += '\'%' + item.Value2__c + '%\'';
                        }
                        else if (item.Value_Type__c.equalsIgnoreCase('Field'))
                        {
                            //query += '\'%' + name + '%\'';
                            expression += '\'%' + name + '%\'';
                        }
                        //query += '';
                        if (i<rule.Rule_Items__r.size()-1)
                        {
                            //query += ' AND';
                        }                        
                    }
                    else
                    {
                        //query += ' ' + item.Operator__c;
                        expression += ' ' + item.Operator__c;
                        if (item.Value_Type__c.equalsIgnoreCase('Manual'))
                        {
                            Schema.DisplayType displayType = fields.get(item.Field__c).getDescribe().getType();
                            if (displayType == Schema.DisplayType.CURRENCY)
                            {
                                //query += item.Value2__c;                            
                                expression += item.Value2__c;
                            }
                            else if (displayType == Schema.DisplayType.BOOLEAN)
                            {
                                //query += Boolean.valueOf(item.Value2__c);
                                expression += Boolean.valueOf(item.Value2__c);
                            }
                            else
                            {
                                //query += '\'' + item.Value2__c + '\'';
                                expression += '\'' + item.Value2__c + '\'';
                            }
                        }
                        else if (item.Value_Type__c.equalsIgnoreCase('Field'))
                        {
                            //query += ' :name';
                            expression += ' :name';
                        }       
                        if (i<(rule.Rule_Items__r.size()-1))
                        {
                            //query += ' AND';                            
                        }                                     
                    }
                    expressions.add(expression);
                }                
            }
            System.debug(expressions);
            
            if (rule.Condition_Requirements__c.equalsIgnoreCase('Custom'))
            {
                String expression = rule.Condition_Logic__c;
                for (Integer i=0; i<expressions.size(); i++)
                {
                    expression = expression.replace(String.valueOf(i+1), expressions[i]);                           
                }                
                ruleExpression += expression;
            }
            else
            {
                for (Integer i=0; i<expressions.size(); i++)
                {
                    ruleExpression += expressions.get(i);
                    if (i<(rule.Rule_Items__r.size()-1))
                    {
                        if (rule.Condition_Requirements__c.equalsIgnoreCase('AND'))
                            ruleExpression += ' AND';
                        else if (rule.Condition_Requirements__c.equalsIgnoreCase('OR'))
                            ruleExpression += ' OR';
                    }            
                }  
            } 
            ruleExpressions.add(ruleExpression);
        }

        for (Integer i=0; i<ruleExpressions.size(); i++)
        {
            query += '( ' + ruleExpressions.get(i) + ' )';
            if (i<(ruleExpressions.size()-1))
            {                
                query += ' OR ';
            }            
        }                 

        System.debug(query);

        return Database.query(query);
    }
}