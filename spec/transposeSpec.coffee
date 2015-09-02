transpose = require('../src/excel-as-json').transpose

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;


_removeDuplicates = (array) ->
  set = {}
  set[array[key]] = array[key] for key in [0..array.length-1]
  return (key for key of set)


describe 'transpose', ->

  square = [
    ['one', 'two', 'three'],
    ['one', 'two', 'three'],
    ['one', 'two', 'three']
  ]

  rectangleWide = [
    ['one', 'two', 'three'],
    ['one', 'two', 'three']
  ]

  rectangleTall = [
    ['one', 'two'],
    ['one', 'two'],
    ['one', 'two']
  ]


  it 'should transpose square 2D arrays', ->
    result = transpose square
    result.length.should.equal 3

    for row in result
      row.length.should.equal 3
      _removeDuplicates(row).length.should.equal 1


  it 'should transpose wide rectangular 2D arrays', ->
    result = transpose rectangleWide
    result.length.should.equal 3

    for row in result
      row.length.should.equal 2
      _removeDuplicates(row).length.should.equal 1


  it 'should transpose tall rectangular 2D arrays', ->
    result = transpose rectangleTall
    result.length.should.equal 2

    for row in result
      row.length.should.equal 3
      _removeDuplicates(row).length.should.equal 1


