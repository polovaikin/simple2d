package core.atlas {
    import core.ImageSource;

    import flash.display.BitmapData;
    import flash.utils.Dictionary;

    public class AtlasManager {

        public var atlases:Vector.<AtlasTexture>;
        public var imageFragmentByBitmapData:Dictionary;
        private static const ATLAS_WIDTH:int = 2048;
        private static const ATLAS_HEIGHT:int = 2048;
        /*
         * Singleton
         */
        private static var _instance:AtlasManager;

        public static function get instance():AtlasManager {
            if (!_instance)_instance = new AtlasManager();
            return _instance;
        }

        public function AtlasManager() {
            atlases = new Vector.<AtlasTexture>();
            imageFragmentByBitmapData = new Dictionary();
            atlases.push(new AtlasTexture(ATLAS_WIDTH, ATLAS_HEIGHT));
        }

        public function validateUpload():void {
            for each(var atlas:AtlasTexture in atlases) {
                atlas.validateUpload();
            }
        }

        public function clear():void {
            for each(var atlas:AtlasTexture in atlases) {
                atlas.dispose();
            }
            atlases = new Vector.<AtlasTexture>();
            imageFragmentByBitmapData = new Dictionary();
        }

        public function addImageSource(bitmapData:BitmapData, id:String):ImageSource {
            return imageFragmentByBitmapData[id] = createImageSource(bitmapData);
        }

        public function createImageSource(bitmapData:BitmapData):ImageSource {

            var imageSource:ImageSource;

            if (!bitmapData.width || !bitmapData.height || bitmapData.width > ATLAS_WIDTH || bitmapData.height > ATLAS_HEIGHT) {
                throw new Error("AtlasBuilder::addBitmapData bitmapData invalid sizes width = " + bitmapData.width + " height = " + bitmapData.height);
            }

            var i:int = 0;
            var length:uint = atlases.length;

            while (i < length && !imageSource) {
                var atlas:AtlasTexture = atlases[i++];
                imageSource = atlas.addBitmapData(bitmapData);
            }

            if (!imageSource) {
                atlas = new AtlasTexture(ATLAS_WIDTH, ATLAS_HEIGHT);
                atlases.push(atlas);
                imageSource = atlas.addBitmapData(bitmapData);
            }

            return imageSource;
        }
    }
}


