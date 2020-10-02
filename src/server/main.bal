import ballerina/http;
import ballerina/log;
import ballerina/io;

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
        path: "/send-photo/original/{imageName}/{extension}"        
    }
    resource function sendPhotoOriginal(http:Caller caller, http:Request req, string imageName, string extension) {
        savePhoto(caller, req, "/var/www/html/original/", imageName + "." + extension);
    }

        @http:ResourceConfig {
        methods: ["POST"],
        path: "/send-photo/processed/{imageName}/{extension}"        
    }
    resource function sendPhotoProcessed(http:Caller caller, http:Request req, string imageName, string extension) {
        savePhoto(caller, req, "/var/www/html/processed/", imageName + "." + extension);
    }
}

function savePhoto(http:Caller caller, http:Request req, string path, string image) {
        http:Response res = new;
        string imagePath = path + image;

        byte[]|error requestBinaryContent = req.getBinaryPayload();
        if (requestBinaryContent is byte[]) {
            if !(writeToImage(<byte[]> requestBinaryContent, <@untainted>imagePath)) {
                res.statusCode = 500;
                log:printError(ERROR_IN_WRITING);
            }
        } else {
            res.statusCode = 500;
            log:printError(ERROR_INVALID_FORMAT);
        }

        respondClient(caller, res);
}

function respondClient(http:Caller caller, http:Response res) {
    var result = caller->respond(res);
    if (result is error) {
        io:print(result);
    }       
}
