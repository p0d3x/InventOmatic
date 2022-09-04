package extractors {

import modules.ExtractorModuleConfig;

public class ItemExtractor extends BaseItemExtractor {

    public static const MOD_NAME:String = "Invent-O-Matic-Extractor";

    public function ItemExtractor(consumer:InventoryConsumer, config:ExtractorModuleConfig) {
        super(MOD_NAME, consumer, config, true, true);
    }

    protected override function getCharacterData():Object {
        var charData:Object = GameApiDataExtractor.getCharacterInfoData();
        return {
            name: charData.name,
            level: charData.level
        };
    }

    protected override function getAccountData():Object {
        var acData:Object = GameApiDataExtractor.getAccountInfoData();
        return {
            name: acData.name
        };
    }
}
}