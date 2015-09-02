convertValue = require('../src/excel-as-json').convertValue

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

describe 'convert value', ->

  it 'should convert text integers to literal numbers', ->
    convertValue('1000').should.equal 1000
    convertValue('-999').should.equal -999


  it 'should convert text floats to literal numbers', ->
    convertValue('999.0').should.equal   999.0
    convertValue('-100.0').should.equal -100.0


  it 'should convert text exponential numbers to literal numbers', ->
    convertValue('2e32').should.equal 2e+32


  it 'should not convert things that are not numbers', ->
    convertValue('test').should.equal 'test'


  it 'should true and false to Boolean', ->
    convertValue('true').should.equal true
    convertValue('TRUE').should.equal true
    convertValue('TrUe').should.equal true
    convertValue('false').should.equal false
    convertValue('FALSE').should.equal false
    convertValue('fAlSe').should.equal false
