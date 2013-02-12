package utils {
    public class Enum {

        public var value:String;
        private var fullValue:String;

        public function Enum(id:String) {
            this.value = id;
            this.fullValue = getShortClassName(this) + "." + id;
        }

        public function toString():String {
            return fullValue;
        }
    }
}
