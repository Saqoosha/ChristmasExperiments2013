THREE = require('threejs')

module.exports =

  class CalibratedCamera extends THREE.Camera

    constructor: ->
      THREE.Camera.call(this)
      
      nearDist = 10
      farDist = 10000
      cx = 326.259
      cy = 235.269
      fx = 634.957
      fy = 634.779
      h = 480 / 2
      w = 640 / 2
      @projectionMatrix.makeFrustum(
        nearDist * (-cx) / fx, nearDist * (w - cx) / fx,
        nearDist * (cy - h) / fy, nearDist * (cy) / fy,
        nearDist, farDist)
      @matrixAutoUpdate = false
      @matrix.lookAt(new THREE.Vector3(0, 0, 0), new THREE.Vector3(0, 0, 1), new THREE.Vector3(0, -1, 0))

