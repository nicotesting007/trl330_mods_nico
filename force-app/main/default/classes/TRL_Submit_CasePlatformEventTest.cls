/***
*  @name: TRL_Submit_CasePlatformEvent to externalize method for submission of the PE
*  @GUS: #W-8097697
*  @Author: thoeger@mulesoft.com
*  @CreationDate: 2020-October-21
* 
* */
@IsTest
public class TRL_Submit_CasePlatformEventTest {
    Final static string DebugClass = '## TRL_Submit_CasePlatformEventTest ';


    @testSetUp
    static void setUpData(){
        Account a = new Account();
        a.name = 'Test Account';
        // a.ADR_Owner_User_Sales_Theater__c = 'EMEA';
        // a.AnnualRevenue = 4000000000;
        a.BillingCountry = 'Germany';
        insert a;
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        Case testCase = new Case();
        testCase.RecordTypeId = trlRecordType.getRecordTypeId();
        testCase.Subject = 'TRL Case subject';
        testCase.AccountId = a.Id;
        insert testCase;
    }
    

    
    @IsTest 
    static void testTRL_CasePE_Publish(){
        Final String DebugMethod = DebugClass + ' testTRL_CasePE_Publish ';
        system.debug(DebugMethod + 'I am here now!');
        Case testCase = [SELECT Id, AccountID FROM Case WHERE Subject = 'TRL Case subject' LIMIT 1];

        Test.startTest();

        TRL_Submit_CasePlatformEvent t = new TRL_Submit_CasePlatformEvent();
        t.Submit_TRL_CasePlatformEvent(testCase);
        system.debug(DebugMethod + ' Event submitted:' + t);

        /** 
        TRL_Case_Priorization_Event__e newEvent = new TRL_Case_Priorization_Event__e(
            AccountId__c=testCase.AccountID,
            CaseID__c=testCase.id
        );
        Database.SaveResult sr = EventBus.publish(newEvent);  
         // Verify that the publish was successful
         System.assertEquals(true, sr.isSuccess());
        
         // Deliver the test event before Test.stopTest()
         Test.getEventBus().deliver();     
         Test.stopTest();   
         **/
    }
    
}

