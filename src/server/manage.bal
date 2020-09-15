import ballerina/io;
import ballerina/log;

public function populateTables() returns boolean {
    return createTables();
}

public function writeToImage(byte[] byteStream, string imageName) returns boolean {
    error? e = writeImage(imageName, <byte[]> byteStream);
    if e is error {
        log:printError(ERROR_IN_WRITING);
        return false;
    } else {
        log:printInfo("New result written: " + imageName);
        return true;
    }
}

function writeImage(string path, byte[] content) returns @tainted error? {
    io:WritableByteChannel wbc = check io:openWritableFile(path);
    _ = check wbc.write(content, 0); // TODO: replace check to ensure channels are closed
    check wbc.close();
}

public function getLoginInfo(json droneUserInfo) returns json {
    record {}|boolean userInfo = getUserInfo(droneUserInfo.userID.toString(), droneUserInfo.password.toString());

    io:println(userInfo);
    json responseJson = {};
    if (userInfo is boolean) {
        responseJson = {
            "success" : false
        };
    } else {
        json j = {
            userID : userInfo["userID"].toString()
        };

        responseJson = {
            "success" : true,
            "result" : j
        };  
    }
    
    return responseJson;
}