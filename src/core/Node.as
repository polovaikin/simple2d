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

        protected var isChangeTransForm:Boolean = true;
        private var _alpha:Number = 1;
        public var alphaGlobal:Number = 1;
        private var _visible:Boolean = true;
        public var visibleGlobal:Boolean = true;
        private var _transformInvert:Matrix3D;

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
            clone.mouseEnabled = mouseEnabled;

            return clone;
        }

        public function getLocalMousePos():Vector3D {
            return transformInvert.transformVector(engine.viewportMousePos);
        }

        public function get transformInvert():Matrix3D {
            if (isChangeTransForm)validateMatrix();
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
            if (isChangeTransForm) {
                isChangeTransForm = false;
                validateMatrix();
            }
            return _transform;
        }

        public function invalidateMatrix():void {
            invalidateTransform();
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
            _alpha = value;
            validateMeAndChildrenProperty();
        }

        public function validateMeAndChildrenProperty():void {
            validateProperty();
        }

        protected function validateProperty():void {
            alphaGlobal = _alpha;
            visibleGlobal = _visible;
            if (parent) {
                alphaGlobal *= parent.alphaGlobal;
                visibleGlobal &&= parent.visibleGlobal;
            }
        }

        public function get visible():Boolean {
            return _visible;
        }

        public function set visible(value:Boolean):void {
            _visible = value;
            validateMeAndChildrenProperty();
        }

        public function render(time:int):void {

        }

        public function get x():Number {
            return _x;
        }

        public function set x(value:Number):void {
            _x = engine.roundPixelX(value);

            invalidateTransform();
        }

        public function get y():Number {
            return _y;
        }

        public function set y(value:Number):void {
            _y = engine.roundPixelY(value);

            invalidateTransform();
        }

        public function invalidateTransform():void {
            isChangeTransForm = true;
        }

        public function get scaleX():Number {
            return _scaleX;
        }

        public function set scaleX(value:Number):void {
            _scaleX = value;
            invalidateTransform();
        }

        public function get scaleY():Number {
            return _scaleY;
        }

        public function set scaleY(value:Number):void {
            _scaleY = value;
            invalidateTransform();
        }

        public function get rotateX():Number {
            return _rotateX;
        }

        public function set rotateX(value:Number):void {
            _rotateX = value;
            invalidateTransform();
        }

        public function get rotateY():Number {
            return _rotateY;
        }

        public function set rotateY(value:Number):void {
            _rotateY = value;
            invalidateTransform();
        }

        public function get rotateZ():Number {
            return _rotateZ;
        }

        public function set rotateZ(value:Number):void {
            _rotateZ = value;
            invalidateTransform();
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
    }
}