package modules.devtools {
import Shared.AS3.Data.BSUIDataManager;
import Shared.AS3.Events.CustomEvent;

import com.adobe.serialization.json.JSONEncoder;

import utils.Logger;

public class GameApiDataExtractor {
    public static const EVENT_INSPECT_ITEM:String = "Container::InspectItem";
    public static var CharacterInfoData:String = "CharacterInfoData";
    public static var AccountInfoData:String = "AccountInfoData";
    public static var OtherInventoryTypeData:String = "OtherInventoryTypeData";
    private static var GAME_API_METHODS:Array = [
        "FriendsContextMenuData",
        "StoreCategoryData",
        "StoreAtomPackData",
        "PerkCardGameModeFilterUIData",
        "ChallengeCompleteData",
        "StoreMenuData",
        "ChallengeTrackerUpdateData",
        "HUDModeData",
        "QuestTrackerData",
        "FanfareData",
        "CurrencyData",
        "MapMenuData",
        "ScoreboardFilterData",
        "ControlMapData",
        "ReputationData",
        "PerksUIData",
        "LegendaryPerksMenuData",
        "BabylonAvailableMapsData",
        "HUDMessageProvider",
        "CardPacksUIData",
        "BabylonUIData",
        "PurchaseCompleteData",
        "SeasonWidgetData",
        "LoginInfoData",
        "LoginResponseData",
        "HubMenuShuttle",
        "WorkshopStateData",
        "WorkshopBudgetData",
        "WorkshopButtonBarData",
        "WorkshopCategoryData",
        "WorkshopConfigData",
        "WorkshopItemCardData",
        "WorkshopMessageData",
        "OtherInventoryTypeData",
        "OtherInventoryData",
        "MyOffersData",
        "TheirOffersData",
        "ContainerOptionsData",
        "CampVendingOfferData",
        "FireForgetEvent"
        // IGNORED FIELDS
//        "InventoryItemCardData"
//        "PlayerInventoryData",
//        "CharacterInfoData",
//        "AccountInfoData"
    ];


    protected var sfCodeObj:Object;
    protected var apiMethods:Array = [];

    public function GameApiDataExtractor(sfCodeObj:Object, config:DevToolsModuleConfig) {
        this.sfCodeObj = sfCodeObj;
        if (config.apiMethods) {
            this.apiMethods = config.apiMethods;
        } else {
            this.apiMethods = GAME_API_METHODS;
        }
    }

    public function extract():void {
        try {
            var data:Object = GameApiDataExtractor.getFullApiData(apiMethods);
            var str = toString(data);
            sfCodeObj.call('writeItemsModFile', str);
            Logger.get().info("wrote api methods to file, {0} characters", str.length);
        } catch (e:Error) {
            Logger.get().error("failed to extract api data: {0}", e);
        }
    }

    protected static function toString(obj:Object):String {
        return new JSONEncoder(obj).getString();
    }

    private static function getFullApiData(array:Array):Object {
        var gameApiData:Object = {};
        if (array == null || array.length < 1) {
            Logger.get().debug("no api methods defined in config, using 'all'");
            array = GAME_API_METHODS;
        }
        array.forEach(function (apiMethodName:String):void {
            gameApiData[apiMethodName] = getApiData(apiMethodName);
        });
        return gameApiData;
    }

    public static function getApiData(input:String):Object {
        try {
            return BSUIDataManager.GetDataFromClient(input).data;
        } catch (e:Error) {
        }
        return {
            message: "Error extracting data for " + input
        };
    }

    public static function getAccountInfoData():Object {
        return getApiData(AccountInfoData);
    }

    public static function getCharacterInfoData():Object {
        return getApiData(CharacterInfoData);
    }

    public static function inspectItem(serverHandleId:Number, fromContainer:Boolean):void {
        BSUIDataManager.dispatchEvent(new CustomEvent(EVENT_INSPECT_ITEM, {
            "serverHandleId": serverHandleId,
            "fromContainer": fromContainer
        }));
    }
}
}