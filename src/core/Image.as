package core {
    import flash.geom.Matrix;

    public class Image extends Node {

        private var _source:ImageSource;

        public var x0:Number;
        public var y0:Number;

        public var x1:Number;
        public var y1:Number;

        public var x2:Number;
        public var y2:Number;

        public var x3:Number;
        public var y3:Number;

        public var linear:Boolean;
        public var isChangeVertices:Boolean = true;

        override public function clone():Node {
            var clone:Image = Image(super.clone());
            clone._source = _source;
            clone.linear = linear;
            clone.isChangeVertices = isChangeVertices;

            clone.x0 = x0;
            clone.y0 = y0;

            clone.x1 = x1;
            clone.y1 = y1;

            clone.x2 = x2;
            clone.y2 = y2;

            clone.x3 = x3;
            clone.y3 = y3;

            return clone;
        }

        public function Image(imageSource:ImageSource = null, linear:Boolean = false) {
            this.mouseEnabled = true;
            this.source = imageSource;
            this.linear = linear;
        }

        public function validateVertices():void {
            if (isChangeVertices) {
                isChangeVertices = false;
                var transform:Matrix = transform;
                var a:Number = transform.a;
                var b:Number = transform.b;
                var c:Number = transform.c;
                var d:Number = transform.d;
                var tx:Number = transform.tx;
                var ty:Number = transform.ty;

                x0 = 0 * a + 0 * c + tx;
                x1 = 0 * a + _height * c + tx;
                x2 = _width * a + _height * c + tx;
                x3 = _width * a + 0 * c + tx;

                y0 = 0 * b + 0 * d + ty;
                y1 = 0 * b + _height * d + ty;
                y2 = _width * b + _height * d + ty;
                y3 = _width * b + 0 * d + ty;
            }
        }


        override public function invalidateTransform():void {
            super.invalidateTransform();
            isChangeVertices = true;
        }

        override public function render(time:int):void {
            if (visibleGlobal) {
                Renderer.instance.render(this);
            }
        }

        public function get source():ImageSource {
            return _source;
        }

        public function set source(value:ImageSource):void {
            if (_source != value) {
                _source = value;
                if (_source) {
                    _width = value.width;
                    _height = value.height;
                }
            }
        }
    }
}