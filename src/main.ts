import {vec3, vec2} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import Mesh from './geometry/Mesh';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import {readTextFile} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Texture from './rendering/gl/Texture';

// Define an object with application parameters and button callbacks
const controls = {
  postProcessEffect: 'motion blur',

  
};

let square: Square;


let obj0: string;
let mesh0: Mesh;

let tex0: Texture;

export var currPassIndex : number;



var timer = {
  deltaTime: 0.0,
  startTime: 0.0,
  currentTime: 0.0,
  updateTime: function() {
    var t = Date.now();
    t = (t - timer.startTime) * 0.001;
    timer.deltaTime = t - timer.currentTime;
    timer.currentTime = t;
  },
}


function loadOBJText() {
  obj0 = readTextFile('../resources/obj/wahoo.obj')
}


function loadScene() {
  square && square.destroy();
  mesh0 && mesh0.destroy();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  mesh0 = new Mesh(obj0, vec3.fromValues(0, 0, 0));
  mesh0.create();

  tex0 = new Texture('../resources/textures/wahoo.bmp')
}


function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
   const gui = new DAT.GUI();
   gui.add(controls, "postProcessEffect", ["depth of field", "motion blur"]);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 9, 25), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);

  function random2( p : vec2) : vec2 {
    var result = vec2.create();
    var a = (Math.sin(vec2.dot(p,vec2.fromValues(127.1,311.7))) *43758.5453) % 1.0;
    var b = (Math.sin(vec2.dot(p,vec2.fromValues(269.5,183.3))) *43758.5453) % 1.0;
    result = vec2.scale(result, result, 2.0);
    result = vec2.subtract(result, result, vec2.fromValues(1.0, 1.0));
    result = vec2.normalize(result, result);
    return result;
  }


  function perlin(p:vec2, gridPoint: vec2) : number {
    var gradient = random2(gridPoint);
    var toP = vec2.create();
    toP = vec2.subtract(toP, p, gridPoint);
    return vec2.dot(toP, gradient);
}



  renderer.setClearColor(Math.cos(timer.currentTime) * Math.random(), (Math.sin(timer.currentTime) + 1) / 10.0, (Math.cos(timer.currentTime) + 1) / 4.0, 1);

  gl.enable(gl.DEPTH_TEST);

  const standardDeferred = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/standard-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/standard-frag.glsl')),
    ]);

  standardDeferred.setupTexUnits(["tex_Color"]);

  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    timer.updateTime();
    renderer.setClearColor(Math.cos(timer.currentTime), (Math.sin(timer.currentTime) + 1) / 10.0, (Math.cos(timer.currentTime) + 1) / 4.0, 1);

    renderer.updateTime(timer.deltaTime, timer.currentTime);

    if(controls.postProcessEffect == 'motion blur') {
      currPassIndex = 1;
    }
    else if(controls.postProcessEffect == 'depth of field') {
      currPassIndex = 0;
    }

    standardDeferred.bindTexToUnit("tex_Color", tex0, 0);

    renderer.clear();
    renderer.clearGB();

    // TODO: pass any arguments you may need for shader passes
    // forward render mesh info into gbuffers
    renderer.renderToGBuffer(camera, standardDeferred, [mesh0]);
    // render from gbuffers into 32-bit color buffer
    renderer.renderFromGBuffer(camera);
    // apply 32-bit post and tonemap from 32-bit color to 8-bit color
    renderer.renderPostProcessHDR();
    // apply 8-bit post and draw
    renderer.renderPostProcessLDR();

    stats.end();
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}


function setup() {
  timer.startTime = Date.now();
  loadOBJText();
  main();
}

setup();
