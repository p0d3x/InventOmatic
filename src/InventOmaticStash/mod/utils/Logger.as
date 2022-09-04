package utils {

import com.adobe.serialization.json.JSON;

import flash.text.TextField;
import flash.utils.getQualifiedClassName;

import mx.utils.StringUtil;

public class Logger {

    public static var LOG_LEVEL_TRACE:int = 1;
    public static var LOG_LEVEL_DEBUG:int = 2;
    public static var LOG_LEVEL_INFO:int = 3;
    public static var LOG_LEVEL_WARN:int = 4;
    public static var LOG_LEVEL_ERROR:int = 5;

    private static var INSTANCE:Logger;
    private var _debugger:TextField;
    private var _logLevel:int = LOG_LEVEL_TRACE;

    public static function get():Logger {
        return INSTANCE;
    }

    public static function init(debuger:TextField):void {
        // noinspection JSValidateTypes
        INSTANCE = new Logger(debuger);
        INSTANCE.info("###### INIT ######");
    }

    function Logger(debuger:TextField):void {
        this._debugger = debuger;
        this._debugger.visible = false;
        this._debugger.selectable = true;
        this._debugger.mouseWheelEnabled = true;
        this._debugger.mouseEnabled = true;
        this._debugger.useRichTextClipboard = true;
        this._debugger.width = this._debugger.width * 2;
    }

    public function get logLevel():int {
        return _logLevel;
    }

    public function set logLevel(value:int):void {
        _logLevel = value;
    }

    public function debugWindowVisible(debug:Boolean):void {
        this._debugger.visible = debug;
    }

    public function toggleWindowVisible():void {
        this._debugger.visible = !this._debugger.visible;
    }

    public function clear(): void {
        this._debugger.text = "";
    }

    public function trace(fmt:String, ... args):void {
        logWithLevel(LOG_LEVEL_TRACE, "TRACE", fmt, args);
    }

    public function debug(fmt:String, ... args):void {
        logWithLevel(LOG_LEVEL_DEBUG, "DEBUG", fmt, args);
    }

    public function info(fmt:String, ... args):void {
        logWithLevel(LOG_LEVEL_INFO, "INFO", fmt, args);
    }

    public function warn(fmt:String, ... args):void {
        logWithLevel(LOG_LEVEL_WARN, "WARN", fmt, args);
    }

    public function error(fmt:String, ... args):void {
        logWithLevel(LOG_LEVEL_ERROR, "ERROR", fmt, args);
    }

    private function logWithLevel(logLevel:int, logLevelName:String, fmt:String, args:Array):void {
        if (_logLevel > logLevel) {
            return;
        }
        args = args.map(function (arg:Object):String {
            if (typeof(arg) == "object") {
                return convert(arg);
            }
            return arg.toString();
        });
        args.unshift(fmt);
        var logLine = StringUtil.substitute.apply(null, args);
        this._debugger.appendText(StringUtil.substitute("[{0}] {1}\n", logLevelName, logLine));
        this._debugger.scrollV = this._debugger.maxScrollV;
    }

    private static function convert(object:Object):String {
        try {
            return com.adobe.serialization.json.JSON.encode(object);
        } catch (e) {
            if (object == null) {
                return "null object";
            }
        }
        return object.toString();
    }
}
}