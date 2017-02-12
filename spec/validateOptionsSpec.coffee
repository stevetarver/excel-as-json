_validateOptions = require('../src/excel-as-json')._validateOptions

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

TEST_OPTIONS =
  sheet: '1'
  isColOriented: false
  omitEmptyFields: false

describe 'validate options', ->

  it 'should provide default options when none are specified', (done) ->
    options = _validateOptions(null)
    options.sheet.should.equal '1'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal false

    options = _validateOptions(undefined)
    options.sheet.should.equal '1'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal false
    done()


  it 'should fill in missing sheet id', (done) ->
    o =
      isColOriented: false
      omitEmptyFields: false

    options = _validateOptions(o)
    options.sheet.should.equal '1'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal false
    done()


  it 'should fill in missing isColOriented', (done) ->
    o =
      sheet: '1'
      omitEmptyFields: false

    options = _validateOptions(o)
    options.sheet.should.equal '1'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal false
    done()


  it 'should fill in missing omitEmptyFields', (done) ->
    o =
      sheet: '1'
      isColOriented: false

    options = _validateOptions(o)
    options.sheet.should.equal '1'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal false
    done()


  it 'should convert a numeric sheet id to text', (done) ->
    o =
      sheet: 3
      isColOriented: false
      omitEmptyFields: true

    options = _validateOptions(o)
    options.sheet.should.equal '3'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal true
    done()


  it 'should detect invalid sheet ids and replace with the default', (done) ->
    o =
      sheet: 'one'
      isColOriented: false
      omitEmptyFields: true

    options = _validateOptions(o)
    options.sheet.should.equal '1'
    options.isColOriented.should.equal false
    options.omitEmptyFields.should.equal true

    o.sheet = 0
    options = _validateOptions(o)
    options.sheet.should.equal '1'

    o.sheet = true
    options = _validateOptions(o)
    options.sheet.should.equal '1'

    o.sheet = isNaN
    options = _validateOptions(o)
    options.sheet.should.equal '1'
    done()
