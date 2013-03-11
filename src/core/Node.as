package core {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    import utils.getClass;

    public class Node extends EventDispatcher {

        protected static const engine:Engine = Engine.instance;

        protected var _transform:Matrix3D = new Matrix3D();
        public var parent:Container;
        private var _x:Number = 0;
        private var _y:Number = 0;
        private var _scaleX:Number = 1;
        private var _scaleY:Number = 1;
        private var _rotateX:Number = 0;
        private var _rotateY:Number = 0;
        private var _rotateZ:Number = 0;

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
        private var _transformInvert:Matrix3D = new Matrix3D();

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
            clone._rotateX = _rotateX;
            clone._rotateY = _rotateY;
            clone._rotateZ = _rotateZ;
            clone._alpha = _alpha;
            clone.alphaGlobal = alphaGlobal;
            clone._visible = _visible;
            clone.visibleGlobal = visibleGlobal;
            clone._blendMode = _blendMode;
            clone.blendModeGlobal = blendModeGlobal;
            clone.mouseEnabled = mouseEnabled;
            clone._transform = _transform.clone();
            clone._transformInvert = _transformInvert.clone();

            return clone;
        }

        public function getLocalMousePos():Vector3D {
            return transformInvert.transformVector(engine.viewportMousePos);
        }

        public function get transformInvert():Matrix3D {
            if (isChangeTransform)validateMatrix();
            return _transformInvert;
        }

        public function getNodeUnderMouse():Node {
            if (mouseEnabled && visibleGlobal) {
                var mousePos:Vector3D = getLocalMousePos();
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

                var mousePos:Vector3D = getLocalMousePos();

                guiMouseEvent.localX = mousePos.x;
                guiMouseEvent.localY = mousePos.y;
            }

            super.dispatchEvent(event);

            if (event.bubbles && parent) {
                parent.dispatchEvent(event);
            }

            return true;
        }

        public function get transform():Matrix3D {
            if (isChangeTransform) {
                isChangeTransform = false;
                validateMatrix();
            }
            return _transform;
        }

        public function validateMatrix():void {
            _transform.identity();

            _transform.appendRotation(_rotateX, Vector3D.X_AXIS);
            _transform.appendRotation(_rotateY, Vector3D.Y_AXIS);
            _transform.appendRotation(_rotateZ, Vector3D.Z_AXIS);

            _transform.appendScale(_scaleX, _scaleY, 1);

            _transform.appendTranslation(_x, _y, 0);

            if (parent) {
                _transform.append(parent.transform);
            }

            _transformInvert = _transform.clone();
            _transformInvert.invert();

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

        public function get rotateX():Number {
            return _rotateX;
        }

        public function set rotateX(value:Number):void {
            if (_rotateX != value) {
                _rotateX = value;
                invalidateTransform();
            }
        }

        public function get rotateY():Number {
            return _rotateY;
        }

        public function set rotateY(value:Number):void {
            if (_rotateY != value) {
                _rotateY = value;
                invalidateTransform();
            }
        }

        public function get rotateZ():Number {
            return _rotateZ;
        }

        public function set rotateZ(value:Number):void {
            if (_rotateZ != value) {
                _rotateZ = value;
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