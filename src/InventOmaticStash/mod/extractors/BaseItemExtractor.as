package extractors {
import Shared.AS3.Data.FromClientDataEvent;
import com.adobe.serialization.json.JSONDecoder;
import com.adobe.serialization.json.JSONEncoder;

import flash.display.MovieClip;
import flash.utils.setTimeout;

import modules.ExtractorModuleConfig;

import utils.Logger;

public class BaseItemExtractor {

    protected var modName:String;
    protected var additionalItemDataForAll:Boolean = false;
    protected var inventoryConsumer:InventoryConsumer;

    protected var pendingItemCardUpdates:Array = [];
    protected var itemCardEntries:Object = {};
    protected var waitingForUpdates:Boolean = false;

    protected var usesInventory:Boolean = false;
    protected var playerInventory:Array = [];

    protected var usesContainer:Boolean = false;
    protected var stashInventory:Array = [];

    public function BaseItemExtractor(modName:String, consumer:InventoryConsumer, config:ExtractorModuleConfig,
                                      usesInventory:Boolean, usesContainer:Boolean) {
        this.modName = modName;
        this.additionalItemDataForAll = config.additionalItemDataForAll;
        this.inventoryConsumer = consumer;
        this.usesInventory = usesInventory;
        this.usesContainer = usesContainer;
        GameApiDataExtractor.subscribeInventoryItemCardData(onInventoryItemCardDataUpdate);
    }

    public function getExtractorName():String {
        return modName + ' v' + Version.VERSION;
    }

    public function extractFromSecureTrade(parent:MovieClip):void {
        InventOmaticStash.ShowHUDMessage('extracting items!', Logger.LOG_LEVEL_INFO);
        Logger.get().info('extracting items!');
        pendingItemCardUpdates = [];
        if (usesInventory) {
            Logger.get().debug("gathering items data from player inventory!");
            playerInventory = collectItems(parent, parent.PlayerInventory_mc, false);
        }
        if (usesContainer) {
            Logger.get().debug("gathering items data from offer inventory or container!");
            stashInventory = collectItems(parent, parent.OfferInventory_mc, true);
        }
        Logger.get().debug("collecting item card data for {0} items", pendingItemCardUpdates.length);
        waitingForUpdates = true;
        populateCardsAndExtract();
    }

    protected function clone(object:Object):Object {
        try {
            var str:String = toString(object);
            return new JSONDecoder(str, true).getValue();
        } catch (e:Error) {
            InventOmaticStash.ShowHUDMessage("Error cloning object: " + e, Logger.LOG_LEVEL_ERROR)
            Logger.get().error("Error cloning object: {0}", e);
        }
        return {};
    }

    public function saveOutput():void {
        try {
            Logger.get().debug('saving items!');
            var itemsModIni:Object = {
                modName: modName,
                version: Version.VERSION,
                characterInventories: {}
            };
            var characterData:Object = getCharacterData();
            var accountData:Object = getAccountData();
            itemsModIni.characterInventories[characterData.name] = {
                playerInventory: playerInventory,
                stashInventory: stashInventory,
                AccountInfoData: accountData,
                CharacterInfoData: characterData
            };
            inventoryConsumer.accept(itemsModIni);
            Logger.get().debug('saved items!');
        } catch (e:Error) {
            InventOmaticStash.ShowHUDMessage('Error extracting items(core): ' + e, Logger.LOG_LEVEL_ERROR);
            Logger.get().error('Error extracting items(core): {0}', e);
        }
    }

    protected function getCharacterData():Object {
        return {};
    }

    protected function getAccountData():Object {
        return {};
    }

    protected static function toString(obj:Object):String {
        return new JSONEncoder(obj).getString();
    }

    protected function collectItems(parent:MovieClip, inventory:SecureTradeInventory, fromContainer:Boolean):Array {
        var inv:Array = inventory.ItemList_mc.List_mc.MenuListData;
        var result:Array = inv.map(function (item:Object):Object {
            item.ItemCardEntries = [];
            if (!itemCardEntries[item.serverHandleId] && (item.isLegendary || additionalItemDataForAll)) {
                pendingItemCardUpdates.push({
                    id: item.serverHandleId,
                    parentList: parent,
                    inventory: inventory,
                    fromContainer: fromContainer
                });
            }
            return item;
        });
        return result;
    }

    protected function onInventoryItemCardDataUpdate(eventData:FromClientDataEvent):void {
        var data:Object = eventData.data;
        Logger.get().trace("card update: {0}", data.serverHandleId);
        itemCardEntries[data.serverHandleId] = clone(data);
        setTimeout(function ():void {
            populateCardsAndExtract();
        }, 0);
    }

    protected function populateCardsAndExtract():void {
        if (!waitingForUpdates) {
            return;
        }
        if (pendingItemCardUpdates.length > 0) {
            selectNextPendingItem();
            return;
        }
        waitingForUpdates = false;
        Logger.get().info("all pending item card updates received");
        fillItemCardEntries();
        saveOutput();
        InventOmaticStash.ShowHUDMessage('done!', Logger.LOG_LEVEL_INFO);
        Logger.get().info('done!');
    }

    private function fillItemCardEntries():void {
        stashInventory.forEach(function (item:Object):void {
            if (itemCardEntries[item.serverHandleId]) {
                item.ItemCardEntries = itemCardEntries[item.serverHandleId].itemCardEntries;
            }
        });
        playerInventory.forEach(function (item:Object):void {
            if (itemCardEntries[item.serverHandleId]) {
                item.ItemCardEntries = itemCardEntries[item.serverHandleId].itemCardEntries;
            }
        });
    }

    private function selectNextPendingItem():void {
        var pendingItem:* = pendingItemCardUpdates.pop();
        try {
            Logger.get().debug("selecting: {0}", pendingItem.id);
            pendingItem.parentList.selectedList = pendingItem.inventory;
            pendingItem.inventory.Active = true;
            GameApiDataExtractor.selectItem(pendingItem.id, pendingItem.fromContainer);
        } catch (e:Error) {
            Logger.get().error("Error getting data for item {0}: {1}", pendingItem.id, e);
        }
    }
}
}