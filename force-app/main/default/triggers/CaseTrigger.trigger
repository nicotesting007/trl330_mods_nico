trigger CaseTrigger on Case(before update) 
{
    
    Map<Id, Case> rejectedStatements = new Map<Id, Case>{};
        
        for(Case cur: trigger.new)
    {
        
        Case oldCur = new Case();
        oldCur = System.Trigger.oldMap.get(cur.Id);
        
        if (oldCur.Status != 'Rejected' && cur.Status == 'Rejected')
        { 
            rejectedStatements.put(cur.Id, cur);  
        }
    }
    
    
    
    
    if (!rejectedStatements.isEmpty())  
    {
        
        List<Id> processInstanceIds = new List<Id>{};
            
            for (Case curn : [SELECT 
                              (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1)
                              FROM Case WHERE ID IN :rejectedStatements.keySet()])
            
        {
            processInstanceIds.add(curn.ProcessInstances[0].Id);
        }
        
        for (ProcessInstance pi : [SELECT TargetObjectId,
                                   (SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 )
                                   FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC]) 
            
            
            
        {                     
            if (Approval.isLocked(rejectedStatements.get(pi.TargetObjectId)) && (pi.Steps[0].Comments == null || 
                 pi.Steps[0].Comments.trim().length() == 0))
            {
                rejectedStatements.get(pi.TargetObjectId).addError('Please provide a rejection reason!');
                //rejectedStatements.get(curn.ID).ID.addError('Please provide a rejection reason!');
            }
        }  
    }
}