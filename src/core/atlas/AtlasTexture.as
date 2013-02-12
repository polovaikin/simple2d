package core.atlas {
    import core.Engine;
    import core.Image;
    import core.ImageSource;

    import flash.display.BitmapData;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class AtlasTexture {

        public var texture:Texture;
        private var bitmapData:BitmapData;
        private var isBitmapDataChange:Boolean = true;
        private var root:AtlasNode;

        public function AtlasTexture(width:int, height:int) {
            bitmapData = new BitmapData(width, height, true, 0);
            root = new AtlasNode(0, 0, width, height);
        }

        public function get width():int {
            return bitmapData.width;
        }

        public function get height():int {
            return bitmapData.height;
        }

        public function validateUpload():void {
            if (isBitmapDataChange) {
                if (!texture)texture = Engine.instance.context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
                texture.uploadFromBitmapData(bitmapData);
                isBitmapDataChange = false;
            }
        }

        public function dispose():void {

        }

        public function addBitmapData(bitmapData:BitmapData):ImageSource {
            if (!bitmapData) throw new Error("ImageAtlas::addBitmapData bitmapData is null");

            var node:AtlasNode = root.addBitmapDataRect(bitmapData.rect);
            if (!node)return null;

            var rect:Rectangle = node.rect;

            this.bitmapData.copyPixels(bitmapData, bitmapData.rect, new Point(rect.x, rect.y));
            isBitmapDataChange = true;

            return new ImageSource(rect.clone(), this);
        }
    }
}

