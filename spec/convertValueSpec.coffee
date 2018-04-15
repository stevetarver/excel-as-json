convertValue = require('../src/excel-as-json').convertValue

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

OPTIONS =
  sheet: '1'
  isColOriented: false
  omitEmptyFields: false
  omitKeysWithEmptyValues: false
  convertTextToNumber: true


describe 'convert value', ->

  it 'should convert text integers to literal numbers', ->
    convertValue('1000', OPTIONS).should.be.a('number').and.equal(1000)
    convertValue('-999', OPTIONS).should.be.a('number').and.equal(-999)


  it 'should convert text floats to literal numbers', ->
    convertValue('999.0', OPTIONS).should.be.a('number').and.equal(999.0)
    convertValue('-100.0', OPTIONS).should.be.a('number').and.equal(-100.0)


  it 'should convert text exponential numbers to literal numbers', ->
    convertValue('2e32', OPTIONS).should.be.a('number').and.equal(2e+32)


  it 'should not convert things that are not numbers', ->
    convertValue('test', OPTIONS).should.be.a('string').and.equal('test')


  it 'should convert true and false to Boolean', ->
    convertValue('true', OPTIONS).should.be.a('boolean').and.equal(true)
    convertValue('TRUE', OPTIONS).should.be.a('boolean').and.equal(true)
    convertValue('TrUe', OPTIONS).should.be.a('boolean').and.equal(true)
    convertValue('false', OPTIONS).should.be.a('boolean').and.equal(false)
    convertValue('FALSE', OPTIONS).should.be.a('boolean').and.equal(false)
    convertValue('fAlSe', OPTIONS).should.be.a('boolean').and.equal(false)


  it 'should return blank strings as strings', ->
    convertValue('', OPTIONS).should.be.a('string').and.equal('')
    convertValue(' ', OPTIONS).should.be.a('string').and.equal(' ')


  it 'should treat text that looks like numbers as text when directed', ->
    o =
      convertTextToNumber: false

    convertValue('999.0', o).should.be.a('string').and.equal('999.0')
    convertValue('-100.0', o).should.be.a('string').and.equal('-100.0')
    convertValue('2e32', o).should.be.a('string').and.equal('2e32')
    convertValue('00956', o).should.be.a('string').and.equal('00956')


  it 'should not convert numbers to text when convertTextToNumber = false', ->
    o =
      convertTextToNumber: false

    convertValue(999.0, o).should.be.a('number').and.equal(999.0)
    convertValue(-100.0, o).should.be.a('number').and.equal(-100.0)
    convertValue(2e+32, o).should.be.a('number').and.equal(2e+32)
    convertValue(956, o).should.be.a('number').and.equal(956)
    convertValue(0x4aa, o).should.be.a('number').and.equal(1194)
