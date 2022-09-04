package modules {
import Shared.AS3.SecureTradeShared;

import extractors.BaseItemExtractor;

import extractors.InventoryConsumer;
import extractors.ItemExtractor;
import extractors.VendorPriceCheckExtractor;

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
            InventOmaticStash.ShowHUDMessage("SFE not found, extract disabled!", Logger.LOG_LEVEL_ERROR);
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
            InventOmaticStash.ShowHUDMessage("Running extractor: " + extractor.getExtractorName());
            Logger.get().info("Running extractor: {0}", extractor.getExtractorName());
            extractor.extractFromSecureTrade(secureTrade);
        } catch (e:Error) {
            InventOmaticStash.ShowHUDMessage("Error extracting items(init): " + e, Logger.LOG_LEVEL_ERROR);
            Logger.get().error("Error extracting items(init): {0}", e);
        }
    }
}
}
