convert = require('../src/excel-as-json').convert

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

DEFAULT_OPTIONS =
  isColOriented: false
  omitEmptyFields: false
  convertTextToNumber: true

describe 'convert', ->

  it 'should convert a row to a list of object', ->
    data = [
      ['a', 'b', 'c'  ],
      [ 1,   2,  'true' ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":true}]'


  it 'should convert rows to a list of objects', ->
    data = [
      ['a', 'b', 'c'],
      [ 1,   2,   3 ],
      [ 4,   5,   6 ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'


  it 'should convert rows to a list of objects, omitting empty values', ->
    o =
      isColOriented: false
      omitEmptyFields: true
    data = [
      ['a', 'b', 'c'],
      [ 1,   '',   3 ],
      [ '',   5,   6 ],
      [ '',   5,   '' ]]
    result = convert data, o
    JSON.stringify(result).should.equal '[{"a":1,"c":3},{"b":5,"c":6},{"b":5}]'


  it 'should convert a column to list of object', ->
    o =
      isColOriented: true
      omitEmptyFields: false
    data = [['a', 1],
            ['b', 2],
            ['c', 3]]
    result = convert data, o
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3}]'


  it 'should convert columns to list of objects', ->
    o =
      isColOriented: true
      omitEmptyFields: false
    data = [['a', 1, 4 ],
            ['b', 2, 5 ],
            ['c', 3, 6 ]]
    result = convert data, o
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'


  it 'should understand dotted key paths with 2 elements', ->
    data = [
      ['a', 'b.a', 'b.b'],
      [ 1,    2,     3  ],
      [ 4,    5,     6  ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":2,"b":3}},{"a":4,"b":{"a":5,"b":6}}]'


  it 'should understand dotted key paths with 2 elements and omit elements appropriately', ->
    o =
      isColOriented: false
      omitEmptyFields: true
    data = [
      ['a', 'b.a', 'b.b'],
      [ 1,    2,     3  ],
      [ '',   5,     '' ]]
    result = convert data, o
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":2,"b":3}},{"b":{"a":5}}]'


  it 'should understand dotted key paths with 3 elements', ->
    data = [['a', 'b.a.b', 'c'],
            [ 1,     2,     3 ],
            [ 4,     5,     6 ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":{"b":2}},"c":3},{"a":4,"b":{"a":{"b":5}},"c":6}]'


  it 'should understand indexed arrays in dotted paths', ->
    data = [['a[0].a', 'b.a.b', 'c'],
            [   1,        2,     3 ],
            [   4,        5,     6 ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":[{"a":1}],"b":{"a":{"b":2}},"c":3},{"a":[{"a":4}],"b":{"a":{"b":5}},"c":6}]'


  it 'should understand indexed arrays in dotted paths', ->
    data = [['a[0].a', 'a[0].b', 'c'],
            [   1,        2,      3 ],
            [   4,        5,      6 ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":[{"a":1,"b":2}],"c":3},{"a":[{"a":4,"b":5}],"c":6}]'


  it 'should understand indexed arrays when out of order', ->
    data = [['a[1].a', 'a[0].a', 'c'],
            [   1,        2,      3 ],
            [   4,        5,      6 ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":[{"a":2},{"a":1}],"c":3},{"a":[{"a":5},{"a":4}],"c":6}]'


  it 'should understand indexed arrays in deep dotted paths', ->
    data = [['a[0].a', 'b.a[0].b', 'c.a.b[0].d'],
            [   1,         2,           3      ],
            [   4,         5,           6      ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":[{"a":1}],"b":{"a":[{"b":2}]},"c":{"a":{"b":[{"d":3}]}}},{"a":[{"a":4}],"b":{"a":[{"b":5}]},"c":{"a":{"b":[{"d":6}]}}}]'


  it 'should understand flat arrays as terminal key names', ->
    data = [['a[]', 'b.a[]', 'c.a.b[]'],
            ['a;b',  'c;d',    'e;f'  ],
            ['g;h',  'i;j',    'k;l'  ]]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":["a","b"],"b":{"a":["c","d"]},"c":{"a":{"b":["e","f"]}}},{"a":["g","h"],"b":{"a":["i","j"]},"c":{"a":{"b":["k","l"]}}}]'


  it 'should convert text to numbers where appropriate', ->
    data = [[  'a',   'b',    'c'  ],
            [ '-99', 'test', '2e64']]
    result = convert data, DEFAULT_OPTIONS
    JSON.stringify(result).should.equal '[{"a":-99,"b":"test","c":2e+64}]'


  it 'should not convert text that looks like numbers to numbers when directed', ->
    o =
      convertTextToNumber: false

    data = [[  'a',   'b',    'c',    ],
            [ '-99', '00938', '02e64' ]]
    result = convert data, o
    result[0].should.have.property('a', '-99')
    result[0].should.have.property('b', '00938')
    result[0].should.have.property('c', '02e64')


  it 'should not convert numbers to text when convertTextToNumber = false', ->
    o =
      convertTextToNumber: false

    data = [[  'a', 'b', 'c',  'd' ],
            [ -99,  938, 2e64, 0x4aa ]]
    result = convert data, o
    result[0].should.have.property('a', -99)
    result[0].should.have.property('b', 938)
    result[0].should.have.property('c', 2e+64)
    result[0].should.have.property('d', 1194)

