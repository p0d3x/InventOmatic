package extractors {

import modules.ExtractorModuleConfig;

public class VendorPriceCheckExtractor extends BaseItemExtractor {

    public static const MOD_NAME:String = "Invent-O-Matic-Vendor-Extractor";

    public function VendorPriceCheckExtractor(consumer:InventoryConsumer, config:ExtractorModuleConfig) {
        super(MOD_NAME, consumer, config, false, true);
    }

    protected override function getCharacterData():Object {
        return {
            name: 'priceCheck',
            level: 0
        };
    }

    protected override function getAccountData():Object {
        var vendorData:* = GameApiDataExtractor.getApiData(GameApiDataExtractor.OtherInventoryTypeData);
        var accountName:String;
        if (vendorData && vendorData.defaultHeaderText) {
            accountName = vendorData.defaultHeaderText;
        }
        return {
            name: accountName
        };
    }
}
}