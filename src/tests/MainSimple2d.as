package tests {

    import core.Container;
    import core.Engine;
    import core.Image;
    import core.atlas.AtlasManager;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class MainSimple2d extends Sprite {

        private var image:Image;
        private var sprite:Container;
        private var scene:Container;

        public function MainSimple2d() {
            scene = Engine.instance.init(this, 640, 1000);

            var bitmapData:BitmapData = new BitmapData(100, 100, true, 0xFF0000FF);


            bitmapData.fillRect(new Rectangle(0, 0, 10, 10), 0xFF000000);
            bitmapData.fillRect(new Rectangle(90, 90, 10, 10), 0xFFFF0000);

            image = new Image(AtlasManager.instance.createImageSource(bitmapData), true);

            sprite = new Container();

            sprite.addChild(image);

            scene.addChild(sprite);

            sprite.x = 100;
            sprite.y = 100;
            image.x = -50;
            image.y = -50;


            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event:Event):void {

            sprite.rotateZ++;
        }


    }
}
