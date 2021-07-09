# Salesforce CS TRL App

This is CS Technical Request Salesfroce App - TRL. Enables CSM/CSSA to submit technical requests & manage time used to complete these requests. The base of this app is a Case record with TRL record type to make a new request and time tracking records.

Source for this TRL app is stored in DX format that works with scratch and sandbox orgs. To deploy to production source needs to be converted to metadata using CLI command. We do not store metadata format in this repository because it is intermediate build step.

This guide has helpful information for Salesforce developers who are new to Visual Studio Code go from zero to a deployed app using Salesforce Extensions for VS Code and Salesforce CLI.

Sprint TRL v3.3.0

## Installation Instructions

There are two ways to install TRL App:

-   [Using Salesforce DX](#installing-permission-navigator-using-salesforce-dx): This is the recommended installation option. Use this option if you are a developer who may want to customize the app and may be contribute to this project code.
-   [Using an Unlocked Package](#installing-permission-navigator-using-an-unlocked-package): This option allows anybody to install and use the TRL App without installing a local development environment.

## Working with GitHub Reppository
This sfdx project typically has monthly release schedule driven by BT team schedule. Each release TRL team manges in a release branch naming convention `trl210` - thisis eaxmple of TRL 2.1.0 release branch.

TRL is using GUS Agile project management system to track Stories, bugs, requiremets, this is important point, for Story development GUS story names format: `W-1234566` are used as branch names to easy tracking branch - story - metadata changes. Keeping this naming helps to track metadata related to each story. Story branches are created typically from release branch: `trl300 -> W-854231`

## Installing TRL using Salesforce DX CLI
These instructions apply if you do not have Production ORG with DEVHUB access to build scratch org.

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Sign up for a Developer org and enable Dev Hub
    - Install the current version of the Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the APEX, Lightning Web Components and other Salesforce extensions

1. If you haven't already done so, authenticate with your Dev Hub org and provide it with your personalized alias, example (MyDevHub):

    ```
    sfdx force:auth:web:login -d -a MyDevHub
    ```

1. Install [sfdx-wry-plugin](https://github.com/billryoung/sfdx-wry-plugin) used to manage sample data inports with record types

Here using the open source dx plugin: [sfdx-wry-plugin](https://github.com/billryoung/sfdx-wry-plugin)
to install plugin requires additional git submodule node dependnecies, follow these steps to complete installation. 
** Note the installation can be done in any local directory.

```
$ git clone https://github.com/billryoung/sfdx-wry-plugin.git
$ cd sfdx-wry-plugin
$ mkdir utils
$ git submodule add https://github.com/billryoung/sfdx-wry-plugin.git utils/sfdx-wry-plugin
$ sfdx plugins:link utils/sfdx-wry-plugin
```


1. Clone the `sfdx-cssa-trl` repository:

    ```
    git clone https://github.com/mulesoft-consulting/sfdx-cssa-trl.git
    cd sfdx-cssa-trl
    ```
1. Manual step needed to prep QA user referenced in Workflow needs change of user name (must be unique in Salesforce) change user name file `config/user-def-2.json`
1. Change Workflow `Suvey_result__c.workflow-meta.xml` taht referenced the old user name, typically `trl210.qa@mulesoft.com`
1. Execute script `/scripts/dx/dxorg <ALIAS>` to setup your developer environment in new DX scratch org. This script will automatically exacute a set of programmed steps, after successful execution the environment will be ready for use.
	
	- Create a scratch org valid for 30 days with a simple alias **trl**
	- Push source metadata into new org
	- Create a test user with permissions
	- Run all TRL realted Unit tests (Optional**)
	- Add sample testr data
	- Open new org


After these steps new SFDX Scratch Org is set up for development.

Manual Steps to insert data

1. Insert sample data for Accounts, Opportunity, Case, Time Tracking runthis command: `scripts/dx/dataimport $ORG_ALIAS`

Some cases the record types do not match and need manual work.

1. Manual step: need to update Case TRL Record type ID, run command: `sfdx force:data:record:get --json -u trl -s RecordType -w "DeveloperName='TRL'"`

1. Use New record Type ID update all cases in sample data file Case `/testdata/export-account-Cases.json`

1. Insert sample data for Accounts, Opportunity, Case, Time Tracking runthis command: `sfdx force:data:tree:import --targetusername trl --plan test-data/export-account-Account-Case-Opportunity-plan.json`


If any issues encountered during these steps the failed step and what follow after can be repeated manually. Developer will fix the issue and can execute each command to complete this setup. Typically that fail can occur on source push step, Sample data insert or unit tests.

Run Unit tests is an optional step and can be omited or executed anytime after source is pushed to new org to validate all tests pass before any changes.

```
sfdx force:apex:test:run --suits TRLAllTests --resultformat tap --codecoverage -u trl
```

The following steps documented for developer reference manual execution.

1. Create a scratch org valid for 1-30 days and provide it with a simple alias (**trl** in the command below):

    ```
    sfdx force:org:create --setdefaultusername --setalias trl --definitionfile config/project-scratch-def.json -d 30
    ```

1. Push the app source to your scratch org:

    ```
    sfdx force:source:push -u trl
    ```
1. Create test user

	```
	sfdx force:user:permset:assign -n TRL_Permissions
	sfdx force:user:create --setalias qa-user --definitionfile config/user-def.json
	sfdx force:user:display -u qa-user
	```
1. Insert Sample data

	```
	sfdx force:data:tree:import --targetusername trl --plan test-data/export-account-Account-Case-Opportunity-plan.json
	```
1. Open the scratch org:

    ```
    sfdx force:org:open -u trl
    ```


## Installing TRL using an Unlocked Package

*** This section TBD as a team majes selection on deployment methods ***

1. Login to the org, ensure My Domain is enabled, and deploy thsi package it to all users.

1. Click [TBD]() to install the unlocked package in your org.

1. Select **Install for All Users**

1. In App Launcher, select the **TRL** app.

## Known Issues

Error while SFDX assign permissions set to user:

```
sfdx force:user:permset:assign --permsetname TRL_Permissions --onbehalfof trl320-user -u trl320

ERROR running force:user:permset:assign:  Cannot read property 'Id' of undefined
```
his is fixed in the latest-rc release of the cli or v1.0.9 of plugin-user
`npm install sfdx-cli@latest-rc --global` or `sfdx plugins:install user`

1. Custom Time Log Button to Create new Time Log for TRL Case is using hardcoded Case Field vlue that build by POD differ on PRD Sandbox or Scratchorg. (Need a dynamic solution and custom button like this will not do it)
This is PROD example URL:
<url>/{!$ObjectType.Time_tracking__c}/e?CF00N1m000001Cy5L={!Case.CaseNumber}&amp;CF00N1m000001Cy5L_lkid={!Case.Id}&amp;retURL=/apex/TRLCase_detail_page?id={!Case.Case_Id_18_digit__c}&amp;newid={!Time_tracking__c.Id}p&amp;saveURL=/apex/TRLCase_detail_page?id={!Case.Case_Id_18_digit__c}&amp;newid={!Time_tracking__c.Id}</url>

CSDEV URL: <url>/{!$ObjectType.Time_tracking__c}/e?CF00N2T000005eOBZ={!Case.CaseNumber}&amp;CF00N2T000005eOBZ_lkid={!Case.Id}&amp;retURL=/apex/TRLCase_detail_page?id={!Case.Case_Id_18_digit__c}&amp;newid={!Time_tracking__c.Id}p&amp;saveURL=/apex/TRLCase_detail_page?id={!Case.Case_Id_18_digit__c}&amp;newid={!Time_tracking__c.Id}</url>

## Developer Resources

## Setup CICD with GitHub Actions & DX
TBD

## Part 1: Choosing a Development Model

There are two types of developer processes or models supported in Salesforce Extensions for VS Code and Salesforce CLI. These models are explained below. Each model offers pros and cons and is fully supported.

### Package Development Model

The package development model allows you to create self-contained applications or libraries that are deployed to your org as a single package. These packages are typically developed against source-tracked orgs called scratch orgs. This development model is geared toward a more modern type of software development process that uses org source tracking, source control, and continuous integration and deployment.

If you are starting a new project, we recommend that you consider the package development model. To start developing with this model in Visual Studio Code, see [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model). For details about the model, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) Trailhead module.

If you are developing against scratch orgs, use the command `SFDX: Create Project` (VS Code) or `sfdx force:project:create` (Salesforce CLI)  to create your project. If you used another command, you might want to start over with that command.

When working with source-tracked orgs, use the commands `SFDX: Push Source to Org` (VS Code) or `sfdx force:source:push` (Salesforce CLI) and `SFDX: Pull Source from Org` (VS Code) or `sfdx force:source:pull` (Salesforce CLI). Do not use the `Retrieve` and `Deploy` commands with scratch orgs.

### Org Development Model

The org development model allows you to connect directly to a non-source-tracked org (sandbox, Developer Edition (DE) org, Trailhead Playground, or even a production org) to retrieve and deploy code directly. This model is similar to the type of development you have done in the past using tools such as Force.com IDE or MavensMate.

To start developing with this model in Visual Studio Code, see [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model). For details about the model, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) Trailhead module.

If you are developing against non-source-tracked orgs, use the command `SFDX: Create Project with Manifest` (VS Code) or `sfdx force:project:create --manifest` (Salesforce CLI) to create your project. If you used another command, you might want to start over with this command to create a Salesforce DX project.

When working with non-source-tracked orgs, use the commands `SFDX: Deploy Source to Org` (VS Code) or `sfdx force:source:deploy` (Salesforce CLI) and `SFDX: Retrieve Source from Org` (VS Code) or `sfdx force:source:retrieve` (Salesforce CLI). The `Push` and `Pull` commands work only on orgs with source tracking (scratch orgs).

## The `sfdx-project.json` File

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

The most important parts of this file for getting started are the `sfdcLoginUrl` and `packageDirectories` properties.

The `sfdcLoginUrl` specifies the default login URL to use when authorizing an org.

The `packageDirectories` filepath tells VS Code and Salesforce CLI where the metadata files for your project are stored. You need at least one package directory set in your file. The default setting is shown below. If you set the value of the `packageDirectories` property called `path` to `force-app`, by default your metadata goes in the `force-app` directory. If you want to change that directory to something like `src`, simply change the `path` value and make sure the directory you’re pointing to exists.

```json
"packageDirectories" : [
    {
      "path": "force-app",
      "default": true
    }
]
```

## Part 2: Working with Source

For details about developing against scratch orgs, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) module on Trailhead or [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model).

For details about developing against orgs that don’t have source tracking, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) module on Trailhead or [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model).

## Part 3: Deploying to Production

Don’t deploy your code to production directly from Visual Studio Code. The deploy and retrieve commands do not support transactional operations, which means that a deployment can fail in a partial state. Also, the deploy and retrieve commands don’t run the tests needed for production deployments. The push and pull commands are disabled for orgs that don’t have source tracking, including production orgs.

Deploy your changes to production using [packaging](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp.htm) or by [converting your source](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_source.htm#cli_reference_convert) into metadata format and using the [metadata deploy command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_mdapi.htm#cli_reference_deploy).