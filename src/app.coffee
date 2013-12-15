THREE = require('threejs')
Stats = require('Stats')
CalibratedCamera = require('./calibratedcamera.coffee')
CameraQuad = require('./cameraquad.coffee')
FaceMesh = require('./facemesh.coffee')
Beard = require('./beard.coffee')
dat = require('datgui')

navigator.getUserMedia = navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.msGetUserMedia


module.exports =

  class App

    constructor: ->
      @initWorker()


    initWorker: =>
      @worker = new Worker('worker.js')
      @worker.onmessage = @handleWorkerMessage


    handleWorkerMessage: (message) =>
      switch message.data.command

        when 'ready'
          if 0
            @initVideo('images/test.webm')
          else
            navigator.getUserMedia video: true, audio: false, (stream) =>
              @initVideo(window.URL.createObjectURL(stream))
            , (error) ->
              document.getElementById('needcamera').style.display = 'none'
              document.getElementById('nocamera').style.display = 'table-cell'
              console.log(error)

        when 'result'
          @trackImage()
          if message.data.success
            @faceMesh.replaceVertices(message.data.data.objectPoints)

        else
          console.log(message.data.command, message.data.data)


    initVideo: (src) =>
      document.getElementById('needcamera').style.display = 'none'
      @video = document.createElement('video')
      @video.width = 320
      @video.height = 240
      @video.src = src
      @video.loop = true
      @video.load()
      @video.play()
  #    document.body.appendChild(@video)

      @initCanvas()
      @initScene()
      @initObjects()
      @initDebug()
      @animate()
      @trackImage()


    initCanvas: =>
      @captureCanvas = document.createElement('canvas')
      @captureCanvas.width = 320
      @captureCanvas.height = 240
      # document.body.appendChild(@captureCanvas)
      @captureContext = @captureCanvas.getContext('2d')
      @captureContext.translate(320, 0)
      @captureContext.scale(-1, 1)


    initScene: =>
      @camera = new CalibratedCamera()
      @scene = new THREE.Scene()

      light = new THREE.DirectionalLight(0xffffff, 0.3)
      light.position.set(1, 1, 1)
      @scene.add(light)
      light = new THREE.HemisphereLight(0xffffff, 0x888888, 0.7)
      @scene.add(light)

      @renderer = new THREE.WebGLRenderer(antialias: true, preserveDrawingBuffer: true)
      @renderer.setSize(640, 480)

      container = document.getElementById('container')
      container.appendChild(@renderer.domElement)

      button = document.getElementById('takeaphoto')
      button.onclick = @takePhoto
      button.style.display = 'block'


    initObjects: =>
      @cameraQuad = new CameraQuad(@captureCanvas)
      @scene.add(@cameraQuad)
      @faceMesh = new FaceMesh(@scene)
      @faceMesh.visible = false
      @scene.add(@faceMesh)


    initDebug: =>
      @stats = new Stats()
      container.appendChild(@stats.domElement)

      params = Debug: false
      @gui = new dat.GUI()
      @gui.add(params, 'Debug').onChange (value) =>
        @faceMesh.setDebug(value)
      @gui.add(Beard, 'SPRING', 1, 200)
      @gui.add(Beard, 'DAMPING', 0, 3).step(0.01)
      @gui.add(Beard, 'FORCE', 0, 3).step(0.01)
      @gui.close()


    animate: =>
      requestAnimationFrame(@animate)

      @captureContext.drawImage(@video, 0, 0, 320, 240)

      @cameraQuad.update()
      @faceMesh.update()

      @renderer.render(@scene, @camera)
      @stats.update()


    trackImage: =>
      data = @captureContext.getImageData(0, 0, 320, 240)
      @worker.postMessage(data.data.buffer, [data.data.buffer])


    takePhoto: =>
      e = document.createEvent('MouseEvents')
      e.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
      a = document.createElement('a')
      a.href = @renderer.domElement.toDataURL()
      a.download = "santaclaus-#{Date.now()}.png"
      a.dispatchEvent(e)

