package core {

    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;

    import utils.Enum;

    public class BlendMode3D extends Enum {

        public static const NO_ALPHA:BlendMode3D = new BlendMode3D("NO_ALPHA", Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

        public static const NORMAL:BlendMode3D = new BlendMode3D("NORMAL", Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        public static const ADD:BlendMode3D = new BlendMode3D("ADD", Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);

        public static const ADD_PREMULTIPLIED_ALPHA:BlendMode3D = new BlendMode3D("ADD_PREMULTIPLIED_ALPHA", Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);

        public static const ERASE:BlendMode3D = new BlendMode3D("ERASE", Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        public static const LIGHTING:BlendMode3D = new BlendMode3D("MULT", Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_COLOR);

        public static const SCREEN:BlendMode3D = new BlendMode3D("SCREEN", Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR);

        public static const LAYER:BlendMode3D = new BlendMode3D("LAYER", Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);


        public var src:String;
        public var dst:String;

        public function BlendMode3D(id:String, src:String, dst:String) {
            super(id);
            this.src = src;
            this.dst = dst;
        }

        public function apply(context3D:Context3D):void {
            context3D.setBlendFactors(src, dst);
        }
    }
}
