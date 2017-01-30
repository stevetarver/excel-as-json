parseKeyName = require('../src/excel-as-json').parseKeyName
expect = require('./helpers').expect
should = require('./helpers').should


describe 'parse key name', ->

  it 'should parse simple key names', ->
    [keyIsList, keyName, index] = parseKeyName 'names'
    keyIsList.should.equal false
    keyName.should.equal 'names'
    expect(index).to.be.an 'undefined'


  it 'should parse indexed array key names like names[1]', ->
    [keyIsList, keyName, index] = parseKeyName 'names[1]'
    keyIsList.should.equal true
    keyName.should.equal 'names'
    index.should.equal 1


  it 'should parse array key names like names[]', ->
    [keyIsList, keyName, index] = parseKeyName 'names[]'
    keyIsList.should.equal true
    keyName.should.equal 'names'
    expect(index).to.be.an 'undefined'


