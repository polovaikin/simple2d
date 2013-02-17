package core {
    public class Image extends Node {

        private var _source:ImageSource;

        private var vertices:Vector.<Number> = new <Number>[];
        private var _verticesTransformed:Vector.<Number> = new <Number>[];
        public var linear:Boolean;

        override public function clone():Node {
            var clone:Image = Image(super.clone());
            clone._source = _source;
            clone.vertices = vertices.concat();
            clone.linear = linear;

            return clone;
        }

        public function Image(imageSource:ImageSource = null, linear:Boolean = false) {
            this.mouseEnabled = true;
            this.source = imageSource;
            this.linear = linear;
        }

        public function get verticesTransformed():Vector.<Number> {
            if (isChangeTransForm) {
                isChangeTransForm = false;
                validateMatrix();
                _transform.transformVectors(vertices, _verticesTransformed);
            }
            return _verticesTransformed;
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

                    vertices = Vector.<Number>([
                        0, 0, 0,
                        0, _height, 0,
                        _width, _height, 0,
                        _width, 0, 0
                    ]);
                }
            }
        }
    }
}