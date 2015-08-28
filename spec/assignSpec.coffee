excelToJson = require '../src/ExcelToJson.coffee'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

describe 'assign', ->

  it 'should assign first level properties', ->
    subject = {}
    excelToJson.assign subject, 'foo', 'clyde'
    subject.foo.should.equal 'clyde'


  it 'should assign second level properties', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar', 'wombat'
    subject.foo.bar.should.equal 'wombat'


  it 'should assign third level properties', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar.bazz', 'honey badger'
    subject.foo.bar.bazz.should.equal 'honey badger'


  it 'should overwrite existing values', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar.bazz', 'honey badger'
    subject.foo.bar.bazz.should.equal 'honey badger'
    excelToJson.assign subject, 'foo.bar.bazz', "don't care"
    subject.foo.bar.bazz.should.equal "don't care"


  it 'should assign any literal value', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar.bazz', 1
    subject.foo.bar.bazz.should.equal 1

    excelToJson.assign subject, 'foo.bar.bazz', ['a', 2, ['three']]
    subject.foo.bar.bazz.toString().should.equal ['a', 2, ['three']].toString()

    test = {one: 1, 'two': 'too'}
    excelToJson.assign subject, 'foo.bar.bazz', test
    JSON.stringify(subject.foo.bar.bazz).should.equal JSON.stringify(test)


  it 'should assign properties to objects in a list', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar[0].what', 'that'
    subject.foo.bar[0].what.should.equal 'that'


  it 'should assign properties to objects in a list out of order', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar[1].what', 'that'
    excelToJson.assign subject, 'foo.bar[0].what', 'this'
    subject.foo.bar[1].what.should.equal 'that'
    subject.foo.bar[0].what.should.equal 'this'


  it 'should split a semicolon delimited list for flat arrays', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar[]', 'peter;paul;mary'
    subject.foo.bar.toString().should.equal ['peter','paul','mary'].toString()


  it 'should not split a semicolon list with a terminal indexed array', ->
    subject = {}
    excelToJson.assign subject, 'foo.bar[0]', 'peter;paul;mary'
    subject.foo.bar.should.equal 'peter;paul;mary'
