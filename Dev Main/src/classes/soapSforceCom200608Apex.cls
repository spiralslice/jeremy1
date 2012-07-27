//Generated by wsdl2apex

public class soapSforceCom200608Apex {
    public class Apex {
        public String endpoint_x = 'https://na7-api.salesforce.com/services/Soap/s/25.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public soapSforceCom200608Apex.AllowFieldTruncationHeader_element AllowFieldTruncationHeader;
        public soapSforceCom200608Apex.PackageVersionHeader_element PackageVersionHeader;
        public soapSforceCom200608Apex.SessionHeader_element SessionHeader;
        public soapSforceCom200608Apex.DebuggingInfo_element DebuggingInfo;
        public soapSforceCom200608Apex.CallOptions_element CallOptions;
        public soapSforceCom200608Apex.DisableFeedTrackingHeader_element DisableFeedTrackingHeader;
        public soapSforceCom200608Apex.DebuggingHeader_element DebuggingHeader;
        private String AllowFieldTruncationHeader_hns = 'AllowFieldTruncationHeader=http://soap.sforce.com/2006/08/apex';
        private String PackageVersionHeader_hns = 'PackageVersionHeader=http://soap.sforce.com/2006/08/apex';
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/08/apex';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/08/apex';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/08/apex';
        private String DisableFeedTrackingHeader_hns = 'DisableFeedTrackingHeader=http://soap.sforce.com/2006/08/apex';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/08/apex';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/08/apex', 'soapSforceCom200608Apex'};
        public soapSforceCom200608Apex.WsdlToApexResult wsdlToApex(soapSforceCom200608Apex.WsdlToApexInfo info) {
            soapSforceCom200608Apex.wsdlToApex_element request_x = new soapSforceCom200608Apex.wsdlToApex_element();
            soapSforceCom200608Apex.wsdlToApexResponse_element response_x;
            request_x.info = info;
            Map<String, soapSforceCom200608Apex.wsdlToApexResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.wsdlToApexResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/08/apex',
              'wsdlToApex',
              'http://soap.sforce.com/2006/08/apex',
              'wsdlToApexResponse',
              'soapSforceCom200608Apex.wsdlToApexResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public soapSforceCom200608Apex.RunTestsResult runTests(soapSforceCom200608Apex.RunTestsRequest RunTestsRequest) {
            soapSforceCom200608Apex.runTests_element request_x = new soapSforceCom200608Apex.runTests_element();
            soapSforceCom200608Apex.runTestsResponse_element response_x;
            request_x.RunTestsRequest = RunTestsRequest;
            Map<String, soapSforceCom200608Apex.runTestsResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.runTestsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/08/apex',
              'runTests',
              'http://soap.sforce.com/2006/08/apex',
              'runTestsResponse',
              'soapSforceCom200608Apex.runTestsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public soapSforceCom200608Apex.CompileClassResult[] compileClasses(String[] scripts) {
            soapSforceCom200608Apex.compileClasses_element request_x = new soapSforceCom200608Apex.compileClasses_element();
            soapSforceCom200608Apex.compileClassesResponse_element response_x;
            request_x.scripts = scripts;
            Map<String, soapSforceCom200608Apex.compileClassesResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.compileClassesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/08/apex',
              'compileClasses',
              'http://soap.sforce.com/2006/08/apex',
              'compileClassesResponse',
              'soapSforceCom200608Apex.compileClassesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public soapSforceCom200608Apex.CompileAndTestResult compileAndTest(soapSforceCom200608Apex.CompileAndTestRequest CompileAndTestRequest) {
            soapSforceCom200608Apex.compileAndTest_element request_x = new soapSforceCom200608Apex.compileAndTest_element();
            soapSforceCom200608Apex.compileAndTestResponse_element response_x;
            request_x.CompileAndTestRequest = CompileAndTestRequest;
            Map<String, soapSforceCom200608Apex.compileAndTestResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.compileAndTestResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/08/apex',
              'compileAndTest',
              'http://soap.sforce.com/2006/08/apex',
              'compileAndTestResponse',
              'soapSforceCom200608Apex.compileAndTestResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public soapSforceCom200608Apex.ExecuteAnonymousResult executeAnonymous(String String_x) {
            soapSforceCom200608Apex.executeAnonymous_element request_x = new soapSforceCom200608Apex.executeAnonymous_element();
            soapSforceCom200608Apex.executeAnonymousResponse_element response_x;
            request_x.String_x = String_x;
            Map<String, soapSforceCom200608Apex.executeAnonymousResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.executeAnonymousResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/08/apex',
              'executeAnonymous',
              'http://soap.sforce.com/2006/08/apex',
              'executeAnonymousResponse',
              'soapSforceCom200608Apex.executeAnonymousResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public soapSforceCom200608Apex.CompileTriggerResult[] compileTriggers(String[] scripts) {
            soapSforceCom200608Apex.compileTriggers_element request_x = new soapSforceCom200608Apex.compileTriggers_element();
            soapSforceCom200608Apex.compileTriggersResponse_element response_x;
            request_x.scripts = scripts;
            Map<String, soapSforceCom200608Apex.compileTriggersResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.compileTriggersResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/08/apex',
              'compileTriggers',
              'http://soap.sforce.com/2006/08/apex',
              'compileTriggersResponse',
              'soapSforceCom200608Apex.compileTriggersResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    public class NamespacePackagePair {
        public String namespace;
        public String packageName;
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] packageName_type_info = new String[]{'packageName','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'namespace','packageName'};
    }
    public class CodeLocation {
        public Integer column;
        public Integer line;
        public Integer numExecutions;
        public Double time_x;
        private String[] column_type_info = new String[]{'column','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] line_type_info = new String[]{'line','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] numExecutions_type_info = new String[]{'numExecutions','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] time_x_type_info = new String[]{'time','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'column','line','numExecutions','time_x'};
    }
    public class CodeCoverageWarning {
        public String id;
        public String message;
        public String name;
        public String namespace;
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','false'};
        private String[] message_type_info = new String[]{'message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'id','message','name','namespace'};
    }
    public class RunTestFailure {
        public String id;
        public String message;
        public String methodName;
        public String name;
        public String namespace;
        public String stackTrace;
        public Double time_x;
        public String type_x;
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','false'};
        private String[] message_type_info = new String[]{'message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] methodName_type_info = new String[]{'methodName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] stackTrace_type_info = new String[]{'stackTrace','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] time_x_type_info = new String[]{'time','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] type_x_type_info = new String[]{'type','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'id','message','methodName','name','namespace','stackTrace','time_x','type_x'};
    }
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    public class runTests_element {
        public soapSforceCom200608Apex.RunTestsRequest RunTestsRequest;
        private String[] RunTestsRequest_type_info = new String[]{'RunTestsRequest','http://soap.sforce.com/2006/08/apex','RunTestsRequest','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'RunTestsRequest'};
    }
    public class CompileClassResult {
        public Integer bodyCrc;
        public Integer column;
        public String id;
        public Integer line;
        public String name;
        public String problem;
        public Boolean success;
        public String[] warnings;
        private String[] bodyCrc_type_info = new String[]{'bodyCrc','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] column_type_info = new String[]{'column','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','true'};
        private String[] line_type_info = new String[]{'line','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] problem_type_info = new String[]{'problem','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] success_type_info = new String[]{'success','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] warnings_type_info = new String[]{'warnings','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'bodyCrc','column','id','line','name','problem','success','warnings'};
    }
    public class compileClassesResponse_element {
        public soapSforceCom200608Apex.CompileClassResult[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','CompileClassResult','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
    public class compileClasses_element {
        public String[] scripts;
        private String[] scripts_type_info = new String[]{'scripts','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'scripts'};
    }
    public class wsdlToApexResponse_element {
        public soapSforceCom200608Apex.WsdlToApexResult result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','WsdlToApexResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class RunTestSuccess {
        public String id;
        public String methodName;
        public String name;
        public String namespace;
        public Double time_x;
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','false'};
        private String[] methodName_type_info = new String[]{'methodName','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] time_x_type_info = new String[]{'time','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'id','methodName','name','namespace','time_x'};
    }
    public class CodeCoverageResult {
        public String id;
        public soapSforceCom200608Apex.CodeLocation[] locationsNotCovered;
        public String name;
        public String namespace;
        public Integer numLocations;
        public Integer numLocationsNotCovered;
        public String type_x;
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','false'};
        private String[] locationsNotCovered_type_info = new String[]{'locationsNotCovered','http://soap.sforce.com/2006/08/apex','CodeLocation','0','-1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] numLocations_type_info = new String[]{'numLocations','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] numLocationsNotCovered_type_info = new String[]{'numLocationsNotCovered','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] type_x_type_info = new String[]{'type','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'id','locationsNotCovered','name','namespace','numLocations','numLocationsNotCovered','type_x'};
    }
    public class executeAnonymous_element {
        public String String_x;
        private String[] String_x_type_info = new String[]{'String','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'String_x'};
    }
    public class RunTestsRequest {
        public Boolean allTests;
        public String[] classes;
        public String namespace;
        public String[] packages;
        private String[] allTests_type_info = new String[]{'allTests','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] classes_type_info = new String[]{'classes','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] packages_type_info = new String[]{'packages','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'allTests','classes','namespace','packages'};
    }
    public class CompileAndTestRequest {
        public Boolean checkOnly;
        public String[] classes;
        public String[] deleteClasses;
        public String[] deleteTriggers;
        public soapSforceCom200608Apex.RunTestsRequest runTestsRequest;
        public String[] triggers;
        private String[] checkOnly_type_info = new String[]{'checkOnly','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] classes_type_info = new String[]{'classes','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] deleteClasses_type_info = new String[]{'deleteClasses','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] deleteTriggers_type_info = new String[]{'deleteTriggers','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] runTestsRequest_type_info = new String[]{'runTestsRequest','http://soap.sforce.com/2006/08/apex','RunTestsRequest','0','1','false'};
        private String[] triggers_type_info = new String[]{'triggers','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'checkOnly','classes','deleteClasses','deleteTriggers','runTestsRequest','triggers'};
    }
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    public class CompileAndTestResult {
        public soapSforceCom200608Apex.CompileClassResult[] classes;
        public soapSforceCom200608Apex.DeleteApexResult[] deleteClasses;
        public soapSforceCom200608Apex.DeleteApexResult[] deleteTriggers;
        public soapSforceCom200608Apex.RunTestsResult runTestsResult;
        public Boolean success;
        public soapSforceCom200608Apex.CompileTriggerResult[] triggers;
        private String[] classes_type_info = new String[]{'classes','http://soap.sforce.com/2006/08/apex','CompileClassResult','0','-1','false'};
        private String[] deleteClasses_type_info = new String[]{'deleteClasses','http://soap.sforce.com/2006/08/apex','DeleteApexResult','0','-1','false'};
        private String[] deleteTriggers_type_info = new String[]{'deleteTriggers','http://soap.sforce.com/2006/08/apex','DeleteApexResult','0','-1','false'};
        private String[] runTestsResult_type_info = new String[]{'runTestsResult','http://soap.sforce.com/2006/08/apex','RunTestsResult','1','1','false'};
        private String[] success_type_info = new String[]{'success','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] triggers_type_info = new String[]{'triggers','http://soap.sforce.com/2006/08/apex','CompileTriggerResult','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'classes','deleteClasses','deleteTriggers','runTestsResult','success','triggers'};
    }
    public class WsdlToApexResult {
        public String[] apexScripts;
        public String[] errors;
        public Boolean success;
        private String[] apexScripts_type_info = new String[]{'apexScripts','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] errors_type_info = new String[]{'errors','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] success_type_info = new String[]{'success','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'apexScripts','errors','success'};
    }
    public class compileTriggersResponse_element {
        public soapSforceCom200608Apex.CompileTriggerResult[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','CompileTriggerResult','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class CompileTriggerResult {
        public Integer bodyCrc;
        public Integer column;
        public String id;
        public Integer line;
        public String name;
        public String problem;
        public Boolean success;
        private String[] bodyCrc_type_info = new String[]{'bodyCrc','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] column_type_info = new String[]{'column','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','true'};
        private String[] line_type_info = new String[]{'line','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] problem_type_info = new String[]{'problem','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] success_type_info = new String[]{'success','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'bodyCrc','column','id','line','name','problem','success'};
    }
    public class AllowFieldTruncationHeader_element {
        public Boolean allowFieldTruncation;
        private String[] allowFieldTruncation_type_info = new String[]{'allowFieldTruncation','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'allowFieldTruncation'};
    }
    public class PackageVersion {
        public Integer majorNumber;
        public Integer minorNumber;
        public String namespace;
        private String[] majorNumber_type_info = new String[]{'majorNumber','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] minorNumber_type_info = new String[]{'minorNumber','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'majorNumber','minorNumber','namespace'};
    }
    public class DeleteApexResult {
        public String id;
        public String problem;
        public Boolean success;
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/08/apex','ID','1','1','true'};
        private String[] problem_type_info = new String[]{'problem','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] success_type_info = new String[]{'success','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'id','problem','success'};
    }
    public class ExecuteAnonymousResult {
        public Integer column;
        public String compileProblem;
        public Boolean compiled;
        public String exceptionMessage;
        public String exceptionStackTrace;
        public Integer line;
        public Boolean success;
        private String[] column_type_info = new String[]{'column','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] compileProblem_type_info = new String[]{'compileProblem','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] compiled_type_info = new String[]{'compiled','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] exceptionMessage_type_info = new String[]{'exceptionMessage','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] exceptionStackTrace_type_info = new String[]{'exceptionStackTrace','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] line_type_info = new String[]{'line','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] success_type_info = new String[]{'success','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'column','compileProblem','compiled','exceptionMessage','exceptionStackTrace','line','success'};
    }
    public class compileAndTest_element {
        public soapSforceCom200608Apex.CompileAndTestRequest CompileAndTestRequest;
        private String[] CompileAndTestRequest_type_info = new String[]{'CompileAndTestRequest','http://soap.sforce.com/2006/08/apex','CompileAndTestRequest','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'CompileAndTestRequest'};
    }
    public class wsdlToApex_element {
        public soapSforceCom200608Apex.WsdlToApexInfo info;
        private String[] info_type_info = new String[]{'info','http://soap.sforce.com/2006/08/apex','WsdlToApexInfo','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'info'};
    }
    public class DisableFeedTrackingHeader_element {
        public Boolean disableFeedTracking;
        private String[] disableFeedTracking_type_info = new String[]{'disableFeedTracking','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'disableFeedTracking'};
    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category','http://soap.sforce.com/2006/08/apex','LogCategory','1','1','false'};
        private String[] level_type_info = new String[]{'level','http://soap.sforce.com/2006/08/apex','LogCategoryLevel','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    public class compileTriggers_element {
        public String[] scripts;
        private String[] scripts_type_info = new String[]{'scripts','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'scripts'};
    }
    public class DebuggingHeader_element {
        public soapSforceCom200608Apex.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories','http://soap.sforce.com/2006/08/apex','LogInfo','0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel','http://soap.sforce.com/2006/08/apex','LogType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    public class executeAnonymousResponse_element {
        public soapSforceCom200608Apex.ExecuteAnonymousResult result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','ExecuteAnonymousResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class RunTestsResult {
        public soapSforceCom200608Apex.CodeCoverageResult[] codeCoverage;
        public soapSforceCom200608Apex.CodeCoverageWarning[] codeCoverageWarnings;
        public soapSforceCom200608Apex.RunTestFailure[] failures;
        public Integer numFailures;
        public Integer numTestsRun;
        public soapSforceCom200608Apex.RunTestSuccess[] successes;
        public Double totalTime;
        private String[] codeCoverage_type_info = new String[]{'codeCoverage','http://soap.sforce.com/2006/08/apex','CodeCoverageResult','0','-1','false'};
        private String[] codeCoverageWarnings_type_info = new String[]{'codeCoverageWarnings','http://soap.sforce.com/2006/08/apex','CodeCoverageWarning','0','-1','false'};
        private String[] failures_type_info = new String[]{'failures','http://soap.sforce.com/2006/08/apex','RunTestFailure','0','-1','false'};
        private String[] numFailures_type_info = new String[]{'numFailures','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] numTestsRun_type_info = new String[]{'numTestsRun','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] successes_type_info = new String[]{'successes','http://soap.sforce.com/2006/08/apex','RunTestSuccess','0','-1','false'};
        private String[] totalTime_type_info = new String[]{'totalTime','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'codeCoverage','codeCoverageWarnings','failures','numFailures','numTestsRun','successes','totalTime'};
    }
    public class PackageVersionHeader_element {
        public soapSforceCom200608Apex.PackageVersion[] packageVersions;
        private String[] packageVersions_type_info = new String[]{'packageVersions','http://soap.sforce.com/2006/08/apex','PackageVersion','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'packageVersions'};
    }
    public class runTestsResponse_element {
        public soapSforceCom200608Apex.RunTestsResult result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','RunTestsResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class compileAndTestResponse_element {
        public soapSforceCom200608Apex.CompileAndTestResult result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','CompileAndTestResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class WsdlToApexInfo {
        public soapSforceCom200608Apex.NamespacePackagePair[] mapping;
        public String wsdl;
        private String[] mapping_type_info = new String[]{'mapping','http://soap.sforce.com/2006/08/apex','NamespacePackagePair','0','-1','false'};
        private String[] wsdl_type_info = new String[]{'wsdl','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'mapping','wsdl'};
    }
}