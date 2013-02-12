package core {
    import core.atlas.AtlasManager;

    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    import utils.getShortClassName;

    public class FlashConvertor {

        public static function getFramesFromMovieClip(child:MovieClip, border:Rectangle = null, linear:Boolean = false):Vector.<Node> {

            var className:String = getQualifiedClassName(child);

            var frames:Vector.<Node> = new <Node>[];

            var totalFrames:int = child.totalFrames;
            while(totalFrames==1){
                child = MovieClip(child.getChildAt(0));
                totalFrames = child.totalFrames;
            }

            for (var i:int = 0; i < totalFrames; i++) {
                child.gotoAndStop(i);
                var frame:Node = getNodeFromDisplayObject(child, className + "_" + i, border, linear);

                frames.push(frame);
            }
            return frames;
        }

        public static function getNodeFromDisplayObject(child:DisplayObject, id:String = null, border:Rectangle = null, linear:Boolean = false):Node {

            var rotation:Number = child.rotation;
            child.rotation = 0;

            var matrix:Matrix = child.transform.matrix;

            var bounds:Rectangle = child.getBounds(child);

            if (!border)border = new Rectangle(4, 4, 4, 4);

            bounds.left -= border.x;
            bounds.top -= border.y;
            bounds.width += border.width;
            bounds.height += border.height;

            var scaleX:Number = matrix.a < 0 ? -matrix.a : matrix.a;
            var scaleY:Number = matrix.d < 0 ? -matrix.d : matrix.d;

            if (!id) {
                id = getQualifiedClassName(child) + scaleX.toFixed(5) + "_" + scaleY.toFixed(5);
            }

            var imageSource:ImageSource = AtlasManager.instance.imageFragmentByBitmapData[id];

            var screenScaleX:Number = Engine.instance.scaleX;
            var screenScaleY:Number = Engine.instance.scaleY;

            var bitmapScaleX:Number = scaleX * screenScaleX;
            var bitmapScaleY:Number = scaleY * screenScaleY;

            var tx:Number = int(-bounds.left * bitmapScaleX);
            var ty:Number = int(-bounds.top * bitmapScaleY);

            if (!imageSource) {

                var bitmapData:BitmapData = new BitmapData((bounds.width * bitmapScaleX),
                        (bounds.height * bitmapScaleY), true, 0);

                bitmapData.draw(child, new Matrix(bitmapScaleX, 0, 0, bitmapScaleY, tx, ty), null, null, null, true);

                var s:Shape = new Shape();
                var g:Graphics = s.graphics;
                g.lineStyle(1, 0x000000, 0.7);
                g.drawRect(0, 0, bitmapData.width - 1, bitmapData.height - 1);
                g.moveTo(tx - 4, ty);
                g.lineTo(tx + 5, ty);
                g.moveTo(tx, ty - 4);
                g.lineTo(tx, ty + 5);
                bitmapData.draw(s);


                imageSource = AtlasManager.instance.addImageSource(bitmapData, id);
                imageSource.width /= screenScaleX;
                imageSource.height /= screenScaleY;
                /*
                 imageSource.width = int(bounds.width);
                 imageSource.height = int(bounds.height);
                 */
            }

            var container:Container = new Container();
            var bitmap:Image = new Image(imageSource);
            bitmap.linear = linear;
            bitmap.name = getShortClassName(child) + "_" + child.name;

            container.addChild(bitmap);

            bitmap.x = bounds.left * scaleX;
            bitmap.y = bounds.top * scaleX;

            if (matrix.a < 0)bitmap.scaleX = -1;
            if (matrix.d < 0)bitmap.scaleY = -1;

            container.x = child.x;
            container.y = child.y;

            container.rotateZ = rotation;

            child.rotation = rotation;

            return container;
        }
    }
}