package extractors {
import Shared.AS3.SecureTradeShared;

import flash.display.MovieClip;
import flash.utils.setTimeout;

public class VendorPriceCheckExtractor extends BaseItemExtractor {

    public static const MOD_NAME:String = "Invent-O-Matic-Vendor-Extractor";

    protected var accountName:String;

    public function VendorPriceCheckExtractor(consumer:InventoryConsumer, config:*) {
        super(MOD_NAME, Version.VENDOR, consumer, config);
        var vendorData = GameApiDataExtractor.getApiData(GameApiDataExtractor.OtherInventoryTypeData);
        if (vendorData && vendorData.defaultHeaderText) {
            this.accountName = vendorData.defaultHeaderText;
        }
    }

    override public function buildOutputObject():Object {
        var itemsModIni:Object = super.buildOutputObject();
        itemsModIni.characterInventories = {};
        var characterInventory:Object = {};
        characterInventory.stashInventory = this.stashInventory;
        characterInventory.AccountInfoData = {
            name: accountName
        };
        characterInventory.CharacterInfoData = {};
        itemsModIni.characterInventories['priceCheck'] = characterInventory;
        return itemsModIni;
    }

    public override function setInventory(parent:MovieClip):void {
        ShowHUDMessage("Starting gathering items data from stash!");
        var delay:Number = populateItemCards(parent, parent.OfferInventory_mc, true, stashInventory);
        setTimeout(function ():void {
            populateItemCardEntries(stashInventory);
            extractItems();
        }, delay);
    }

    override public function isValidMode(menuMode:uint):Boolean {
        return menuMode === SecureTradeShared.MODE_PLAYERVENDING
                || menuMode === SecureTradeShared.MODE_NPCVENDING
                || menuMode === SecureTradeShared.MODE_VENDING_MACHINE;
    }
}
}