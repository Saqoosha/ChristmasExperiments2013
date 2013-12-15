module.exports = (grunt) ->

  grunt.initConfig

    browserify:
      'dist/bundle.js': ['src/main.coffee']
      options:
        transform: ['coffeeify']
        debug: true
        shim:
          threejs:
            path: 'src/libs/three.js'
            exports: 'THREE'
          OBJLoader:
            path: 'src/libs/OBJLoader.js'
            exports: ''
            depends: threejs: 'THREE'
          Detector:
            path: 'src/libs/Detector.js'
            exports: 'Detector'
          Stats:
            path: 'src/libs/stats.min.js'
            exports: 'Stats'
          datgui:
            path: 'src/libs/dat.gui.js'
            exports: 'dat'


    coffee:
      options:
        bare: true
        sourceMap: true
      worker:
        src: ['src/worker.coffee']
        dest: 'dist/worker.js'

    watch:
      html:
        files: ['dist/*']
        options:
          livereload: true
      scripts:
        files: ['src/*.coffee']
        tasks: ['browserify', 'coffee']

    connect:
      server:
        options:
          base: 'dist'

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.registerTask('default', ['connect', 'browserify', 'coffee', 'watch'])
