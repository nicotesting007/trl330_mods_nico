/***
*  @name: TRL Case priorization calculation class
*  @GUS: #W-8097697, #W-8937505, W-8937494, W-8937515 , #W-9116357 
*  @Author: thoeger@mulesoft.com
*  @CreationDate: 2020-October-19
*  @LastUpdate: 2021-May-05 by thoeger@mulesoft.com
* */

public with sharing class TRL_Case_Priorization_Calculation {
    string debugClass = '## TRL_Case_Priorization_Calculation ';

    public class EvaluationListItem
        { 
            public String scoringString;
            public String fieldLabel;  // this is added to accomodate reading labels from Global value set
            public Double filterLow;
            public Double filterHigh;
            public Double filterScore;
            public Double factor;
            public Integer order;  
            public Double scoreWeight;
            public Double scoringFactor;
            public Boolean isParent;
            public Double calcresult;   // to host the final result of domain prio calculation
        } 
    
    public  void calculatePrio(ID caseID)
    {
        Final String debugMethod = debugClass + ' calculatePrio ';
        system.debug(debugMethod + 'I am here now! With caseID: '+caseID);

        // (1) get case data needed for Prio calc
        String caseQueryString = 'select ' 
        + ' id '
        + ', TRL_Task_Is_Clear__c '
       // + ', TRL_Request_Type__c '
        + ',TRL_Type__c '
        + ', TRL_Calc_Prio_Score__c '
        + ', TRL_Priorisation_Details__c'
        + ', CaseNumber '
        + ', Status'                       // corrected for W-9116357
        + ', accountId '
        + ', account.ARR__c '
        + ', account.CSSA_Renewal_Quota__c '
        + ', account.Next_Renewal_Date__c '
        + ', account.Weighted_Open_ACV__c '
        + ', account.Top_1000_Joint_Account__c '
        + ', account.Focus_Account_Level__c '
        + ', account.CS_Tech_Priority__c  '
        + ', account.Territory__c '
        + ',LastModifiedBy.name'
        + ',LastModifiedBy.email'
        + ' from case ';
        String caseQueryStringFull = caseQueryString + ' where id= \'' + caseID + '\'';
        system.debug(debugMethod + 'CaseQueryStringFull: '+caseQueryStringFull);

        String CasePrioScoreDetails = '';   // defining variable for feedback to user
        Boolean DoExecute = false;  // is beeing set to control execution of calculation

        Case caseTowork = new case();
        try {
            caseTowork = Database.query(caseQueryStringFull); 
            system.debug(debugMethod + 'fetched caseTowork: '+caseTowork);
        }
        catch (Exception caseFetchException) {
            system.debug(debugMethod + 'Error retrieving case: '+caseFetchException);
            return; //ending method due to no available data
        }

        Boolean CaseIsNew = true;
        CaseIsNew = ((caseTowork.TRL_Priorisation_Details__c == null) || (caseTowork.TRL_Priorisation_Details__c == '')) ;
        CaseIsNew = CaseIsNew  && (caseTowork.Status == 'New' );  // bug fix for sending too many e-mails #W-9116357
        system.debug(debugMethod + 'CaseIsNew: '+CaseIsNew + ' Case:'+caseTowork);

        // (2) retrieve Priorization config fom TRL_Priorization_Config
        List<TRL_Priorization_Config__c> PrioConfigLst = new List<TRL_Priorization_Config__c>();
        try {
            PrioConfigLst= [ SELECT Id
                            , Filter_Score__c
                            , FieldLabel__c       // for W-8937494 ... displaying userfriendly UI names .... this is a Picklist based on Global ValueSet TRL_Prio_Fields
                            , FilterHigh__c
                            , FilterLow__c
                            , FilterType__c
                            , IsParent__c
                            , Name
                            , Parent_Filter__c
                            , Score_Weight__c
                            , Scoring_Factor__c
                            , ScoringString__c
                            , SystemModstamp
                            , Theather__c
                            , TRL_Config_Field__c
                            , TRL_Config_Region__c
                            FROM TRL_Priorization_Config__c 
                            where 
                                Theather__c= :caseTowork.account.Territory__c 
                                or TRL_Config_Region__c= :caseTowork.account.Territory__c 
                            order by 
                                IsParent__c desc
                                , name
                                , Parent_Filter__c
                            ];    
            //Note: is is extremely important to keep the sort order and make sure, that on data entry the Name is correalating to the filter
            // this query already filters only on Theater aka account.Territory__c to built only the required subset of Confi elements
            // added 2021-01-31 ... this order seems not to be relevant ... as pratical testing showed
            system.debug(debugMethod + 'PrioConfigLst: '+PrioConfigLst.size() + ' ..'+ PrioConfigLst);
        }
        catch (Exception PrioListFetchException) {
            system.debug(debugMethod + 'Error retrieving PrioConfigLst: '+PrioListFetchException);
            CasePrioScoreDetails = 'Error querying PrioConfigLst for case.account.Territory__c: >' + caseTowork.account.Territory__c + '<'; 
            // return; //ending method due to no available data
        }
        

        if (PrioConfigLst.size() == null || PrioConfigLst.size()==0) 
        {
            system.debug(debugMethod + 'PrioConfigLst: seems to be empty: '+PrioConfigLst.size() + ' stopping here');
            CasePrioScoreDetails = 'Error retrieving PrioConfigLst for case.account.Territory__c: >' + caseTowork.account.Territory__c + '<'; 
            // return; //ending method due to no available data
        } else 
        {
            DoExecute = true;
        }

        Schema.sObjectField TPCLabelField;
        List<PicklistEntry> PrioCalcFields = new List<PicklistEntry>();
        Map<String,String> PrioCalcFieldsMap = new Map<String,String>();
        try {
            TPCLabelField  = TRL_Priorization_Config__c.FieldLabel__c.getDescribe().getSObjectField();
            PrioCalcFields = TPCLabelField.getDescribe().getPicklistValues();
                    
            for (PicklistEntry pe : PrioCalcFields)
            {
                // system.debug(debugMethod +'Priostring:'+pe.getlabel() + '  ...:' + pe.getValue());
                PrioCalcFieldsMap.put(pe.getValue(), pe.getlabel());
            }
        } catch  (Exception PrioListFetchException) {
            system.debug(debugMethod + 'Error retrieving PrioConfigStrings: '+PrioListFetchException);
            CasePrioScoreDetails = 'Error retrieving Labels';
            DoExecute = false;
            // return; //ending method due to no available data
        }

        Double casePrioScore=null; // define variable with initial value  

        if (DoExecute) {
            
            casePrioScore=0;

            List<EvaluationListItem> arrScoreEval = new List<EvaluationListItem>();
            List<EvaluationListItem> cSSARenewalQuotaWeightedSEval = new List<EvaluationListItem>();       
            List<EvaluationListItem> weightedOpenACVEval = new List<EvaluationListItem>();
            List<EvaluationListItem> focusAccountEval = new List<EvaluationListItem>();
            List<EvaluationListItem> cSTechPriorityEval = new List<EvaluationListItem>();        
            List<EvaluationListItem> tRLTaskIsClearEval = new List<EvaluationListItem>();    

            // evaluate TRL Prio Score value and add to respective lists
            for (TRL_Priorization_Config__c pcl : PrioConfigLst)
            {
                // system.debug(debugMethod + 'working on pcl: '+pcl); // temp debug for analyses
                EvaluationListItem eli = new EvaluationListItem();
                if (pcl.IsParent__c)
                {
                    eli.isParent = true;
                    eli.ScoringFactor =  pcl.Scoring_Factor__c;
                    eli.ScoreWeight = pcl.Score_Weight__c;
                    eli.fieldLabel = PrioCalcFieldsMap.get(pcl.FieldLabel__c);
                    eli.calcresult = 0;
                    // this populates value [0] of each List.. and is referenced than in the final calculation
                }  else {
                    eli.isParent = false;
                    eli.FilterScore = pcl.Filter_Score__c;
                    if (pcl.ScoringString__c != null) eli.ScoringString = pcl.ScoringString__c;
                    if (pcl.FilterLow__c != null) eli.FilterLow = pcl.FilterLow__c;
                    if (pcl.FilterHigh__c != null) eli.FilterHigh = pcl.FilterHigh__c;                
                }
                if ( 
                    (pcl.FieldLabel__c !=null && pcl.FieldLabel__c.containsIgnoreCase('account.ARR__c')) || 
                    (pcl.TRL_Config_Field__c !=null && pcl.TRL_Config_Field__c.containsIgnoreCase('account.ARR__c')) 
                    )
                    arrScoreEval.add(eli);
                if ( 
                    (pcl.FieldLabel__c !=null && pcl.FieldLabel__c.containsIgnoreCase('account.Focus_Account_Level__c')) || 
                    ( pcl.TRL_Config_Field__c !=null && pcl.TRL_Config_Field__c.containsIgnoreCase('account.Focus_Account_Level__c')) 
                    )
                    focusAccountEval.add(eli);
                if ( 
                    (pcl.FieldLabel__c !=null && pcl.FieldLabel__c.containsIgnoreCase('account.Weighted_Open_ACV__c')) || 
                    ( pcl.TRL_Config_Field__c !=null && pcl.TRL_Config_Field__c.containsIgnoreCase('account.Weighted_Open_ACV__c')) 
                    )
                    weightedOpenACVEval.add(eli);
                if ( 
                    (pcl.FieldLabel__c !=null && pcl.FieldLabel__c.containsIgnoreCase('case.CS_Tech_Priority__c')) || 
                    ( pcl.TRL_Config_Field__c !=null && pcl.TRL_Config_Field__c.containsIgnoreCase('case.CS_Tech_Priority__c')) 
                    )
                    cSTechPriorityEval.add(eli);
                if ( 
                    (pcl.FieldLabel__c !=null && pcl.FieldLabel__c.containsIgnoreCase('case.TRL_Task_Is_Clear__c')) || 
                    ( pcl.TRL_Config_Field__c !=null && pcl.TRL_Config_Field__c.containsIgnoreCase('case.TRL_Task_Is_Clear__c')) 
                    )
                    tRLTaskIsClearEval.add(eli);
                if ( 
                    (pcl.FieldLabel__c !=null && pcl.FieldLabel__c.containsIgnoreCase('account.CSSA_Renewal_Quota__c')) || 
                    ( pcl.TRL_Config_Field__c !=null && pcl.TRL_Config_Field__c.containsIgnoreCase('account.CSSA_Renewal_Quota__c')) 
                    )
                    cSSARenewalQuotaWeightedSEval.add(eli);          
            } 
            
            system.debug(debugMethod + 'arrScoreEval: '+arrScoreEval.size() + ' '+ arrScoreEval);
            system.debug(debugMethod + 'focusAccountEval: '+focusAccountEval.size() + ' '+focusAccountEval);
            system.debug(debugMethod + 'weightedOpenACVEval: '+weightedOpenACVEval.size() + ' '+weightedOpenACVEval);
            system.debug(debugMethod + 'cSTechPriorityEval: '+cSTechPriorityEval.size() + ' '+cSTechPriorityEval);
            system.debug(debugMethod + 'tRLTaskIsClearEval: '+tRLTaskIsClearEval.size() + ' '+tRLTaskIsClearEval);
            system.debug(debugMethod + 'cSSARenewalQuotaWeightedSEval: '+cSSARenewalQuotaWeightedSEval.size() + ' '+cSSARenewalQuotaWeightedSEval);
            
            // (3) calculate Priorization 

            /** 
            Double arrScore= calcWeighteNumericScore(caseTowork.account.ARR__c, 'arrScore' ,  arrScoreEval );
            arrScoreEval[0].calcresult = arrScore;
            system.debug(debugMethod + 'arrScoreEval: '+arrScoreEval + ' ..'+arrScoreEval[0]);
            Double cSSARenewalQuotaScore= calcCSSARenewalQuotaScore(caseTowork.account.CSSA_Renewal_Quota__c, caseTowork.account.Next_Renewal_Date__c, cSSARenewalQuotaWeightedSEval );
            Double weightedOpenACVScore = calcWeighteNumericScore(caseTowork.account.Weighted_Open_ACV__c,'weightedOpenACVScore',  weightedOpenACVEval );
            Double focusAccountScore = ( caseTowork.account.Top_1000_Joint_Account__c ? calcFocusAccountScore(caseTowork.account.Focus_Account_Level__c,  focusAccountEval ) : 0); // evaluate only if selected
            Double cSTechPriorityScore = calcCSTechPriorityScore(caseTowork.account.CS_Tech_Priority__c, cSTechPriorityEval );
            Double tRLTaskIsClearScore = ( ( caseTowork.TRL_Task_Is_Clear__c.toLowerCase() == 'yes') ? calctRLTaskIsClearScore( tRLTaskIsClearEval) : 0 );  // Business Justification Provided - only parent entry since all or nothing
            **/

            if ( (null != arrScoreEval) && (arrScoreEval.size() > 0) ) {
                system.debug(debugMethod + 'arrScoreEval.size(): '+arrScoreEval.size());
                if ( (null != caseTowork.account.ARR__c) && (caseTowork.account.ARR__c >= 0)) 
                {
                    arrScoreEval[0].calcresult = calcWeighteNumericScore(caseTowork.account.ARR__c, 'arrScore' ,  arrScoreEval );
                } else {
                    arrScoreEval[0].calcresult = 0;
                }
                CasePrioScoreDetails =   arrScoreEval[0].fieldLabel +': ' + arrScoreEval[0].calcresult ; 
                casePrioScore = arrScoreEval[0].calcresult ;
                System.debug(debugMethod + 'ScoreDetails: ' + CasePrioScoreDetails);
            }

            if ( (null != cSSARenewalQuotaWeightedSEval)  && (cSSARenewalQuotaWeightedSEval.size() > 0) ) {
                cSSARenewalQuotaWeightedSEval[0].calcresult = calcCSSARenewalQuotaScore(caseTowork.account.CSSA_Renewal_Quota__c, caseTowork.account.Next_Renewal_Date__c, cSSARenewalQuotaWeightedSEval );
                CasePrioScoreDetails += '\n' + cSSARenewalQuotaWeightedSEval[0].fieldLabel +': ' + cSSARenewalQuotaWeightedSEval[0].calcresult ; 
                casePrioScore += cSSARenewalQuotaWeightedSEval[0].calcresult ;
                System.debug(debugMethod + 'ScoreDetails: ' + CasePrioScoreDetails);
            }

            if ( (null != weightedOpenACVEval) &&  (weightedOpenACVEval.size()  > 0) ) {
                if (null != caseTowork.account.Weighted_Open_ACV__c)   
                {
                    weightedOpenACVEval[0].calcresult = calcWeighteNumericScore(caseTowork.account.Weighted_Open_ACV__c,'weightedOpenACVScore',  weightedOpenACVEval );
                } else {
                    weightedOpenACVEval[0].calcresult = 0;
                }
                CasePrioScoreDetails += '\n' + weightedOpenACVEval[0].fieldLabel +': ' + weightedOpenACVEval[0].calcresult;
                casePrioScore += weightedOpenACVEval[0].calcresult ;
                System.debug(debugMethod + 'ScoreDetails: ' + CasePrioScoreDetails);
            }


            if ( (null != focusAccountEval) && (focusAccountEval.size() > 0) ) {
                if (null != caseTowork.account.Focus_Account_Level__c ) 
                {
                    focusAccountEval[0].calcresult = ( caseTowork.account.Top_1000_Joint_Account__c ? calcFocusAccountScore(caseTowork.account.Focus_Account_Level__c,  focusAccountEval ) : 0); // evaluate only if selected
                } else {
                    focusAccountEval[0].calcresult = 0;
                }
                CasePrioScoreDetails += '\n' + focusAccountEval[0].fieldLabel +': ' + focusAccountEval[0].calcresult ;
                casePrioScore += focusAccountEval[0].calcresult ;
                System.debug(debugMethod + 'ScoreDetails: ' + CasePrioScoreDetails);
            }

            if ( (null != cSTechPriorityEval)  && (cSTechPriorityEval.size() > 0) ) {
                if (null != caseTowork.account.CS_Tech_Priority__c ) 
                {
                    cSTechPriorityEval[0].calcresult = calcCSTechPriorityScore(caseTowork.account.CS_Tech_Priority__c, cSTechPriorityEval );
                } else {
                    cSTechPriorityEval[0].calcresult = 0;
                }
                CasePrioScoreDetails += '\n' + cSTechPriorityEval[0].fieldLabel +': ' + cSTechPriorityEval[0].calcresult ;
                casePrioScore += cSTechPriorityEval[0].calcresult ;
                System.debug(debugMethod + 'ScoreDetails: ' + CasePrioScoreDetails);
            }
            
            if (null != tRLTaskIsClearEval && tRLTaskIsClearEval.size() > 0) {
                if (null != caseTowork.TRL_Task_Is_Clear__c ) {
                    tRLTaskIsClearEval[0].calcresult = ( ( caseTowork.TRL_Task_Is_Clear__c.toLowerCase() == 'yes') ? calctRLTaskIsClearScore( tRLTaskIsClearEval) : 0 );  // Business Justification Provided - only parent entry since all or nothing
                } else {
                    tRLTaskIsClearEval[0].calcresult = 0;
                }
                CasePrioScoreDetails += '\n' + tRLTaskIsClearEval[0].fieldLabel +': ' + tRLTaskIsClearEval[0].calcresult;
                casePrioScore += tRLTaskIsClearEval[0].calcresult ;
                System.debug(debugMethod + 'ScoreDetails: ' + CasePrioScoreDetails);
            }

            System.debug(debugMethod + ' PrioScore: '+ casePrioScore +'\nScoreDetails total: ' + CasePrioScoreDetails );
        
        }  // endif DoExecute

        // (4) update case 
        // finally update the case Prio calc back to the org 
        // the case as retrieved is only used in r/o approach
        Boolean updateCaseSuccessStatus = updateCase(caseTowork, CasePrioScore, CasePrioScoreDetails, CaseIsNew);
        system.debug(debugMethod + 'updateCaseSuccessStatus: '+updateCaseSuccessStatus);
    }
    

    /** here are individual score calculation methods implenting the calculation logic */

    // private double calcWeightedOpenACVScore(Decimal Amount, String theater, List<EvaluationListItem> eLst)
    private double calcWeighteNumericScore(Decimal Amount, String FieldInfo, List<EvaluationListItem> eLst)
    {
        Final String debugMethod = debugClass + ' calcWeighteNumericScore ';
        system.debug(debugMethod + 'begin : '+ Amount + ', '+ FieldInfo + ', '+eLst);     
        Double score=0; // score shall be 0 if no amount present 
        if (Amount != null ||  Amount !=0) 
        {
            for (Integer i = 1 ; i < eLst.size(); i++) 
            {
                system.debug(debugMethod + 'loop eLst:'+i + ':' +eLst[i]);
                if (Amount < eLst[i].FilterHigh && Amount >= eLst[i].FilterLow)  // lower score value <= (x) < higher score value
                    score = eLst[i].FilterScore/100;   //devide by 100 as the Filterscore is 0...100 Percent
                system.debug(debugMethod + 'for : '+i + ' :' + score ); 
            }    
        }
        if(eLst != null && eLst.size()>0){
            // score = score * eLst[0].ScoreWeight / 100 * eLst[0].ScoringFactor;
            score = score * eLst[0].ScoringFactor;
        }
        system.debug(debugMethod + 'end : score='+ score );     
        return score; //ok
    }
    
    private double calcCSSARenewalQuotaScore(Boolean isCSSARenewalQuota, Date nextRenewalDate, List<EvaluationListItem> eLst )
    {
        Final String debugMethod = debugClass + ' calcCSSARenewalQuotaScore ';
        system.debug(debugMethod + 'begin : '+ isCSSARenewalQuota + ', '+ nextRenewalDate + ', '+eLst);  
        Boolean renewalIsCurrentYear = (nextRenewalDate != null ? (nextRenewalDate.year()  == Date.today().year()) : false );  // check date
        Double score = 0;
        if(eLst != null && eLst.size()>0){
            // score = (isCSSARenewalQuota && renewalIsCurrentYear ?  100 : 0) * eLst[0].ScoreWeight/100 * eLst[0].ScoringFactor;
            score = (isCSSARenewalQuota && renewalIsCurrentYear ?  100 : 0) * eLst[0].ScoringFactor/100;  
        }
        system.debug(debugMethod + 'end : score='+ score );     
        return score; //ok
    }

    private double calcFocusAccountScore(String focusAccountLevel, List<EvaluationListItem> eLst)
    {
        return calcPicklistValScore(focusAccountLevel, eLst, 'calcFocusAccountScore');
    }

    private double calcCSTechPriorityScore(String cSTechPriority, List<EvaluationListItem> eLst)
    {
        return calcPicklistValScore(cSTechPriority, eLst, 'calcCSTechPriorityScore');
    }

    private double calcPicklistValScore(String EvaluationString, List<EvaluationListItem> eLst, String FieldInfo )
    {
        Final String debugMethod = debugClass + ' calcPicklistValScore ';
        system.debug(debugMethod + 'begin : '+ EvaluationString  + ', FieldInfo:'+FieldInfo +   ', '+eLst);     
        Double score=0;  // starting value
        if(eLst != null && eLst.size()>0){
            if (EvaluationString != null) 
            {
                for (Integer i = 1 ; i <eLst.size(); i++) 
                {
                    // system.debug(debugMethod + 'loop eLst:'+i + ':' +eLst[i]);
                    if (EvaluationString.containsIgnoreCase( eLst[i].ScoringString))  // caseIgnore shall be robust enough .. as long as no spaces are hidden
                        score =  eLst[i].FilterScore / 100;   // this is the percentage from the evaluate list
                    // system.debug(debugMethod + 'for : '+i + ' :' + score ); 
                }    
            }
            score = score * eLst[0].ScoringFactor;  // removed division by 100 at that level as this would be duplicate to above score calculation
        }
        system.debug(debugMethod + 'end '+FieldInfo+': score='+ score );     
        return score; //ok
    }

    private double calctRLTaskIsClearScore( List<EvaluationListItem> eLst)   // Case.TRL_Task_Is_Clear__c  ... this is ="Business Justification Provided
    {
        Final String debugMethod = debugClass + ' calctRLTaskIsClearScore ';
        system.debug(debugMethod + 'begin : ' + eLst);   
        Double score = 0;  
        if(eLst != null && eLst.size()>0){
            score = 100 * eLst[0].ScoringFactor / 100; 
        }   
        system.debug(debugMethod + 'end : score='+ score );     
        return score; //ok
    }

    /** this is final part of prio calculatio */
    // finally update the case Prio calc back to the org
    // the case as retrieved is only used in r/o approach
    private Boolean updateCase(Case c, Double CasePrioScore, String CasePrioScoreDetails, Boolean CaseIsNew)
    {
        Final String debugMethod = debugClass + ' updateCase ';
        system.debug(debugMethod + 'updateCase: '+c.Id + ' CasePrioScore:'+CasePrioScore + ' CasePrioScoreDetails:'+'<'); 
        Boolean UpdateSuccessful = false;
        c.TRL_Calc_Prio_Score__c = CasePrioScore;
        c.TRL_Priorisation_Details__c = CasePrioScoreDetails;   // for #W-8937505 

        if (CaseIsNew) // ( CasePrioScoreDetails == null || CasePrioScoreDetails == '' )
        { 
            //Fetching the assignment rules on case as per https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
            // originally in TRL_Action_New_CTRL .. now moved here to have prio calc in
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            system.debug(debugMethod + 'AsgnRule::' + AR); 

            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            dmlOpts.emailHeader.triggerAutoResponseEmail = true;
            dmlOpts.emailHeader.triggerUserEmail = true;


            system.debug(debugMethod + 'dmlOpts::' + dmlOpts); 

            //Setting the DMLOption on Case instance
            c.setOptions(dmlOpts);
            ///
        }
        
        Database.SaveResult sr = Database.update(c);
        system.debug(debugMethod + 'sr::' + sr); 
        
        if (sr.isSuccess()) {
            System.debug( debugClass +  
            'Successfully updated case.');
            UpdateSuccessful = true;
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug( debugClass + 'Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
            }
        }
        return UpdateSuccessful;
    }
        
}