

class App

  constructor: ->
    @prev = 0

  handleMessage: (message) =>
#    t = Date.now()
#    Module.print "t " + (t - @prev)
#    @prev = t

    Module.HEAPU8.set(new Uint8Array(message.data), @data)
    success = !!_update(@tracker, @data, 320, 240)
    result = null
    if success
      points = _getImagePoints(@tracker)
      imagePoints = new Float64Array(66 * 2)
      points = points >> 3
      imagePoints.set(Module.HEAPF64.subarray(points, points + imagePoints.length))
      p = _getCalibratedObjectPoints(@tracker)
      p = p >> 2
      objectPoints = new Float32Array(66 * 3)
      objectPoints.set(Module.HEAPF32.subarray(p, p + objectPoints.length))
      result = imagePoints: imagePoints, objectPoints: objectPoints
    self.postMessage(
      command: "result"
      success: success
      data: result
    )

  print: (text) =>
    self.postMessage
      command: "print"
      data: text

  printErr: (text) =>
    self.postMessage
      command: "printErr"
      data: text

  setStatus: (text) =>
    self.postMessage
      command: "setStatus"
      data: text

  postRun: =>
    start = Date.now()
    @tracker = _createTracker()
    @print "_createTracker: " + (Date.now() - start)
    @data = _malloc(640 * 480 * 4)
    self.postMessage command: "ready"


app = new App()
self.onmessage = app.handleMessage

window =
  location: pathname: "hoge"
  encodeURIComponent: -> "hoge"
Module =
  print: app.print
  printErr: app.printErr
  setStatus: app.setStatus
  postRun: app.postRun

importScripts "libft.js"
