@IsTest
public class TRL_Case_Priorization_CalculationTest {
    Final static string DebugClass = '## TRL_Case_Priorization_CalculationTest ';


    @testSetUp
    static void setUpData()
    {
        Final String DebugMethod = DebugClass + ' setUpData ';
        system.debug(DebugMethod + 'I am here now!');

        // Set config record for EMEA
        TRL_Priorization_Config__c pc = new TRL_Priorization_Config__c();
        // Parent
        pc.IsParent__c = true;
        pc.FieldLabel__c = 'case.CS_Tech_Priority__c';
        pc.FilterType__c = 'Range';
        pc.Score_Weight__c = 5;
        pc.Scoring_Factor__c = 0.4;
        pc.Theather__c = 'EMEA';
        insert pc;

        List<TRL_Priorization_Config__c> lst = new List<TRL_Priorization_Config__c>();

        TRL_Priorization_Config__c ch1 = new TRL_Priorization_Config__c();
        ch1.IsParent__c = false;
        ch1.Parent_Filter__c = pc.Id;
        ch1.Filter_Score__c = 30;
        ch1.ScoringString__c = 'Low';
        lst.add(ch1);

        TRL_Priorization_Config__c ch2 = new TRL_Priorization_Config__c();
        ch2.IsParent__c = false;
        ch2.Parent_Filter__c = pc.Id;
        ch2.Filter_Score__c = 100;
        ch2.ScoringString__c = 'High';
        lst.add(ch2);

        TRL_Priorization_Config__c ch3 = new TRL_Priorization_Config__c();
        ch3.IsParent__c = false;
        ch3.Parent_Filter__c = pc.Id;
        ch3.Filter_Score__c = 60;
        ch3.ScoringString__c = 'Medium';
        lst.add(ch3);
        insert lst;

        Account a = new Account();
        a.name = 'Test Account';
        // a.ADR_Owner_User_Sales_Theater__c = 'EMEA';
        // a.AnnualRevenue = 4000000000;
        a.BillingCountry = 'Germany';
        a.Territory__c = 'EMEA'; 
        a.Region__c = 'NE';
        a.CS_Tech_Priority__c = 'High';
        a.Focus_Account_Level__c = 'Theater';
        a.CSSA_Renewal_Quota__c = true;
        insert a;
        system.debug(DebugMethod + 'inderting account:'+a);
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        Case testCase = new Case();
        testCase.RecordTypeId = trlRecordType.getRecordTypeId();
        testCase.Subject = 'TRL Case subject';
        testCase.AccountId = a.Id;
        testCase.TRL_Task_Is_Clear__c = 'yes';
        insert testCase;
        system.debug(DebugMethod + 'inderting testCase:'+testCase);

    }

    @IsTest //(SeeAllData=true) // to verify that config data in in does not work with testsetup
    static void testTRL_Case_Priorization_Calculation(){
        Final String DebugMethod = DebugClass + ' testTRL_Case_Priorization_Calculation ';
        system.debug(DebugMethod + 'I am here now!');

        String caseQueryString = 'select ' 
        + ' id '
        + ', TRL_Task_Is_Clear__c '
       // + ', TRL_Request_Type__c '
        + ', TRL_Calc_Prio_Score__c '
        + ', CaseNumber '
        + ', accountId '
        + ', account.ARR__c '
        + ', account.CSSA_Renewal_Quota__c '
        + ', account.Next_Renewal_Date__c '
        + ', account.Weighted_Open_ACV__c '
        + ', account.Top_1000_Joint_Account__c '
        + ', account.Focus_Account_Level__c '
        + ', account.CS_Tech_Priority__c  '
        + ', account.Territory__c '
        + ' from case ';
        String caseQueryStringFull = caseQueryString + ' where Subject= \'TRL Case subject\'';
        system.debug(DebugMethod + 'using caseQueryStringFull:'+ caseQueryStringFull);
        //Case testCase = [SELECT Id, AccountID FROM Case WHERE Subject = 'TRL Case subject' LIMIT 1];
        Case testCase = database.query(caseQueryStringFull);
        system.debug(DebugMethod + 'using case:'+ testCase);

        TRL_Case_Priorization_Calculation TRLCPCalc= new TRL_Case_Priorization_Calculation();

        Test.startTest();
        TRLCPCalc.calculatePrio(testCase.id);  
        Test.stopTest();
    
    }
    
}