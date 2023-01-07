package modules.market {

import modules.BaseModuleConfig;

public class SelectedItemPriceCheckModuleConfig extends BaseModuleConfig {
    private var _postTarget:Object = null;
    public function SelectedItemPriceCheckModuleConfig() {
        super(false, 73);
    }

    public function get postTarget():Object {
        return _postTarget;
    }

    public function set postTarget(value:Object):void {
        _postTarget = value;
    }
}
}
