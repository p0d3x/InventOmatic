package modules {

import extractors.GameApiDataExtractor;

import utils.Logger;

public class DevToolsModule extends BaseModule {

    private var sfeCodeObj:Object;

    public function DevToolsModule(sfeCodeObj:Object, config:DevToolsModuleConfig) {
        super(config);
        this.sfeCodeObj = sfeCodeObj;
        this._buttonText = "Extract API";
        if (!_active) {
            return;
        }
        if (sfeCodeObj == null || sfeCodeObj.call == null) {
            InventOmaticStash.ShowHUDMessage("SFE not found, dev tools disabled!", Logger.LOG_LEVEL_ERROR);
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
        var devToolsExtractor:GameApiDataExtractor = new GameApiDataExtractor(sfeCodeObj, DevToolsModuleConfig(config));
        devToolsExtractor.extract();
    }
}
}
