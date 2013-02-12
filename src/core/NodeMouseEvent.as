package core {
    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class NodeMouseEvent extends MouseEvent {

        public var propagation:Propagation;

        public function NodeMouseEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = 0, localY:Number = 0, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0, propagation:Propagation = null) {
            super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
            this.propagation = propagation;
        }

        override public function stopImmediatePropagation():void {
            super.stopImmediatePropagation();
            propagation.isStopPropagation = true;
        }

        override public function clone():Event {
            var clone:NodeMouseEvent = new NodeMouseEvent(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
            clone.propagation = propagation;
            return clone;
        }

        public function startPropagation():void {
            propagation = new Propagation();
        }

        public function get isStopPropagation():Boolean {
            return propagation.isStopPropagation;
        }

        override public function get stageX():Number {
            return Engine.instance.stage.mouseX / Engine.instance.scaleX;
        }

        override public function get stageY():Number {
            return Engine.instance.stage.mouseY / Engine.instance.scaleY;
        }
    }

}

class Propagation {
    public var isStopPropagation:Boolean;
}
