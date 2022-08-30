package {
import Shared.GlobalFunc;

import extractors.GameApiDataExtractor;

import modules.ScrapModuleConfig;

import utils.Logger;

public class ScrapItemWorker extends ItemWorker {
    private var _playerInventory:Array = [];
    private var _config:ScrapModuleConfig = null;

    public function set playerInventory(value:Array):void {
        _playerInventory = value;
    }

    public function set config(value:ScrapModuleConfig):void {
        _config = value;
    }

    private function isValidScrapConfig():Boolean {
        return _config && _config.enabled && _config.types && _config.types.length > 0;
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
            Logger.get().debug("checking " + inventory.length + " for items to scrap, limits: "
                    + _config.maxItems + ", " + _config.maxStacks);
            inventory.forEach(function (item:Object):void {
                if ((_config.maxItems > 0 && totalScrapped >= _config.maxItems)
                        || (_config.maxStacks > 0 && stacksScrapped >= _config.maxStacks)) {
                    return;
                }
                if (!item.isLegendary && shouldScrap(item)) {
                    Logger.get().debug("Going to scrap: " + item.text);
                    GameApiDataExtractor.scrapItem(item);
                    totalScrapped += item.count;
                    stacksScrapped++;
                }
            });
            Logger.get().debug("Scrapped " + totalScrapped + " items (" + stacksScrapped + "stacks)");
            GlobalFunc.ShowHUDMessage("Scrapped " + totalScrapped + " items (" + stacksScrapped + "stacks)");
        } catch (e:Error) {
            Logger.get().errorHandler("Error ItemWorker scrap", e);
        }
    }

    private function shouldScrap(item:Object):Boolean {
        if (!isValidTypeToScrap(item)) {
            return false;
        }
        try {
            if (!_config.excluded || _config.excluded.length == 0) {
                return true;
            }
            var itemName:String = item.text.toLowerCase();
            for (var i:int = 0; i < _config.excluded.length; i++) {
                var configItemName:String = _config.excluded[i].toLowerCase();
                if (isMatchingString(itemName, configItemName, MatchMode.CONTAINS)) {
                    Logger.get().info(itemName + " matches exclusion: " + configItemName);
                    return false;
                }
            }
            return true;
        } catch (e:Error) {
            Logger.get().errorHandler("Error checking items for scrapping", e);
        }
        return false;
    }

    private function isValidTypeToScrap(item:Object):Boolean {
        try {
            var types:Array = _config.types;
            var matchingFilterFlags:Array = [];
            for (var i:int = 0; i < types.length; i++) {
                matchingFilterFlags = matchingFilterFlags.concat(matchingFilterFlags, ItemTypes.ITEM_TYPES[types[i]]);
            }
            return matchingFilterFlags.indexOf(item.filterFlag) !== -1;
        } catch (e:Error) {
            Logger.get().errorHandler("Error checking type for scrap", e);
        }
        return false;
    }
}
}