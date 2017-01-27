assign = require('../src/excel-as-json').assign
should = require('./helpers').should

describe 'assign', ->

  it 'should assign first level properties', ->
    subject = {}
    assign subject, 'foo', 'clyde'
    subject.foo.should.equal 'clyde'


  it 'should assign second level properties', ->
    subject = {}
    assign subject, 'foo.bar', 'wombat'
    subject.foo.bar.should.equal 'wombat'


  it 'should assign third level properties', ->
    subject = {}
    assign subject, 'foo.bar.bazz', 'honey badger'
    subject.foo.bar.bazz.should.equal 'honey badger'


  it 'should convert text to numbers', ->
    subject = {}
    assign subject, 'foo.bar.bazz', '42'
    subject.foo.bar.bazz.should.equal 42


  it 'should convert text to booleans', ->
    subject = {}
    assign subject, 'foo.bar.bazz', 'true'
    subject.foo.bar.bazz.should.equal true
    assign subject, 'foo.bar.bazz', 'false'
    subject.foo.bar.bazz.should.equal false


  it 'should overwrite existing values', ->
    subject = {}
    assign subject, 'foo.bar.bazz', 'honey badger'
    subject.foo.bar.bazz.should.equal 'honey badger'
    assign subject, 'foo.bar.bazz', "don't care"
    subject.foo.bar.bazz.should.equal "don't care"


  it 'should assign properties to objects in a list', ->
    subject = {}
    assign subject, 'foo.bar[0].what', 'that'
    subject.foo.bar[0].what.should.equal 'that'


  it 'should assign properties to objects in a list with first entry out of order', ->
    subject = {}
    assign subject, 'foo.bar[1].what', 'that'
    assign subject, 'foo.bar[0].what', 'this'
    subject.foo.bar[0].what.should.equal 'this'
    subject.foo.bar[1].what.should.equal 'that'


  it 'should assign properties to objects in a list with second entry out of order', ->
    subject = {}
    assign subject, 'foo.bar[0].what', 'this'
    assign subject, 'foo.bar[2].what', 'that'
    assign subject, 'foo.bar[1].what', 'other'
    subject.foo.bar[0].what.should.equal 'this'
    subject.foo.bar[2].what.should.equal 'that'
    subject.foo.bar[1].what.should.equal 'other'


  it 'should split a semicolon delimited list for flat arrays', ->
    subject = {}
    assign subject, 'foo.bar[]', 'peter;paul;mary'
    subject.foo.bar.toString().should.equal ['peter','paul','mary'].toString()


  it 'should convert text in a semicolon delimited list to numbers', ->
    subject = {}
    assign subject, 'foo.bar[]', 'peter;-43;mary'
    subject.foo.bar.toString().should.equal ['peter',-43,'mary'].toString()


  it 'should convert text in a semicolon delimited list to booleans', ->
    subject = {}
    assign subject, 'foo.bar[]', 'peter;false;true'
    subject.foo.bar.toString().should.equal ['peter',false,true].toString()


  it 'should not split a semicolon list with a terminal indexed array', ->
    subject = {}
    assign subject, 'foo.bar[0]', 'peter;paul;mary'
    subject.foo.bar.should.equal 'peter;paul;mary'
