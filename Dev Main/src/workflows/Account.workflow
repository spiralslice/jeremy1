<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Annual_Task_box</fullName>
        <field>Made_Annual_Task__c</field>
        <literalValue>1</literalValue>
        <name>Check Annual Task box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pop_Pod_Name</fullName>
        <field>Pod_Name__c</field>
        <formula>Test_Pod__r.Name</formula>
        <name>Pop Pod Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Annual_Task</fullName>
        <field>Made_Annual_Task__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Annual Task</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>reset_last_anniversary</fullName>
        <field>Last_Anniversary__c</field>
        <formula>if(isnull(priorvalue(Next_Anniversary__c)),
    datevalue(CreatedDate) ,
   priorvalue(Next_Anniversary__c) )</formula>
        <name>reset last anniversary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_next_anniversary</fullName>
        <field>Next_Anniversary__c</field>
        <formula>if(isnull(priorvalue(Next_Anniversary__c)),
    datevalue(CreatedDate) + 365,
   priorvalue(Next_Anniversary__c) + 365)</formula>
        <name>update next anniversary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Copy Pod Name</fullName>
        <actions>
            <name>Pop_Pod_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Test recursive tasks</fullName>
        <actions>
            <name>reset_last_anniversary</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_next_anniversary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>! Made_Annual_Task__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Annual_Task</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Test_Anniversary_Task</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Account.Next_Anniversary__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Annual_Task</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.Next_Anniversary__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Annual_Task</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.LastModifiedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Test_Anniversary_Task</fullName>
        <assignedToType>owner</assignedToType>
        <description>test</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Account.Next_Anniversary__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Test Anniversary Task</subject>
    </tasks>
</Workflow>
