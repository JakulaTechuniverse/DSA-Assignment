import ballerina/http;
import ballerina/time;

listener http:Listener httpListener = new (8080);

type Programme record {|
    readonly string id;
    string name;
    int duration_years;
    string[] courses;
    time:Date start_date;
|};

table<Programme> key(id) programmeTable = table [];

service /programme on httpListener {

    resource function get all() returns Programme[] {
        return programmeTable.toArray();
    }

    resource function post add(@http:Payload Programme programme) returns Programme|error {
        error? result = programmeTable.add(programme);
        if result is error {
            return error("Failed to add programme");
        }
        return programme;
    }

    resource function put update/[string id](@http:Payload Programme programme) returns Programme|error {
        Programme? existingProgramme = programmeTable[id];
        if existingProgramme is () {
            return error("Programme not found");
        }
        _ = programmeTable.put(programme);
        return programme;
    }
    resource function get [string id]() returns Programme|error {
        Programme? programme = programmeTable[id];
        if programme is () {
            return error("Programme not found");
        }
        return programme;
    }

    resource function delete remove/[string id]() returns string|error {
        Programme? programme = programmeTable.remove(id);
        if programme is () {
            return error("Programme not found");
        }
        return string `Programme ${programme.name} removed successfully`;
    }

    resource function get byDuration/[int duration_years]() returns Programme[] {
        return from Programme programme in programmeTable
               where programme.duration_years == duration_years
               select programme;
    }
}
