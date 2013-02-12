package utils {
    public class UtilID {
        private static var id:uint = 1;

        public static function newId():int {
            return id++;
        }

        public static function newStrId():String {
            return String(newId());
        }

        public static function newStrIdPrefix(prefix:String):String {
            return prefix + "_" + newId();
        }
    }
}