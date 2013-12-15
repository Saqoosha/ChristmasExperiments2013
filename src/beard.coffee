THREE = require('threejs')

module.exports =

  class Beard

    @BASE: null
    @setup: (original) ->
      Beard.BASE = original
      Beard.BASE.geometry.applyMatrix(new THREE.Matrix4().makeScale(10, 10, 10))
      Beard.BASE.material = new THREE.MeshLambertMaterial(color: 0xffffff, map: THREE.ImageUtils.loadTexture('images/beard.png'), transparent: true, opacity: 0.75, depthTest: false, depthWrite: false, shading: THREE.SmoothShading)
      Beard.BASE.alpha = []
      Beard.BASE.mass = []
      for v in @BASE.geometry.vertices
        # 0.95 - -19.98
        a = 1 - Math.pow((v.y - 1) / -20 * 0.7, 0.25)
        Beard.BASE.alpha.push(a)
        m = if v.z < 0 then 0 else Math.max(0, Math.min(0.9, -(v.y) / 20))
        Beard.BASE.mass.push(m)
        # console.log(v.y, a, m)
      

    tmp = new THREE.Matrix4()

    constructor: (@face, @index, @coord, @scale) ->
      @object = new THREE.Mesh(Beard.BASE.geometry.clone(), Beard.BASE.material)
      @object.frustumCulled = false
      @object.renderDepth = 1
      @object.matrixAutoUpdate = false
      @local = new THREE.Matrix4()
      @velocity = []
      for i in [0...@object.geometry.vertices.length]
        @velocity.push(new THREE.Vector3())
      @update()

    target = new THREE.Vector3()
    damping = new THREE.Vector3()
    force = new THREE.Vector3()
    acc = new THREE.Vector3()
    v = new THREE.Vector3()

    update: =>
      pos = @face.getInterpolatedPos(@index, @coord)
      z = @face.getInterpolatedNormal(@index, @coord)
      y = new THREE.Vector3(0, 1, 0)
      x = new THREE.Vector3().crossVectors(z, y)
      y.crossVectors(z, x)
      x.multiplyScalar(@scale)
      y.multiplyScalar(@scale)
      z.multiplyScalar(@scale)
      @local.set(
        x.x, y.x, z.x, pos.x
        x.y, y.y, z.y, pos.y
        x.z, y.z, z.z, pos.z
        0, 0, 0, 1
        )

      original = Beard.BASE.geometry.vertices
      alpha = Beard.BASE.alpha
      current = @object.geometry.vertices
      k = 70
      velocity = @velocity
      mass = Beard.BASE.mass
      for i in [0...original.length]
        target.copy(original[i]).applyMatrix4(@local)
        if mass[i] < 0.1
          current[i].copy(target)
        else
          damping.copy(velocity[i]).multiplyScalar(-1.5)
          force.copy(current[i]).sub(target).multiplyScalar(-k).add(damping).multiplyScalar(1.5)
          acc.copy(force).multiplyScalar(1 / mass[i] * .016666667)
          velocity[i].add(acc)
          v.copy(velocity[i]).multiplyScalar(.01666666)
          current[i].add(v)
        # current[i].lerp(target, alpha[i])

      @object.geometry.verticesNeedUpdate = true

