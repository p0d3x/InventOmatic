package utils {

import flash.text.TextField;

public class Logger {
    private static const DEBUG_MODE:Boolean = true;
    private static const USE_JSON:Boolean = true;
    private var _debugger:TextField;
    private static var INSTANCE:Logger;

    public static function get():Logger {
        return INSTANCE;
    }

    public static function init(debuger:TextField):void {
        INSTANCE = new Logger(debuger);
    }

    public function Logger(debuger:TextField) {
        this._debugger = debuger;
        this._debugger.visible = true;
        this._debugger.selectable = true;
        this._debugger.mouseWheelEnabled = true;
        this._debugger.mouseEnabled = true;
        this._debugger.useRichTextClipboard = true;
    }

    public function debug(object:Object):void {
        if (!DEBUG_MODE) {
            return;
        }
        trace("[DEBUG]");
        trace(object);
        this._debugger.appendText("[DEBUG] " + convert(object));
        this.nl();
    }

    public function error(object:Object):void {
        if (!DEBUG_MODE) {
            return;
        }
        trace("[ERROR]");
        trace(object);
        this._debugger.appendText("[ERROR] " + convert(object));
        this.nl();
    }

    public function info(object:Object):void {
        if (!DEBUG_MODE) {
            return;
        }
        trace("[INFO]");
        trace(object);
        this._debugger.appendText("[INFO] " + convert(object));
        this.nl();
    }

    public function warn(object:Object):void {
        if (!DEBUG_MODE) {
            return;
        }
        trace("[WARN]");
        trace(object);
        this._debugger.appendText("[WARN] " + convert(object));
        this.nl();
    }

    private function nl():void {
        this._debugger.appendText("\r\n");
        this._debugger.appendText("-----------------");
        this._debugger.appendText("\r\n");
    }

    private static function convert(object:Object):String {
        if (USE_JSON) {
//            return JSON.stringify(object);
        }
        return object.toString();
    }
}
}