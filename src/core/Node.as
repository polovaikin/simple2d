package core {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import utils.getClass;

    public class Node extends EventDispatcher {

        protected static const engine:Engine = Engine.instance;

        protected var _transform:Matrix = new Matrix();
        public var parent:Container;
        private var _x:Number = 0;
        private var _y:Number = 0;
        private var _scaleX:Number = 1;
        private var _scaleY:Number = 1;
        private var _rotation:Number = 0;

        public var mouseEnabled:Boolean;

        protected var _width:Number = 0;
        protected var _height:Number = 0;

        protected var isChangeTransform:Boolean = true;
        private var _alpha:Number = 1;
        public var alphaGlobal:Number = 1;
        private var _visible:Boolean = true;
        public var visibleGlobal:Boolean = true;
        private var _blendMode:BlendMode3D = BlendMode3D.NORMAL;
        public var blendModeGlobal:BlendMode3D = BlendMode3D.NORMAL;

        public var name:String;

        public function clone():Node {
            var clazz:Class = getClass(this);
            var clone:Node = new clazz;
            clone._transform = _transform;
            clone._x = _x;
            clone._y = _y;
            clone.name = name;
            clone._width = _width;
            clone._height = _height;
            clone._scaleX = _scaleX;
            clone._scaleY = _scaleY;
            clone._rotation = _rotation;
            clone._alpha = _alpha;
            clone.alphaGlobal = alphaGlobal;
            clone._visible = _visible;
            clone.visibleGlobal = visibleGlobal;
            clone._blendMode = _blendMode;
            clone.blendModeGlobal = blendModeGlobal;
            clone.mouseEnabled = mouseEnabled;
            clone._transform = _transform.clone();

            return clone;
        }

        public function getLocalMousePos():Point {
            var m:Matrix = transform.clone();
            m.invert();
            return m.transformPoint(engine.viewportMousePos);
        }

        public function getNodeUnderMouse():Node {
            if (mouseEnabled && visibleGlobal) {
                var mousePos:Point = getLocalMousePos();
                if (containsPoint(mousePos.x, mousePos.y))return this;
            }

            return null;
        }

        public function containsPoint(x:Number, y:Number):Boolean {
            return 0 <= x && x < width &&
                    0 <= y && y < height;
        }

        override public function dispatchEvent(event:Event):Boolean {

            var guiMouseEvent:NodeMouseEvent = event as NodeMouseEvent;
            if (guiMouseEvent) {
                if (guiMouseEvent.isStopPropagation)return true;

                var mousePos:Point = getLocalMousePos();

                guiMouseEvent.localX = mousePos.x;
                guiMouseEvent.localY = mousePos.y;
            }

            super.dispatchEvent(event);

            if (event.bubbles && parent) {
                parent.dispatchEvent(event);
            }

            return true;
        }

        public function get transform():Matrix {
            if (isChangeTransform) {
                isChangeTransform = false;
                validateMatrix();
            }
            return _transform;
        }

        public function validateMatrix():void {
            _transform.identity();

            _transform.createBox(_scaleX, _scaleY, _rotation * 0.01745329251, _x, _y);

            if (parent) {
                _transform.concat(parent.transform);
            }
        }

        public function get alpha():Number {
            return _alpha;
        }

        public function set alpha(value:Number):void {
            if (_alpha != value) {
                _alpha = value;
                validateMeAndChildrenProperty();
            }
        }

        public function validateMeAndChildrenProperty():void {
            validateProperty();
        }

        protected function validateProperty():void {
            alphaGlobal = _alpha;
            visibleGlobal = _visible;
            blendModeGlobal = _blendMode;
            if (parent) {
                alphaGlobal *= parent.alphaGlobal;
                visibleGlobal &&= parent.visibleGlobal;


                var parentBlendMode:BlendMode3D = parent.blendMode;

                if (parentBlendMode != BlendMode3D.NORMAL) {
                    blendModeGlobal = parentBlendMode;
                }

            }
        }

        public function get visible():Boolean {
            return _visible;
        }

        public function set visible(value:Boolean):void {
            if (_visible != value) {
                _visible = value;
                validateMeAndChildrenProperty();
            }
        }

        public function render(time:int):void {

        }

        public function get x():Number {
            return _x;
        }

        public function set x(value:Number):void {
            var newValue:Number = engine.roundPixelX(value);
            if (_x != newValue) {
                _x = newValue;
                invalidateTransform();
            }
        }

        public function get y():Number {
            return _y;
        }

        public function set y(value:Number):void {
            var newValue:Number = engine.roundPixelY(value);
            if (_y != newValue) {
                _y = newValue;
                invalidateTransform();
            }
        }

        public function invalidateTransform():void {
            isChangeTransform = true;
        }

        public function get scaleX():Number {
            return _scaleX;
        }

        public function set scaleX(value:Number):void {
            if (_scaleX != value) {
                _scaleX = value;
                invalidateTransform();
            }
        }

        public function get scaleY():Number {
            return _scaleY;
        }

        public function set scaleY(value:Number):void {
            if (_scaleY != value) {
                _scaleY = value;
                invalidateTransform();
            }
        }

        public function get rotation():Number {
            return _rotation;
        }

        public function set rotation(value:Number):void {
            if (_rotation != value) {
                _rotation = value;
                invalidateTransform();
            }
        }

        public function get width():Number {
            return _width;
        }

        public function set width(value:Number):void {
            _width = value;
        }

        public function get height():Number {
            return _height;
        }

        public function set height(value:Number):void {
            _height = value;
        }

        public function get blendMode():BlendMode3D {
            return _blendMode;
        }

        public function set blendMode(value:BlendMode3D):void {
            if (_blendMode != value) {
                _blendMode = value;
                validateMeAndChildrenProperty();
            }
        }
    }
}