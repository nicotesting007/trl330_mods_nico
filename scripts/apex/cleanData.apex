List<Time_tracking__c> tm = [SELECT Id, Name FROM Time_tracking__c];
delete tm;
List<Opportunity> olst = [Select Id FROM Opportunity];
delete olst;
List<Case> cs = [SELECT Id FROM Case];
delete cs;
List<Account> acc = [SELECT Id, Name FROM Account];
delete acc;