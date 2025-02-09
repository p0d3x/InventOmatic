package modules.transfer {

import Shared.AS3.Data.BSUIDataManager;
import Shared.AS3.Events.CustomEvent;

import utils.MatchingUtil;

public class TransferItemWorker {
    public static const EVENT_TRANSFER_ITEM:String = "Container::TransferItem";
    public static const DIRECTION_TO_CONTAINER:String = "TO_CONTAINER";
    public static const DIRECTION_FROM_CONTAINER:String = "FROM_CONTAINER";
    private var _playerInventory:Array = [];
    private var _stashInventory:Array = [];
    private var _config:TransferModuleConfig = null;

    public function set playerInventory(value:Array):void {
        _playerInventory = value;
    }

    public function set stashInventory(value:Array):void {
        _stashInventory = value;
    }

    public function set config(value:TransferModuleConfig):void {
        _config = value;
    }

    private function isValidTransferConfig():Boolean {
        return _config && _config.enabled && _config.itemNames && _config.itemNames.length > 0 && _config.direction;
    }

    public function transferItems():void {
        if (!isValidTransferConfig()) {
            return;
        }
        var direction:String = _config.direction;
        if (DIRECTION_FROM_CONTAINER === direction) {
            transfer(_stashInventory, true);
        } else if (DIRECTION_TO_CONTAINER === direction) {
            transfer(_playerInventory, false);
        }
    }

    private function transfer(inventory:Array, fromContainer:Boolean):void {
        if (!inventory || inventory.length == 0 || !isValidTransferConfig()) {
            return;
        }
        inventory.forEach(function (item:Object):void {
            if (isMatchingItemName(item.text)) {
                // fromContainer = true, means moving items from pipboy to container
                BSUIDataManager.dispatchEvent(new CustomEvent(EVENT_TRANSFER_ITEM, {
                    "serverHandleId": item.serverHandleId,
                    "quantity": item.count,
                    "fromContainer": fromContainer
                }));
            }
        });
    }

    private function isMatchingItemName(item:String):Boolean {
        // these checks seem rather excessive
        if (item === null || item == null || item.length < 1 || item === '' || item == '') {
            return false;
        }
        const matchMode:String = _config.matchMode;
        var itemName:String = item.toLowerCase();
        for (var i:int = 0; i < _config.itemNames.length; i++) {
            var configItemName:String = _config.itemNames[i].toLowerCase();
            if (MatchingUtil.isMatchingString(itemName, configItemName, matchMode)) {
                return true;
            }
        }
        return false;
    }
}
}