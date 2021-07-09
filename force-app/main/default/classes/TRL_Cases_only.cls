public with sharing class TRL_Cases_only {
    
    public Integer currentPage {get;set;}
    public Integer listSize {get;set;}
    public Integer totalSize {get;set;}
    //Prasenjit :: fetch cases with the logged in user id
    public Boolean csacse_checkbox {get;set;}
    public Boolean user_role {get;set;} 
    public Boolean requestor_checkbox {get;set;}
    public List<Case> cases {get;set;}
    public Case caseForStatus {get; set;}
    public Account accountForTerritory {get; set;}
    // UI variables
    public String searchExpression {get; set;}
    public String selectedCaseStatus {get; set;} // piclist selector status
    private List<TRL_ObjectPicklistUtil.PickList> statusList;
    public String selectedTheater {get; set;} // piclist selector Terrotory/Theater
    private List<TRL_ObjectPicklistUtil.PickList> territoryList;
    public String selectedArea {get; set;} // picklist selector Area/Region
    public Boolean selectedAreaDisable {get; set;}
    private Map<String, List<TRL_ObjectPicklistUtil.PickList>> areaMap; // Key map of depenndent pick values

    // A.I. Comment: Once we choose to use Local store for tehse values these parameters and code related to pass them NOT needed
    // ----- CLEANUP ---- UBT TEST REFACTOR required
    //Nagini's change
    string selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
    string selectedTerritory = ApexPages.currentPage().getParameters().get('selectedTerritory');
    string selectedRegion = ApexPages.currentPage().getParameters().get('selectedRegion');  
    //Nagini's change

    private Id trlRecordTypeId;
    private static final String QUERY_FOR_CASE_SEARCH = 'SELECT AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById, ' +
        'CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c, TRL_Type__c, CS_Reason__c, CS_Activity__c, TRL_Calc_Prio_Score__c ' +
        'FROM Case WHERE RecordTypeId = {0} ORDER BY CaseNumber DESC LIMIT {1} OFFSET {2}'; 
    private static final String QUERY_FOR_COLUMN_SORT = 'SELECT AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById, ' +
        'CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c, TRL_Type__c, CS_Reason__c, CS_Activity__c, TRL_Calc_Prio_Score__c ' +
        'FROM Case WHERE RecordTypeId = {0} ORDER BY ';
    private static final String QUERY_FOR_CASE_NUMBER = 'SELECT COUNT() ' +
        'FROM Case WHERE RecordTypeId = {0}';
        
    private static final String QUERY_FOR_STATUS = 'SELECT DISTINCT Status FROM Case';
    // Query to find Cases by Requestor or Assigned users
    private static final String QUERY_FOR_CASE_BASE = 'SELECT AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById, ' +
        'CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c, TRL_Type__c, CS_Reason__c, CS_Activity__c, TRL_Calc_Prio_Score__c ' +
        'FROM Case'; 

    
    //Sandeep - TRL Enhancement - Start
    private String sortDirection = '';
    private String sortExp = '';
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    //Sandeep- TRL Enhancement - End    
    public TRL_Cases_Only() {
        currentPage = 1;
        listSize = 50;
        //this.selectedCaseStatus = '--None--';
        //this.selectedTheater = '--None--';
        //this.selectedArea = '--None--';
        this.statusList = TRL_ObjectPicklistUtil.getSelectOptionFromPicklist('Case', 'Status', true);
        this.territoryList = TRL_ObjectPicklistUtil.getSelectOptionFromPicklist('Account', 'Territory__c', true);
        this.areaMap = TRL_ObjectPicklistUtil.GetDependentOptionsEX('Account', 'Territory__c', 'Region__c');
        this.selectedAreaDisable = true;
    //     System.debug('UserRole.Name..........' + UserInfo.getUserRoleId().Name);
    //     if(UserRole.Name.contains('Admin'))
    //         user_role = TRUE;
        Map<String, Schema.RecordTypeInfo> recordTypes  =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Schema.RecordTypeInfo trlRecordType = recordTypes.get('TRL');
        this.trlRecordTypeId = trlRecordType.getRecordTypeId();
        
        //Nagini's change begin
        // A.I. Update: init new selected variables to use as parameters
        if (selectedStatus == null){
            selectedStatus = '';
        }else{
            this.selectedCaseStatus = this.selectedStatus;
        }
        if (selectedTerritory == null){
            selectedTerritory = '';
        }else{
            this.selectedTheater = this.selectedTerritory;
        }
        if (selectedRegion == null){
            selectedRegion = '';  
        }else{
            this.selectedArea = this.selectedRegion;
        }
        accountForTerritory = new Account(Region__c = selectedRegion, Territory__c = selectedTerritory);
        caseForStatus = new Case(RecordTypeId = trlRecordTypeId, Status = selectedStatus);               
        //Nagini's change end
        // A.I Update
        //this.searchExpression = ApexPages.currentPage().getParameters().get('searchExpression');
        // A.I Update

        //this.cases = getTRLCases();
        runFilterSearch();
        this.totalSize = getTotalSize();

    }
    // A.I. New filtering methods -- START --
    // AI Changes: methods to handle picklists without use of restricted Objects and fields
    // Use metadata to pull all values and build UI drop down
    // Case Status list method
    // Case Status - special field pick valiues controlled by Support process and NOT possible to get
    // these values mapped in support-proc from metdata, This is well known GAP in Salesforce Describe method
    // Set up a list of values dorect in code for this fix Bug:30
    
    public List<SelectOption> getStatusItems(){
        ID CurrentUserID = System.UserInfo.getUserId();
        //String CurrentUserDivision = '';
        String CurrentUserDivision = [Select ID, Name,Division From User WHERE ID=:CurrentUserID].Division;
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('--None--', '--None--'));
        
        IF(String.isNotEmpty(CurrentUserDivision) && (CurrentUserDivision.contains('EMEA') || CurrentUserDivision.contains('APAC'))){
            options.add(new SelectOption('Pending Approval', 'Pending Approval'));
        }
        options.add(new SelectOption('New', 'New'));
        options.add(new SelectOption('Assigned', 'Assigned'));
        options.add(new SelectOption('Work in Progress', 'Work in Progress'));
        options.add(new SelectOption('Awaiting info from customer', 'Awaiting info from customer'));
        options.add(new SelectOption('Escalated', 'Escalated'));
        options.add(new SelectOption('Rejected', 'Rejected'));
        options.add(new SelectOption('Withdrawn', 'Withdrawn'));
        options.add(new SelectOption('Completed', 'Completed'));
        options.add(new SelectOption('Cant Accommodate', 'Can\'t Accommodate'));
        //for (TRL_ObjectPicklistUtil.PickList p : this.statusList){
        //    options.add(new SelectOption(p.value, p.label));
        //}
        return options;
    }
    // Territory>Theater list methods
    public List<SelectOption> getTheaterItems(){
        List<SelectOption> options = new List<SelectOption>();
        for (TRL_ObjectPicklistUtil.PickList p : this.territoryList){
            options.add(new SelectOption(p.value, p.label));
        }
        return options;
    }
    // CS Area Region list methods
    public List<SelectOption> getRegionItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--', '--None--'));
        if (areaMap != null && areaMap.containsKey(this.selectedTheater)){
            List<TRL_ObjectPicklistUtil.PickList> regionList = (List<TRL_ObjectPicklistUtil.PickList>)areaMap.get(this.selectedTheater);
            for (TRL_ObjectPicklistUtil.PickList p : regionList){
                options.add(new SelectOption(p.value, p.label));
            }
        }
        return options;
    }
    // UI Methods to b,lock display on area drop
    public Boolean getAreaDisaplay(){
        if(this.selectedTheater != null && this.selectedTheater != '--None--'){
            this.selectedAreaDisable = false; // Enable Area list
        }else{
            this.selectedAreaDisable = true;
        }
        return this.selectedAreaDisable;
    }
    // A.I. New filtering methods -- END --
    private String getFiltersForQuery() {
        system.debug('## Status: '+this.selectedCaseStatus);
        String filters = '\'' + this.trlRecordTypeId + '\'';
        if (this.selectedCaseStatus != null && this.selectedCaseStatus.length() > 0 && this.selectedCaseStatus != '--None--') {
            String s =  String.escapeSingleQuotes(this.selectedCaseStatus);
            filters += ' AND Status = \'' + s + '\'';
        }
        // A.I. add escapeSingleQuotes handle SOQL/SOSL injection issues Bug: W-8618354
        if (this.selectedTheater != null && this.selectedTheater.length() > 0 && this.selectedTheater != '--None--') {
            String cstheater = String.escapeSingleQuotes(this.selectedTheater);
            filters += ' AND Account.Territory__c = \'' + cstheater + '\'';
            if (this.selectedArea != null && this.selectedArea.length() > 0 && this.selectedArea != '--None--') {
                String csarea = String.escapeSingleQuotes(this.selectedArea);
                filters += ' AND Account.Region__c = \'' + csarea + '\'';
            }
        }
/** Test filter
        if (caseForStatus.Status != null && caseForStatus.Status != '') {
            filters += ' AND Status = \'' + caseForStatus.Status + '\'';
        }
        
        if (accountForTerritory.Territory__c != null && accountForTerritory.Territory__c != '') {
            filters += ' AND Account.Territory__c = \'' + accountForTerritory.Territory__c + '\'';
            if (accountForTerritory.Region__c != null && accountForTerritory.Region__c != '') {
                filters += ' AND Account.Region__c = \'' + accountForTerritory.Region__c + '\'';
            }
        }
 */
        //Prasenjit :: fetch cases with the logged in user id
        if (csacse_checkbox == TRUE ){
                    filters += ' AND Case.CSA_CSE__c = \'' + Userinfo.getUserId() + '\'';
                }
        if (requestor_checkbox == TRUE ){
                    filters += ' AND Case.CreatedById = \'' + Userinfo.getUserId() + '\'';
                }

        /*
        System.debug('### '+caseForStatus.CSA_CSE__c+' FL: '+filters);
        if (caseForStatus.CSA_CSE__c != null) {
            filters += ' AND CSA_CSE__c = \'' + caseForStatus.CSA_CSE__c + '\'';
        }
        System.debug('### 2 '+caseForStatus.CSA_CSE__c+' FL: '+filters);
        */
        // Escape specials
        return filters;
    }

    // Use SOQL Query direct result with WHERE filters
    private List<Case> getTRLCases() {
        
        //build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        String soqlQuery= '';
        List<Case> allCases = new List<Case>();
        System.debug('sortFullExp' + sortFullExp);
        //query the database based on the sort expression
        If (sortFullExp == null || sortFullExp == ' '){
            soqlQuery = String.format(QUERY_FOR_CASE_SEARCH, new List<Object>{
                getFiltersForQuery(), listSize, listSize*(currentPage-1)
                    });       
        }
        else{
            System.debug('OFFSET==>' + listSize*(currentPage-1));
            soqlQuery = String.format(QUERY_FOR_COLUMN_SORT + sortFullExp + ' LIMIT {1} OFFSET {2}' , new List<Object>{
                getFiltersForQuery(), listSize, listSize*(currentPage-1)
                    });  
        }    
        try{
            System.debug('soqlQuery :::::::'+soqlQuery);
            allCases =  Database.query(soqlQuery);
        } catch(QueryException ex){
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Something went wrong, please contact your administrator'));
            allCases = new List<Case>();
        }  
        return allCases;    
          
    }
    private Integer getTotalSize() {
        
        String soqlQuery = String.format(QUERY_FOR_CASE_NUMBER,  new List<Object>{
            getFiltersForQuery()
                });
        
        try{
            return Database.countQuery(soqlQuery);
        } catch(QueryException ex){
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Something went wrong, please contact your administrator'));
            return 0;
        }
        
    }
    
    // SOSL Search cases with same filters applied to SOQL query 
    /** A.I. Comment method not used replaced with reload
    public void searchCases(){
        System.debug('## searchCases: '+this.searchExpression);
        if (this.searchExpression != null && this.searchExpression.length() > 1){
            this.currentPage = 1;
            this.cases = searchAllCases();
            this.totalSize = cases.size();
        }else{
            // send error
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The value for search must be more than 1 character'));
        }
    }
    **/
    // A.I. COmment: Add Search methods SOSL search text for Case User & Account objects
    // Merge results with selected cases
    // SOSL Search cases with same filters applied to SOQL query
    private List<Case> searchAllCases(){
        List<Case> caseList = new List<Case>();
        System.debug('## searchAllCases ENTER === '+this.searchExpression);
        if(this.searchExpression != null && this.searchExpression.length() > 1){
            String qry = 'IN ALL FIELDS RETURNING Case (Id, AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById, ' +
                                                'CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c, TRL_Type__c, CS_Reason__c, CS_Activity__c, TRL_Calc_Prio_Score__c ' +
                                                ' WHERE RecordTypeId = ' + getFiltersForQuery() + ' ORDER BY CaseNumber DESC), ' +
                                                'User (Id, Email, UserName, Name, FirstName, LastName), ' +
                                                'Account (Id, Name)';
            // Escape single quotes
            String s =  String.escapeSingleQuotes(this.searchExpression);
            String searchquery='FIND \''+ s + '\' '+qry; 
            System.debug('## SEARCH: '+searchquery);
            
            List<List<SObject>>searchList=search.query(searchquery);
            System.debug('## QRY: '+searchquery);
            if(searchList.size() > 0){
                caseList = (List<Case>)searchList[0];
                System.debug('## FOUND CASES: '+caseList.size());
            }
            if(searchList.size() > 1){
                List<Case> soslCases = searchByUserCase((List<User>)searchList[1]);
                caseList = addCaseList(caseList, soslCases);     
            }
            if(searchList.size() > 2){ 
                List<Case> soslAccountCases = searchByAccountCase((List<Account>)searchList[2]);
                caseList = addCaseList(caseList, soslAccountCases);
            }

        }   
        System.debug('## searchAllCases DONE ==='+caseList.size());
        return caseList;
    }
    // A.I. Comment: New methods v2.1.1 Merge serch results
    private List<Case> addCaseList(List<Case> soslCases, List<Case> casesList){
        List<Case> caseList = new List<Case>();
        
        // Merge case lists from Case serch and by User Case search
        Map<String,Case> caseMap = new Map<String,Case>();
        for(Case c : soslCases){
            caseMap.put(c.Id,c);
        }
        for(Case ac : casesList){
            caseMap.put(ac.Id,ac);
        }
        
        caseList = (List<Case>)caseMap.values();
        // Sort list
        //caseList.sort();

        return caseList;
    }
    // Merge 2 Case list result set and keep it unique sorted by Case number
    private List<Case> mergeCaseResultSet(List<Case> filterCases, List<Case> soslCases){
        List<Case> caseList = new List<Case>();
        
            // Merge case lists from Case serch and by User Case search
            Map<String,Case> caseMap = new Map<String,Case>();
            // Ignore SOQL if search has results including all same filters
            // This search result method include SQL filter result is NO search reult
            //if(soslCases != null && soslCases.size()==0){
            //    for(Case c : filterCases){
            //        caseMap.put(c.Id,c);
            //    }
            //}
            //for(Case c : soslCases){
            //    caseMap.put(c.Id,c);
            //}

            // A.I. Comment: Search filter behaviour change when There is a search expression
            // SOQL Query result are ignored and filter apply with search expression result set
            // In this case if search+filer has NO results = empty list
            // IF No search expression then Use query result with filters
            if(this.searchExpression == null || this.searchExpression == ''){
                for(Case c : filterCases){
                    caseMap.put(c.Id,c);
                }
            }
            if(this.searchExpression != null && this.searchExpression.length() > 1){
                for(Case c : soslCases){
                    caseMap.put(c.Id,c);
                }
            } 
            caseList = (List<Case>)caseMap.values();
            // Sort list
            //caseList.sort();
        return caseList;
    }
    // A.I. Comment: New methods v2.1.1 Search by User
    // Search cases by User where Assigned or Requestor set to User name
    private List<Case> searchByUserCase(List<User> usrList){
        List<Case> caseList = new List<Case>();
        if(usrList != null && usrList.size() > 0){
            System.debug('## FOUND USERS: '+usrList.size());
           List<String> uid = new  List<String>();
           String usrid_list = '';
           for(User u : usrList){
                uid.add(u.Id);
                if(usrid_list.length()>0){
                    usrid_list += ',';    
                }
                usrid_list += '\'' + u.Id + '\'';
           }
           String soqlQuery = QUERY_FOR_CASE_BASE + ' WHERE RecordTypeId = ' + getFiltersForQuery() +
                                    ' AND ( CSA_CSE__c IN (' + usrid_list + ') OR CreatedById IN (' + usrid_list +
                                    ') ) ORDER BY CaseNumber DESC';
/**
           String QUERY_FOR_CASE_BY_USER = 'SELECT AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById, ' +
        'CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c ' +
        'FROM Case'; 
           String usrid_list = '\'0053400000C48PjAAJ\',\'0052T00000BzTUvQAN\',\'0053400000C4m8JAAR\'';
           String filter = '\'0122T000000GJX2QAO\' AND Status = \'Assigned\' AND Account.Territory__c = \'AMER\'';
           String qry = QUERY_FOR_CASE_BY_USER + ' WHERE RecordTypeId = ' + filter +
           ' AND ( CSA_CSE__c IN (' + usrid_list + ') OR CreatedById IN (' + usrid_list +
           ') ) ORDER BY CaseNumber DESC';
**/
           System.debug('## USER QRY: '+soqlQuery);

           try{
                System.debug('soqlQuery :::::::'+soqlQuery);
                caseList =  Database.query(soqlQuery);
            } catch(QueryException ex){
                System.debug(ex.getMessage() + '\n' + ex.getCause());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Something went wrong, please contact your administrator'));
                caseList = new List<Case>();
            }     


           //caseList = [SELECT AccountId, Account.Name, Subject, CaseNumber, Status, Type, CreatedById, 
           //             CreatedDate, Account_Region__c, Level_of_Priority__c, CSA_CSE__c 
           //             FROM Case WHERE RecordTypeId =: this.trlRecordTypeId AND (CSA_CSE__c IN :uid OR CreatedById IN :uid)
           //             ORDER BY CaseNumber DESC];
        }
        return caseList;
    }  
    // A.I. Comment: New methods v2.1.1 Search by Account
    // Search Cases by Account where Account name matches text
    private List<Case> searchByAccountCase(List<Account> actList){
        List<Case> caseList = new List<Case>();
        if(actList != null && actList.size() > 0){
            System.debug('## FOUND ACCOUNTS: '+actList.size());
           List<String> aid = new  List<String>();
           String actid_list = '';
           for(Account a : actList){
                aid.add(a.Id);
                if(actid_list.length()>0){
                    actid_list += ',';    
                }
                actid_list += '\'' + a.Id + '\'';
           }
           String soqlQuery = QUERY_FOR_CASE_BASE + ' WHERE RecordTypeId = ' + getFiltersForQuery() +
                                    ' AND AccountID IN (' + actid_list + ') ORDER BY CaseNumber DESC';
           System.debug('## USER QRY: '+soqlQuery);

           try{
                System.debug('soqlQuery :::::::'+soqlQuery);
                caseList =  Database.query(soqlQuery);
            } catch(QueryException ex){
                System.debug(ex.getMessage() + '\n' + ex.getCause());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Account query gack error, please contact your administrator'));
                caseList = new List<Case>();
            }     

        }
        return caseList;
    }  

    private void runFilterSearch(){
        this.currentPage = 1;
        List<Case> filterCases = getTRLCases();
        List<Case> soslCases = searchAllCases();
        System.debug('## FilterSearch: '+filterCases.size()+' search:'+soslCases.size());
        this.cases = mergeCaseResultSet(filterCases, soslCases);
        this.totalSize = getTotalSize();
    }
    // A.I. New method to reset filters a nd refresh view
    public PageReference refreshCaseView(){
        System.debug('## Refresh: '+this.searchExpression);
        // Clear the search value
        this.searchExpression = '';
        this.selectedCaseStatus = '--None--';
        this.selectedTheater = '--None--';
        this.selectedArea = '--None--';
        //this.accountForTerritory.Territory__c = '--None--';
        //this.accountForTerritory.Region__c = '--None--';
        this.selectedStatus = '';
        this.selectedTerritory = '';
        this.selectedRegion = '';  
        this.csacse_checkbox = false;
        //Boolean user_role {get;set;} 
        this.requestor_checkbox = false;

        runFilterSearch();
        return null;
    }

    public PageReference reloadCases() {
        runFilterSearch();
        return null;
    }
    
    public PageReference newCase() {
        //Nagini's change
        //if (selectedStatus == null)
        //	selectedStatus = '';
    	//if (selectedTerritory == null)
        //	selectedTerritory = '';
    	//if (selectedRegion == null)
        //    selectedRegion = ''; 
                    
        //PageReference reference = new PageReference('/apex/TRL_Action_New' + 
        //                                            '?selectedStatus=' + selectedStatus + 
        //                                            '&selectedTerritory=' + selectedTerritory + 
        //                                            '&selectedRegion=' + selectedRegion);
        //Nagini's change

        // A.I. Update: init new selected variables
        PageReference reference = new PageReference('/apex/TRL_Action_New' + 
                                                    '?selectedStatus=' + this.selectedCaseStatus + 
                                                    '&selectedTerritory=' + this.selectedTheater  + 
                                                    '&selectedRegion=' + this.selectedArea +
                                                    '&searchExpression=' + this.searchExpression);
        // A.I. Change
        reference.setRedirect(true);
        return reference;
    }
    
    public void goToFirstPage() {  //when the user clicked the beginning button
        currentPage = 1;
        cases = getTRLCases();
        totalSize = getTotalSize();
    }
    
    public void goToPreviousPage() { //user clicked the previous button
        currentPage -= 1;
        cases = getTRLCases();
        totalSize = getTotalSize();
    }
    
    public void goToNextPage() {    //user clicked the Next button
        currentPage += 1;
        cases = getTRLCases();
        totalSize = getTotalSize();
    }
    
    public void goToEndPage() {      //user clicked the End button
        currentPage = (Integer) Math.ceil(Decimal.valueOf(totalSize)/Decimal.valueOf(listSize));
        cases =getTRLCases();
        totalSize = getTotalSize();
    }
    
    //Sandeep - TRL Enhancement - Start
    public void goToSortColumn() {    //user clicked on the column Name to Sort the table
        cases = getTRLCases();
        totalSize = getTotalSize();
    }
    //Sandeep - TRL Enhancement - End
    //multiselect 
//    public List<SelectOption> getMyCheckboxes() {
//        List<selectOption> options = new List<selectOption>();
//        Map<String, Integer> m = new Map<String, Integer>([SELECT status, COUNT(Id) FROM Case group by Status]);
//        options.addAll(m.keySet());
//        return options;
//       }

}