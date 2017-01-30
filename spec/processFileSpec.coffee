processFile = require('../src/excel-as-json').processFile
expect = require('./helpers').expect
should = require('./helpers').should
fs = require 'fs-extra'

ROW_XLSX = 'data/row-oriented.xlsx'
ROW_JSON = 'build/row-oriented.json'
COL_XLSX = 'data/col-oriented.xlsx'
COL_JSON = 'build/col-oriented.json'
COL_JSON_NESTED = 'build/newDir/col-oriented.json'

describe 'process file', ->

  before (done) ->
    fs.remove 'build', done

  afterEach (done) ->
    fs.remove 'build', done

  it 'should notify on file does not exist', (done) ->
    processFile 'data/doesNotExist.xlsx', null, false, (err, data) ->
      err.should.be.a 'string'
      expect(data).to.be.an 'undefined'
      done()


  it 'should not blow up when a file does not exist and no callback is provided', (done) ->
    processFile 'data/doesNotExist.xlsx', ->
    done()


  it 'should notify on read error', (done) ->
    processFile 'data/row-oriented.csv', null, false, (err, data) ->
      err.should.be.a 'string'
      expect(data).to.be.an 'undefined'
      done()


  it 'should not blow up on read error when no callback is provided', (done) ->
    processFile 'data/row-oriented.csv', ->
    done()


  it 'should process row oriented Excel files, write the result, and return the parsed object', (done) ->
    processFile ROW_XLSX, ROW_JSON, {isColumnsOriented: false}, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should process col oriented Excel files, write the result, and return the parsed object', (done) ->
    processFile COL_XLSX, COL_JSON, {isColumnsOriented: true}, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615},"isEmployee":true,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"098.765.4321"}],"aliases":["stormagedden","bob"]},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7891"},{"type":"work","number":"098.765.4322"}],"aliases":["mac","markie"]}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should create the destination directory if it does not exist', (done) ->
    processFile COL_XLSX, COL_JSON_NESTED, {isColumnsOriented: true}, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(COL_JSON_NESTED, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615},"isEmployee":true,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"098.765.4321"}],"aliases":["stormagedden","bob"]},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7891"},{"type":"work","number":"098.765.4322"}],"aliases":["mac","markie"]}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should return a parsed object without writing a file', (done) ->
    processFile ROW_XLSX, undefined, {isColumnsOriented: false}, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync(ROW_JSON).should.equal false
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}]'
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should notify on write error', (done) ->
    processFile ROW_XLSX, 'build', {isColumnsOriented: false}, (err) ->
      expect(err).to.be.an 'string'
      done()
      
  it 'should process specific sheet', (done) ->
    processFile ROW_XLSX, undefined, {sheets: 2}, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync(ROW_JSON).should.equal false
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81618}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81667}}]'
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should process specific sheet, write the result, and return the parsed object', (done) ->
    processFile ROW_XLSX, ROW_JSON, {sheets: 2}, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81618}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81667}}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should process multiple sheets', (done) ->
    processFile ROW_XLSX, undefined, {sheets: [{index: 1}, {index: 2}]}, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync(ROW_JSON).should.equal false
      resultStr = '[[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}],[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81618}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81667}}]]'
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should process multiple sheets, write files with custom sub directory and name', (done) ->
    processFile ROW_XLSX, 'build', {
      sheets: [
        {index: 1, name: 'it.json'},
        {index: 2, subfolder: '/test/',  name: 'en.json'}]
    }, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync('build/it.json').should.equal true
      fs.existsSync('build/test/en.json').should.equal true
      resultStr = '[[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}],[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81618}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81667}}]]'
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should process multiple sheets with global options, write one file with custom sub directory per each column (only sheet 3) ', (done) ->
    processFile ROW_XLSX, 'build', {
      sheets: [
        {index: 1, subfolder: '/test/', name: 'it.json'},
        {index: 2, subfolder: '/test/', name: 'en.json'},
        {index: 3, subfolder: '/splitted/', isColumnsOriented: true, oneFilePerColumn: true, filenameFromField: 'key'}
      ]
    }, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync('build/test/it.json').should.equal true
      fs.existsSync('build/test/en.json').should.equal true
      fs.existsSync('build/splitted/it.json', 'utf8').should.equal true
      fs.existsSync('build/splitted/en.json', 'utf8').should.equal true
      fs.existsSync('build/splitted/fr.json', 'utf8').should.equal true
      fs.existsSync('build/splitted/es.json', 'utf8').should.equal true
      resultsStr = '[[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}],[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81618}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81667}}],{"LANGUAGE":{"LONG":"Italiano","SHORT":"IT"}},{"LANGUAGE":{"LONG":"English","SHORT":"EN"}},{"LANGUAGE":{"LONG":"Français","SHORT":"FR"}},{"LANGUAGE":{"LONG":"Español","SHORT":"ES"}}]'
      JSON.stringify(data).should.equal resultsStr
      done()




