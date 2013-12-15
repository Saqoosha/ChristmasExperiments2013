Detector = require('Detector')
App = require('./app.coffee')

if Detector.webgl
  document.getElementById('needcamera').style.display = 'table-cell'
  new App()
else
  document.getElementById('nosupport').style.display = 'table-cell'
