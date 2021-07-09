/***
*  @name: TRL_Submit_CasePlatformEvent to externalize method for submission of the PE
*  @GUS: #W-8097697
*  @Author: thoeger@mulesoft.com
*  @CreationDate: 2020-October-21
* 
* */
public class TRL_Submit_CasePlatformEvent {
    
    Final string DebugClass = '## TRL_Submit_CasePlatformEvent ';
    
    public void Submit_TRL_CasePlatformEvent(Case c)
    {
        List<case> CaseLst = new List<case>();
        CaseLst.add(c);
        Submit_TRL_CasePlatformEvent(CaseLst);
    }
    
    
    public void Submit_TRL_CasePlatformEvent(List<case> CaseLst)
    {
        Final String DebugMethod = DebugClass + '## Submit_TRL_CasePlatformEvent ';
        List<TRL_Case_Priorization_Event__e> CPELst = new List<TRL_Case_Priorization_Event__e>();
        
        for (Case c : CaseLst)
        {
            TRL_Case_Priorization_Event__e newEvent = new TRL_Case_Priorization_Event__e(
                AccountId__c=c.AccountID,
                CaseID__c=c.id
            );
            CPELst.add(newEvent);
        }
        // Call method to publish events
        system.debug(DebugClass + ' newEvents:'+CPELst);
        List<Database.SaveResult> srlst = EventBus.publish(CPELst);
        system.debug(DebugClass + ' PublishEventResults:'+srlst);
        // Inspect publishing result
        for (Database.SaveResult sr   : srlst)
        {
            if (sr.isSuccess()) {
                System.debug( DebugClass +  'Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug( DebugClass + 'Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
        
        
    }
}