package extractors {
import flash.display.MovieClip;
import flash.utils.setTimeout;

import modules.ExtractorModuleConfig;

import utils.Logger;

public class ItemExtractor extends BaseItemExtractor {

    public static const MOD_NAME:String = "Invent-O-Matic-Extractor";

    public function ItemExtractor(consumer:InventoryConsumer, config:ExtractorModuleConfig) {
        super(MOD_NAME, Version.ITEM_EXTRACTOR, consumer, config);
    }

    public override function buildOutputObject():Object {
        var outputObject:Object = super.buildOutputObject();

        var charData:Object = GameApiDataExtractor.getCharacterInfoData();
        var acData:Object = GameApiDataExtractor.getAccountInfoData();

        outputObject.characterInventories = {};
        outputObject.characterInventories[charData.name] = {
            playerInventory: playerInventory,
            stashInventory: stashInventory,
            AccountInfoData: {
                name: acData.name
            },
            CharacterInfoData: {
                name: charData.name,
                level: charData.level
            }
        };

        return outputObject;
    }

    public override function setInventory(parent:MovieClip):void {
        Logger.get().info("Starting gathering items data from inventory!");
        var delay:Number = populateItemCards(parent, parent.PlayerInventory_mc, false, playerInventory);
        setTimeout(function ():void {
            Logger.get().info("Starting gathering items data from stash!");
            var delay2:Number = populateItemCards(parent, parent.OfferInventory_mc, true, stashInventory);
            setTimeout(function ():void {
                Logger.get().info("Building output object...");
                try {
                    populateItemCardEntries(playerInventory);
                    populateItemCardEntries(stashInventory);
                    extractItems();
                } catch (e:Error) {
                    Logger.get().info("Error building output object " + e);
                }
            }, delay2);

        }, delay);
    }
}
}