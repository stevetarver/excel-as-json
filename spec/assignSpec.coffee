assign = require('../src/excel-as-json').assign

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

# NOTE: the excel package uses '' for all empty cells
EMPTY_CELL = ''
DEFAULT_OPTIONS =
  omitEmptyFields: false
  convertTextToNumber: true


describe 'assign', ->

  it 'should assign first level properties', ->
    subject = {}
    assign subject, 'foo', 'clyde', DEFAULT_OPTIONS
    subject.foo.should.equal 'clyde'


  it 'should assign second level properties', ->
    subject = {}
    assign subject, 'foo.bar', 'wombat', DEFAULT_OPTIONS
    subject.foo.bar.should.equal 'wombat'


  it 'should assign third level properties', ->
    subject = {}
    assign subject, 'foo.bar.bazz', 'honey badger', DEFAULT_OPTIONS
    subject.foo.bar.bazz.should.equal 'honey badger'


  it 'should convert text to numbers', ->
    subject = {}
    assign subject, 'foo.bar.bazz', '42', DEFAULT_OPTIONS
    subject.foo.bar.bazz.should.equal 42


  it 'should convert text to booleans', ->
    subject = {}
    assign subject, 'foo.bar.bazz', 'true', DEFAULT_OPTIONS
    subject.foo.bar.bazz.should.equal true
    assign subject, 'foo.bar.bazz', 'false', DEFAULT_OPTIONS
    subject.foo.bar.bazz.should.equal false


  it 'should overwrite existing values', ->
    subject = {}
    assign subject, 'foo.bar.bazz', 'honey badger', DEFAULT_OPTIONS
    subject.foo.bar.bazz.should.equal 'honey badger'
    assign subject, 'foo.bar.bazz', "don't care", DEFAULT_OPTIONS
    subject.foo.bar.bazz.should.equal "don't care"


  it 'should assign properties to objects in a list', ->
    subject = {}
    assign subject, 'foo.bar[0].what', 'that', DEFAULT_OPTIONS
    subject.foo.bar[0].what.should.equal 'that'


  it 'should assign properties to objects in a list with first entry out of order', ->
    subject = {}
    assign subject, 'foo.bar[1].what', 'that', DEFAULT_OPTIONS
    assign subject, 'foo.bar[0].what', 'this', DEFAULT_OPTIONS
    subject.foo.bar[0].what.should.equal 'this'
    subject.foo.bar[1].what.should.equal 'that'


  it 'should assign properties to objects in a list with second entry out of order', ->
    subject = {}
    assign subject, 'foo.bar[0].what', 'this', DEFAULT_OPTIONS
    assign subject, 'foo.bar[2].what', 'that', DEFAULT_OPTIONS
    assign subject, 'foo.bar[1].what', 'other', DEFAULT_OPTIONS
    subject.foo.bar[0].what.should.equal 'this'
    subject.foo.bar[2].what.should.equal 'that'
    subject.foo.bar[1].what.should.equal 'other'


  it 'should split a semicolon delimited list for flat arrays', ->
    subject = {}
    assign subject, 'foo.bar[]', 'peter;paul;mary', DEFAULT_OPTIONS
    subject.foo.bar.toString().should.equal ['peter','paul','mary'].toString()


  it 'should convert text in a semicolon delimited list to numbers', ->
    subject = {}
    assign subject, 'foo.bar[]', 'peter;-43;mary', DEFAULT_OPTIONS
    subject.foo.bar.toString().should.equal ['peter',-43,'mary'].toString()


  it 'should convert text in a semicolon delimited list to booleans', ->
    subject = {}
    assign subject, 'foo.bar[]', 'peter;false;true', DEFAULT_OPTIONS
    subject.foo.bar.toString().should.equal ['peter',false,true].toString()


  it 'should not split a semicolon list with a terminal indexed array', ->
    subject = {}
    console.log('Note: warnings on this test expected')
    assign subject, 'foo.bar[0]', 'peter;paul;mary', DEFAULT_OPTIONS
    subject.foo.bar.should.equal 'peter;paul;mary'


  it 'should omit empty scalar fields when directed', ->
    o =
      omitEmptyFields: true
      convertTextToNumber: true
    subject = {}
    assign subject, 'foo', EMPTY_CELL, o
    subject.should.not.have.property 'foo'


  it 'should omit empty nested scalar fields when directed', ->
    o =
      omitEmptyFields: true
      convertTextToNumber: true
    subject = {}
    assign subject, 'foo.bar', EMPTY_CELL, o
    subject.should.have.property 'foo'
    subject.foo.should.not.have.property 'bar'


  it 'should omit nested array fields when directed', ->
    o =
      omitEmptyFields: true
      convertTextToNumber: true

    # specified as an entire list
    subject = {}
    console.log('Note: warnings on this test expected')
    assign subject, 'foo[]', EMPTY_CELL, o
    subject.should.not.have.property 'foo'

    # specified as a list
    subject = {}
    assign subject, 'foo[0]', EMPTY_CELL, o
    subject.should.not.have.property 'foo'

    # specified as a list of objects
    subject = {}
    assign subject, 'foo[0].bar', 'bazz', o
    assign subject, 'foo[1].bar', EMPTY_CELL, o
    subject.foo[1].should.not.have.property 'bar'


  it 'should treat text that looks like numbers as text when directed', ->
    o =
      convertTextToNumber: false

    subject = {}
    assign subject, 'part', '00938', o
    subject.part.should.be.a('string').and.equal('00938')
