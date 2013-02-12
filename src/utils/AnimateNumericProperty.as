package utils {
    import flash.utils.clearInterval;
    import flash.utils.getTimer;
    import flash.utils.setInterval;

    public class AnimateNumericProperty {

        private var target:Object;
        private var property:String;
        private var fromValue:Number;
        private var toValue:Number;
        private var duration:int;
        private var timer:int;

        private var startTime:int;
        private var dValue:Number;
        private var completeFunction:Function;

        public function play(target:Object, property:String, fromValue:Number, toValue:Number, duration:int, completeFunction:Function = null):void {
            this.target = target;
            this.property = property;
            this.fromValue = fromValue;
            this.toValue = toValue;
            this.duration = duration;
            this.completeFunction = completeFunction;

            dValue = toValue - fromValue;

            startTime = getTimer();
            timer = setInterval(onTimer, 16);

            target[property] = fromValue;
        }

        private function onTimer():void {
            var dTime:int = getTimer() - startTime;
            if (dTime >= duration) {
                target[property] = toValue;
                if (completeFunction)completeFunction();
                stop();
            } else {
                target[property] = fromValue + dTime / duration * dValue;
            }

        }

        public function stop():void {
            clearInterval(timer);
            completeFunction = null;
            target = null;
        }
    }
}