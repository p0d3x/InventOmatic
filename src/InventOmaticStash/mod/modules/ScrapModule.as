package modules {
import utils.Logger;

public class ScrapModule extends BaseModule {

    private var playerInventory:Object;

    public function ScrapModule(parent:Object, config:ScrapModuleConfig) {
        super(config);
        this._buttonText = "Scrap items";
        this.playerInventory = parent.PlayerInventory_mc;
        this._active = _active && parent.m_isWorkbench;
    }

    protected override function execute(): void {
        if (!_active) {
            Logger.get().error("Scrap disabled, cannot extract!");
            return;
        }
        try {
            var itemWorker:ScrapItemWorker = new ScrapItemWorker();
            itemWorker.playerInventory = playerInventory.ItemList_mc.List_mc.MenuListData;
            itemWorker.config = ScrapModuleConfig(config);
            itemWorker.scrapItems();
        } catch (e:Error) {
            InventOmaticStash.ShowHUDMessage("Error scrapping items: " + e, Logger.LOG_LEVEL_ERROR);
            Logger.get().error("Error scrapping items: {0}", e);
        }
    }
}
}
