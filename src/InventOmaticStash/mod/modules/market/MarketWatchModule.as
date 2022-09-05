package modules.market {
import Shared.AS3.Data.BSUIDataManager;

import com.adobe.serialization.json.JSONDecoder;

import com.adobe.serialization.json.JSONEncoder;

import modules.BaseModule;

import utils.HttpClient;

import utils.Logger;

public class MarketWatchModule extends BaseModule {

    private var client:HttpClient;
    private var sfCodeObj:Object;

    public function MarketWatchModule(sfCodeObj:Object, config:MarketWatchModuleConfig) {
        super(config);
        this.sfCodeObj = sfCodeObj;
        this._buttonText = "Next Vendor";
        if (!_active) {
            return;
        }
        if (sfCodeObj == null || sfCodeObj.call == null) {
            Logger.get().error("SFE not found, extract disabled!");
            config.enabled = false;
            _active = false;
        }
        client = new HttpClient(sfCodeObj, "localhost", 8443);
    }

    override protected function execute():void {
        if (!_active) {
            Logger.get().error("MarketWatch disabled, cannot extract!");
            return;
        }
        try {
            Logger.get().info("gathering MapMenuData data");
            var data:Object = BSUIDataManager.GetDataFromClient("MapMenuData").data;
            // todo get flyout info
            var playerVendors:Array = data.MarkerData.filter(function(arg:Object):Boolean {
                return arg.markerType == "YourCampMarker" && arg.isVending && !arg.isLocalPlayersCamp;
            }).map(function(v:Object):Object {
                return {
                    player: v.owningPlayerName,
                    x: v.x,
                    y: v.y
                };
            });
            client.post("/api/players", playerVendors, function(code:int, body:String):void {
                var response:Object = new JSONDecoder(body, true).getValue();
                var candidate:Object;
                response.vendors.forEach(function(v:Object):void {
                    Logger.get().debug("vendor {0}, last seen: {1}, times seen: {2}, rating: {3}",
                            v.name, v.lastSeen, v.timesSeen, v.rating);
                    if (v.timesSeen == 0 && !candidate) {
                        candidate = v.name;
                    }
                });
                if (candidate) {
                    // todo tp
                    Logger.get().info("next vendor: {0}", candidate);
                }
            });
            /*var str:String = toString(playerVendors);
            sfCodeObj.call('writeItemsModFile', str);
            Logger.get().info("wrote player camps to file, {0} characters", str.length);*/
        } catch (e:Error) {
            Logger.get().error("failed to extract player camps: {0}", e);
        }
    }

    protected static function toString(obj:Object):String {
        return new JSONEncoder(obj).getString();
    }
}
}
