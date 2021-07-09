/*
 * App TRL Time_tracking__c controller  unit test class
 *
 * author: A.I.
 */
@IsTest
private class TRL_TimeTracking_ExtCtrlTest {
    
    @testSetUp
    static void setUpData(){
        Account acct = new Account();
        acct.Name = 'TRL Test Account';
        acct.Territory__c = 'AMER';
        acct.CS_Area__c = 'West';
        acct.Region__c = 'West';

        // Fill some required fields for CSDEV or NA101
        acct.Industry = 'Insurance';
        acct.AnnualRevenue = 12000000;
        acct.CurrencyIsoCode = 'USD';
        acct.BillingCountry = 'USA';
        insert acct;

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        Case testCase = new Case();
        testCase.RecordTypeId = trlRecordType.getRecordTypeId();
        testCase.AccountId = acct.Id;
        testCase.Subject = 'TRL case';
        testCase.Status = 'New';
        testCase.CS_Reason__c = 'Success Planning and Advisory';
        testCase.CS_Activity__c ='General architectural advice';
        insert testCase;

    }

    @IsTest
    static void testTRL_TimeTracking_ExtCtrl(){
    
        TRL_TimeTracking_ExtCtrl ctrl = new TRL_TimeTracking_ExtCtrl();
    
        Test.startTest();

        Test.stopTest();
    }

    @IsTest
    static void testSave(){
        Case testCase = [SELECT Id, Subject, Description FROM Case LIMIT 1];

        TRL_TimeTracking_ExtCtrl ctrl = new TRL_TimeTracking_ExtCtrl();
        ctrl.newTimeTrack.Case__c = testCase.Id;
        ctrl.newTimeTrack.Name = 'Test Task 1';
        ctrl.newTimeTrack.Time_spent__c = 1;
        ctrl.newTimeTrack.Description__c = 'Test desc text';

        // --- New fields for 2.2.0  
        ctrl.newTimeTrack.Activity_Date__c = Date.today();
        ctrl.newTimeTrack.CS_Reason__c = 'Success Planning and Advisory';
        ctrl.newTimeTrack.CS_Activity__c ='General architectural advice';

        Test.startTest();
        ctrl.save();
        Test.stopTest();

        List<Time_tracking__c> timeLog = [SELECT Id, Name FROM Time_tracking__c];
        Boolean res = false;
        if(timeLog.size() > 0){res=true;}
        System.assertEquals(true, res);
    }

    @IsTest
    static void testSaveNew(){
        Case testCase = [SELECT Id, Subject, Description FROM Case LIMIT 1];

        TRL_TimeTracking_ExtCtrl ctrl = new TRL_TimeTracking_ExtCtrl();
        ctrl.newTimeTrack.Case__c = testCase.Id;
        ctrl.newTimeTrack.Name = 'Test Task 1';
        ctrl.newTimeTrack.Time_spent__c = 1;
        ctrl.newTimeTrack.Description__c = 'Test desc text';
        // --- New fields for 2.2.0  
        ctrl.newTimeTrack.Activity_Date__c = Date.today();
        ctrl.newTimeTrack.CS_Reason__c = 'Success Planning and Advisory';
        ctrl.newTimeTrack.CS_Activity__c ='General architectural advice';

        Test.startTest();
        ctrl.saveNew();
        Test.stopTest();

        Time_tracking__c tlog = [SELECT Id, Name, Description__c FROM Time_tracking__c LIMIT 1];
        System.assertEquals('Test Task 1', tlog.Name);
        System.assertEquals('Test desc text', tlog.Description__c);

    }

    @IsTest
    static void testcancelAction(){
        TRL_TimeTracking_ExtCtrl ctrl = new TRL_TimeTracking_ExtCtrl();

        Test.startTest();
        PageReference testRef = ctrl.cancelAction(); 
        Test.stopTest();

        // Asserts test
        System.assertNotEquals(null, testRef);
        //System.assert(testRef.getRedirect());
    }

}
