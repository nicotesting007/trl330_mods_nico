@isTest
public class TRLCase_detail_page_CTRLTest {
    
    @testSetUp
    static void setUpData(){
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        Case testCase = new Case();
        testCase.RecordTypeId = trlRecordType.getRecordTypeId();
        testCase.Subject = 'TRL Case subject';
        insert testCase;
    }
    
    @IsTest
    static void testEdit(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRLCase_detail_page_CTRL ctrl = new TRLCase_detail_page_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        PageReference testRef = ctrl.edit();        
        
        Test.stopTest();
        
        System.assertNotEquals(null, testRef);
        System.assert(testRef.getRedirect());        
    }
    

    @IsTest 
    static void testDeleteRecord(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'TRL Case subject' LIMIT 1];
        testCase.Subject = 'Test Case';
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRLCase_detail_page_CTRL ctrl = new TRLCase_detail_page_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        ctrl.deleteRecord();
        
        Test.stopTest();
        
        List <Case> resultCases = [SELECT Subject FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals(0, resultCases.size());
    }
    
    @IsTest 
    static void testDeleteRecordError(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRLCase_detail_page_CTRL ctrl = new TRLCase_detail_page_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        ctrl.deleteRecord();
        
        Test.stopTest();
        
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if( message.getDetail() == 'You can not delete case' && message.getSeverity() == ApexPages.Severity.ERROR) {
                messageFound = true;
            }
        }
        System.assert(messageFound);
        
    }
    
    @IsTest
    static void testCancel(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRLCase_detail_page_CTRL ctrl = new TRLCase_detail_page_CTRL(caseStdCtrl);
        
        Test.startTest();
        
        PageReference testRef = ctrl.cancel();        
        
        Test.stopTest();
        
        System.assertNotEquals(null, testRef);
        System.assert(testRef.getRedirect());
    }

    @IsTest
    static void testWithdrawnCase(){
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(new Case());
        TRLCase_detail_page_CTRL ctrl = new TRLCase_detail_page_CTRL(caseStdCtrl);

        Test.startTest();

        PageReference testRef = ctrl.withdrawnCase();

        Test.stopTest();

        System.assertNotEquals(null, testRef);
        System.assert(testRef.getRedirect());
    }

    @IsTest
    static void testGetCaseComments(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'TRL Case subject' LIMIT 1];
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRLCase_detail_page_CTRL ctrl = new TRLCase_detail_page_CTRL(caseStdCtrl);
        List<CaseComment> caseComments = new List<CaseComment>();
        for(Integer i = 0; i < 5; i++) {
            caseComments.add(new CaseComment(ParentId = testCase.Id, CommentBody = 'Test Comment'));
        }
        insert caseComments;

        Test.startTest();

        List<CaseComment> testComments = ctrl.getCaseComments();
        ctrl.goToComments();
        Test.stopTest();

        for(CaseComment c: [SELECT ParentId FROM CaseComment WHERE Id IN :testComments]){
            System.assertEquals(c.ParentId, testCase.Id);
        }
    }
}