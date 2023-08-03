@RestResource(urlMapping='/v1/members/*/segments')
global with sharing class RESTMemberSegment {
    @HttpGet
    global static void getMemberSegments() {
        String requestUri = RestContext.request.requestUri;
        String memberId = requestUri.substring( requestUri.indexOf('/members/')  , requestUri.indexOf('/segments') );
        memberId = memberId.replace('/members/', '');

        String fieldset = RestContext.request.params.get('fields');
        Set<String> fields = new Set<String>();
        for(String s : fieldset != null ? fieldset.split(',') : new List<String>{'Id', 'Name','RecordType.Name', 'FieloPLT__OnlineProcessing__c','FieloPLT__RecordBased__c'}){
            fields.add(s);
        }

        String quant = RestContext.request.params.get('limit');
        Integer quantity = String.isNotBlank(quant) ? Integer.valueOf(quant) : 20;

        String off = RestContext.request.params.get('offset');
        Integer offset = String.isNotBlank(off) ? Integer.valueOf(off) : 0;

        String order = RestContext.request.params.get('orderby');
        String orderBy = String.isNotBlank(order)  ? order :'CreatedDate ASC';

        RestAPIResponse response = new RestAPIResponse();
        RestResponse resp = RestContext.response;
        resp.addHeader('Accept', 'application/json');
        resp.addHeader('Content-Type', 'application/json');

        Set<Id> segmentIds = FieloPLT.SegmentService.getMemberSegments(memberId, null);
        if( !segmentIds.isEmpty() ){
            String query = 'SELECT ' + String.join(new List<String>(fields), ',') + ' FROM FieloPLT__Segment__c WHERE Id IN: segmentIds ';
            if( String.isNotBlank(orderBy) ){
                query += ' ORDER BY ' + orderBy;
            }
            if(quantity != null){
                query += ' LIMIT ' + quantity;

                if(offset != null){
                    query += ' OFFSET ' + offset;
                }
            }
            List<FieloPLT__Segment__c> segments = (List<FieloPLT__Segment__c>) Database.query(query);
            resp.responseBody = Blob.valueOf( JSON.serialize(segments) );
            resp.statusCode = 200;
            response.message = 'SUCESS';
        } else {
            resp.statusCode = 404;
            response.errorcode = 'RECORD_NOT_FOUND';
            response.message = 'Record not found';
            resp.responseBody = Blob.valueOf( JSON.serialize(new List<RestAPIResponse>{response}) );
        }
    }
}