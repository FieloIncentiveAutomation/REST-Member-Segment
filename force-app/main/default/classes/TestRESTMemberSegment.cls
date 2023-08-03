@isTest
private class TestRESTMemberSegment {
    @isTest
    static void getMemberSegmentsDefault(){
        FieloPLT__Program__c program = new FieloPLT__Program__c(Name = 'Default',FieloPLT__OnlineTransactionProcessing__c = true);
        insert program;

        Map<String, Schema.RecordTypeInfo> recordTypesMap =
            Schema.SObjectType.FieloPLT__Segment__c.getRecordTypeInfosByDeveloperName();

        Id rtDynamicId = recordTypesMap.get('Dynamic').getRecordTypeId();
        Id rtManualId = recordTypesMap.get('Manual').getRecordTypeId();
        List<FieloPLT__Segment__c> segments = new List<FieloPLT__Segment__c>();

        FieloPLT__Segment__c seg1 = new FieloPLT__Segment__c(Name = 'Individual Members',RecordTypeId = rtDynamicId);
        seg1.FieloPLT__IsActive__c = true;
        seg1.FieloPLT__LogicalExpression__c = 'ALL';
        seg1.FieloPLT__Program__c = program.Id;
        seg1.FieloPLT__RecordBased__c = false;
        seg1.FieloPLT__OnlineProcessing__c = true;
        segments.add(seg1);

        FieloPLT__Segment__c seg2 = new FieloPLT__Segment__c(Name = 'Opt-out Members',RecordTypeId = rtDynamicId);
        seg2.FieloPLT__IsActive__c = true;
        seg2.FieloPLT__LogicalExpression__c = 'ALL';
        seg2.FieloPLT__Program__c = program.Id;
        seg2.FieloPLT__RecordBased__c = true;
        seg2.FieloPLT__OnlineProcessing__c = false;
        segments.add(seg2);

        FieloPLT__Segment__c seg3 = new FieloPLT__Segment__c(Name = 'Manager Members',RecordTypeId = rtDynamicId);
        seg3.FieloPLT__IsActive__c = true;
        seg3.FieloPLT__LogicalExpression__c = 'ALL';
        seg3.FieloPLT__Program__c = program.Id;
        seg3.FieloPLT__RecordBased__c = false;
        seg3.FieloPLT__OnlineProcessing__c = true;
        segments.add(seg3);

        FieloPLT__Segment__c seg4 = new FieloPLT__Segment__c(Name = 'VIP Members',RecordTypeId = rtManualId);
        seg4.FieloPLT__IsActive__c = true;
        seg4.FieloPLT__Program__c = program.Id;
        segments.add(seg4);
        insert segments;

        List<FieloPLT__Criterion__c> criterions = new List<FieloPLT__Criterion__c>();
        FieloPLT__Criterion__c criteria1 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg1.Id);
        criteria1.FieloPLT__FieldName__c = 'FieloPLT__Type__c';
        criteria1.FieloPLT__FieldType__c = 'Picklist';
        criteria1.FieloPLT__Values__c = 'Individual Account';
        criteria1.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria1);
        FieloPLT__Criterion__c criteria2 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg2.Id);
        criteria2.FieloPLT__FieldName__c = 'FieloPLT__Status__c';
        criteria2.FieloPLT__FieldType__c = 'Picklist';
        criteria2.FieloPLT__Values__c = 'Opt-Out';
        criteria2.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria2);
        FieloPLT__Criterion__c criteria3 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg3.Id);
        criteria3.FieloPLT__FieldName__c = 'FieloPLT__IsManager__c';
        criteria3.FieloPLT__FieldType__c = 'Boolean';
        criteria3.FieloPLT__BooleanValue__c = true;
        criteria3.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria3);
        insert criterions;

        //Delete the job created after the insert of the segments
        for (AsyncApexJob job : [SELECT Id, ApexClassId FROM AsyncApexJob]) {
            System.abortJob(job.Id);
        }

        FieloPLT__Member__c member = new FieloPLT__Member__c(
			Name = 'member test',
			FieloPLT__Email__c = ('member test').deleteWhitespace() + Datetime.now().getTime() + '@fielo.com',
			FieloPLT__Program__c = program.Id,
			FieloPLT__Type__c = 'Individual Account',
            FieloPLT__IsManager__c = true
		);
        insert member;

        FieloPLT__MemberSegment__c ms = new FieloPLT__MemberSegment__c(FieloPLT__Member__c = member.Id, FieloPLT__Segment__c = seg4.Id);
        insert ms;


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/FieloPLT/v1/members/' + member.Id + '/segments';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            RESTMemberSegment.getMemberSegments();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Wrong response status code');
        String result = res.responseBody.toString();
        List<FieloPLT__Segment__c> segmentsReturned = (List<FieloPLT__Segment__c>) JSON.deserialize(result,List<FieloPLT__Segment__c>.class);
        System.assertEquals(3, segmentsReturned.size(), 'Wrong segments returned size');
        for(Integer i=0; i<segmentsReturned.size(); i++){
            if(i==0){
                System.assertEquals(seg1.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg1.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Dynamic', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
                System.assertEquals(seg1.FieloPLT__OnlineProcessing__c, segmentsReturned.get(i).FieloPLT__OnlineProcessing__c, 'Field doesnt match');
                System.assertEquals(seg1.FieloPLT__RecordBased__c, segmentsReturned.get(i).FieloPLT__RecordBased__c, 'Field doesnt match');
            }else if(i==1){
                System.assertEquals(seg3.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg3.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Dynamic', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
                System.assertEquals(seg3.FieloPLT__OnlineProcessing__c, segmentsReturned.get(i).FieloPLT__OnlineProcessing__c, 'Field doesnt match');
                System.assertEquals(seg3.FieloPLT__RecordBased__c, segmentsReturned.get(i).FieloPLT__RecordBased__c, 'Field doesnt match');
            }else{
                System.assertEquals(seg4.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg4.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Manual', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
                System.assertEquals(seg4.FieloPLT__OnlineProcessing__c, segmentsReturned.get(i).FieloPLT__OnlineProcessing__c, 'Field doesnt match');
                System.assertEquals(seg4.FieloPLT__RecordBased__c, segmentsReturned.get(i).FieloPLT__RecordBased__c, 'Field doesnt match');
            }
        }
    }

    @isTest
    static void getMemberSegmentsWithParameters(){
        FieloPLT__Program__c program = new FieloPLT__Program__c(Name = 'Default',FieloPLT__OnlineTransactionProcessing__c = true);
        insert program;

        Id rtDynamicId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dynamic'].Id;
        Id rtManualId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Manual'].Id;
        List<FieloPLT__Segment__c> segments = new List<FieloPLT__Segment__c>();

        FieloPLT__Segment__c seg1 = new FieloPLT__Segment__c(Name = 'Individual Members',RecordTypeId = rtDynamicId);
        seg1.FieloPLT__IsActive__c = true;
        seg1.FieloPLT__LogicalExpression__c = 'ALL';
        seg1.FieloPLT__Program__c = program.Id;
        seg1.FieloPLT__RecordBased__c = false;
        seg1.FieloPLT__OnlineProcessing__c = true;
        segments.add(seg1);

        FieloPLT__Segment__c seg2 = new FieloPLT__Segment__c(Name = 'Opt-out Members',RecordTypeId = rtDynamicId);
        seg2.FieloPLT__IsActive__c = true;
        seg2.FieloPLT__LogicalExpression__c = 'ALL';
        seg2.FieloPLT__Program__c = program.Id;
        seg2.FieloPLT__RecordBased__c = true;
        seg2.FieloPLT__OnlineProcessing__c = false;
        segments.add(seg2);

        FieloPLT__Segment__c seg3 = new FieloPLT__Segment__c(Name = 'Manager Members',RecordTypeId = rtDynamicId);
        seg3.FieloPLT__IsActive__c = true;
        seg3.FieloPLT__LogicalExpression__c = 'ALL';
        seg3.FieloPLT__Program__c = program.Id;
        seg3.FieloPLT__RecordBased__c = false;
        seg3.FieloPLT__OnlineProcessing__c = true;
        segments.add(seg3);

        FieloPLT__Segment__c seg4 = new FieloPLT__Segment__c(Name = 'VIP Members',RecordTypeId = rtManualId);
        seg4.FieloPLT__IsActive__c = true;
        seg4.FieloPLT__Program__c = program.Id;
        segments.add(seg4);
        insert segments;

        List<FieloPLT__Criterion__c> criterions = new List<FieloPLT__Criterion__c>();
        FieloPLT__Criterion__c criteria1 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg1.Id);
        criteria1.FieloPLT__FieldName__c = 'FieloPLT__Type__c';
        criteria1.FieloPLT__FieldType__c = 'Picklist';
        criteria1.FieloPLT__Values__c = 'Individual Account';
        criteria1.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria1);
        FieloPLT__Criterion__c criteria2 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg2.Id);
        criteria2.FieloPLT__FieldName__c = 'FieloPLT__Status__c';
        criteria2.FieloPLT__FieldType__c = 'Picklist';
        criteria2.FieloPLT__Values__c = 'Opt-Out';
        criteria2.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria2);
        FieloPLT__Criterion__c criteria3 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg3.Id);
        criteria3.FieloPLT__FieldName__c = 'FieloPLT__IsManager__c';
        criteria3.FieloPLT__FieldType__c = 'Boolean';
        criteria3.FieloPLT__BooleanValue__c = true;
        criteria3.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria3);
        insert criterions;

        //Delete the job created after the insert of the segments
        for (AsyncApexJob job : [SELECT Id, ApexClassId FROM AsyncApexJob]) {
            System.abortJob(job.Id);
        }

        FieloPLT__Member__c member = new FieloPLT__Member__c(
			Name = 'member test',
			FieloPLT__Email__c = ('member test').deleteWhitespace() + Datetime.now().getTime() + '@fielo.com',
			FieloPLT__Program__c = program.Id,
			FieloPLT__Type__c = 'Individual Account',
            FieloPLT__IsManager__c = true
		);
        insert member;

        FieloPLT__MemberSegment__c ms = new FieloPLT__MemberSegment__c(FieloPLT__Member__c = member.Id, FieloPLT__Segment__c = seg4.Id);
        insert ms;


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/FieloPLT/v1/members/' + member.Id + '/segments';
        req.httpMethod = 'GET';
        req.addParameter('orderby', 'CreatedDate DESC');
        req.addParameter('limit', '2');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            RESTMemberSegment.getMemberSegments();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Wrong response status code');
        String result = res.responseBody.toString();
        List<FieloPLT__Segment__c> segmentsReturned = (List<FieloPLT__Segment__c>) JSON.deserialize(result,List<FieloPLT__Segment__c>.class);
        System.assertEquals(2, segmentsReturned.size(), 'Wrong segments returned size');
        for(Integer i=0; i<segmentsReturned.size(); i++){
            if(i==0){
                System.assertEquals(seg4.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg4.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Manual', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
                System.assertEquals(seg4.FieloPLT__OnlineProcessing__c, segmentsReturned.get(i).FieloPLT__OnlineProcessing__c, 'Field doesnt match');
                System.assertEquals(seg4.FieloPLT__RecordBased__c, segmentsReturned.get(i).FieloPLT__RecordBased__c, 'Field doesnt match');
            }else if(i==1){
                System.assertEquals(seg3.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg3.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Dynamic', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
                System.assertEquals(seg3.FieloPLT__OnlineProcessing__c, segmentsReturned.get(i).FieloPLT__OnlineProcessing__c, 'Field doesnt match');
                System.assertEquals(seg3.FieloPLT__RecordBased__c, segmentsReturned.get(i).FieloPLT__RecordBased__c, 'Field doesnt match');
            }
        }
    }

    @isTest
    static void getMemberSegmentsWithParameters2(){
        FieloPLT__Program__c program = new FieloPLT__Program__c(Name = 'Default',FieloPLT__OnlineTransactionProcessing__c = true);
        insert program;

        Id rtDynamicId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dynamic'].Id;
        Id rtManualId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Manual'].Id;
        List<FieloPLT__Segment__c> segments = new List<FieloPLT__Segment__c>();

        FieloPLT__Segment__c seg1 = new FieloPLT__Segment__c(Name = 'Individual Members',RecordTypeId = rtDynamicId);
        seg1.FieloPLT__IsActive__c = true;
        seg1.FieloPLT__LogicalExpression__c = 'ALL';
        seg1.FieloPLT__Program__c = program.Id;
        seg1.FieloPLT__RecordBased__c = false;
        seg1.FieloPLT__OnlineProcessing__c = true;
        segments.add(seg1);

        FieloPLT__Segment__c seg2 = new FieloPLT__Segment__c(Name = 'Opt-out Members',RecordTypeId = rtDynamicId);
        seg2.FieloPLT__IsActive__c = true;
        seg2.FieloPLT__LogicalExpression__c = 'ALL';
        seg2.FieloPLT__Program__c = program.Id;
        seg2.FieloPLT__RecordBased__c = true;
        seg2.FieloPLT__OnlineProcessing__c = false;
        segments.add(seg2);

        FieloPLT__Segment__c seg3 = new FieloPLT__Segment__c(Name = 'Manager Members',RecordTypeId = rtDynamicId);
        seg3.FieloPLT__IsActive__c = true;
        seg3.FieloPLT__LogicalExpression__c = 'ALL';
        seg3.FieloPLT__Program__c = program.Id;
        seg3.FieloPLT__RecordBased__c = false;
        seg3.FieloPLT__OnlineProcessing__c = true;
        segments.add(seg3);

        FieloPLT__Segment__c seg4 = new FieloPLT__Segment__c(Name = 'VIP Members',RecordTypeId = rtManualId);
        seg4.FieloPLT__IsActive__c = true;
        seg4.FieloPLT__Program__c = program.Id;
        segments.add(seg4);
        insert segments;

        List<FieloPLT__Criterion__c> criterions = new List<FieloPLT__Criterion__c>();
        FieloPLT__Criterion__c criteria1 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg1.Id);
        criteria1.FieloPLT__FieldName__c = 'FieloPLT__Type__c';
        criteria1.FieloPLT__FieldType__c = 'Picklist';
        criteria1.FieloPLT__Values__c = 'Individual Account';
        criteria1.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria1);
        FieloPLT__Criterion__c criteria2 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg2.Id);
        criteria2.FieloPLT__FieldName__c = 'FieloPLT__Status__c';
        criteria2.FieloPLT__FieldType__c = 'Picklist';
        criteria2.FieloPLT__Values__c = 'Opt-Out';
        criteria2.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria2);
        FieloPLT__Criterion__c criteria3 = new FieloPLT__Criterion__c(FieloPLT__Segment__c = seg3.Id);
        criteria3.FieloPLT__FieldName__c = 'FieloPLT__IsManager__c';
        criteria3.FieloPLT__FieldType__c = 'Boolean';
        criteria3.FieloPLT__BooleanValue__c = true;
        criteria3.FieloPLT__Operator__c = 'equals';
        criterions.add(criteria3);
        insert criterions;

        //Delete the job created after the insert of the segments
        for (AsyncApexJob job : [SELECT Id, ApexClassId FROM AsyncApexJob]) {
            System.abortJob(job.Id);
        }

        FieloPLT__Member__c member = new FieloPLT__Member__c(
			Name = 'member test',
			FieloPLT__Email__c = ('member test').deleteWhitespace() + Datetime.now().getTime() + '@fielo.com',
			FieloPLT__Program__c = program.Id,
			FieloPLT__Type__c = 'Individual Account',
            FieloPLT__IsManager__c = true
		);
        insert member;

        FieloPLT__MemberSegment__c ms = new FieloPLT__MemberSegment__c(FieloPLT__Member__c = member.Id, FieloPLT__Segment__c = seg4.Id);
        insert ms;


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/FieloPLT/v1/members/' + member.Id + '/segments';
        req.httpMethod = 'GET';
        req.addParameter('limit', '2');
        req.addParameter('offset', '1');
        req.addParameter('fields', 'Id,Name,RecordType.Name');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            RESTMemberSegment.getMemberSegments();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Wrong response status code');
        String result = res.responseBody.toString();
        List<FieloPLT__Segment__c> segmentsReturned = (List<FieloPLT__Segment__c>) JSON.deserialize(result,List<FieloPLT__Segment__c>.class);
        System.assertEquals(2, segmentsReturned.size(), 'Wrong segments returned size');
        for(Integer i=0; i<segmentsReturned.size(); i++){
            if(i==0){
                System.assertEquals(seg3.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg3.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Dynamic', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
            }else{
                System.assertEquals(seg4.Id, segmentsReturned.get(i).Id, 'Field doesnt match');
                System.assertEquals(seg4.Name, segmentsReturned.get(i).Name, 'Field doesnt match');
                System.assertEquals('Manual', segmentsReturned.get(i).RecordType.Name, 'Field doesnt match');
            }
            Map<String,Object> fields = segmentsReturned.get(i).getPopulatedFieldsAsMap();
            System.assert(!fields.containsKey('FieloPLT__OnlineProcessing__c'), 'Default fields should not be returned since fields parameter was used');
            System.assert(!fields.containsKey('FieloPLT__RecordBased__c'), 'Default fields should not be returned since fields parameter was used');
        }
    }
}