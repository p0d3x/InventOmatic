package modules.extractor {
import modules.*;

import Shared.AS3.SecureTradeShared;

import modules.extractor.BaseItemExtractor;

import modules.extractor.InventoryConsumer;
import modules.extractor.ItemExtractor;
import modules.extractor.VendorPriceCheckExtractor;

import flash.display.MovieClip;

import utils.Logger;

public class ExtractorModule extends BaseModule {

    private var extractorSupplier:Function;
    private var secureTrade:MovieClip;

    public function ExtractorModule(parent:MovieClip, config:ExtractorModuleConfig) {
        super(config);
        _buttonText = "Extract Items";
        secureTrade = parent;
        if (!_active) {
            return;
        }
        if (parent.__SFCodeObj == null || parent.__SFCodeObj.call == null) {
            Logger.get().error("SFE not found, extract disabled!");
            config.enabled = false;
            _active = false;
            return;
        }

        extractorSupplier = function():BaseItemExtractor {
            var consumer:InventoryConsumer = new InventoryConsumer(parent.__SFCodeObj, config);
            switch (parent.m_MenuMode) {
                case SecureTradeShared.MODE_PLAYERVENDING:
                case SecureTradeShared.MODE_NPCVENDING:
                case SecureTradeShared.MODE_VENDING_MACHINE:
                    return new VendorPriceCheckExtractor(consumer, config);
                default:
                    return new ItemExtractor(consumer, config);
            }
        }
    }

    protected override function execute():void {
        try {
            var extractor:BaseItemExtractor = extractorSupplier();
            InventOmaticStash.ShowHUDMessage(Logger.LOG_LEVEL_INFO, "Running extractor: {0}",
                    extractor.getExtractorName());
            Logger.get().info("Running extractor: {0}", extractor.getExtractorName());
            extractor.extractFromSecureTrade(secureTrade);
        } catch (e:Error) {
            InventOmaticStash.ShowHUDMessage(Logger.LOG_LEVEL_ERROR, "Error extracting items(init): {0}", e);
            Logger.get().error("Error extracting items(init): {0}", e);
        }
    }
}
}
