import ballerina/http;
import ballerina/io;
import ballerina/time;

final http:Client programmeClient = check new ("http://localhost:8080");

type Programme record {|
    string id;
    string name;
    int duration_years;
    string[] courses;
    time:Utc start_date;
|};

public function main() returns error? {
    while true {
        printMenu();
        string choice = io:readln();

        match choice {
            "1" => { check getAllProgrammes(); }
            "2" => { check addProgramme(); }
            "3" => { check updateProgramme(); }
            "4" => { check getProgrammeById(); }
            "5" => { check deleteProgramme(); }
            "6" => { check getProgrammesByDuration(); }
            "0" => { 
                io:println("Exiting...");
                break;
            }
            _ => { io:println("Invalid choice. Try again."); }
        }
    }
}

function printMenu() {
    io:println("\n╔════ Programme Management System ════╗");
    io:println("║ 1. List all programmes              ║");
    io:println("║ 2. Add a new programme              ║");
    io:println("║ 3. Update a programme               ║");
    io:println("║ 4. Get a programme by ID            ║");
    io:println("║ 5. Delete a programme               ║");
    io:println("║ 6. Get programmes by duration       ║");
    io:println("║ 0. Exit                             ║");
    io:println("╚═════════════════════════════════════╝");
    io:print("Enter your choice: ");
}

function getAllProgrammes() returns error? {
    io:println("\n╭──── All Programmes ────╮");
    Programme[] programmes = check programmeClient->/programme/all;
    if programmes.length() == 0 {
        io:println("│ No programmes found.   │");
    } else {
        foreach var programme in programmes {
            printProgramme(programme);
        }
    }
    io:println("╰───────────────────────╯");
}

function addProgramme() returns error? {
    io:println("\n╭──── Add New Programme ────╮");
    Programme newProgramme = {
        id: io:readln("│ Enter programme ID: "),
        name: io:readln("│ Enter name: "),
        duration_years: check int:fromString(io:readln("│ Enter duration in years: ")),
        courses: [],
        start_date: time:utcNow() // Changed to use time:Utc
    };
    Programme|error result = programmeClient->/programme/add.post(newProgramme);
    if result is Programme {
        io:println("│ Programme added successfully. │");
    } else {
        io:println("│ Failed to add programme.      │");
    }
    io:println("╰─────────────────────────────╯");
}

function updateProgramme() returns error? {
    io:println("\n╭──── Update Programme ────╮");
    string id = io:readln("│ Enter programme ID to update: ");
    Programme updatedProgramme = {
        id: id,
        name: io:readln("│ Enter new name: "),
        duration_years: check int:fromString(io:readln("│ Enter new duration in years: ")),
        courses: [],
        start_date: time:utcNow() // Changed to use time:Utc
    };
    Programme|error result = programmeClient->/programme/update/[id].put(updatedProgramme);
    if result is Programme {
        io:println("│ Programme updated successfully. │");
    } else {
        io:println("│ Failed to update programme.     │");
    }
    io:println("╰────────────────────────────╯");
}

function getProgrammeById() returns error? {
    io:println("\n╭──── Get Programme by ID ────╮");
    string id = io:readln("│ Enter programme ID: ");
    Programme|error result = programmeClient->/programme/[id];
    if result is Programme {
        printProgramme(result);
    } else {
        io:println("│ Programme not found.         │");
    }
    io:println("╰─────────────────────────────╯");
}

function deleteProgramme() returns error? {
    io:println("\n╭──── Delete Programme ────╮");
    string id = io:readln("│ Enter programme ID to delete: ");
    string|error result = programmeClient->/programme/remove/[id].delete;
    if result is string {
        io:println("│ ", result, " │");
    } else {
        io:println("│ Failed to delete programme.   │");
    }
    io:println("╰────────────────────────────╯");
}

function getProgrammesByDuration() returns error? {
    io:println("\n╭──── Get Programmes by Duration ────╮");
    int duration_years = check int:fromString(io:readln("│ Enter duration in years: "));
    Programme[] programmes = check programmeClient->/programme/byDuration/[duration_years];
    if programmes.length() == 0 {
        io:println("│ No programmes found for this duration. │");
    } else {
        foreach var programme in programmes {
            printProgramme(programme);
        }
    }
    io:println("╰────────────────────────────╯");
}

function printProgramme(Programme programme) {
    io:println("│ ID: ", programme.id);
    io:println("│ Name: ", programme.name);
    io:println("│ Duration (years): ", programme.duration_years);
    io:println("│ Courses: ", programme.courses);
    io:println("│ Start Date: ", programme.start_date.toString()); // Adjusted for time:Utc
    io:println("│");
}
