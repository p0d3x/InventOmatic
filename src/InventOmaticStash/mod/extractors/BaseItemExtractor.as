package extractors {
import Shared.AS3.Data.FromClientDataEvent;
import Shared.GlobalFunc;

import com.adobe.serialization.json.JSONDecoder;
import com.adobe.serialization.json.JSONEncoder;

import flash.display.MovieClip;
import flash.utils.setTimeout;

import modules.ExtractorModuleConfig;

import utils.Logger;

public class BaseItemExtractor {

    protected var playerInventory:Array = [];
    protected var stashInventory:Array = [];
    protected var version:Number;
    protected var modName:String;
    protected static var itemCardEntries:Object = {};
    protected static var DEFAULT_DELAY:Number = 1000;
    protected static var ITEM_CARD_ENTRY_DELAY_STEP:Number = 100;
    protected var additionalItemDataForAll:Boolean = false;
    protected var inventoryConsumer:InventoryConsumer;

    public function BaseItemExtractor(modName:String, version:Number, consumer:InventoryConsumer,
                                      config:ExtractorModuleConfig) {
        this.modName = modName;
        this.version = version;
        this.inventoryConsumer = consumer;
        this.additionalItemDataForAll = config.additionalItemDataForAll;
        GameApiDataExtractor.subscribeInventoryItemCardData(onInventoryItemCardDataUpdate);
    }

    public function getExtractorName():String {
        return modName + ' v' + version;
    }

    public function setInventory(parent:MovieClip):void {
        // to be implemented by subclasses
    }

    protected function populateItemCardEntries(inventory:Array):void {
        inventory.forEach(function (item:Object):void {
            if (itemCardEntries[item.serverHandleId]) {
                item.ItemCardEntries = itemCardEntries[item.serverHandleId].itemCardEntries;
            }
        });
    }

    protected function populateItemCards(parent:MovieClip, inventory:SecureTradeInventory,
            fromContainer:Boolean, output:Array):Number {
        var inv:Array = inventory.ItemList_mc.List_mc.MenuListData;
        var delay:Number = ITEM_CARD_ENTRY_DELAY_STEP;
        inv.forEach(function (item:Object):void {
            item.ItemCardEntries = [];
            if (item.isLegendary || additionalItemDataForAll) {
                setTimeout(function ():void {
                    try {
                        parent.selectedList = inventory;
                        inventory.Active = true;
                        GameApiDataExtractor.selectItem(item.serverHandleId, fromContainer);
                        var itemCardData:Object = clone(GameApiDataExtractor.getInventoryItemCardData());
                        itemCardEntries[itemCardData.serverHandleId] = itemCardData;
                        output.push(item);
                    } catch (e:Error) {
                        Logger.get().errorHandler("Error getting data for item " + item.text, e)
                    }
                }, delay);
                delay += ITEM_CARD_ENTRY_DELAY_STEP;
            } else {
                output.push(item);
            }
        });
        return delay + DEFAULT_DELAY;
    }

    private function clone(object:Object):Object {
        try {
            var str:String = toString(object);
            return new JSONDecoder(str, true).getValue();
        } catch (e:Error) {
            ShowHUDMessage("Error cloning object: " + e)
        }
        return {};
    }

    public function extractItems():void {
        try {
            ShowHUDMessage('Starting extracting items!');
            var itemsModIni:Object = buildOutputObject();
            inventoryConsumer.accept(itemsModIni);
            ShowHUDMessage('Done saving items!', true);
        } catch (e:Error) {
            ShowHUDMessage('Error extracting items(core): ' + e);
        }
    }

    public function buildOutputObject():Object {
        return {
            modName: modName,
            version: version
        };
    }

    protected static function toString(obj:Object):String {
        return new JSONEncoder(obj).getString();
    }

    public function ShowHUDMessage(text:String, force:Boolean = false):void {
        if (Logger.DEBUG_MODE || force) {
            GlobalFunc.ShowHUDMessage('[' + modName + ' v' + version + '] ' + text);
        }
        Logger.get().debug(text);
    }

    private function onInventoryItemCardDataUpdate(eventData:FromClientDataEvent):void {
        var data:Object = eventData.data;
        itemCardEntries[data.serverHandleId] = clone(data);
    }
}
}