package utils {
import Shared.AS3.ExtendedSocket;

import com.adobe.serialization.json.JSONEncoder;

import flash.events.Event;
import flash.utils.ByteArray;

public class HttpClient {

    protected var sfCodeObj:Object;
    protected var host:String;
    protected var port:uint;
    protected var socket:ExtendedSocket;
    protected var jobs:Array = [];
    protected var nextCallback:Function;

    public function HttpClient(sfCodeObj:Object, host:String, port:uint) {
        this.sfCodeObj = sfCodeObj;
        this.host = host;
        this.port = port;
    }

    public function post(path:String, data:Object, handler:Function = undefined):void {

        Logger.get().debug("adding new job");
        jobs.push({path: path, data: data, callback: handler});

        if (socket == null) {
            Logger.get().debug("connecting to server");
            socket = new ExtendedSocket(sfCodeObj);
            socket.addEventListener("ExtendedSocket::CONNECT", connectHandler);
            socket.addEventListener("ExtendedSocket::SocketData", socketDataHandler);
            // parameters don't matter, host and port are hardcoded in dxgi.dll
            socket.connect(host, port.toString());
        }
        if (!nextCallback) {
            nextJob();
        }
    }

    function connectHandler(param1:Event) : void {
        nextJob();
    }

    function socketDataHandler(param1:Event) : void {
        var responseText:String = readUTFStringFromSocket();
        Logger.get().trace("rcv:");
        var responseLines:Array = responseText.split("\r\n");
        var curLineNum:int = 0;
        var headers:Array = [];
        var headersDone:Boolean = false;
        var body:String = "";
        var code:int = 0;
        var length:int = 0;
        var chunked:Boolean = false;
        var lengthRead:Boolean = false;
        var lengthValue:String = "";
        while (curLineNum < responseLines.length) {
            var curLine:String = responseLines[curLineNum];
            Logger.get().trace(curLine);
            if (curLine.length == 0) {
                headersDone = true;
            } else if (!headersDone) {
                if (curLine.indexOf("HTTP/") == 0) {
                    code = parseInt(curLine.split(" ")[1]);
                } else if (curLine.indexOf("Content-Length:") == 0) {
                    length = parseInt(curLine.split(": ")[1]);
                } else if (curLine.indexOf("Transfer-Encoding: chunked") == 0) {
                    Logger.get().trace("chunked body");
                    chunked = true;
                }
                headers.push(curLine);
            } else {
                if (chunked) {
                    // TODO handle chunks properly
                    if (lengthRead) {
                        body += curLine;
                        lengthRead = false;
                        Logger.get().trace("read chunk {0}", lengthValue);
                    } else {
                        lengthValue = curLine;
                        lengthRead = true;
                        Logger.get().trace("next chunk {0}", lengthValue);
                    }
                } else {
                    body += curLine;
                }
            }
            curLineNum++;
        }
        Logger.get().debug("Response: {0}, Length: {1}, Body: {2}", code, length, body);
        if (nextCallback) {
            nextCallback(code, body);
            nextCallback = undefined;
        }
        nextJob();
    }

    private function nextJob():void {
        if (jobs.length == 0) {
            return;
        }
        var job:Object = jobs.shift();
        nextCallback = job.callback;

        var body = new JSONEncoder(job.data).getString();
        var b:ByteArray = new ByteArray();
        b.writeUTFBytes(body);
        var bodyLength = b.length;
        Logger.get().debug("posting {0} bytes to {1}", bodyLength, job.path);

        socket.writeUTFBytes("POST " + job.path + " HTTP/1.1\n" +
                "Content-Type: application/json\n" +
                "User-Agent: InventOmatic/" + Version.VERSION + "\n" +
                "Accept: */*\n" +
                "Cache-Control: no-cache\n" +
                "Host: " + host + ":" + port + "\n" +
                "Accept-Encoding: gzip, deflate, br\n" +
                "Connection: keep-alive\n" +
                "Keep-Alive: timeout=60\n" +
                "Content-Length: " + bodyLength + "\n" +
                "\n" + body);
    }

    private function readUTFStringFromSocket():String {
        var rcvByte:* = undefined;
        var responseText:String = "";
        while (this.socket.bytesAvailable > 0) {
            // TODO check this section, I have no idea how it parses the code points
            if ((rcvByte = this.socket.readByte()) < 0 && rcvByte != -62) {
                rcvByte = parseInt(this.toTwosComplement(rcvByte, 1, 2000));
            } else if (rcvByte == -62) {
                continue;
            }
            responseText += String.fromCharCode(rcvByte);
        }
        return responseText;
    }

    private function toTwosComplement(param1:*, param2:*, param3:*) : *
    {
        var _loc4_:* = (param2 || 1) * 8;
        if(!param3 && (param1 < -(1 << _loc4_ - 1) || param1 > (1 << _loc4_ - 1) - 1))
        {
            Logger.get().error("something went wrong");
        }
        if(param1 >= 0)
        {
            return param1;
        }
        return ~(-param1 - 1 | ~((1 << _loc4_) - 1));
    }
}
}
