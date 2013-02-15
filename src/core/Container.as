package core {
    import flash.geom.Vector3D;

    public class Container extends Node {

        protected var _children:Vector.<Node> = new <Node>[];
        public var mouseChildren:Boolean = true;

        override public function clone():Node {
            var clone:Container = Container(super.clone());
            clone.mouseChildren = mouseChildren;

            for each(var child:Node in _children) {
                clone.addChild(child.clone());
            }

            return clone;
        }

        override public function invalidateTransform():void {
            super.invalidateTransform();
            for each(var child:Node in _children) {
                child.invalidateTransform();
            }
        }

        override public function render(time:int):void {
            if (visibleGlobal) {
                for each(var child:Node in _children) {
                    child.render(time);
                }
            }
        }

        public function get numChildren():int {
            return _children.length;
        }

        override public function validateMeAndChildrenProperty():void {
            validateProperty();
            for each(var child:Node in _children) {
                child.validateMeAndChildrenProperty();
            }
        }

        public function addChild(child:Node):Node {
            return addChildAt(child, numChildren);
        }

        public function addChildAt(child:Node, index:int):Node {
            _children.splice(index, 0, child);
            if (child.parent) {
                child.parent.removeChild(child);
            }
            child.parent = this;

            if (_width < child.width)_width = child.width;
            if (_height < child.height)_height = child.height;

            return child;
        }

        public function getChildIndex(child:Node):int {
            return _children.indexOf(child);
        }

        public function removeChild(child:Node):Node {
            var index:int = getChildIndex(child);
            if (index > -1) removeChildAt(index);
            return child;
        }

        public function removeChildAt(index:int):Node {
            var child:Node = getChildAt(index);
            child.parent = null;
            _children.splice(index, 1);

            return child;
        }

        public function removeAllChildren():void {
            for each(var child:Node in _children) {
                child.parent = null;
            }
            _children.length = 0;
        }

        public function getChildAt(index:int):Node {
            if (index < 0 || index >= numChildren)throw new Error("Index " + index + " out of bounds");
            return _children[index];
        }

        public function contains(child:Node):Boolean {
            return getChildIndex(child) > -1;
        }

        override public function getNodeUnderMouse():Node {
            if (visibleGlobal) {
                var mousePos:Vector3D = getLocalMousePos();

                //if (containsPoint(mousePos.x, mousePos.y)) {
                //if (mouseEnabled) return this;

                if (mouseChildren) {
                    for (var i:int = _children.length - 1; i >= 0; i--) {
                        var underMouse:Node = _children[i].getNodeUnderMouse();
                        if (underMouse) return underMouse;
                    }
                }
                // }
            }
            return null;
        }
    }
}