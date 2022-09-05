package modules.devtools {
import modules.*;

public class DevToolsModuleConfig extends BaseModuleConfig {
    private var _apiMethods:Array;
    public function DevToolsModuleConfig() {
        super(false, 78);
    }

    public function set apiMethods(apiMethods:Array):void {
        _apiMethods = apiMethods;
    }

    public function get apiMethods():Array {
        return _apiMethods;
    }
}
}
