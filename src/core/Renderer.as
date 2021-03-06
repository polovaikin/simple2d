package core {
    import core.atlas.AtlasTexture;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;

    import utils.AGALMiniAssembler;

    public class Renderer {

        private var vertexBuffer3D:VertexBuffer3D;
        private var vertexBufferNumber:Vector.<Number>;
        private var indexBufferUint:Vector.<uint>;
        private var indexBufferByCount:Object;
        private var context3D:Context3D;

        private var shaderAlphaLinear:Program3D;
        private var shaderAlpha:Program3D;

        /*
         * Singleton
         */
        private static var _instance:Renderer;

        public static function get instance():Renderer {
            if (!_instance)_instance = new Renderer();
            return _instance;
        }

        public function init(context3D:Context3D) {
            this.context3D = context3D;
            createVideoResources();
        }

        public function dispose():void {
            if (shaderAlpha) {
                shaderAlpha.dispose();
                shaderAlpha = null;
            }

            if (shaderAlphaLinear) {
                shaderAlphaLinear.dispose();
                shaderAlphaLinear = null;
            }

            if (vertexBuffer3D) {
                vertexBuffer3D.dispose();
                vertexBuffer3D = null;
            }

        }

        protected function createVideoResources():void {
            dispose();

            indexBufferByCount = new Object();

            var vertexCount:int = maxImageCount * 4;

            vertexBufferNumber = new Vector.<Number>(vertexCount * 5, true);

            vertexBuffer3D = context3D.createVertexBuffer(vertexCount, 5);
            vertexBuffer3D.uploadFromVector(vertexBufferNumber, 0, vertexCount);

            var indexCount:int = maxImageCount * 6;

            indexBufferUint = new Vector.<uint>(indexCount, true);

            var i:int = 0;
            var k:int = 0;

            while (k < vertexCount) {

                indexBufferUint[i++] = k;
                indexBufferUint[i++] = k + 2;
                indexBufferUint[i++] = k + 1;

                indexBufferUint[i++] = k + 2;
                indexBufferUint[i++] = k;
                indexBufferUint[i++] = k + 3;
                k += 4;
            }

            context3D.setRenderToBackBuffer();
            context3D.setCulling(Context3DTriangleFace.NONE);
            context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);

            context3D.setVertexBufferAt(0, vertexBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
            context3D.setVertexBufferAt(1, vertexBuffer3D, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
            context3D.setVertexBufferAt(2, vertexBuffer3D, 4, Context3DVertexBufferFormat.FLOAT_1); //alpha

            shaderAlphaLinear = createShader(true);
            shaderAlpha = createShader(false);
        }

        private function getIndexBuffer(spriteCount:int):IndexBuffer3D {
            var indexBuffer3D:IndexBuffer3D = indexBufferByCount[spriteCount];
            if (!indexBuffer3D) {
                var indexCount:int = spriteCount * 6;
                indexBuffer3D = indexBufferByCount[spriteCount] = context3D.createIndexBuffer(indexCount);
                indexBuffer3D.uploadFromVector(indexBufferUint, 0, indexCount);
            }
            return indexBuffer3D;
        }

        private var currentIndexInVertexBuffer:int = 0;
        private var imageCountBatch:int = 0;
        public var renderCount:int = 0;
        private var vertexCount:int = 0;
        private var lastTexture:Texture;
        private var lastBlendMode:BlendMode3D;

        private var lastLinear:Boolean;

        public static var maxImageCount:int = 10000;

        public var imageCount:int;

        public function render(image:Image):void {
            imageCount++;

            if (imageCountBatch >= maxImageCount) {
                renderBatch();
            } else {

                var atlasTexture:AtlasTexture = image.source.texture;

                var texture:Texture = atlasTexture.texture;
                var blendMode:BlendMode3D = image.blendModeGlobal;
                var linear:Boolean = image.linear;

                if (lastTexture != texture || lastBlendMode != blendMode || lastLinear != linear) {

                    renderBatch();

                    lastTexture = texture;
                    lastBlendMode = blendMode;
                    lastLinear = linear;
                }
            }
            loadPoints(image);
        }

        public function renderBatch():void {
            if (imageCountBatch == 0 || !lastTexture)return;

            renderCount++;

            vertexBuffer3D.uploadFromVector(vertexBufferNumber, 0, vertexCount);

            lastBlendMode.apply(context3D);

            context3D.setTextureAt(0, lastTexture);
            context3D.setProgram(lastLinear ? shaderAlphaLinear : shaderAlpha);

            context3D.drawTriangles(getIndexBuffer(imageCountBatch), 0, imageCountBatch << 1);

            clear();
        }

        private function clear():void {
            imageCountBatch = 0;
            vertexCount = 0;
            currentIndexInVertexBuffer = 0;
            lastBlendMode = null;
            lastTexture = null;
            lastLinear = false;
        }

        private function createShader(linear:Boolean):Program3D {
            var filter:String = linear ? "linear" : "nearest";

            var vs:String = "mov op, va0\n"
            vs += "mov v0, va1\n";


            vs += "mov v1, va2\n";

            var fs:String = "tex ft1, v0.xy, fs0 <display, repeat, " + filter + "> \n";
            fs += "mul oc, ft1, v1.x";


            var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexAssembler.assemble(Context3DProgramType.VERTEX, vs);
            var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fs);

            var shader:Program3D = context3D.createProgram();
            shader.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
            return shader;
        }

        private function loadPoints(image:Image):void {

            image.validateVertices();

            var x0:Number = image.x0;
            var x1:Number = image.x1;
            var x2:Number = image.x2;
            var x3:Number = image.x3;

            if ((x0 < -1 && x1 < -1 && x2 < -1 && x3 < -1) ||
                    (1 < x0 && 1 < x1 && 1 < x2 && 1 < x3))return;

            var y0:Number = image.y0;
            var y1:Number = image.y1;
            var y2:Number = image.y2;
            var y3:Number = image.y3;

            if ((y0 < -1 && y1 < -1 && y2 < -1 && y3 < -1) ||
                    (1 < y0 && 1 < y1 && 1 < y2 && 1 < y3))return;

            var alpha:Number = image.alphaGlobal;

            var imageSource:ImageSource = image.source;


            vertexBufferNumber[currentIndexInVertexBuffer++] = x0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.u0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.v0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = alpha;

            vertexBufferNumber[currentIndexInVertexBuffer++] = x1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.u0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.v1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = alpha;

            vertexBufferNumber[currentIndexInVertexBuffer++] = x2;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y2;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.u1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.v1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = alpha;

            vertexBufferNumber[currentIndexInVertexBuffer++] = x3;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y3;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.u1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = imageSource.v0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = alpha;


            vertexCount += 4;
            imageCountBatch++;
        }
    }

}