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
        private var uvBuffer3D:VertexBuffer3D;
        private var alphaBuffer3D:VertexBuffer3D;
        private var vertexBufferNumber:Vector.<Number>;
        private var uvBufferNumber:Vector.<Number>;
        private var alphaBufferNumber:Vector.<Number>;
        private var indexBufferUint:Vector.<uint>;
        private var indexBufferByCount:Object;
        private var context3D:Context3D;

        private var shaderLinear:Program3D;
        private var shaderAlphaLinear:Program3D;

        private var shader:Program3D;
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
            if (shader) {
                shader.dispose();
                shader = null;
            }
            if (shaderAlpha) {
                shaderAlpha.dispose();
                shaderAlpha = null;
            }

            if (shaderLinear) {
                shaderLinear.dispose();
                shaderLinear = null;
            }
            if (shaderAlphaLinear) {
                shaderAlphaLinear.dispose();
                shaderAlphaLinear = null;
            }

            if (vertexBuffer3D) {
                vertexBuffer3D.dispose();
                vertexBuffer3D = null;
            }
            if (uvBuffer3D) {
                uvBuffer3D.dispose();
                uvBuffer3D = null;
            }
            if (alphaBuffer3D) {
                alphaBuffer3D.dispose();
                alphaBuffer3D = null;
            }
        }

        protected function createVideoResources():void {
            dispose();

            indexBufferByCount = new Object();

            var vertexCount:int = maxSprites * 4;

            vertexBufferNumber = new Vector.<Number>(vertexCount * 3, true);
            uvBufferNumber = new Vector.<Number>(vertexCount * 2, true);
            alphaBufferNumber = new Vector.<Number>(vertexCount, true);

            vertexBuffer3D = context3D.createVertexBuffer(vertexCount, 3);
            vertexBuffer3D.uploadFromVector(new Vector.<Number>(vertexCount * 3), 0, vertexCount);
            uvBuffer3D = context3D.createVertexBuffer(vertexCount, 2);
            uvBuffer3D.uploadFromVector(new Vector.<Number>(vertexCount * 2), 0, vertexCount);
            alphaBuffer3D = context3D.createVertexBuffer(vertexCount, 1);
            alphaBuffer3D.uploadFromVector(new Vector.<Number>(vertexCount), 0, vertexCount);

            var indexCount:int = maxSprites * 6;

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

            context3D.setVertexBufferAt(0, vertexBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
            context3D.setVertexBufferAt(1, uvBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_2); //uv

            shaderLinear = createShader(false, true);
            shaderAlphaLinear = createShader(true, true);

            shader = createShader(false, false);
            shaderAlpha = createShader(true, false);
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
        private var currentIndexInUVBuffer:int = 0;
        private var currentIndexInAlhaBuffer:int = 0;
        private var batchCount:int = 0;
        public var batchAll:int = 0;
        private var vertexCount:int = 0;
        private var lastTexture:Texture;
        private var lastBlendMode:BlendMode3D;

        private var lastLinear:Boolean;

        public static var maxSprites:int = 1000;
        private var needAlpha:Boolean;

        public function render(image:Image):void {
            if (batchCount >= maxSprites) {
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
            if (batchCount == 0 || !lastTexture)return;

            batchAll++;

            if (needAlpha) {
                alphaBuffer3D.uploadFromVector(alphaBufferNumber, 0, vertexCount);
            }
            vertexBuffer3D.uploadFromVector(vertexBufferNumber, 0, vertexCount);
            uvBuffer3D.uploadFromVector(uvBufferNumber, 0, vertexCount);

            var blendMode:BlendMode3D = lastBlendMode;

            if (blendMode && blendMode != BlendMode3D.NORMAL) {
                blendMode.apply(context3D);
            } else {
                BlendMode3D.NORMAL.apply(context3D);
            }

            context3D.setTextureAt(0, lastTexture);
            context3D.setScissorRectangle(null);

            //context3D.setStencilReferenceValue(1);
            //context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.INCREMENT_WRAP);

            if (needAlpha) {
                context3D.setVertexBufferAt(2, alphaBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_1); //alpha
            } else {
                context3D.setVertexBufferAt(2, null); //alpha
            }

            var shader:Program3D = lastLinear ? (needAlpha ? shaderAlphaLinear : shaderLinear) : (needAlpha ? shaderAlpha : shader)

            context3D.setProgram(shader);

            context3D.drawTriangles(getIndexBuffer(batchCount), 0, batchCount << 1);

            clear();
        }

        private function clear():void {
            batchCount = 0;
            vertexCount = 0;
            needAlpha = false;
            currentIndexInVertexBuffer = 0;
            currentIndexInUVBuffer = 0;
            currentIndexInAlhaBuffer = 0;
            lastBlendMode = null;
            lastTexture = null;
            lastLinear = false;
        }

        private function createShader(isAlphaEnable:Boolean, linear:Boolean):Program3D {
            var filter:String = linear ? "linear" : "nearest";

            var vs:String = "mov op, va0\n"
            vs += "mov v0, va1\n";

            if (isAlphaEnable) {
                vs += "mov v1, va2\n";

                var fs:String = "tex ft1, v0.xy, fs0 <display, repeat, " + filter + "> \n";
                fs += "mul oc, ft1, v1.x";

            } else {
                fs = "tex oc, v0.xy, fs0 <display, repeat, " + filter + ">";
            }

            var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexAssembler.assemble(Context3DProgramType.VERTEX, vs);
            var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fs);

            var shader:Program3D = context3D.createProgram();
            shader.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
            return shader;
        }

        private function loadPoints(image:Image):void {

            var verticesTransformed:Vector.<Number> = image.verticesTransformed;

            var x0:Number = verticesTransformed[0];
            var x1:Number = verticesTransformed[3];
            var x2:Number = verticesTransformed[6];
            var x3:Number = verticesTransformed[9];

            if ((x0 < -1 && x1 < -1 && x2 < -1 && x3 < -1) ||
                    (1 < x0 && 1 < x1 && 1 < x2 && 1 < x3))return;

            var y0:Number = verticesTransformed[1];
            var y1:Number = verticesTransformed[4];
            var y2:Number = verticesTransformed[7];
            var y3:Number = verticesTransformed[10];

            if ((y0 < -1 && y1 < -1 && y2 < -1 && y3 < -1) ||
                    (1 < y0 && 1 < y1 && 1 < y2 && 1 < y3))return;


            vertexBufferNumber[currentIndexInVertexBuffer++] = x0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y0;
            vertexBufferNumber[currentIndexInVertexBuffer++] = verticesTransformed[2];

            vertexBufferNumber[currentIndexInVertexBuffer++] = x1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y1;
            vertexBufferNumber[currentIndexInVertexBuffer++] = verticesTransformed[5];

            vertexBufferNumber[currentIndexInVertexBuffer++] = x2;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y2;
            vertexBufferNumber[currentIndexInVertexBuffer++] = verticesTransformed[8];


            vertexBufferNumber[currentIndexInVertexBuffer++] = x3;
            vertexBufferNumber[currentIndexInVertexBuffer++] = y3;
            vertexBufferNumber[currentIndexInVertexBuffer++] = verticesTransformed[11];

            var imageSource:ImageSource = image.source;
            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.u0;
            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.v0;

            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.u0;
            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.v1;

            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.u1;
            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.v1;

            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.u1;
            uvBufferNumber[currentIndexInUVBuffer++] = imageSource.v0;

            var alpha:int = image.alpha;
            needAlpha ||= alpha < 1;

            alphaBufferNumber[currentIndexInAlhaBuffer++] = alpha;
            alphaBufferNumber[currentIndexInAlhaBuffer++] = alpha;
            alphaBufferNumber[currentIndexInAlhaBuffer++] = alpha;
            alphaBufferNumber[currentIndexInAlhaBuffer++] = alpha;

            vertexCount += 4;
            batchCount++;
        }
    }

}