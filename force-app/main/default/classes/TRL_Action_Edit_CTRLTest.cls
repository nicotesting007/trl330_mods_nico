@IsTest
public class TRL_Action_Edit_CTRLTest {
    
    @testSetUp
    static void setUpData(){
        Account account1 = new Account(Name = 'TestAccount1', Territory__c = 'APAC', Region__c = 'Japan', BillingCountry = 'Japan');
        insert account1;
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        Case testCase = new Case();
        testCase.RecordTypeId = trlRecordType.getRecordTypeId();
        testCase.Subject = 'TRL Case subject';
        testCase.AccountId = account1.Id;
        insert testCase;
    }
    
    @IsTest 
    static void testUpdateRecord(){
        Case testCase = [SELECT Id, AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById,
                            CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c, TRL_Type__c, 
                            CS_Reason__c, CS_Activity__c
                            FROM Case WHERE Subject = 'TRL Case subject' LIMIT 1];
        testCase.Subject = 'Test Case';
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRL_Action_Edit_CTRL ctrl = new TRL_Action_Edit_CTRL(caseStdCtrl);

        User currentUser = new User(Id = UserInfo.getUserId(), TRLcases__c = 'Super User');
        update currentUser;
        
        Test.startTest();
        
        ctrl.updateRecord();
        
        Test.stopTest();
        
        Case resultCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals('Test Case', resultCase.Subject);
    }
    
    @IsTest 
    static void testUpdateRecordError(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRL_Action_Edit_CTRL ctrl = new TRL_Action_Edit_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        ctrl.updateRecord();
        
        Test.stopTest();
        
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if( message.getDetail() == 'You can not edit the case' && message.getSeverity() == ApexPages.Severity.ERROR) {
                messageFound = true;
            }
        }
        System.assert(messageFound);
        
    }
    
    @IsTest 
    static void testSaveAndNew(){
        Case testCase = [SELECT Id, AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById,
                                CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c, TRL_Type__c, 
                                CS_Reason__c, CS_Activity__c
                                FROM Case WHERE Subject = 'TRL Case subject' LIMIT 1];
        testCase.Subject = 'Test Case';
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRL_Action_Edit_CTRL ctrl = new TRL_Action_Edit_CTRL(caseStdCtrl);

        User currentUser = new User(Id = UserInfo.getUserId(), TRLcases__c = 'Super User');
        update currentUser;

        Test.startTest();
        
        ctrl.saveAndNew();
        
        Test.stopTest();
        
        Case resultCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals('Test Case', resultCase.Subject);
    }
    
    @IsTest 
    static void testSaveAndNewError(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRL_Action_Edit_CTRL ctrl = new TRL_Action_Edit_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        ctrl.saveAndNew();
        
        Test.stopTest();
        
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if( message.getDetail() == 'You can not edit the case' && message.getSeverity() == ApexPages.Severity.ERROR) {
                messageFound = true;
            }
        }
        System.assert(messageFound);
        
    }
    
    @IsTest
    static void testCancel(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRL_Action_Edit_CTRL ctrl = new TRL_Action_Edit_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        PageReference testRef = ctrl.cancel();        
        
        Test.stopTest();
        
        System.assertNotEquals(null, testRef);
        System.assert(testRef.getRedirect());
    }

}