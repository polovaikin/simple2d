package core.atlas {
    import flash.geom.Rectangle;

    public class AtlasNode {

        public var rect:Rectangle;
        private var left:AtlasNode;
        private var right:AtlasNode;
        private var bitmapDataRect:Rectangle;

        function AtlasNode(x:int, y:int, width:int, height:int) {
            rect = new Rectangle(x, y, width, height);
            bitmapDataRect = null;
        }

        public function addBitmapDataRect(bitmapDataRect:Rectangle):AtlasNode {
            if (left != null || right != null) {
                var newNode:AtlasNode = left.addBitmapDataRect(bitmapDataRect);

                if (newNode != null) {
                    return newNode;
                }

                return right.addBitmapDataRect(bitmapDataRect);
            } else {
                if (this.bitmapDataRect != null) {
                    return null; // occupied
                }

                if (bitmapDataRect.width > rect.width || bitmapDataRect.height > rect.height) {
                    return null; // does not fit
                }

                if (bitmapDataRect.width == rect.width && bitmapDataRect.height == rect.height) {
                    this.bitmapDataRect = bitmapDataRect; // perfect fit
                    return this;
                }

                var dw:int = rect.width - bitmapDataRect.width;
                var dh:int = rect.height - bitmapDataRect.height;

                if (dw > dh) {
                    left = new AtlasNode(rect.x, rect.y, bitmapDataRect.width, rect.height);
                    right = new AtlasNode(rect.x + bitmapDataRect.width, rect.y, rect.width - bitmapDataRect.width, rect.height);
                }
                else {
                    left = new AtlasNode(rect.x, rect.y, rect.width, bitmapDataRect.height);
                    right = new AtlasNode(rect.x, rect.y + bitmapDataRect.height, rect.width, rect.height - bitmapDataRect.height);
                }

                return left.addBitmapDataRect(bitmapDataRect);
            }
        }
    }
}