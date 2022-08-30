package {
import Shared.AS3.BSButtonHintData;
import Shared.AS3.Data.BSUIDataManager;
import Shared.GlobalFunc;

import com.adobe.serialization.json.JSONDecoder;

import flash.display.MovieClip;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.utils.setTimeout;

import modules.BaseModule;
import modules.DevToolsModule;
import modules.ExtractorModule;
import modules.ScrapModule;
import modules.TransferModule;

import utils.Logger;

public class InventOmaticStash extends MovieClip {

    public var debugLogger:TextField;
    protected var _parent:MovieClip;
    protected var config:InventOmaticStashConfig;
    protected var modules:Array;

    public function InventOmaticStash() {
        super();
        try {
            Logger.DEBUG_MODE = true;
            Logger.init(this.debugLogger);
        } catch (e:Error) {
            ShowHUDMessage("Error loading mod " + e, true);
            Logger.get().error(e);
        }
    }

    //noinspection JSUnusedGlobalSymbols
    public function setParent(parent:MovieClip):void {
        Logger.get().debug("Mod Initializing");
        this._parent = parent;
        setTimeout(loadConfigAndInit, 1000);
        /*
         BSUIDataManager.Subscribe("PlayerInventoryData",this.onPlayerInventoryDataUpdate);
         BSUIDataManager.Subscribe("OtherInventoryTypeData",this.onOtherInvTypeDataUpdate);
         BSUIDataManager.Subscribe("OtherInventoryData",this.onOtherInvDataUpdate);
         BSUIDataManager.Subscribe("MyOffersData",this.onMyOffersDataUpdate);
         BSUIDataManager.Subscribe("TheirOffersData",this.onTheirOffersDataUpdate);
         BSUIDataManager.Subscribe("CharacterInfoData",this.onCharacterInfoDataUpdate);
         BSUIDataManager.Subscribe("ContainerOptionsData",this.onContainerOptionsDataUpdate);
         BSUIDataManager.Subscribe("CampVendingOfferData",this.onCampVendingOfferDataUpdate);
         BSUIDataManager.Subscribe("FireForgetEvent",this.onFFEvent);
         BSUIDataManager.Subscribe("AccountInfoData",this.onAccountInfoUpdate);
         BSUIDataManager.Subscribe("InventoryItemCardData",this.onInventoryItemCardDataUpdate);
         BSUIDataManager.Subscribe("HUDModeData",this.onHudModeDataUpdate);
         */
    }

    private function loadConfigAndInit():void {
        try {
            Logger.get().debug("Loading config file");
            var url:URLRequest = new URLRequest("../inventOmaticStashConfigNew.json");
            var loader:URLLoader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE, loaderComplete);

            function loaderComplete(e:Event):void {
                var jsonData:Object = new JSONDecoder(loader.data, true).getValue();
                config = mergeDefaultConfig(jsonData);
                Logger.get().debugMode = config.debug;
                Logger.get().debug("Config file is loaded!");
                init();
            }
        } catch (e:Error) {
            ShowHUDMessage("Failed to load config: " + e.message, true);
            Logger.get().errorHandler("Failed to load config", e);
        }
    }

    private function mergeDefaultConfig(loadedConfig:Object):InventOmaticStashConfig {
        return new InventOmaticStashConfig(loadedConfig);
    }

    private function init():void {

        if (_parent.ButtonHintBar_mc == null) {
            ShowHUDMessage("Unexpected error while adding buttons!");
            Logger.get().error("Error getting button hint bar from parent.");
            return;
        }

        this.modules = [
            new ExtractorModule(_parent, config.extractConfig),
            new TransferModule(_parent, config.transferConfig),
            new ScrapModule(_parent, config.scrapConfig),
            new DevToolsModule(_parent.__SFCodeObj, config.devToolsConfig)
        ];
        try {
            var buttons:Vector.<BSButtonHintData> = _parent.ButtonHintDataV;
            for (var i:int = 0; i < 4; i++) {
                var module:BaseModule = modules[i];
                if (module.active) {
                    Logger.get().debug("module " + module.buttonText + " is active, adding button/key-listener");
                    module.registerKeyUpListener(stage);
                    var hint:BSButtonHintData = module.getButtonHint();
                    if (hint) {
                        buttons.push(hint);
                    }
                } else {
                    Logger.get().debug("module " + module.buttonText + " is not active");
                }
            }

            _parent.ButtonHintBar_mc.SetButtonHintData(buttons);
            _parent.ButtonHintBar_mc.onRemovedFromStage();
            _parent.ButtonHintBar_mc.onAddedToStage();
            _parent.ButtonHintBar_mc.redrawDisplayObject();
        } catch (e:Error) {
            Logger.get().errorHandler("Error init buttons", e);
        }
    }

    public static function ShowHUDMessage(text:String, force:Boolean = false):void {
        if (Logger.DEBUG_MODE || force) {
            GlobalFunc.ShowHUDMessage("[Invent-O-Matic-Stash v" + Version.LOADER + "] " + text);
        }
    }
}
}
