import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/mime;

int index = 0;
@http:ServiceConfig {
    basePath: "/tea-monitor",
    cors: {
        allowOrigins: ["*"]
    }
}
service quarantineMonitor on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/health-check"
    }
    resource function healthCheck(http:Caller caller, http:Request req) {
        http:Response res = new;

        json responseJson = {
            "server": true
        };
        res.setJsonPayload(<@untainted>responseJson);

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/populate-tables"
    }
    resource function populateTables(http:Caller caller, http:Request req) {
        
        http:Response res = new;
        if (!populateTables()) {
            res.statusCode = 500;
            res.setPayload("Cannot create tables");
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/login"
    }
    resource function logIn(http:Caller caller, http:Request req) {
        http:Response res = new;

        var payload = req.getJsonPayload();

        if (payload is json) {            
            res.setJsonPayload(<@untainted>getLoginInfo(<@untainted>payload));
        } else {
            res.statusCode = 500;
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/send-photo"        
    }
    resource function sendPhoto(http:Caller caller, http:Request req) {
        http:Response res = new;
        string image = "image_" + index.toString();

        byte[]|error requestBinaryContent = req.getBinaryPayload();
        if (requestBinaryContent is byte[]) {
            if !(writeToImage(<byte[]> requestBinaryContent, image)) {
                res.statusCode = 500;
                log:printError(ERROR_IN_WRITING);
            }
            index = index + 1;
        } else {
            res.statusCode = 500;
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
    }
}

public function respondClient(http:Caller caller, http:Response res) {
    var result = caller->respond(res);
    if (result is error) {
        io:print(result);
    }       
}
