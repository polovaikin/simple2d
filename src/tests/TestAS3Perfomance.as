package tests {

    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getTimer;

    public class TestAS3Perfomance extends Sprite {

        private var label:TextField;

        public function TestAS3Perfomance():void {
            label = new TextField();
            label.mouseEnabled = false;
            label.background = true;
            label.backgroundColor = 0xF0F0F0;
            label.autoSize = TextFieldAutoSize.LEFT;
            addChild(label)
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
        }

        private function onAddToStage(event:Event):void {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.frameRate = 60;
        }

        var n:int = 1000000;

        protected function onEnterFrame(event:Event):void {
            label.text = "";
            var time:int;
            var i:int;


            var rawData:Vector.<Number> = new Vector.<Number>();
            for (i = 0; i < 16; i++) {
                rawData[i] = getRandom();
            }
            var m:Matrix3D = new Matrix3D(rawData);

            var vin:Vector.<Number> = new Vector.<Number>(12, true);
            var vout:Vector.<Number> = new Vector.<Number>(8);
            for (i = 0; i < 12; i++) {
                vin[i] = getRandom();
            }

            time = getTimer();
            for (i = 0; i < n; i++) {
                m.transformVectors(vin, vout)
            }
            label.appendText("\n" + (getTimer() - time));


            var width:Number = getRandom();
            var height:Number = getRandom();

            var inX0:Number = 0;
            var inY0:Number = 0;

            var inX1:Number = 0;
            var inY1:Number = height;

            var inX2:Number = width;
            var inY2:Number = height;

            var inX3:Number = width;
            var inY3:Number = 0;

            var m00:Number = getRandom();
            var m10:Number = getRandom();
            var m01:Number = getRandom();
            var m11:Number = getRandom();

            var m02:Number = getRandom();
            var m12:Number = getRandom();

            time = getTimer();
            for (i = 0; i < n; i++) {
                var outX0:Number = inX0 * m00 + inY0 * m01 + m02;
                var outY0:Number = inX0 * m10 + inY0 * m11 + m12;

                var outX1:Number = inX1 * m00 + inY1 * m01 + m02;
                var outY1:Number = inX1 * m10 + inY1 * m11 + m12;

                var outX2:Number = inX2 * m00 + inY2 * m01 + m02;
                var outY2:Number = inX2 * m10 + inY2 * m11 + m12;

                var outX3:Number = inX3 * m00 + inY3 * m01 + m02;
                var outY3:Number = inX3 * m10 + inY3 * m11 + m12;
            }
            label.appendText("\n" + (getTimer() - time));

        }

        private function getRandom():Number {
            return Math.random() * 1000 - 500;
        }

    }
}
