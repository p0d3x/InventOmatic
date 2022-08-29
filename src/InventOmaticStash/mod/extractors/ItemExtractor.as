package extractors {
public class ItemExtractor extends BaseItemExtractor {

    public static const MOD_NAME:String = "Invent-O-Matic-Extractor";

    public function ItemExtractor(consumer:InventoryConsumer, config:*) {
        super(MOD_NAME, Version.ITEM_EXTRACTOR, consumer, config);
    }

    public override function buildOutputObject():Object {
        var outputObject:Object = super.buildOutputObject();

        var charData:Object = GameApiDataExtractor.getCharacterInfoData();
        var acData:Object = GameApiDataExtractor.getAccountInfoData();

        var characterInventory:Object = {};
        characterInventory.playerInventory = this.playerInventory;
        characterInventory.stashInventory = this.stashInventory;
        characterInventory.AccountInfoData = {
            name: acData.name
        };
        characterInventory.CharacterInfoData = {
            name: charData.name,
            level: charData.level
        };

        outputObject.characterInventories = {};
        outputObject.characterInventories[charData.name] = characterInventory
        return outputObject;
    }

    override public function isValidMode(menuMode:uint):Boolean {
        return true;
    }
}
}