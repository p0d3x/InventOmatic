package modules {
public class ExtractorModuleConfig extends BaseModuleConfig {

    private var _additionalItemDataForAll:Boolean = false;
    private var _postTarget:Object = null;
    private var _postToUrl:Boolean = false;
    private var _writeToFile:Boolean = false;

    public function ExtractorModuleConfig() {
        super(false, 79);
    }

    public function set additionalItemDataForAll(additionalItemDataForAll:Boolean):void {
        _additionalItemDataForAll = additionalItemDataForAll;
    }

    public function set writeToFile(writeToFile:Boolean):void {
        _writeToFile = writeToFile;
    }

    public function set postToUrl(postToUrl:Boolean):void {
        _postToUrl = postToUrl;
    }

    public function set postTarget(postTarget:Object):void {
        if (postTarget && postTarget.host && postTarget.port && postTarget.path) {
            _postTarget = postTarget;
        }
    }

    public function get additionalItemDataForAll():Boolean {
        return _additionalItemDataForAll;
    }

    public function get postTarget():Object {
        return _postTarget;
    }

    public function get postToUrl():Boolean {
        return _postToUrl;
    }

    public function get writeToFile():Boolean {
        return _writeToFile;
    }
}
}
