import ballerina/mysql;
import ballerina/sql;
import ballerina/io;

string dbUser = "root";
string dbPassword = "root";
string db = "tea_monitor";
mysql:Client mysqlClient = initializeClients();

function initializeClients() returns mysql:Client {
    mysql:Client|sql:Error tempClient = new ("localhost", dbUser, dbPassword, db);
    if (tempClient is sql:Error) {
        io:println("Error when initializing the MySQL client ", tempClient);
    } else {
        io:println("Simple MySQL client created successfully");
        // check tempClient.close();
    }
    return <mysql:Client>tempClient;
}

public function createTables() returns boolean {
    sql:ExecutionResult|sql:Error result = mysqlClient->execute(CREATE_USER_INFO_TABLE);
    if (result is sql:Error) {
        return false;
    }

    return true;
}

type LoginInfo record {|
    string userID;
|};

public function getUserInfo(string userID, string password) returns @tainted record {}|boolean {
    sql:ParameterizedQuery SELECT_USER_INFO = `SELECT userID as userID FROM users_info WHERE userID = ${userID} AND password = ${password}`;
    stream<record{}, error> resultStream = mysqlClient->query(SELECT_USER_INFO);

    record {|record {} value;|}|error? result = resultStream.next();
    if (result is record {|record {} value;|}) {
        record {} r = result.value;
        return result.value;
    } 
    return false;
}