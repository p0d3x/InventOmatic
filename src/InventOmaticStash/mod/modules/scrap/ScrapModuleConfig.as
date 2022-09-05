package modules.scrap {
import modules.*;

public class ScrapModuleConfig extends BaseModuleConfig {
    private var _dryRun:Boolean = false;
    private var _maxItems:int = -1;
    private var _maxStacks:int = -1;
    private var _filterFlags:Array = [];
    private var _excluded:Array = [];
    public function ScrapModuleConfig() {
        super(false, 73);
    }

    public function get dryRun():Boolean {
        return _dryRun;
    }

    public function set dryRun(value:Boolean):void {
        _dryRun = value;
    }

    public function set maxItems(maxItems:int):void {
        _maxItems = maxItems;
    }

    public function set maxStacks(maxStacks:int):void {
        _maxStacks = maxStacks;
    }

    public function set filterFlags(types:Array):void {
        if (!!types) {
            _filterFlags = types.map(function(arg:String):uint {
                switch(arg) {
                    case "WEAPON":
                        return 1 << 2;
                    case "ARMOR":
                        return 1 << 3;
                    case "APPAREL":
                        return 1 << 4;
                    case "FOOD_WATER":
                        return 1 << 5;
                    case "AID":
                        return 1 << 6;
                    case "NOTES":
                        return 1 << 10;
                    case "MISC":
                        return 1 << 12;
                    case "JUNK":
                        return 1 << 13;
                    case "MODS":
                        return 1 << 14;
                    case "AMMO":
                        return 1 << 15;
                    case "HOLO":
                        return 1 << 16;
                }
                return 0;
            });
        }
    }

    public function set excluded(excluded:Array):void {
        if (!!excluded) {
            _excluded = excluded;
        }
    }

    public function get maxItems():int {
        return _maxItems;
    }

    public function get maxStacks():int {
        return _maxStacks;
    }

    public function get filterFlags():Array {
        return _filterFlags;
    }

    public function get excluded():Array {
        return _excluded;
    }
}
}
