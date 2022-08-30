package modules {
import Shared.AS3.BSButtonHintData;
import Shared.GlobalFunc;

import flash.display.Stage;

import flash.events.KeyboardEvent;

import flash.ui.Keyboard;

import flash.utils.Dictionary;
import flash.utils.describeType;

import utils.Logger;

public class BaseModule {

    static var keyDict:Dictionary = getKeyboardDict();

    protected var config:BaseModuleConfig;
    protected var _buttonText:String = "<no text>";
    protected var _active:Boolean = false;

    public function BaseModule(config:BaseModuleConfig) {
        this.config = config;
        _active = config && config.enabled && config.keyCode;
    }

    public function getButtonHint():BSButtonHintData {
        if (!_active) {
            return undefined;
        }
        var button:BSButtonHintData =
                new BSButtonHintData(_buttonText, getKey(), "PSN_Start","Xenon_Start", 1, execute);
        button.ButtonVisible = true;
        button.ButtonDisabled = false;
        return button;
    }

    public function get buttonText():String {
        return _buttonText;
    }

    protected function getKey():String {
        return keyDict[config.keyCode];
    }

    public function get active():Boolean {
        return _active;
    }

    public function registerKeyUpListener(stage:Stage):void {
        stage.addEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
    }

    private function keyUpHandler(e:KeyboardEvent):void {
        if (_active && e.keyCode == config.keyCode) {
            execute();
        }
    }

    protected function execute():void {
        // to be implemented by subclasses
    }

    static function getKeyboardDict():Dictionary {
        var keyDescription:XML = describeType(Keyboard);
        var keyNames:XMLList = keyDescription..constant.@name;

        var keyboardDict:Dictionary = new Dictionary();

        var len:int = keyNames.length();
        for(var i:int = 0; i < len; i++) {
            keyboardDict[Keyboard[keyNames[i]]] = keyNames[i];
        }

        return keyboardDict;
    }

    public static function ShowHUDMessage(text:String, force:Boolean = false):void {
        if (Logger.DEBUG_MODE || force) {
            GlobalFunc.ShowHUDMessage("[Invent-O-Matic-Stash v" + Version.LOADER + "] " + text);
        }
    }
}
}
