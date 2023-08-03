# Fielo-REST-Member-Segment

Click on the following button to deploy the repository to any org. Salesforce Login is required

<a href="https://githubsfdeploy.herokuapp.com?owner=FieloIncentiveAutomation&repo=REST-Member-Segment&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# How to Use:
Call the REST Api using following URL:
/services/apexrest/v1/members/memberId/segments

Use the parameters, if applies:
/services/apexrest/v1/members/memberId/segments?fields=Id,Name,FieloPLT__OnlineProcessing__c&limit=10&offset=5&orderby=Name+ASC

If no parameter is used, the default values are: <br>
Fields: Id, Name, RecordType.Name, FieloPLT__OnlineProcessing__c, FieloPLT__RecordBased__c<br>
Limit: 20 <br>
Offset: 0 <br>
Order By: CreatedDate ASC <br>
