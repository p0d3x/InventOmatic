package extractors {
import Shared.AS3.ExtendedSocket;

import com.adobe.serialization.json.JSONEncoder;

import flash.events.Event;
import flash.utils.ByteArray;

import modules.ExtractorModuleConfig;

import utils.Logger;

public class InventoryConsumer {

    protected var sfCodeObj:Object;
    protected var socket:ExtendedSocket;
    protected var writeToFile:Boolean = true;
    protected var postToUrl:Boolean = false;
    protected var host:String;
    protected var port:int;
    protected var path:String;

    public function InventoryConsumer(sfCodeObj:Object, config:ExtractorModuleConfig) {
        this.sfCodeObj = sfCodeObj;
        this.writeToFile = config.writeToFile;
        if (config.postTarget) {
            this.postToUrl = config.postToUrl;
            this.host = config.postTarget.host;
            this.port = config.postTarget.port;
            this.path = config.postTarget.path;
        } else {
            Logger.get().warn("postTarget is not defined, disabling postToUrl");
            this.postToUrl = false;
        }
    }

    public function accept(itemsModIni:Object):void {
        var error;
        if (postToUrl) {
            try {
                sendDataChatMod(itemsModIni);
            } catch (e:Error) {
                Logger.get().errorHandler("Sending items failed: ", e);
                error = e;
            }
        }
        if (writeToFile) {
            try {
                writeData(itemsModIni);
            } catch (e:Error) {
                Logger.get().errorHandler("writing items failed: ", e);
                error = e;
            }
        }
        if (error) {
            throw error;
        }
    }

    protected function writeData(data:Object):void {
        sfCodeObj.call('writeItemsModFile', toString(data));
    }

    protected static function toString(obj:Object):String {
        return new JSONEncoder(obj).getString();
    }

    protected function sendDataChatMod(data:Object):void {
        Logger.get().debug("connecting to server");

        if (socket == null) {
            socket = new ExtendedSocket(sfCodeObj);
            socket.addEventListener("ExtendedSocket::CONNECT", connectHandler);
            socket.addEventListener("ExtendedSocket::SocketData", socketDataHandler);
        }
        if (!socket.connected) {
            // parameters don't matter, host and port are hardcoded in dxgi.dll
            socket.connect(host, port.toString());
        }

        function connectHandler(param1:Event) : void {
            Logger.get().debug("posting inventory to server");

            var body = toString(data);
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(body);
            var bodyLength = b.length;
            Logger.get().debug("sending request with body length: " + bodyLength);

            socket.writeUTFBytes("POST " + path + " HTTP/1.1\n" +
                    "Content-Type: application/json\n" +
                    "User-Agent: InventOmatic/" + Version.VERSION + "\n" +
                    "Accept: */*\n" +
                    "Cache-Control: no-cache\n" +
                    "Host: " + host + ":" + port + "\n" +
                    "Accept-Encoding: gzip, deflate, br\n" +
                    "Connection: close\n" +
                    "Content-Length: " + bodyLength + "\n" +
                    "\n" + body);
        }
    }

    private function socketDataHandler(param1:Event) : void {
        var rcvByte:* = undefined;
        var responseText:String = "";
        while (this.socket.bytesAvailable > 0) {
            // TODO check this section, I have no idea how it parses the code points
            if ((rcvByte = this.socket.readByte()) < 0 && rcvByte != -62) {
                rcvByte = parseInt(this.toTwosComplement(rcvByte,1,2000));
            } else if(rcvByte == -62) {
                continue;
            }
            responseText += String.fromCharCode(rcvByte);
        }
        Logger.get().debug("rcv:");
        var responseLines:Array = responseText.split("\r\n");
        var curLineNum:int = 0;
        var headers:Array = [];
        var headersDone:Boolean = false;
        var body:String = "";
        var code:int = 0;
        var length:int = 0;
        while(curLineNum < responseLines.length) {
            var curLine:String = responseLines[curLineNum];
            Logger.get().debug(curLine);
            if (curLine.length == 0) {
                headersDone = true;
            } else if (!headersDone) {
                if (curLine.indexOf("HTTP/") == 0) {
                    code = parseInt(curLine.split(" ")[1]);
                } else if (curLine.indexOf("Content-Length:") == 0) {
                    length = parseInt(curLine.split(": ")[1]);
                }
                headers.push(curLine);
            } else {
                body += curLine;
            }
            curLineNum++;
        }
        Logger.get().debug("Response: " + code + ", Length: " + length + ", Body: " + body);
        this.socket.close();
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
