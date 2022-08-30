package {
import modules.DevToolsModuleConfig;
import modules.ExtractorModuleConfig;
import modules.ScrapModuleConfig;
import modules.TransferModuleConfig;

public class InventOmaticStashConfig {

    private var _debug:Boolean = false;
    private var _extractConfig:ExtractorModuleConfig = new ExtractorModuleConfig();
    private var _transferConfig:TransferModuleConfig = new TransferModuleConfig();
    private var _scrapConfig:ScrapModuleConfig = new ScrapModuleConfig();
    private var _devToolsConfig:DevToolsModuleConfig = new DevToolsModuleConfig();
    // not yet implemented
    //private var _priceCheckConfig:ExtractorModuleConfig = new ExtractorModuleConfig();

    public function InventOmaticStashConfig(loadedConfig:Object) {
        if (!loadedConfig) {
            return;
        }
        debug = loadedConfig.debug;
        mergeExtractConfig(loadedConfig.extractConfig, loadedConfig);
        mergeTransferConfig(loadedConfig.transferConfig);
        mergeScrapConfig(loadedConfig.scrapConfig);
        mergeDevToolsConfig(loadedConfig.devToolsConfig, loadedConfig);
    }

    private function mergeExtractConfig(extractConfig:Object, legacyConfig:Object):void {
        if (!extractConfig) {
            _extractConfig.enabled = true;
            _extractConfig.additionalItemDataForAll = legacyConfig.additionalItemDataForAll;
        } else {
            _extractConfig.enabled = extractConfig.enabled;
            _extractConfig.additionalItemDataForAll = extractConfig.additionalItemDataForAll;
            _extractConfig.writeToFile = extractConfig.writeToFile;
            _extractConfig.postToUrl = extractConfig.postToUrl;
            _extractConfig.postTarget = extractConfig.postTarget;
            _extractConfig.keyCode = extractConfig.keyCode;
        }
    }

    private function mergeTransferConfig(transferConfig:Object):void {
        if (!transferConfig) {
            return;
        }
        _transferConfig.enabled = transferConfig.enabled;
        _transferConfig.itemNames = transferConfig.itemNames;
        _transferConfig.matchMode = transferConfig.matchMode;
        _transferConfig.direction = transferConfig.direction;
        _transferConfig.keyCode = transferConfig.keyCode;
    }

    private function mergeScrapConfig(scrapConfig:Object):void {
        if (!scrapConfig) {
            return;
        }
        _scrapConfig.enabled = scrapConfig.enabled;
        _scrapConfig.maxItems = scrapConfig.maxItems;
        _scrapConfig.maxStacks = scrapConfig.maxStacks;
        _scrapConfig.types = scrapConfig.types;
        _scrapConfig.excluded = scrapConfig.excluded;
        _scrapConfig.keyCode = scrapConfig.keyCode;
    }

    private function mergeDevToolsConfig(devToolsConfig:Object, legacyConfig:Object):void {
        if (!devToolsConfig) {
            _devToolsConfig.enabled = legacyConfig.verboseOutput;
            _devToolsConfig.apiMethods = legacyConfig.apiMethods;
        } else {
            _devToolsConfig.enabled = devToolsConfig.enabled;
            _devToolsConfig.apiMethods = devToolsConfig.apiMethods;
            _devToolsConfig.keyCode = devToolsConfig.keyCode;
        }
    }

    public function set debug(debug:Boolean):void {
        _debug = debug;
    }

    public function get debug():Boolean {
        return _debug;
    }

    public function get extractConfig():ExtractorModuleConfig {
        return _extractConfig;
    }

    public function get transferConfig():TransferModuleConfig {
        return _transferConfig;
    }

    public function get scrapConfig():ScrapModuleConfig {
        return _scrapConfig;
    }

    public function get devToolsConfig():DevToolsModuleConfig {
        return _devToolsConfig;
    }
}
}
