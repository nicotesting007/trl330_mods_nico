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
// This not a class - use for CSDEV sandbox setup

// Map username to correct email for TRL team
Map<String,String> emailMap = new Map<String,String>();
emailMap.put('ramesh.rangaiah@mulesoft.com.csdev','ramesh.rangaiah@mulesoft.com');
emailMap.put('sandeep.deshmukh@mulesoft.com.csdev','sandeep.deshmukh@mulesoft.com');
emailMap.put('kaman.ng@mulesoft.com.csdev','kaman.ng@mulesoft.com');
emailMap.put('kyle.burke@mulesoft.com.csdev','kyle.burke@mulesoft.com');
emailMap.put('naddagatla@mulesoft.com.csdev','naddagatla@mulesoft.com');
emailMap.put('thoeger@mulesoft.com.csdev','thoeger@mulesoft.com');
emailMap.put('prasenjit.banerjee@mulesoft.com.csdev','prasenjit.banerjee@mulesoft.com');
emailMap.put('hkasibhatta@mulesoft.com.csdev','hkasibhatta@mulesoft.com');
// Other members for UAT/QA
emailMap.put('dan.owen@mulesoft.com.csdev','dan.owen@mulesoft.com');
emailMap.put('dezso.pallagi@mulesoft.com.csdev','dezso.pallagi@mulesoft.com');
emailMap.put('giuliano.pezzoli@mulesoft.com.csdev','giuliano.pezzoli@mulesoft.com');

List<User> trlUsrList = [SELECT Id, Username, LastName, FirstName, Name, Email, ProfileId, UserType 
                        FROM User where Username 
                        IN ('iandrosov@mulesoft.com.csdev','ramesh.rangaiah@mulesoft.com.csdev', 
                        'sandeep.deshmukh@mulesoft.com.csdev', 'naddagatla@mulesoft.com.csdev', 
                        'kyle.burke@mulesoft.com.csdev', 'kaman.ng@mulesoft.com.csdev','thoeger@mulesoft.com.csdev',
                        'prasenjit.banerjee@mulesoft.com.csdev','hkasibhatta@mulesoft.com.csdev')];

List<User> qaUsrList = [SELECT Id, Username, LastName, FirstName, Name, Email, ProfileId, UserType 
                        FROM User where Username 
                        IN ('dan.owen@mulesoft.com.csdev','dezso.pallagi@mulesoft.com.csdev', 
                        'giuliano.pezzoli@mulesoft.com.csdev')];

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
