package tests {

    import core.Container;
    import core.Engine;
    import core.Image;
    import core.ImageSource;
    import core.atlas.AtlasManager;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.utils.getTimer;

    [SWF(width="320", height="500", backgroundColor="0", frameRate="60")]
    public class MainSimple2d extends Sprite {

        private var image:Image;
        private var sprite:Container;
        private var scene:Container;
        private var textField:TextField;


        public function MainSimple2d() {
            scene = Engine.instance.init(this, 640, 1000);


            var bitmapData:BitmapData = new BitmapData(100, 100, true, 0xFF0000FF);


            bitmapData.fillRect(new Rectangle(0, 0, 10, 10), 0xFFFFFFFF);
            bitmapData.fillRect(new Rectangle(90, 90, 10, 10), 0xFFFF0000);

            var imageSource:ImageSource = AtlasManager.instance.createImageSource(bitmapData);

            for (var i:int = 0; i < 10000; i++) {

                image = new Image(imageSource, true);

                sprite = new Container();

                sprite.addChild(image);

                scene.addChild(sprite);

                sprite.x = 100;
                sprite.y = 100;
                image.x = -50;
                image.y = -50;

            }

            addEventListener(Event.ENTER_FRAME, onEnterFrame);

            textField = new TextField();
            addChild(textField);
        }

        private var lastFPSTime:int;
        private var fpsCount:int;

        private function onEnterFrame(event:Event):void {
            var time:int = getTimer();
            fpsCount++
            if (time - lastFPSTime > 1000) {
                textField.text = "fps " + fpsCount;
                fpsCount = 0;
                lastFPSTime = time;
            }


           // sprite.rotateZ++;
        }


    }
}
