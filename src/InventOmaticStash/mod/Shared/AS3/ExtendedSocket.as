package Shared.AS3 {
import flash.display.MovieClip;
import flash.errors.EOFError;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class ExtendedSocket extends MovieClip implements IEventDispatcher {

    public var sfCodeObject = null;
    public var prevBytesAvailable:uint = 0;
    public var bytesAvailable:uint = 0;
    public var connected:Boolean = false;
    private var connectTimer:Timer;
    private var dataTimer:Timer;
    private var connectCalled:Boolean = false;

    public function ExtendedSocket(param1:*) {
        this.connectTimer = new Timer(5, 1);
        this.dataTimer = new Timer(50, 1);
        super();
        if (param1 != null) {
            this.sfCodeObject = param1;
            if (param1.call != null) {
                this.sfCodeObject.call("register", this);
            }
        }
    }

    public function connect(param1:String, param2:String):void {
        if (this.connected) {
            return;
        }
        this.connectCalled = true;
        if (this.sfCodeObject.call != null) {
            this.sfCodeObject.call("connect", param1, param2);
            this.connectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onConnectLoop);
            this.dataTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onSocketLoop);
            this.connectTimer.reset();
            this.connectTimer.start();
            this.dataTimer.reset();
            this.dataTimer.start();
        }
    }

    public function close():void {
    }

    public function readByte():int {
        return this.sfCodeObject.call("readByte");
    }

    public function readUTFBytes(param1:uint):String {
        if (param1 > this.bytesAvailable) {
            param1 = this.bytesAvailable;
        }
        var _loc2_:String = "";
        _loc2_ = this.sfCodeObject.call("readUTFBytes", param1);
        if (_loc2_ === "$$IOERROR$$") {
            this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
            throw new IOError();
        }
        if (_loc2_ === "$$EOFERROR$$") {
            throw new EOFError();
        }
        return _loc2_;
    }

    public function writeUTFBytes(param1:String):void {
        var _loc2_:Boolean = this.sfCodeObject.call("writeUTFBytes", param1);
        if (!_loc2_) {
            this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
            throw new IOError();
        }
    }

    public function flush():void {
    }

    public function onConnectLoop():void {
        if (this.connected) {
            this.dispatchEvent(new Event("ExtendedSocket::CONNECT"));
        } else {
            this.connectTimer.reset();
            this.connectTimer.start();
        }
    }

    public function onSocketLoop():void {
        if (this.bytesAvailable > this.prevBytesAvailable) {
            this.dispatchEvent(new Event("ExtendedSocket::SocketData"));
        }
        this.prevBytesAvailable = this.bytesAvailable;
        this.dataTimer.reset();
        this.dataTimer.start();
    }
}
}