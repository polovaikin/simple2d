package core {
    public class Animation extends Container {

        public var countPlay:int = -1;

        private var fps:int;

        private var endFunction:Function;
        private var startTime:int;
        private var isPlay:Boolean;
        private var currentFrameIndex:int;

        public function Animation(frames:Vector.<Node> = null, fps:int = 24) {
            this.fps = fps;
            if (frames) {
                this.frames = frames;
            }
        }

        public function play(time:int, countPlay:int = -1, endFunction:Function = null):void {
            this.startTime = time;
            this.endFunction = endFunction;
            this.countPlay = countPlay;
            this.isPlay = true;

        }

        public function set frames(value:Vector.<Node>):void {
            for each(var child:Node in value) {
                var childClone:Node = child.clone();
                _children.push(childClone);
                childClone.parent = this;
            }
        }

        override public function render(time:int):void {
            if (visibleGlobal) {
                if (isPlay) {
                    var delteTime:int = time - startTime;
                    currentFrameIndex = delteTime * 0.001 * fps;

                    var frameCount:int = _children.length;

                    if (countPlay == -1 || currentFrameIndex / frameCount < countPlay) {
                        currentFrameIndex %= frameCount;
                    } else {
                        isPlay = false;
                        if (endFunction)endFunction();
                    }
                }

                _children[currentFrameIndex].render(time);
            }
        }
    }
}