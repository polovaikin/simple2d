package core {
    import core.atlas.*;

    import flash.geom.Rectangle;

    public class ImageSource extends Node {

        public var texture:AtlasTexture;
        public var u0:Number;
        public var v0:Number;
        public var u1:Number;
        public var v1:Number;


        public function ImageSource(sourceRect:Rectangle, texture:AtlasTexture) {
            this.texture = texture;
            _width = sourceRect.width;
            _height = sourceRect.height;

            var kx:Number = 1 / texture.width;
            var ky:Number = 1 / texture.height;

            u0 = sourceRect.x * kx;
            v0 = sourceRect.y * ky;
            u1 = u0 + sourceRect.width * kx;
            v1 = v0 + sourceRect.height * ky;
        }


    }
}