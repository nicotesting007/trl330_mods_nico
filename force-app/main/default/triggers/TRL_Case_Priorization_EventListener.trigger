/***
*  TRL Case priorization Platform event Listener
* 	GUS: #W-8097697
*  Author: thoeger@mulesoft.com
*  CreationDate: 2020-October-19
* 
* */

trigger TRL_Case_Priorization_EventListener on TRL_Case_Priorization_Event__e (after insert) {

    TRL_Case_Priorization_Calculation TRLCPCalc = new TRL_Case_Priorization_Calculation();
    for (TRL_Case_Priorization_Event__e event : Trigger.New) {
        // initial comment that event was received
        system.debug('## TRL_Case_Priorization_EventListener: '+event );   
        TRLCPCalc.calculatePrio(event.CaseID__c);  
    }
    // TRL_Case_Priorization_Calculation.calculatePrio(Trigger.New);
}