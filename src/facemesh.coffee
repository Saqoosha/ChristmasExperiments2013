THREE = require('threejs')
require('OBJLoader')
Beard = require('./beard.coffee')


cross = (a, b) -> 
  return a.x * b.y - a.y * b.x

x_ = new THREE.Vector2()
y_ = new THREE.Vector2()
pointInTriangle = (p, a, b, c) ->
  if cross(x_.subVectors(p, a), y_.subVectors(b, a)) < 0.0 then return false
  if cross(x_.subVectors(p, b), y_.subVectors(c, b)) < 0.0 then return false
  if cross(x_.subVectors(p, c), y_.subVectors(a, c)) < 0.0 then return false
  return true


module.exports =

  class FaceMesh extends THREE.Mesh

    bristles: []

    constructor: (@scene) ->
      THREE.Mesh.call(this)

      @geometry = new THREE.BufferGeometry()
      @geometry.attributes['index'] = itemSize: 1, array: new Uint16Array([20,21,23,21,22,23,0,1,36,15,16,45,0,36,17,16,26,45,17,37,18,25,44,26,17,36,37,26,44,45,18,38,19,24,43,25,18,37,38,25,43,44,19,38,20,23,43,24,20,39,21,22,42,23,20,38,39,23,42,43,21,27,22,21,39,27,22,27,42,27,28,42,27,39,28,28,47,42,28,39,40,1,41,36,15,45,46,1,2,41,14,15,46,28,40,29,28,29,47,2,40,41,14,46,47,2,29,40,14,47,29,2,3,29,13,14,29,29,31,30,29,30,35,3,31,29,13,29,35,30,32,33,30,33,34,30,31,32,30,34,35,3,4,31,12,13,35,4,5,48,11,12,54,5,6,48,10,11,54,6,59,48,10,54,55,6,7,59,9,10,55,7,58,59,9,55,56,8,57,58,8,56,57,7,8,58,8,9,56,4,48,31,12,35,54,31,48,49,35,53,54,31,49,50,35,52,53,31,50,32,34,52,35,32,50,33,33,52,34,33,50,51,33,51,52,48,60,49,49,60,50,50,60,61,50,61,51,51,61,52,61,62,52,52,62,53,53,62,54,54,63,55,55,63,56,56,63,64,56,64,57,64,65,57,57,65,58,58,65,59,48,59,65])
      @geometry.attributes['position'] = itemSize: 3, array: new Float32Array(66 * 3)
      @geometry.attributes['uv'] = itemSize: 2, array: new Float32Array([0.009070,0.786945,0.015295,0.669642,0.033595,0.554594,0.066636,0.434842,0.121454,0.314560,0.192284,0.208899,0.274712,0.122319,0.368155,0.059204,0.474319,0.041652,0.582336,0.055997,0.680900,0.111066,0.772844,0.187850,0.854184,0.286494,0.916765,0.406050,0.953679,0.529307,0.976074,0.649619,0.989946,0.772212,0.173021,0.849411,0.228432,0.871933,0.291164,0.877797,0.354235,0.867982,0.412712,0.844687,0.551554,0.848130,0.615323,0.868595,0.682697,0.874763,0.748562,0.862066,0.805419,0.832079,0.471572,0.725183,0.468898,0.642428,0.466619,0.562268,0.464717,0.485835,0.400529,0.429777,0.430456,0.416901,0.462796,0.411997,0.498237,0.415961,0.531346,0.427867,0.238870,0.736432,0.283133,0.760112,0.335198,0.755055,0.374256,0.725835,0.328682,0.716709,0.281154,0.717174,0.589321,0.724516,0.629836,0.753261,0.682746,0.754968,0.727286,0.729491,0.683582,0.712413,0.635399,0.713228,0.351485,0.282824,0.384409,0.311944,0.422824,0.336077,0.465366,0.328531,0.511262,0.335245,0.552319,0.310277,0.590543,0.281760,0.554035,0.253334,0.512305,0.234165,0.466000,0.227961,0.422227,0.234061,0.382886,0.253344,0.424446,0.293056,0.465324,0.292358,0.510077,0.292741,0.507957,0.291535,0.465287,0.287728,0.426207,0.291884])
      @geometry.offsets.push(start: 0, count: 91*3, index: 0)
      @geometry.computeVertexNormals()
      @geometry.computeBoundingSphere()

      @material = new THREE.MeshPhongMaterial(color: 0xffffff, sides: THREE.DoubleSide, map: THREE.ImageUtils.loadTexture('images/grid.png'))

      @matrixAutoUpdate = false
      @updateMatrix()
      @frustumCulled = false
      @renderDepth = 1

      loader = new THREE.OBJLoader()
      loader.load 'images/beard.obj', (object) =>
        Beard.setup(object.children[0])
        map = new Image()
        map.src = 'images/beardmap.png'
        map.onload = =>
          canvas = document.createElement('canvas')
          canvas.width = 256
          canvas.height = 256
          ctx = canvas.getContext('2d')
          ctx.drawImage(map, 0, 0, 256, 256)
          data = ctx.getImageData(0, 0, 256, 256)
          for y in [0...256] by 12
            for x in [0...256] by 12
              i = (y * 256 + x) * 4
              if data.data[i] > 32
                uv = new THREE.Vector2(x + (Math.random() - 0.5) * 12, 256 - y + (Math.random() - 0.5) * 12)
                uv.divideScalar(256)
                @addBristle(uv, data.data[i] / 256)
          for y in [0...256] by 6
            for x in [0...256] by 6
              i = (y * 256 + x) * 4 + 1
              if data.data[i] > 32
                uv = new THREE.Vector2(x + (Math.random() - 0.5) * 6, 256 - y + (Math.random() - 0.5) * 6)
                uv.divideScalar(256)
                @addBristle(uv, data.data[i] / 256 * 0.4)

      # loader = new THREE.OBJLoader()
      # loader.load 'images/hat.obj', (object) =>
      #   @hat = object.children[0]
      #   @hat = new THREE.Mesh(new THREE.CubeGeometry(50, 1, 10), new THREE.MeshLambertMaterial(color: 0xff0000, wireframe: false, wireframeLinewidth: 2))
      #   @hat.material = new THREE.MeshLambertMaterial(color: 0xffffff, wireframe: true, wireframeLinewidth: 2)
      #   @hat.matrixAutoUpdate = false
      #   @hat.frustumCulled = false
      #   @hat.renderDepth = 1
      #   axis = new THREE.AxisHelper(20)
      #   axis.material.linewidth = 3
      #   @hat.add(axis)
      #   @scene.add(@hat)


    addBristle: (uv, scale) =>
      index = @getFaceIndex(uv)
      if index == -1 then return
      coord = @getCoordOnFace(uv, index)
      b = new Beard(this, index, coord, scale)
      @scene.add(b.object)
      @bristles.push(b)
      return b


    getFacePositions: (faceIndex) =>
      indices = @geometry.attributes.index.array
      faceIndex *= 3
      v0 = indices[faceIndex++] * 3
      v1 = indices[faceIndex++] * 3
      v2 = indices[faceIndex++] * 3
      pos = @geometry.attributes.position.array
      return [
        new THREE.Vector3(pos[v0], pos[v0 + 1], pos[v0 + 2])
        new THREE.Vector3(pos[v1], pos[v1 + 1], pos[v1 + 2])
        new THREE.Vector3(pos[v2], pos[v2 + 1], pos[v2 + 2])
        ]


    getFaceNormals: (faceIndex) =>
      indices = @geometry.attributes.index.array
      faceIndex *= 3
      v0 = indices[faceIndex++] * 3
      v1 = indices[faceIndex++] * 3
      v2 = indices[faceIndex++] * 3
      normal = @geometry.attributes.normal.array
      return [
        new THREE.Vector3(normal[v0], normal[v0 + 1], normal[v0 + 2])
        new THREE.Vector3(normal[v1], normal[v1 + 1], normal[v1 + 2])
        new THREE.Vector3(normal[v2], normal[v2 + 1], normal[v2 + 2])
        ]


    getFaceUVs: (faceIndex) =>
      indices = @geometry.attributes.index.array
      faceIndex *= 3
      v0 = indices[faceIndex++] * 2
      v1 = indices[faceIndex++] * 2
      v2 = indices[faceIndex++] * 2
      uvs = @geometry.attributes.uv.array
      return [
        new THREE.Vector2(uvs[v0], uvs[v0 + 1], uvs[v0 + 2])
        new THREE.Vector2(uvs[v1], uvs[v1 + 1], uvs[v1 + 2])
        new THREE.Vector2(uvs[v2], uvs[v2 + 1], uvs[v2 + 2])
        ]

    getFaceIndex: (uv) =>
      for i in [0...91]
        uvs = @getFaceUVs(i)
        if pointInTriangle(uv, uvs[0], uvs[2], uvs[1])
          # console.log('found!', i, uv, uvs)
          return i
      return -1


    getCoordOnFace: (p, faceIndex) =>
      uvs = @getFaceUVs(faceIndex)
      p0 = uvs[0]
      p1 = uvs[1]
      p2 = uvs[2]
      U = p1.clone().sub(p0)
      V = p2.clone().sub(p0)
      x = cross(U, V)
      p = p.clone().sub(p0)
      return new THREE.Vector2(cross(p, V) / x, -cross(p, U) / x)


    getInterpolatedPos: (faceIndex, uv) =>
      pos = @getFacePositions(faceIndex)
      pos[0].multiplyScalar(1 - uv.x - uv.y)
      pos[1].multiplyScalar(uv.x)
      pos[2].multiplyScalar(uv.y)
      return pos[0].add(pos[1]).add(pos[2])


    getInterpolatedNormal: (faceIndex, uv) =>
      normal = @getFaceNormals(faceIndex)
      normal[0].multiplyScalar(1 - uv.x - uv.y)
      normal[1].multiplyScalar(uv.x)
      normal[2].multiplyScalar(uv.y)
      return normal[0].add(normal[1]).add(normal[2])


    replaceVertices: (position) =>
      @geometry.attributes.position.array = position
      @geometry.attributes.position.needsUpdate = true
      @geometry.computeVertexNormals()
      @geometry.attributes.normal.needsUpdate = true



      # if @hat
      #   uv = new THREE.Vector2(245, 512 - 96).divideScalar(512)
      #   index = @getFaceIndex(uv)
      #   coord = @getCoordOnFace(uv, index)
      #   pos = @getInterpolatedPos(index, coord)
      #   z = @getInterpolatedNormal(index, coord)
      #   y = new THREE.Vector3(0, 1, 0)
      #   x = new THREE.Vector3().crossVectors(z, y)
      #   y.crossVectors(z, x)
      #   @hat.matrix.set(
      #     x.x, y.x, z.x, pos.x
      #     x.y, y.y, z.y, pos.y
      #     x.z, y.z, z.z, pos.z
      #     0, 0, 0, 1
      #     )
      #   @hat.matrixWorldNeedsUpdate = true

        # i = 21 * 3
        # p0 = new THREE.Vector3(position[i], position[i + 1], position[i + 2])
        # i = 22 * 3
        # p1 = new THREE.Vector3(position[i], position[i + 1], position[i + 2])
        # i = 27 * 3
        # p2 = new THREE.Vector3(position[i], position[i + 1], position[i + 2])
        # i = 30 * 3
        # p3 = new THREE.Vector3(position[i], position[i + 1], position[i + 2])
        # origin = p0#.clone().add(p1).multiplyScalar(0.5)
        # x = p1.clone().sub(p0).normalize()
        # y = p2.clone().sub(p3).normalize()
        # z = new THREE.Vector3(0, 0, 1)#.crossVectors(x, y).normalize()
        # y.crossVectors(z, x)
        # # x.set(1, 0, 0)
        # # y.set(0, -1, 0)
        # # z.set(0, 0, -1)
        # @hat.matrixAutoUpdate = false
        # @hat.matrix.multiplyMatrices(@matrix, new THREE.Matrix4(
        #   x.x, -y.x, z.x, origin.x
        #   x.y, -y.y, z.y, origin.y
        #   x.z, -y.z, z.z, origin.z
        #   0, 0, 0, 1
        #   ))
        # @hat.matrixWorldNeedsUpdate = true


    update: =>
      b.update() for b in @bristles



