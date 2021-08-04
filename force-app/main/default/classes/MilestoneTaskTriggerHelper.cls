public class MilestoneTaskTriggerHelper 
{
    public static Boolean inTrigger = false;
    public static Set<Id> processedTasks;
    
    public static Date calcStart(Date DesiredStartDate, Date parentEndDate, Date completedDate, boolean includeWeekends)
    {
        Date startDate;
        if(completedDate <= DesiredStartDate || completedDate <= parentEndDate)
            startDate = completedDate;
        else if(parentEndDate == null || DesiredStartDate > parentEndDate)
            // Use desired start if after parent end (or if there is no parent)
            startDate = DesiredStartDate;
        else
            // Otherwise, set to Parent End + 1
            startDate = parentEndDate + 1;

        // adjust for weekday if not schduling on weekend...
        if(!includeWeekends)
            startDate = getNextWeekDay(startDate);
        
        return startDate;
    }
    
    
    public static Date calcEnd(Date startDate, Integer work, Date completedDate, boolean includeWeekends)
    {
        if(completedDate != null)
        	return completedDate;
        if(!includeWeekends)
            return startDate + calcDuration(startDate, work);
        return startDate + work - 1;   // e.g. if work is 1 day, end date is same as start date
    }
    
    
    public static Integer calcDuration(Date startDate, Integer work)
    {
        Integer duration = work;
        Date day = startDate;
        Integer workDays = 0;
        while(workDays < work)
        {
            if(isWorkDay(day))    // cluncky to do this in a loop, but better to rely on the library functions to determine weekdays...
                workDays++;
            day = day + 1;
        }
        duration = startDate.daysBetween(day)-1;

        return duration;
    }
    
    
    public static Integer calcWork(Date startDate, Date endDate, boolean includeWeekends)
    {
        if(!includeWeekends)
       		return getDiffBusinessDays(startDate, endDate);
        return startDate.daysBetween(endDate)+1;
    }

    
    public static Boolean isWorkDay(Date dt)
    {
        Date saturday = Date.newInstance(1900, 1, 6);
        Date sunday = Date.newInstance(1900, 1, 7);
        
        if(Math.mod(saturday.daysBetween(dt),7) == 0)          // saturday?
            return false;
        else if(Math.mod(sunday.daysBetween(dt),7) == 0)		// sunday?
            return false;
        
        return true;
    }

    
    
    public static Date getNextWeekDay(Date dt)
    {
        Date saturday = Date.newInstance(1900, 1, 6);
        Date sunday = Date.newInstance(1900, 1, 7);
        
        if(Math.mod(saturday.daysBetween(dt),7) == 0)          // saturday?
            dt += 2;  // add two days
        else if(Math.mod(sunday.daysBetween(dt),7) == 0)		// sunday?
            dt += 1;
        
        return dt;
    }
    
    
    private static Integer getDiffBusinessDays(Date startdt, Date enddt) 
    {
        Date tempdate = null;
        if (startdt > enddt)
        {
            tempdate = enddt;
            enddt = startdt;
            startdt = tempdate;
        }
        
        Integer i = Math.mod((date.newinstance(1985, 6, 24)).daysBetween(startdt),7); // 24/6/85 was a monday
        Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>> 
        {
            0 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 5 , 5 => 5 , 6 => 5 },
            1 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 4 , 5 => 4 , 6 => 5 },
            2 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 3 , 4 => 3 , 5 => 4 , 6 => 5 },
            3 => new Map<Integer, Integer> { 1 => 2 , 2 => 2 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
            4 => new Map<Integer, Integer> { 1 => 1 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
            5 => new Map<Integer, Integer> { 1 => 0 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
            6 => new Map<Integer, Integer> { 1 => 1 , 2 => 2 , 3 => 3 , 4 => 4 , 5 => 5 , 6 => 5 }
        };
            
        Integer i2 = Math.mod((startdt.daysBetween(enddt)),7);
        Integer i3 = (m.get(i)).get(i2);
        
        if (i2 == null || i2 < 1 || i2 > 6) 
        {
            if (i >= 0 && i <= 4) 
            { 
                i3 = 1; 
            }
            else  
            { 
                i3 = 0; 
            }
        }
        
        i3 = i3 + 5 * (Math.floor( ((Decimal) startdt.daysBetween(enddt)).divide(7,4))).intValue();
        if (tempdate != null) 
            i3 *= -1; // negative number of days
        return i3;
    }
}