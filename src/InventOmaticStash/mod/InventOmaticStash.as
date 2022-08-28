package {
import Shared.AS3.BSButtonHintBar;
import Shared.AS3.BSButtonHintData;
import Shared.GlobalFunc;

import com.adobe.serialization.json.JSONDecoder;

import extractors.BaseItemExtractor;
import extractors.ItemExtractor;
import extractors.VendorPriceCheckExtractor;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;

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
            ShowHUDMessage("Error loading mod " + e);
        }
    }

    private function init():void {
        try {
            this.initButtonHints();
            stage.addEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
            var extractorToUse:BaseItemExtractor = this._priceCheckItemExtractor;
            if (!extractorToUse.isValidMode(this.parentClip.m_MenuMode)) {
                extractorToUse = this._itemExtractor;
            }
            ShowHUDMessage("Loaded extractor: " + extractorToUse.getExtractorName())
        } catch (e:Error) {
            Logger.get().errorHandler("Error init buttons", e);
        }
    }

    private function initButtonHints():void {
        if (buttonHintBar == null) {
            ShowHUDMessage("Unexpected error while adding extract button!");
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

        if (config.extractConfig && config.extractConfig.enabled) {
            Logger.get().debug("adding Extract button");
            var extractButton:BSButtonHintData = new BSButtonHintData("Extract items", "O", "PSN_Start",
                    "Xenon_Start", 1, this.extractDataCallback);
            extractButton.ButtonVisible = true;
            extractButton.ButtonDisabled = false;
            buttons.push(extractButton);
        } else {
            Logger.get().debug("Extract not enabled, not adding Extract button");
        }

        if (config.transferConfig && config.transferConfig.enabled) {
            Logger.get().debug("adding Transfer button");
            var transferButton:BSButtonHintData = new BSButtonHintData("Transfer items", "P", "PSN_Start",
                    "Xenon_Start", 1, this.transferItemsCallback);
            transferButton.ButtonVisible = true;
            transferButton.ButtonDisabled = false;
            buttons.push(transferButton);
        } else {
            Logger.get().debug("Transfer not enabled, not adding Extract button");
        }

        if (config.scrapConfig && config.scrapConfig.enabled) {
            Logger.get().debug("adding Scrap button");
            var scrapItemsButton:BSButtonHintData = new BSButtonHintData("Scrap items", "I", "PSN_Start",
                    "Xenon_Start", 1, this.scrapItemsCallback);
            scrapItemsButton.ButtonVisible = true;
            scrapItemsButton.ButtonDisabled = false;
            buttons.push(scrapItemsButton);
        } else {
            Logger.get().debug("Scrap not enabled, not adding Extract button");
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

    public function extractDataCallback():void {
        try {
            var extractorToUse:BaseItemExtractor = this._priceCheckItemExtractor;
            if (!extractorToUse.isValidMode(this.parentClip.m_MenuMode)) {
                extractorToUse = this._itemExtractor;
            }
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
        ShowHUDMessage("Mod Initializing");
        this._parent = parent;
        this._itemExtractor = new ItemExtractor(_parent);
        this._priceCheckItemExtractor = new VendorPriceCheckExtractor(_parent);
        this._itemWorker = new ItemWorker();
        this.buttonHintBar = _parent.ButtonHintBar_mc;
        loadConfig();
    }

    private function loadConfig():void {
        try {
            ShowHUDMessage("Loading config file");
            var url:URLRequest = new URLRequest("../inventOmaticStashConfigNew.json");
            var loader:URLLoader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE, loaderComplete);

            function loaderComplete(e:Event):void {
                var jsonData:Object = new JSONDecoder(loader.data, true).getValue();
                config = jsonData;
                if (config.extractConfig && config.extractConfig.enabled) {
                    _itemExtractor.verboseOutput = config.extractConfig.verboseOutput;
                    _itemExtractor.apiMethods = config.extractConfig.apiMethods;
                    _itemExtractor.additionalItemDataForAll = config.extractConfig.additionalItemDataForAll;
                    _itemExtractor.writeToFile = config.extractConfig.writeToFile;
                    _itemExtractor.postToUrl = config.extractConfig.postToUrl;
                    _itemExtractor.url = config.extractConfig.url;
                    _priceCheckItemExtractor.verboseOutput = config.extractConfig.verboseOutput;
                    _priceCheckItemExtractor.apiMethods = config.extractConfig.apiMethods;
                    _priceCheckItemExtractor.additionalItemDataForAll = config.extractConfig.additionalItemDataForAll;
                    _priceCheckItemExtractor.writeToFile = config.extractConfig.writeToFile;
                    _priceCheckItemExtractor.postToUrl = config.extractConfig.postToUrl;
                    _priceCheckItemExtractor.url = config.extractConfig.url;
                }
                Logger.get().debugMode = config.debug;
                ShowHUDMessage("Config file is loaded!");
                init();
            }
        } catch (e:Error) {
            ShowHUDMessage("Failed to load config: " + e.message, true);
        }
    }

    public function get parentClip():MovieClip {
        return _parent;
    }

    private function keyUpHandler(e:KeyboardEvent):void {
        // o
        if (e.keyCode == 79 && config.extractConfig && config.extractConfig.enabled) {
            extractDataCallback();
            // p
        } else if (e.keyCode == 80 && config.transferConfig && config.transferConfig.enabled) {
            transferItemsCallback();
            // i
        } else if (e.keyCode == 73 && config.scrapConfig && config.scrapConfig.enabled) {
            scrapItemsCallback();
        }
    }

    public static function ShowHUDMessage(text:String, force:Boolean = false):void {
        if (Logger.DEBUG_MODE || force) {
            GlobalFunc.ShowHUDMessage("[Invent-O-Matic-Stash v" + Version.LOADER + "] " + text);
        }
    }
}
}
