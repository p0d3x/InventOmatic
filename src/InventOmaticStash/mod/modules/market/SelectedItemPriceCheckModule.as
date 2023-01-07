package modules.market {

import Shared.AS3.Data.BSUIDataManager;
import Shared.AS3.Data.FromClientDataEvent;
import Shared.GlobalFunc;

import com.adobe.serialization.json.JSONDecoder;
import com.adobe.serialization.json.JSONEncoder;

import flash.text.TextField;

import modules.BaseModule;

import scaleform.gfx.TextFieldEx;

import utils.HttpClient;
import utils.Logger;

public class SelectedItemPriceCheckModule extends BaseModule {
    public static var InventoryItemCardData:String = "InventoryItemCardData";

    private var client:HttpClient;
    private var parent:Object;
    private var sfCodeObj:Object;
    private var lastReceivedCards:Object;
    private var _stopped:Boolean;

    public function SelectedItemPriceCheckModule(parent:Object, config:SelectedItemPriceCheckModuleConfig) {
        super(config);
        this.parent = parent;
        this.sfCodeObj = parent.__SFCodeObj;
        this._buttonText = "Price Check";
        if (!_active) {
            return;
        }
        if (sfCodeObj == null || sfCodeObj.call == null) {
            Logger.get().error("SFE not found, extract disabled!");
            config.enabled = false;
            _active = false;
        }
        _stopped = true;
        client = new HttpClient(sfCodeObj, config.postTarget.host, config.postTarget.port);
        BSUIDataManager.Subscribe(InventoryItemCardData, onInventoryItemCardDataUpdate);
    }

    protected function onInventoryItemCardDataUpdate(eventData:FromClientDataEvent):void {
        if (_stopped) {
            return;
        }
        stop();
        var data:Object = eventData.data;
        Logger.get().trace("card update: {0}", data.serverHandleId);
        lastReceivedCards = clone(data);
        runPriceCheck();
    }

    override protected function execute():void {
        _stopped = !_stopped;
        Logger.get().debug("price-checker toggled active: {0}", !_stopped);
    }

    private function runPriceCheck():void {
        if (!_active) {
            Logger.get().error("MarketWatch disabled, cannot extract!");
            return;
        }
        try {
            var selectedItem = getSelectedItem();
            if (!selectedItem) {
                Logger.get().warn("selected item not found!");
                start();
                return;
            }
            Logger.get().info("sending selected item '{0}' to price-checker", selectedItem.text);
            Logger.get().trace("POST: {0}", selectedItem);
            var _conf = SelectedItemPriceCheckModuleConfig(config);
            client.post(_conf.postTarget.path, selectedItem, function(code:int, body:String):void {
                var response:Object = new JSONDecoder(body, true).getValue();
                Logger.get().trace("review: {0}", response.valuations);
                if (response.valuations.length > 0) {
                    var tf:TextField = parent.ItemCardContainer_mc.Background_mc.Description_mc.Description_tf;
                    var text:String = tf.text;
                    Logger.get().debug("{0} valuations received.", response.valuations.length)
                    for (var i:int = 0; i < response.valuations.length; i++) {
                        var v:Object = response.valuations[i];
                        Logger.get().debug("source: {0}, price: {1}/[{2}-{3}]/{4}",
                                v.source, v.avgPrice, v.minPrice, v.maxPrice, v.nichePrice);
                        var price:String = v.avgPrice + "";
                        if (v.minPrice != v.maxPrice) {
                            price = v.minPrice + " - " + v.maxPrice;
                        }
                        if (v.quickVendor != 0) {
                            price = v.quickVendor + ", " + price;
                        }
                        if (v.nichePrice != v.avgPrice) {
                            price = price + " (" + v.nichePrice + ")";
                        }
                        text = text + v.source + ": " + price + "\n";
                    }
                    GlobalFunc.SetText(tf, text);
                    TextFieldEx.setVerticalAlign(tf, TextFieldEx.VALIGN_BOTTOM);
                    parent.ItemCardContainer_mc.Background_mc.Description_mc.visible = true;
                }
                start();
            });
        } catch (e:Error) {
            Logger.get().error("failed to price-check: {0}", e);
            start();
        }
    }

    private function getSelectedItem():* {
        if (!lastReceivedCards) {
            return null;
        }
        Logger.get().trace("looking for selected item in offers");
        var selectedItem:Object = findInSecureTradeInventory(parent.OfferInventory_mc);
        if (selectedItem == null) {
            Logger.get().trace("looking for selected item in inventory");
            selectedItem = findInSecureTradeInventory(parent.PlayerInventory_mc);
        }
        return selectedItem;
    }

    private function findInSecureTradeInventory(secureTradeInventory:SecureTradeInventory):Object {
        if (!secureTradeInventory.Active) {
            return null;
        }
        var idx:Number = secureTradeInventory.selectedItemIndex;
        Logger.get().trace("selected index is {0}", idx);
        var selectedItem:Object = clone(secureTradeInventory.ItemList_mc.List_mc.MenuListData[idx]);
        selectedItem.ItemCardEntries = lastReceivedCards.itemCardEntries;
        return selectedItem;
    }

    protected static function toString(obj:Object):String {
        return new JSONEncoder(obj).getString();
    }

    protected function clone(object:Object):Object {
        try {
            var str:String = toString(object);
            return new JSONDecoder(str, true).getValue();
        } catch (e:Error) {
            Logger.get().warn("Error cloning object: {0}", e);
        }
        return {};
    }

    public function stop():void {
        _stopped = true;
    }

    public function start():void {
        _stopped = false;
    }

    public function get stopped():Boolean {
        return _stopped;
    }
}
}
