THREE = require('threejs')

module.exports =

  class CameraQuad extends THREE.Mesh

    constructor: (canvas) ->
      THREE.Mesh.call(this)

      @texture = new THREE.Texture(canvas)
      @geometry = new THREE.PlaneGeometry(2, 2, 1, 1)
      @material = new THREE.ShaderMaterial(
        depthWrite: false
        sides: THREE.DoubleSide
        uniforms:
          map: type: 't', value: @texture
        vertexShader:
          """
          varying vec2 vUv;
          void main() {
            gl_Position = vec4(position, 1);
            vUv = uv;
          }
          """
        fragmentShader:
          """
          uniform sampler2D map;
          varying vec2 vUv;
          void main() {
            gl_FragColor = texture2D(map, vUv);
          }
          """
      )
      @frustumCulled = false
      @renderDepth = -1000

    update: =>
      @texture.needsUpdate = true

