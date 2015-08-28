excelToJson = require '../src/ExcelToJson.coffee'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

describe 'convert', ->

  it 'should convert a row to a list of object', ->
    data = [['a', 'b', 'c'],
            [ 1,   2,   3 ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3}]'


  it 'should convert rows to a list of objects', ->
    data = [['a', 'b', 'c'],
            [ 1,   2,   3 ],
            [ 4,   5,   6 ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'


  it 'should convert a column to list of object', ->
    data = [['a', 1],
            ['b', 2],
            ['c', 3]]
    result = excelToJson.convert data, true
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3}]'


  it 'should convert columns to list of objects', ->
    data = [['a', 1, 4 ],
            ['b', 2, 5 ],
            ['c', 3, 6 ]]
    result = excelToJson.convert data, true
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'


  it 'should understand dotted key paths with 2 elements', ->
    data = [['a', 'b.a', 'b.b'],
            [ 1,    2,     3  ],
            [ 4,    5,     6  ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":2,"b":3}},{"a":4,"b":{"a":5,"b":6}}]'


  it 'should understand dotted key paths with 3 elements', ->
    data = [['a', 'b.a.b', 'c'],
            [ 1,     2,     3 ],
            [ 4,     5,     6 ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":{"b":2}},"c":3},{"a":4,"b":{"a":{"b":5}},"c":6}]'


  it 'should understand indexed arrays in dotted paths', ->
    data = [['a[0].a', 'b.a.b', 'c'],
            [   1,        2,     3 ],
            [   4,        5,     6 ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":1}],"b":{"a":{"b":2}},"c":3},{"a":[{"a":4}],"b":{"a":{"b":5}},"c":6}]'


  it 'should understand indexed arrays in dotted paths', ->
    data = [['a[0].a', 'a[0].b', 'c'],
            [ 1,     2,     3 ],
            [ 4,     5,     6 ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":1,"b":2}],"c":3},{"a":[{"a":4,"b":5}],"c":6}]'


  it 'should understand indexed arrays when out of order', ->
    data = [['a[1].a', 'a[0].a', 'c'],
            [   1,        2,      3 ],
            [   4,        5,      6 ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":2},{"a":1}],"c":3},{"a":[{"a":5},{"a":4}],"c":6}]'


  it 'should understand indexed arrays in deep dotted paths', ->
    data = [['a[0].a', 'b.a[0].b', 'c.a.b[0].d'],
            [   1,         2,           3      ],
            [   4,         5,           6      ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":1}],"b":{"a":[{"b":2}]},"c":{"a":{"b":[{"d":3}]}}},{"a":[{"a":4}],"b":{"a":[{"b":5}]},"c":{"a":{"b":[{"d":6}]}}}]'


  it 'should understand arrays as key names', ->
    data = [['a[]', 'b.a[]', 'c.a.b[]'],
            ['a;b',  'c;d',    'e;f'  ],
            ['g;h',  'i;j',    'k;l'  ]]
    result = excelToJson.convert data
    JSON.stringify(result).should.equal '[{"a":["a","b"],"b":{"a":["c","d"]},"c":{"a":{"b":["e","f"]}}},{"a":["g","h"],"b":{"a":["i","j"]},"c":{"a":{"b":["k","l"]}}}]'


