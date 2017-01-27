convert = require('../src/excel-as-json').convert
should = require('./helpers').should

describe 'convert', ->

  it 'should convert a row to a list of object', ->
    data = [['a', 'b', 'c'  ],
            [ 1,   2,  'true' ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":true}]'


  it 'should convert rows to a list of objects', ->
    data = [['a', 'b', 'c'],
            [ 1,   2,   3 ],
            [ 4,   5,   6 ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'


  it 'should convert a column to list of object', ->
    data = [['a', 1],
            ['b', 2],
            ['c', 3]]
    result = convert data, {isColumnsOriented: true}
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3}]'


  it 'should convert columns to list of objects', ->
    data = [['a', 1, 4 ],
            ['b', 2, 5 ],
            ['c', 3, 6 ]]
    result = convert data, {isColumnsOriented: true}
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'


  it 'should understand dotted key paths with 2 elements', ->
    data = [['a', 'b.a', 'b.b'],
            [ 1,    2,     3  ],
            [ 4,    5,     6  ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":2,"b":3}},{"a":4,"b":{"a":5,"b":6}}]'


  it 'should understand dotted key paths with 3 elements', ->
    data = [['a', 'b.a.b', 'c'],
            [ 1,     2,     3 ],
            [ 4,     5,     6 ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":1,"b":{"a":{"b":2}},"c":3},{"a":4,"b":{"a":{"b":5}},"c":6}]'


  it 'should understand indexed arrays in dotted paths', ->
    data = [['a[0].a', 'b.a.b', 'c'],
            [   1,        2,     3 ],
            [   4,        5,     6 ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":1}],"b":{"a":{"b":2}},"c":3},{"a":[{"a":4}],"b":{"a":{"b":5}},"c":6}]'


  it 'should understand indexed arrays in dotted paths', ->
    data = [['a[0].a', 'a[0].b', 'c'],
            [   1,        2,      3 ],
            [   4,        5,      6 ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":1,"b":2}],"c":3},{"a":[{"a":4,"b":5}],"c":6}]'


  it 'should understand indexed arrays when out of order', ->
    data = [['a[1].a', 'a[0].a', 'c'],
            [   1,        2,      3 ],
            [   4,        5,      6 ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":2},{"a":1}],"c":3},{"a":[{"a":5},{"a":4}],"c":6}]'


  it 'should understand indexed arrays in deep dotted paths', ->
    data = [['a[0].a', 'b.a[0].b', 'c.a.b[0].d'],
            [   1,         2,           3      ],
            [   4,         5,           6      ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":[{"a":1}],"b":{"a":[{"b":2}]},"c":{"a":{"b":[{"d":3}]}}},{"a":[{"a":4}],"b":{"a":[{"b":5}]},"c":{"a":{"b":[{"d":6}]}}}]'


  it 'should understand flat arrays as terminal key names', ->
    data = [['a[]', 'b.a[]', 'c.a.b[]'],
            ['a;b',  'c;d',    'e;f'  ],
            ['g;h',  'i;j',    'k;l'  ]]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":["a","b"],"b":{"a":["c","d"]},"c":{"a":{"b":["e","f"]}}},{"a":["g","h"],"b":{"a":["i","j"]},"c":{"a":{"b":["k","l"]}}}]'


  it 'should convert text to numbers where appropriate', ->
    data = [[  'a',   'b',    'c'  ],
            [ '-99', 'test', '2e64']]
    result = convert data
    JSON.stringify(result).should.equal '[{"a":-99,"b":"test","c":2e+64}]'

describe 'skip', ->

  it 'should skip first n rows', ->
    data = [['skip', 'first', 'row']
            ['a', 'b', 'c'],
            [ 1,   2,   3 ],
            [ 4,   5,   6 ]]
    result = convert data, {skipRows: 1}
    JSON.stringify(result).should.equal '[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}]'

  it 'should skip first n columns', ->
    data = [['a', 'b', 'c'],
            [ 1,   2,   3 ],
            [ 4,   5,   6 ]]
    result = convert data, {skipColumns: 1}
    JSON.stringify(result).should.equal '[{"b":2,"c":3},{"b":5,"c":6}]'

  it 'should skip first n rows and m columsn', ->
    data = [['skip', 'first', 'row']
            ['a', 'b', 'c'],
            [ 1,   2,   3 ],
            [ 4,   5,   6 ]]
    result = convert data, {skipRows: 1, skipColumns: 1}
    JSON.stringify(result).should.equal '[{"b":2,"c":3},{"b":5,"c":6}]'
    

