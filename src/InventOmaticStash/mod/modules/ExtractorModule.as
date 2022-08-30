package modules {
import Shared.AS3.SecureTradeShared;
import Shared.GlobalFunc;

import extractors.BaseItemExtractor;

import extractors.InventoryConsumer;
import extractors.ItemExtractor;
import extractors.VendorPriceCheckExtractor;

import flash.display.MovieClip;

import utils.Logger;

public class ExtractorModule extends BaseModule {

    private var extractor:BaseItemExtractor;
    private var secureTrade:MovieClip;

    public function ExtractorModule(parent:MovieClip, config:ExtractorModuleConfig) {
        super(config);
        _buttonText = "Extract Items";
        secureTrade = parent;
        if (!_active) {
            return;
        }
        if (parent.__SFCodeObj == null || parent.__SFCodeObj.call == null) {
            ShowHUDMessage("SFE not found, extract disabled!", true);
            Logger.get().error("SFE not found, extract disabled!");
            config.enabled = false;
            _active = false;
            return;
        }

        var consumer:InventoryConsumer = new InventoryConsumer(parent.__SFCodeObj, config);
        switch (parent.m_MenuMode) {
            case SecureTradeShared.MODE_PLAYERVENDING:
            case SecureTradeShared.MODE_NPCVENDING:
            case SecureTradeShared.MODE_VENDING_MACHINE:
                extractor = new VendorPriceCheckExtractor(consumer, config);
                break;
            default:
                extractor = new ItemExtractor(consumer, config);
        }
    }

    protected override function execute():void {
        try {
            ShowHUDMessage("Running extractor: " + extractor.getExtractorName());
            extractor.setInventory(secureTrade);
        } catch (e:Error) {
            ShowHUDMessage("Error extracting items(init): " + e, true);
        }
    }

    public static function ShowHUDMessage(text:String, force:Boolean = false):void {
        if (Logger.DEBUG_MODE || force) {
            GlobalFunc.ShowHUDMessage("[Invent-O-Matic-Stash v" + Version.LOADER + "] " + text);
        }
    }
}
}
