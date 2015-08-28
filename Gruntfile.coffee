module.exports = (grunt) ->

  require('time-grunt')(grunt)
  require('load-grunt-tasks')(grunt)

  basePath = '.'
  build = "#{basePath}/build"
  src = "#{basePath}/src"
  spec = "#{basePath}/spec"


  grunt.initConfig

    pkg: grunt.file.readJSON("package.json")


    # --------------------------------------------------------
    # Clean generated files
    # --------------------------------------------------------

    clean:
      dist: ["#{build}", 'test', 'lib', 'index.js']


    # --------------------------------------------------------
    # Run Mocha specs
    # --------------------------------------------------------

    mochaTest:
      test:
        src: ["#{spec}/all-specs.coffee"]
        options:
          reporter: 'spec'
          require: [
            'chai'
            'coffee-script/register'
            ]
          ui: 'bdd'


  # --------------------------------------------------------
  # Grunt Tasks
  # --------------------------------------------------------  

  grunt.registerTask 'default', ['mochaTest']

  grunt.registerTask 'test',    ['mochaTest']

  grunt.registerTask 'dist',    ['mochaTest']

  grunt.option 'force', true