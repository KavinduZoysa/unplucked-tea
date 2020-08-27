import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/mime;

@http:ServiceConfig {
    basePath: "/tea-monitor",
    cors: {
        allowOrigins: ["*"]
    }
}
service quarantineMonitor on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/send-photo"
    }
    resource function logIn(http:Caller caller, http:Request req) {
        http:Response res = new;

        var bodyParts = req.getBodyParts();
        io:print(bodyParts);

        if (bodyParts is mime:Entity[]) {
            foreach var part in bodyParts {
                handleContent(part);
            }
        }
        respondClient(caller, res);
    }

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
}

function handleContent(mime:Entity bodyPart) {
    var mediaType = mime:getMediaType(bodyPart.getContentType());
    if (mediaType is mime:MediaType) {
        string baseType = mediaType.getBaseType();
        io:print(baseType);
        if (mime:IMAGE_PNG == baseType) {
            io:ReadableByteChannel srcCh = <io:ReadableByteChannel> bodyPart.getByteChannel();
            string dstPath = "./files/ballerinaCopy.png";

            io:WritableByteChannel dstCh = <io:WritableByteChannel> io:openWritableFile(dstPath);

            var result = copy(srcCh, dstCh);
            if (result is error) {
                log:printError("error occurred while performing copy ", result);
            } else {
                io:println("File copy completed. The copied file is located at " +
                            dstPath);
            }

            close(srcCh);
            close(dstCh);          
        } else if (mime:APPLICATION_JSON == baseType) {

            var payload = bodyPart.getJson();
            if (payload is json) {
                log:printInfo(payload.toJsonString());
            } 
        } else if (mime:TEXT_PLAIN == baseType) {

            var payload = bodyPart.getText();
            if (payload is string) {
                log:printInfo(payload);
            }
        }
    }
}

function copy(io:ReadableByteChannel src,
              io:WritableByteChannel dst) returns error? {

    while (true) {

        byte[]|io:Error result = src.read(1000);
        if (result is io:EofError) {
            break;
        } else {
            int i = 0;
            byte[] r = <byte[]>result;
            while (i < r.length()) {
                var result2 = dst.write(r, i);
                if (result2 is error) {
                    return result2;
                } else {
                    i = i + result2;
                }
            }
        }
    }
    return;
}

function close(io:ReadableByteChannel|io:WritableByteChannel ch) {
    abstract object {
        public function close() returns error?;
    } channelResult = ch;
    var cr = channelResult.close();
    if (cr is error) {
        log:printError("Error occurred while closing the channel: ", cr);
    }
}

public function respondClient(http:Caller caller, http:Response res) {
    var result = caller->respond(res);
    if (result is error) {
        io:print(result);
    }       
}
