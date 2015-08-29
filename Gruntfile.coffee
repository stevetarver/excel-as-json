module.exports = (grunt) ->

  require('time-grunt')(grunt)
  require('load-grunt-tasks')(grunt)

  build = "./build"  # Temp build files
  lib   = "./lib"    # Transpiled JavaScript files
  spec  = "./spec"   # CoffeeScript specifications
  src   = "./src"    # CoffeeScript source
  test  = "./test"    # Transpiled JavaScript test files


  grunt.initConfig

    pkg: grunt.file.readJSON("package.json")


    # --------------------------------------------------------
    # Clean generated files
    # --------------------------------------------------------

    clean:
      dist: [build, test, lib]


    # --------------------------------------------------------
    # Compile coffee files
    # --------------------------------------------------------

    run:
      tool:
        cmd: './build.sh'


    # --------------------------------------------------------
    # Upload coverage to coveralls
    # --------------------------------------------------------

    coveralls:
      options:
        force: false
      dist:
        src: 'coverage-results/extra-results-*.info'


    # --------------------------------------------------------
    # Run Mocha specs
    # --------------------------------------------------------

    mochaTest:
      test:
        src: ["#{spec}/all-specs.coffee"]
        options:
          reporter: 'spec'
          require: ['chai', 'coffee-script/register']
          ui: 'bdd'


  # --------------------------------------------------------
  # Grunt Tasks
  # --------------------------------------------------------  

  grunt.registerTask 'default', ['mochaTest']
  grunt.registerTask 'test',    ['mochaTest']
  grunt.registerTask 'dist',    ['clean', 'run', 'mochaTest']

  grunt.option 'force', true