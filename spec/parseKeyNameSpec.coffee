excelToJson = require '../src/ExcelToJson.coffee'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;


describe 'parse key name', ->

  it 'should parse simple key names', ->
    [keyIsList, keyName, index] = excelToJson.parseKeyName 'names'
    keyIsList.should.equal false
    keyName.should.equal 'names'
    expect(index).to.be.an 'undefined'


  it 'should parse indexed array key names like names[1]', ->
    [keyIsList, keyName, index] = excelToJson.parseKeyName 'names[1]'
    keyIsList.should.equal true
    keyName.should.equal 'names'
    index.should.equal 1


  it 'should parse array key names like names[]', ->
    [keyIsList, keyName, index] = excelToJson.parseKeyName 'names[]'
    keyIsList.should.equal true
    keyName.should.equal 'names'
    expect(index).to.be.an 'undefined'


