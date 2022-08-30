package modules {
public class TransferModuleConfig extends BaseModuleConfig {
    private var _itemNames:Array;
    private var _matchMode:String;
    private var _direction:String;
    public function TransferModuleConfig() {
        super(false, 80);
    }

    public function set itemNames(itemNames:Array):void {
        _itemNames = itemNames;
    }

    public function set matchMode(matchMode:String):void {
        _matchMode = matchMode;
    }

    public function set direction(direction:String):void {
        _direction = direction;
    }

    public function get itemNames():Array {
        return _itemNames;
    }

    public function get matchMode():String {
        return _matchMode;
    }

    public function get direction():String {
        return _direction;
    }
}
}
