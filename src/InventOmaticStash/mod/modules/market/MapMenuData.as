package modules.market {
public class MapMenuData {

    public var mapIsReady:Boolean = false;
    public var inTargetingMode:Boolean = false;
    public var inRespawnMode:Boolean = false;
    public var inQuickPlaySpawnPickMode:Boolean = false;
    public var isQuickPlaySpawnPointSet:Boolean = false;
    public var isQuickPlaySpawnPickerAllowInput:Boolean = false;
    public var nukeBlastRadius:Number = 0;
    public var savedZoomScale:Number = 0;
    public var StartX:Number = 0;
    public var StartY:Number = 0;
    public var imageData:Object = {};
    public var MarkerData:Array = [];
    public var NonNukableAreas:Array = [];

    public function MapMenuData() {
    }
}
}
