package core {
    import core.atlas.AtlasManager;

    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DRenderMode;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.system.Capabilities;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    public class Engine {

        private static var _instance:Engine;

        public static function get instance():Engine {
            if (!_instance)_instance = new Engine();
            return _instance;
        }

        public var stage3D:Stage3D;
        public var driverInfo:String;
        public var context3D:Context3D;
        public var scene:Container;

        private var app:DisplayObject;
        public var stage:Stage;

        public var debug:Boolean;

        public var scaleX:Number = 1;
        public var scaleY:Number = 1;

        public var virtualWidth:Number;
        public var virtualHeight:Number;
        public var viewportMousePos:Vector3D;

        private var antiAlias:int;

        public function init(app:DisplayObject, virtualWidth:Number, virtualHeight:Number, antiAlias:int = 0):Container {
            this.app = app;
            this.virtualWidth = virtualWidth;
            this.virtualHeight = virtualHeight;
            this.antiAlias = antiAlias;

            scene = new Container();

            if (app.stage) {
                onAddedToStage();
            } else {
                app.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            }

            return  scene;
        }

        public function init3D():void {
            stage3D = stage.stage3Ds[0];

            stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onCreateContext3D);
            stage3D.removeEventListener(ErrorEvent.ERROR, onError);
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreateContext3D);
            stage3D.addEventListener(ErrorEvent.ERROR, onError);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

            reloadContext();
        }

        public function dispose():void {
            if (context3D) {
                context3D.dispose();
            }
            app.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            Renderer.instance.dispose();
        }

        private function reloadContext():void {
            dispose();
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onAddedToStage(event:Event = null):void {
            stage = app.stage;
            app.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            app.stage.addEventListener("resize", onResize);

            stage.quality = StageQuality.BEST;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            onResize();

            init3D();

            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
            stage.addEventListener(MouseEvent.CLICK, onMouseEvent);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);

            stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseEvent);
            stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);

            stage.addEventListener(MouseEvent.ROLL_OUT, onMouseEvent);

            stage.doubleClickEnabled = true;
            stage.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseEvent);
        }

        private function onMouseEvent(event:MouseEvent):void {

            viewportMousePos = scene.transform.transformVector(new Vector3D(event.stageX / scaleX, event.stageY / scaleY, 0));

            event.stopImmediatePropagation();

            var componentUnderMouse:Node = scene.getNodeUnderMouse();

            var guiEvent:NodeMouseEvent = new NodeMouseEvent(event.type, true, true, event.stageX, event.stageY, null, event.ctrlKey, event.altKey, event.shiftKey, event.buttonDown, event.delta);
            guiEvent.startPropagation();

            if (componentUnderMouse) {
                componentUnderMouse.dispatchEvent(guiEvent);
            }

        }

        private function onKeyDown(event:KeyboardEvent):void {
            if (event.keyCode == Keyboard.ESCAPE) {
                reloadContext();
            }
        }

        public function roundPixelX(x:Number):Number {
            return int(x * scaleX) / scaleX;
        }

        public function roundPixelY(y:Number):Number {
            return int(y * scaleY) / scaleY;
        }

        private function onError(event:ErrorEvent):void {
            throw new Error("Grass3D Error: " + event.errorID + " " + event.toString());
        }

        private function onCreateContext3D(event:Event):void {
            app.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            app.addEventListener(Event.ENTER_FRAME, onEnterFrame);

            context3D = stage3D.context3D;
            trace(context3D.driverInfo);

            context3D.enableErrorChecking = debug;
            Renderer.instance.init(context3D);

            driverInfo = context3D.driverInfo;

            onResize();
        }

        private function onResize(event:Event = null):void {
            trace(Capabilities.os)
            if (Capabilities.os.toLowerCase().indexOf("win") > -1) {
                var width:int = stage.stageWidth;
                var height:int = stage.stageHeight;
            } else {
                width = stage.fullScreenWidth;
                height = stage.fullScreenHeight;
            }

            scaleX = scaleY = 1;

            scene.scaleX = 2 / virtualWidth;
            scene.scaleY = -2 / virtualHeight;
            scene.x = -1;
            scene.y = 1;

            scaleX = width / virtualWidth;
            scaleY = height / virtualHeight;

            if (context3D) {
                context3D.configureBackBuffer(width, height, antiAlias, false);
            }
        }

        private function onEnterFrame(event:Event):void {
            Engine.instance.context3D.clear(1, 1, 1);
            AtlasManager.instance.validateUpload();

            var time:int = getTimer();

            scene.render(time);

            Renderer.instance.renderBatch();
            Engine.instance.context3D.present();
        }
    }

}
