package {
import Shared.AS3.BSButtonHintData;
import Shared.GlobalFunc;

import com.adobe.serialization.json.JSONDecoder;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.utils.setTimeout;

import modules.BaseModule;
import modules.devtools.DevToolsModule;
import modules.extractor.ExtractorModule;
import modules.market.SelectedItemPriceCheckModule;
import modules.scrap.ScrapModule;
import modules.transfer.TransferModule;

import mx.utils.StringUtil;

import utils.Logger;

public class InventOmaticStash extends MovieClip {

    public var debugLogger:TextField;
    protected var _parent:MovieClip;
    protected var config:InventOmaticStashConfig;
    protected var moduleArray:Array;

    public function InventOmaticStash() {
        super();
        try {
            Logger.init(this.debugLogger);
        } catch (e:Error) {
            ShowHUDMessage(Logger.LOG_LEVEL_ERROR, "Error loading mod: {0}", e);
            Logger.get().error("Error loading mod: {0}", e);
        }
    }

    //noinspection JSUnusedGlobalSymbols
    public function setParent(parent:MovieClip):void {
        Logger.get().debug("Mod Initializing");
        this._parent = parent;
        setTimeout(loadConfigAndInit, 1000);
    }

    private function loadConfigAndInit():void {
        try {
            Logger.get().debug("Loading config file");
            var url:URLRequest = new URLRequest("../inventOmaticStashConfig.json");
            var loader:URLLoader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE, loaderComplete);

            function loaderComplete(e:Event):void {
                var jsonData:Object = new JSONDecoder(loader.data, true).getValue();
                config = new InventOmaticStashConfig(jsonData);
                Logger.get().debugWindowVisible(config.debug);
                Logger.get().logLevel = config.logLevel;
                Logger.get().debug("Config file is loaded!");
                init();
            }
        } catch (e:Error) {
            ShowHUDMessage(Logger.LOG_LEVEL_ERROR, "Failed to load config: {0}", e.message);
            Logger.get().error("Failed to load config: {0}", e);
        }
    }

    private function init():void {

        if (_parent.ButtonHintBar_mc == null) {
            Logger.get().error("Error getting button hint bar from parent.");
            return;
        }

        var priceCheckModule:SelectedItemPriceCheckModule
                = new SelectedItemPriceCheckModule(_parent, config.priceCheckConfig);
        moduleArray = [
            new ExtractorModule(_parent, config.extractConfig, priceCheckModule),
            new TransferModule(_parent, config.transferConfig),
            new ScrapModule(_parent, config.scrapConfig),
            new DevToolsModule(_parent.__SFCodeObj, config.devToolsConfig),
            priceCheckModule
        ];
        try {
            var buttons:Vector.<BSButtonHintData> = _parent.ButtonHintDataV;
            for (var i:int = 0; i < moduleArray.length; i++) {
                var module:BaseModule = moduleArray[i];
                if (module.active) {
                    Logger.get().debug("module {0} is active, adding button/key-listener", module.buttonText);
                    module.registerKeyUpListener(stage);
                    var hint:BSButtonHintData = module.getButtonHint();
                    if (hint) {
                        buttons.push(hint);
                    }
                } else {
                    Logger.get().debug("module {0} is not active", module.buttonText);
                }
            }
            stage.addEventListener(KeyboardEvent.KEY_UP, function (e:*):void {
                if (e.keyCode == config.toggleDebugKeyCode) { // '#' on german keyboard
                    Logger.get().trace("toggle debug window");
                    Logger.get().toggleWindowVisible();
                    _parent.ButtonHintBar_mc.redrawDisplayObject();
                }
            });

            _parent.ButtonHintBar_mc.SetButtonHintData(buttons);
            _parent.ButtonHintBar_mc.onRemovedFromStage();
            _parent.ButtonHintBar_mc.onAddedToStage();
            _parent.ButtonHintBar_mc.redrawDisplayObject();
        } catch (e:Error) {
            Logger.get().error("Error init buttons: {0}", e);
        }
    }

    public static function ShowHUDMessage(logLevel:int, fmt:String, ... args):void {
        if (logLevel < Logger.get().logLevel) {
            return;
        }
        args.unshift(fmt);
        var line:String = StringUtil.substitute.apply(null, args);
        var message:String = StringUtil.substitute("[Invent-O-Matic-Stash v{0}] {1}", Version.VERSION, line);
        GlobalFunc.ShowHUDMessage(message);
    }
}
}
