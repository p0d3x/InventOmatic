package modules.transfer {
import Shared.AS3.SecureTradeShared;

import modules.*;

import utils.Logger;

public class TransferModule extends BaseModule {

    private var playerInventory:Object;
    private var offerInventory:Object;

    public function TransferModule(parent:Object, config:*) {
        super(config);
        this._buttonText = "Transfer items";
        this.playerInventory = parent.PlayerInventory_mc;
        this.offerInventory = parent.OfferInventory_mc;
        this._active = _active && !parent.m_isWorkbench
                && (parent.m_MenuMode == SecureTradeShared.MODE_CONTAINER
                        || parent.m_MenuMode == SecureTradeShared.MODE_FERMENTER
                        || parent.m_MenuMode == SecureTradeShared.MODE_ALLY
                        || parent.m_MenuMode == SecureTradeShared.MODE_CAMP_DISPENSER
                        || parent.m_MenuMode == SecureTradeShared.MODE_DISPLAY_CASE
                        || parent.m_MenuMode == SecureTradeShared.MODE_REFRIGERATOR);
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
            InventOmaticStash.ShowHUDMessage(Logger.LOG_LEVEL_ERROR, "Error transferring items: {0}", e);
            Logger.get().error("Error transferring items: {0}", e);
        }
    }
}
}
