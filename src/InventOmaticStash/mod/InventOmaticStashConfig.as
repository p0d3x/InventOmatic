package {
import flash.ui.Keyboard;

import modules.devtools.DevToolsModuleConfig;
import modules.extractor.ExtractorModuleConfig;
import modules.market.SelectedItemPriceCheckModuleConfig;
import modules.scrap.ScrapModuleConfig;
import modules.transfer.TransferModuleConfig;

import utils.Logger;

public class InventOmaticStashConfig {
    private var _debug:Boolean = false;
    private var _logLevel:int = Logger.LOG_LEVEL_INFO;
    private var _toggleDebugKeyCode:uint = Keyboard.SLASH;
    private var _extractConfig:ExtractorModuleConfig = new ExtractorModuleConfig();
    private var _transferConfig:TransferModuleConfig = new TransferModuleConfig();
    private var _scrapConfig:ScrapModuleConfig = new ScrapModuleConfig();
    private var _devToolsConfig:DevToolsModuleConfig = new DevToolsModuleConfig();
    private var _priceCheckConfig:SelectedItemPriceCheckModuleConfig = new SelectedItemPriceCheckModuleConfig();
    // not yet implemented
    //private var _priceCheckConfig:ExtractorModuleConfig = new ExtractorModuleConfig();

    public function InventOmaticStashConfig(loadedConfig:Object) {
        if (!loadedConfig) {
            return;
        }
        debug = loadedConfig.debug;
        toggleDebugKeyCode = loadedConfig.toggleDebugKeyCode ? loadedConfig.toggleDebugKeyCode : Keyboard.SLASH;
        logLevelFromName(loadedConfig.logLevel);
        mergeExtractConfig(loadedConfig.extractConfig, loadedConfig);
        mergeTransferConfig(loadedConfig.transferConfig);
        mergeScrapConfig(loadedConfig.scrapConfig);
        mergeDevToolsConfig(loadedConfig.devToolsConfig, loadedConfig);
        mergeItemPriceCheckConfig(loadedConfig.priceCheckConfig);
    }

    private function mergeExtractConfig(extractConfig:Object, legacyConfig:Object):void {
        if (!extractConfig) {
            _extractConfig.enabled = true;
            _extractConfig.additionalItemDataForAll = legacyConfig.additionalItemDataForAll;
            _extractConfig.writeToFile = true;
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
        _scrapConfig.dryRun = scrapConfig.dryRun;
        _scrapConfig.maxItems = scrapConfig.maxItems;
        _scrapConfig.maxStacks = scrapConfig.maxStacks;
        _scrapConfig.filterFlags = scrapConfig.types;
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

    private function mergeItemPriceCheckConfig(priceCheckConfig:Object):void {
        if (!priceCheckConfig) {
            _priceCheckConfig.enabled = false;
        } else {
            _priceCheckConfig.enabled = priceCheckConfig.enabled;
            _priceCheckConfig.keyCode = priceCheckConfig.keyCode;
            _priceCheckConfig.postTarget = priceCheckConfig.postTarget;
        }
    }

    public function set debug(debug:Boolean):void {
        _debug = debug;
    }

    public function get debug():Boolean {
        return _debug;
    }

    public function get toggleDebugKeyCode():uint {
        return _toggleDebugKeyCode;
    }

    public function set toggleDebugKeyCode(value:uint):void {
        _toggleDebugKeyCode = value;
    }

    public function logLevelFromName(logLevel:String):void {
        if (!logLevel) {
            return;
        }
        switch (logLevel) {
            case "TRACE":
                _logLevel = Logger.LOG_LEVEL_TRACE;
                break;
            case "DEBUG":
                _logLevel = Logger.LOG_LEVEL_DEBUG;
                break;
            case "INFO":
                _logLevel = Logger.LOG_LEVEL_INFO;
                break;
            case "WARN":
                _logLevel = Logger.LOG_LEVEL_WARN;
                break;
            case "ERROR":
                _logLevel = Logger.LOG_LEVEL_ERROR;
                break;
        }
        Logger.get().info("log level set to {0} ({1})", _logLevel, logLevel);
    }

    public function get logLevel():int {
        return _logLevel;
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

    public function get priceCheckConfig():SelectedItemPriceCheckModuleConfig {
        return _priceCheckConfig;
    }
}
}
