package tests {

    import core.Container;
    import core.Engine;
    import core.Image;
    import core.ImageSource;
    import core.Renderer;
    import core.atlas.AtlasManager;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getTimer;

    [SWF(width="320", height="500", backgroundColor="0", frameRate="60")]
    public class TestPerfomance extends Sprite {

        private var image:Image;
        private var sprite:Container;
        private var scene:Container;
        private var textField:TextField;

        [Embed(source="benchmark_object.png")]
        private var bitmapDataClass:Class;
        private var bitmapData:BitmapData = Bitmap(new bitmapDataClass()).bitmapData;


        public function TestPerfomance() {
            scene = Engine.instance.init(this, 640, 1000);


            /*var bitmapData:BitmapData = new BitmapData(100, 100, true, 0xFF0000FF);
             bitmapData.fillRect(new Rectangle(0, 0, 10, 10), 0xFFFFFFFF);
             bitmapData.fillRect(new Rectangle(90, 90, 10, 10), 0xFFFF0000);*/

            var imageSource:ImageSource = AtlasManager.instance.createImageSource(bitmapData);

            for (var x:int = 0; x < 640; x += 30) {
                for (var y:int = 0; y < 1000; y += 30) {

                    image = new Image(imageSource, true);

                    sprite = new Container();

                    sprite.addChild(image);

                    scene.addChild(sprite);

                    sprite.x = x / 640 * (640 - bitmapData.width) + bitmapData.width / 2;
                    sprite.y = y / 1000 * (1000 - bitmapData.height) + bitmapData.height / 2;
                    image.x = -bitmapData.width / 2;
                    image.y = -bitmapData.height / 2;

                    sprite.alpha = scene.numChildren>300? 0.3: 0.7;
                }
            }


            addEventListener(Event.ENTER_FRAME, onEnterFrame);

            textField = new TextField();
            textField.background = true;
            textField.backgroundColor = 0xFFFFFF;
            textField.autoSize = TextFieldAutoSize.LEFT;
            addChild(textField);
        }

        private var lastFPSTime:int;
        private var fpsCount:int;

        private function onEnterFrame(event:Event):void {
            var time:int = getTimer();
            fpsCount++
            if (time - lastFPSTime > 1000) {
                textField.text = "fps = " + fpsCount +
                        "\ndriverInfo = " + Engine.instance.driverInfo+
                        "\nenableErrorChecking = " + Engine.instance.enableErrorChecking+
                "\nimageCount = "+Renderer.instance.imageCount;
                fpsCount = 0;
                lastFPSTime = time;
            }


            var numChildren:int = scene.numChildren;
            for (var i:int = 0; i < numChildren; i++) {
                scene.getChildAt(i).rotation++;
            }

        }


    }
}
