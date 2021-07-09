// Use this APEX code to set up new or refreshed Sandbox for TRL team
// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
//
// This Apex code changes TRL team emails to correct valid email
// after sandbox refresh.
// This not a class - use for TESTDEPLOY sandbox setup

// Map username to correct email for TRL team
Map<String,String> emailMap = new Map<String,String>();
emailMap.put('ramesh.rangaiah@mulesoft.com.testdeploy','ramesh.rangaiah@mulesoft.com');
emailMap.put('sandeep.deshmukh@mulesoft.com.testdeploy','sandeep.deshmukh@mulesoft.com');
emailMap.put('kaman.ng@mulesoft.com.testdeploy','kaman.ng@mulesoft.com');
emailMap.put('kyle.burke@mulesoft.com.testdeploy','kyle.burke@mulesoft.com');
emailMap.put('naddagatla@mulesoft.com.testdeploy','naddagatla@mulesoft.com');
emailMap.put('thoeger@mulesoft.com.testdeploy','thoeger@mulesoft.com');
emailMap.put('prasenjit.banerjee@mulesoft.com.testdeploy','prasenjit.banerjee@mulesoft.com');
emailMap.put('hkasibhatta@mulesoft.com.testdeploy','hkasibhatta@mulesoft.com');
// Other members for UAT/QA
emailMap.put('dan.owen@mulesoft.com.testdeploy','dan.owen@mulesoft.com');
emailMap.put('dezso.pallagi@mulesoft.com.testdeploy','dezso.pallagi@mulesoft.com');
emailMap.put('giuliano.pezzoli@mulesoft.com.testdeploy','giuliano.pezzoli@mulesoft.com');

List<User> trlUsrList = [SELECT Id, Username, LastName, FirstName, Name, Email, ProfileId, UserType 
                        FROM User where Username 
                        IN ('iandrosov@mulesoft.com.testdeploy','ramesh.rangaiah@mulesoft.com.testdeploy', 
                        'sandeep.deshmukh@mulesoft.com.testdeploy', 'naddagatla@mulesoft.com.testdeploy', 
                        'kyle.burke@mulesoft.com.testdeploy', 'kaman.ng@mulesoft.com.testdeploy','thoeger@mulesoft.com.testdeploy',
                        'prasenjit.banerjee@mulesoft.com.testdeploy','hkasibhatta@mulesoft.com.testdeploy')];

List<User> qaUsrList = [SELECT Id, Username, LastName, FirstName, Name, Email, ProfileId, UserType 
                        FROM User where Username 
                        IN ('dan.owen@mulesoft.com.testdeploy','dezso.pallagi@mulesoft.com.testdeploy', 
                        'giuliano.pezzoli@mulesoft.com.testdeploy')];

Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator (A&A)' LIMIT 1];
// Change user email and Profile
for (User u : trlUsrList){
    if (emailMap.containsKey(u.Username)){
        u.Email = (String)emailMap.get(u.Username);
        u.ProfileId = prof.Id;
    }
}
// Update TRL users to set valid email and Admin profile to TRL team
update trlUsrList;

// QA Review Team Change user email 
for (User u : qaUsrList){
    if (emailMap.containsKey(u.Username)){
        u.Email = (String)emailMap.get(u.Username);
    }
}
// Update TRL users to set valid email and Admin profile to TRL team
update qaUsrList;
