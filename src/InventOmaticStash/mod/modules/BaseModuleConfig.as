package modules {
public class BaseModuleConfig {

    private var _enabled:Boolean;
    private var _keyCode:uint;

    public function BaseModuleConfig(enabled:Boolean, keyCode:uint) {
        _enabled = enabled;
        _keyCode = keyCode;
    }

    public function set enabled(enabled:Boolean):void {
        _enabled = enabled;
    }

    public function set keyCode(keyCode:uint):void {
        if (!!keyCode) {
            _keyCode = keyCode;
        }
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function get keyCode():uint {
        return _keyCode;
    }
}
}
