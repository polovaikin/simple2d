package core {
    public class Animation extends Container {

        public var countPlay:int = -1;

        private var fps:int;

        private var endFunction:Function;
        private var startTime:int;
        private var isPlay:Boolean;
        private var _frames:Vector.<Node> = new <Node>[];
        private var currentFrame:Node;

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
            _frames = new <Node>[];
            for each(var child:Node in value) {
                _frames.push(child.clone());
            }
        }

        override public function render(time:int):void {
            if (visibleGlobal) {
                if (isPlay) {
                    var delteTime:int = time - startTime;
                    var currentFrameIndex:int = delteTime * 0.001 * fps;

                    var frameCount:int = frameCount;

                    if (countPlay == -1 || currentFrameIndex / frameCount < countPlay) {
                        currentFrameIndex %= frameCount;
                    } else {
                        isPlay = false;
                        if (endFunction)endFunction();
                    }
                    if (currentFrameIndex > -1 && currentFrameIndex < _frames.length) {
                        currentFrame = _frames[currentFrameIndex];
                        _children[0] = currentFrame;
                        currentFrame.parent = this;
                        currentFrame.invalidateTransform();
                    } else {
                        _children = new <Node>[];
                        currentFrame = null;
                    }

                }

                if (currentFrame)currentFrame.render(time);
            }
        }

        private function get frameCount():int {
            return _frames.length;
        }


        override public function clone():Node {
            var clone:Animation = Animation(super.clone());
            clone.frames = _frames;
            return clone;
        }
    }
}