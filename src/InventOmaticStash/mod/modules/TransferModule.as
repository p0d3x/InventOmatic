package modules {

import utils.Logger;

public class TransferModule extends BaseModule {

    private var playerInventory:Object;
    private var offerInventory:Object;

    public function TransferModule(parent:Object, config:*) {
        super(config);
        this._buttonText = "Transfer items";
        this.playerInventory = parent.PlayerInventory_mc;
        this.offerInventory = parent.OfferInventory_mc;
    }

    protected override function execute():void {
        if (!_active) {
            Logger.get().error("Transfer disabled, cannot extract!");
            return;
        }
        try {
            var itemWorker:TransferItemWorker = new TransferItemWorker();
            itemWorker.stashInventory = offerInventory.ItemList_mc.List_mc.MenuListData;
            itemWorker.playerInventory = playerInventory.ItemList_mc.List_mc.MenuListData;
            itemWorker.config = TransferModuleConfig(config);
            itemWorker.transferItems();
        } catch (e:Error) {
            ShowHUDMessage("Error transferring items: " + e, true);
        }
    }
}
}
