package modules.extractor {

import com.adobe.serialization.json.JSONDecoder;
import com.adobe.serialization.json.JSONEncoder;

import utils.HttpClient;

import utils.Logger;

public class InventoryConsumer {

    protected var sfCodeObj:Object;
    protected var client:HttpClient;
    protected var writeToFile:Boolean = true;
    protected var postToUrl:Boolean = false;
    protected var path:String;

    public function InventoryConsumer(sfCodeObj:Object, config:ExtractorModuleConfig) {
        this.sfCodeObj = sfCodeObj;
        this.writeToFile = config.writeToFile;
        if (config.postTarget) {
            this.postToUrl = config.postToUrl;
            this.client = new HttpClient(sfCodeObj, config.postTarget.host, config.postTarget.port);
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
                client.post(path, itemsModIni, function(code:int, body:String):void {
                    var v:Object = new JSONDecoder(body, true).getValue();
                    Logger.get().info("vendor {0}, last seen: {1}, times seen: {2}, rating: {3}",
                            v.name, v.lastSeen, v.timesSeen, v.rating);
                });
            } catch (e:Error) {
                Logger.get().error("Sending items failed: {0}", e);
                error = e;
            }
        }
        if (writeToFile) {
            try {
                writeData(itemsModIni);
            } catch (e:Error) {
                Logger.get().error("writing items failed: {0}", e);
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
}
}
