package modules.scrap {

import Shared.AS3.Data.BSUIDataManager;
import Shared.AS3.Events.CustomEvent;

import utils.Logger;
import utils.MatchMode;
import utils.MatchingUtil;

public class ScrapItemWorker {
    public static const EVENT_SCRAP_ITEM:String = "Workbench::ScrapItem";
    private var _playerInventory:Array = [];
    private var _config:ScrapModuleConfig = null;

    public function set playerInventory(value:Array):void {
        _playerInventory = value;
    }

    public function set config(value:ScrapModuleConfig):void {
        _config = value;
    }

    private function isValidScrapConfig():Boolean {
        return _config && _config.enabled && _config.filterFlags && _config.filterFlags.length > 0;
    }

    public function scrapItems():void {
        if (!isValidScrapConfig()) {
            return;
        }
        scrap(_playerInventory);
    }

    private function scrap(inventory:Array):void {
        if (!inventory || inventory.length == 0 || !isValidScrapConfig()) {
            return;
        }
        try {
            var totalScrapped:int = 0;
            var stacksScrapped:int = 0;
            Logger.get().debug("checking {0} for items to scrap, limits: {1}, {2}",
                    inventory.length, _config.maxItems, _config.maxStacks);
            inventory.forEach(function (item:Object):void {
                if ((_config.maxItems > 0 && totalScrapped >= _config.maxItems)
                        || (_config.maxStacks > 0 && stacksScrapped >= _config.maxStacks)) {
                    return;
                }
                if (!item.isLegendary && shouldScrap(item)) {
                    Logger.get().debug("Going to scrap: {0}", item.text);
                    if (!_config.dryRun) {
                        BSUIDataManager.dispatchEvent(new CustomEvent(EVENT_SCRAP_ITEM, {
                            "serverHandleId": item.serverHandleId,
                            "quantity": item.count
                        }));
                    }
                    totalScrapped += item.count;
                    stacksScrapped++;
                }
            });
            Logger.get().debug("Scrapped {0} items ({1} stacks)", totalScrapped, stacksScrapped);
            InventOmaticStash.ShowHUDMessage(Logger.LOG_LEVEL_INFO, "Scrapped {0} items ({1} stacks)",
                    totalScrapped, stacksScrapped);
        } catch (e:Error) {
            Logger.get().error("Error ItemWorker scrap: {0}", e);
        }
    }

    private function shouldScrap(item:Object):Boolean {
        if (!isValidTypeToScrap(item)) {
            return false;
        }
        try {
            var itemName:String = item.text.toLowerCase();
            for (var i:int = 0; i < _config.excluded.length; i++) {
                var configItemName:String = _config.excluded[i].toLowerCase();
                if (MatchingUtil.isMatchingString(itemName, configItemName, MatchMode.CONTAINS)) {
                    Logger.get().debug("{0} matches exclusion: {1}", itemName, configItemName);
                    return false;
                }
            }
            return true;
        } catch (e:Error) {
            Logger.get().error("Error checking items for scrapping: {0}", e);
        }
        return false;
    }

    private function isValidTypeToScrap(item:Object):Boolean {
        return _config.filterFlags.some(function (arg:uint):Boolean {
            return (item.filterFlag & arg) != 0;
        });
    }
}
}