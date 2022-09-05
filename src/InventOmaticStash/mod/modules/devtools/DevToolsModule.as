package modules.devtools {
import modules.*;

import utils.Logger;

public class DevToolsModule extends BaseModule {

    private var sfCodeObj:Object;

    public function DevToolsModule(sfCodeObj:Object, config:DevToolsModuleConfig) {
        super(config);
        this.sfCodeObj = sfCodeObj;
        this._buttonText = "Extract API";
        if (!_active) {
            return;
        }
        if (sfCodeObj == null || sfCodeObj.call == null) {
            Logger.get().error("SFE not found, extract disabled!");
            config.enabled = false;
            _active = false;
        }
    }

    override protected function execute():void {
        if (!_active) {
            Logger.get().error("DevTools disabled, cannot extract!");
            return;
        }
        var devToolsExtractor:GameApiDataExtractor = new GameApiDataExtractor(sfCodeObj, DevToolsModuleConfig(config));
        devToolsExtractor.extract();
    }
}
}
