package modules {
public class ScrapModuleConfig extends BaseModuleConfig {
    private var _maxItems:int = -1;
    private var _maxStacks:int = -1;
    private var _types:Array = [];
    private var _excluded:Array = [];
    public function ScrapModuleConfig() {
        super(false, 73);
    }

    public function set maxItems(maxItems:int):void {
        _maxItems = maxItems;
    }

    public function set maxStacks(maxStacks:int):void {
        _maxStacks = maxStacks;
    }

    public function set types(types:Array):void {
        if (!!types) {
            _types = types;
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

    public function get types():Array {
        return _types;
    }

    public function get excluded():Array {
        return _excluded;
    }
}
}
