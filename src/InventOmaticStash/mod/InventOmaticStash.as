package {
import Shared.AS3.BSButtonHintBar;
import Shared.AS3.BSButtonHintData;
import Shared.GlobalFunc;

import com.adobe.serialization.json.JSONDecoder;

import extractors.BaseItemExtractor;
import extractors.GameApiDataExtractor;
import extractors.InventoryConsumer;
import extractors.ItemExtractor;
import extractors.VendorPriceCheckExtractor;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.describeType;

import utils.Logger;

public class InventOmaticStash extends MovieClip {

    public var debugLogger:TextField;
    private var _itemExtractor:ItemExtractor;
    private var _priceCheckItemExtractor:VendorPriceCheckExtractor;
    private var _itemWorker:ItemWorker;
    private var _parent:MovieClip;
    public var buttonHintBar:BSButtonHintBar;
    public var config:Object;

    public function InventOmaticStash() {
        super();
        try {
            Logger.DEBUG_MODE = true;
            Logger.init(this.debugLogger);
        } catch (e:Error) {
            Logger.get().error(e);
            ShowHUDMessage("Error loading mod " + e, true);
        }
    }

    private function init():void {
        try {
            this.initButtonHints();
            stage.addEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
        } catch (e:Error) {
            Logger.get().errorHandler("Error init buttons", e);
        }
    }

    function getKeyboardDict():Dictionary {
        var keyDescription:XML = describeType(Keyboard);
        var keyNames:XMLList = keyDescription..constant.@name;

        var keyboardDict:Dictionary = new Dictionary();

        var len:int = keyNames.length();
        for(var i:int = 0; i < len; i++) {
            keyboardDict[Keyboard[keyNames[i]]] = keyNames[i];
        }

        return keyboardDict;
    }

    private function initButtonHints():void {
        if (buttonHintBar == null) {
            ShowHUDMessage("Unexpected error while adding buttons!");
            Logger.get().error("Error getting button hint bar from parent.");
            return;
        }

        // noinspection JSValidateTypes
        var buttons:Vector.<BSButtonHintData>;
        try {
            buttons = this.parentClip.ButtonHintDataV;
        } catch (e:Error) {
            Logger.get().errorHandler("Error getting button hints from parent: ", e);
            return;
        }

        var keyDict:Dictionary = getKeyboardDict();

        if (config.extractConfig && config.extractConfig.enabled && config.extractConfig.keyCode) {
            Logger.get().debug("adding Extract button");
            var button:BSButtonHintData = buttonWithCallback("Extract Items",
                    keyDict[config.extractConfig.keyCode], this.extractDataCallback);
            buttons.push(button);
        } else {
            Logger.get().debug("Extract not enabled, not adding Extract button");
        }

        if (config.devToolsConfig && config.devToolsConfig.enabled && config.devToolsConfig.keyCode) {
            Logger.get().debug("adding API-Extract button");
            var button:BSButtonHintData = buttonWithCallback("Extract API",
                    keyDict[config.devToolsConfig.keyCode], this.devToolsDebugCallback);
            buttons.push(button);
        } else {
            Logger.get().debug("DevTools not enabled, not adding Extract-API button");
        }

        if (config.transferConfig && config.transferConfig.enabled && config.transferConfig.keyCode) {
            Logger.get().debug("adding Transfer button");
            var button:BSButtonHintData = buttonWithCallback("Transfer items",
                    keyDict[config.transferConfig.keyCode], this.transferItemsCallback);
            buttons.push(button);
        } else {
            Logger.get().debug("Transfer not enabled, not adding Transfer button");
        }

        if (config.scrapConfig && config.scrapConfig.enabled && config.scrapConfig.keyCode) {
            Logger.get().debug("adding Scrap button");
            var button:BSButtonHintData = buttonWithCallback("Scrap items",
                    keyDict[config.scrapConfig.keyCode], this.scrapItemsCallback);
            buttons.push(button);
        } else {
            Logger.get().debug("Scrap not enabled, not adding Scrap button");
        }

        try {
            buttonHintBar.SetButtonHintData(buttons);
            buttonHintBar.onRemovedFromStage();
            buttonHintBar.onAddedToStage();
            buttonHintBar.redrawDisplayObject();
        } catch (e:Error) {
            Logger.get().error("Error setting new button hints data: " + e);
        }
    }

    private function buttonWithCallback(title:String, key:String, callback:Function):BSButtonHintData {
        var extractButton:BSButtonHintData = new BSButtonHintData(title, key, "PSN_Start",
                "Xenon_Start", 1, callback);
        extractButton.ButtonVisible = true;
        extractButton.ButtonDisabled = false;
        return extractButton;
    }

    public function devToolsDebugCallback():void {
        if (!isSfeDefined()) {
            Logger.get().error("SFE not found, cannot extract!");
            return;
        }
        var devToolsExtractor:GameApiDataExtractor = new GameApiDataExtractor(_parent.__SFCodeObj, config.devToolsConfig);
        devToolsExtractor.extract();
    }

    public function extractDataCallback():void {
        try {
            var extractorToUse:BaseItemExtractor = this._priceCheckItemExtractor;
            if (!extractorToUse.isValidMode(this.parentClip.m_MenuMode)) {
                extractorToUse = this._itemExtractor;
            }
            ShowHUDMessage("Loaded extractor: " + extractorToUse.getExtractorName())
            extractorToUse.setInventory(this.parentClip);
        } catch (e:Error) {
            ShowHUDMessage("Error extracting items(init): " + e, true);
        }
    }

    public function transferItemsCallback():void {
        try {
            _itemWorker.stashInventory = this.parentClip.OfferInventory_mc.ItemList_mc.List_mc.MenuListData;
            _itemWorker.playerInventory = this.parentClip.PlayerInventory_mc.ItemList_mc.List_mc.MenuListData;
            _itemWorker.config = config;
            _itemWorker.transferItems();
        } catch (e:Error) {
            ShowHUDMessage("Error transferring items: " + e, true);
        }
    }

    public function scrapItemsCallback(): void {
        try {
            if (!this.parentClip.m_isWorkbench) {
                ShowHUDMessage("Items auto scrap allowed only on workbenches!", true);
                return;
            }
            _itemWorker.playerInventory = this.parentClip.PlayerInventory_mc.ItemList_mc.List_mc.MenuListData;
            _itemWorker.config = config;
            _itemWorker.scrapItems();
        } catch (e:Error) {
            ShowHUDMessage("Error scrapping items: " + e, true);
        }
    }

    //noinspection JSUnusedGlobalSymbols
    public function setParent(parent:MovieClip):void {
        Logger.get().debug("Mod Initializing");
        this._parent = parent;
        this._itemWorker = new ItemWorker();
        this.buttonHintBar = _parent.ButtonHintBar_mc;
        loadConfig();
    }

    public function isSfeDefined():Boolean {
        return this._parent.__SFCodeObj != null && this._parent.__SFCodeObj.call != null;
    }

    private function loadConfig():void {
        try {
            Logger.get().debug("Loading config file");
            var url:URLRequest = new URLRequest("../inventOmaticStashConfigNew.json");
            var loader:URLLoader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE, loaderComplete);

            function loaderComplete(e:Event):void {
                var jsonData:Object = new JSONDecoder(loader.data, true).getValue();
                config = jsonData;
                if (config.extractConfig && config.extractConfig.enabled) {
                    if (!isSfeDefined()) {
                        ShowHUDMessage("SFE not found, extract disabled!", true);
                        Logger.get().error("SFE not found, extract disabled!");
                        config.extractConfig.enabled = false;
                    } else {
                        var consumer:InventoryConsumer = new InventoryConsumer(_parent.__SFCodeObj, config.extractConfig);
                        _itemExtractor = new ItemExtractor(consumer, config.extractConfig);
                        _priceCheckItemExtractor = new VendorPriceCheckExtractor(consumer, config.extractConfig);
                    }
                }
                Logger.get().debugMode = config.debug;
                Logger.get().debug("Config file is loaded!");
                init();
            }
        } catch (e:Error) {
            ShowHUDMessage("Failed to load config: " + e.message, true);
            Logger.get().errorHandler("Failed to load config", e);
        }
    }

    public function get parentClip():MovieClip {
        return _parent;
    }

    private function keyUpHandler(e:KeyboardEvent):void {
        if (config.extractConfig && config.extractConfig.enabled && e.keyCode == config.extractConfig.keyCode) {
            extractDataCallback();
        } else if (config.transferConfig && config.transferConfig.enabled && e.keyCode == config.transferConfig.keyCode) {
            transferItemsCallback();
        } else if (config.scrapConfig && config.scrapConfig.enabled && e.keyCode == config.scrapConfig.keyCode) {
            scrapItemsCallback();
        } else if (config.devToolsConfig && config.devToolsConfig.enabled && e.keyCode == config.devToolsConfig.keyCode) {
            devToolsDebugCallback();
        }
    }

    public static function ShowHUDMessage(text:String, force:Boolean = false):void {
        if (Logger.DEBUG_MODE || force) {
            GlobalFunc.ShowHUDMessage("[Invent-O-Matic-Stash v" + Version.LOADER + "] " + text);
        }
    }
}
}
