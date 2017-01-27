processFile = require('../src/excel-as-json').processFile
expect = require('./helpers').expect
should = require('./helpers').should
fs = require 'fs-extra'

ROW_XLSX = 'data/row-oriented.xlsx'
ROW_JSON = 'build/row-oriented.json'
COL_XLSX = 'data/col-oriented.xlsx'
COL_JSON = 'build/col-oriented.json'
COL_JSON_NESTED = 'build/newDir/col-oriented.json'

ROW_SHEET_1_JSON = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}]'
ROW_SHEET_2_JSON = '[{"firstName":"Max","lastName":"Irwin","address":{"street":"123 Fake Street","city":"Rochester","state":"NY","zip":99999}}]'
ROW_SHEET_4_JSON = '{"LANGUAGE":{"LONG":"Italiano","SHORT":"IT"}},{"LANGUAGE":{"LONG":"English","SHORT":"EN"}},{"LANGUAGE":{"LONG":"Français","SHORT":"FR"}},{"LANGUAGE":{"LONG":"Español","SHORT":"ES"}}'
COL_SHEET_1_JSON = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615},"isEmployee":true,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"098.765.4321"}],"aliases":["stormagedden","bob"]},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7891"},{"type":"work","number":"098.765.4322"}],"aliases":["mac","markie"]}]'
COL_SHEET_2_JSON = '[{"firstName":"Max","lastName":"Irwin","address":{"street":"123 Fake Street","city":"Rochester","state":"NY","zip":99999},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"505-505-1010"}],"aliases":["binarymax","arch"]}]'

describe 'process file', ->

  before (done) ->
    fs.remove 'build', done

  afterEach (done) ->
    fs.remove 'build', done

  it 'should notify on file does not exist', (done) ->
    processFile 'data/doesNotExist.xlsx', null, (err, data) ->
      err.should.be.a 'string'
      expect(data).to.be.an 'undefined'
      done()


  it 'should not blow up when a file does not exist and no callback is provided', (done) ->
    processFile 'data/doesNotExist.xlsx', ->
    done()


  it 'should not blow up on read error when no callback is provided', (done) ->
    processFile 'data/row-oriented.csv', ->
    done()


  it 'should notify on read error', (done) ->
    processFile 'data/row-oriented.csv', null, (err, data) ->
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
      JSON.stringify(result).should.equal ROW_SHEET_1_JSON
      JSON.stringify(data).should.equal ROW_SHEET_1_JSON
      done()


  it 'should process col oriented Excel files, write the result, and return the parsed object', (done) ->
    processFile COL_XLSX, COL_JSON, {isColumnsOriented: true}, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      JSON.stringify(result).should.equal COL_SHEET_1_JSON
      JSON.stringify(data).should.equal COL_SHEET_1_JSON
      done()

  it 'should process sheet 2 of row oriented Excel files, write the result, and return the parsed object', (done) ->
    options =
      sheets: 2
      isColumnsOriented: false
      omitEmptyFields: false

    processFile ROW_XLSX, ROW_JSON, options, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      JSON.stringify(result).should.equal ROW_SHEET_2_JSON
      JSON.stringify(data).should.equal ROW_SHEET_2_JSON
      done()

  it 'should process sheet 2 of col oriented Excel files, write the result, and return the parsed object', (done) ->
    options =
      sheets: 2
      isColumnsOriented: true
      omitEmptyFields: false

    processFile COL_XLSX, COL_JSON, options, (err, data) ->
      expect(err).to.not.exist
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      JSON.stringify(result).should.equal COL_SHEET_2_JSON
      JSON.stringify(data).should.equal COL_SHEET_2_JSON
      done()


  it 'should create the destination directory if it does not exist', (done) ->
    options =
      sheet: '1'
      isColumnsOriented: true
      omitEmptyFields: false

    processFile COL_XLSX, COL_JSON_NESTED, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(COL_JSON_NESTED, 'utf8'))
      JSON.stringify(result).should.equal COL_SHEET_1_JSON
      JSON.stringify(data).should.equal COL_SHEET_1_JSON
      done()


  it 'should return a parsed object without writing a file', (done) ->
    # Ensure result file does not exit
    try fs.unlinkSync ROW_JSON
    catch # ignore file does not exist

    options =
      sheet: '1'
      isColumnsOriented: false
      omitEmptyFields: false

    processFile ROW_XLSX, undefined, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      fs.existsSync(ROW_JSON).should.equal false
      JSON.stringify(data).should.equal ROW_SHEET_1_JSON
      done()


  it 'should notify on write error', (done) ->
    processFile ROW_XLSX, 'build', {isColumnsOriented: false}, (err) ->
      expect(err).to.exist
      done()

  it 'should process only specified sheets', (done) ->
    processFile ROW_XLSX, undefined, {sheets: [{index: 1}, {index: 2}]}, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync(ROW_JSON).should.equal false
      resultStr = '[' + ROW_SHEET_1_JSON + ',' + ROW_SHEET_2_JSON + ']'
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
      resultStr = '[' + ROW_SHEET_1_JSON + ',' + ROW_SHEET_2_JSON + ']'
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should process multiple sheets with global options, write one file with custom sub directory per each column (only sheet 3) ', (done) ->
    processFile ROW_XLSX, 'build', {
      sheets: [
        {index: 1, subfolder: '/test/', name: 'it.json'},
        {index: 2, subfolder: '/test/', name: 'en.json'},
        {index: 4, subfolder: '/splitted/', isColumnsOriented: true, oneFilePerColumn: true, filenameFromField: 'key'}
      ]
    }, (err, data) ->
      expect(err).to.not.exist
      fs.existsSync('build/test/it.json').should.equal true
      fs.existsSync('build/test/en.json').should.equal true
      fs.existsSync('build/splitted/it.json', 'utf8').should.equal true
      fs.existsSync('build/splitted/en.json', 'utf8').should.equal true
      fs.existsSync('build/splitted/fr.json', 'utf8').should.equal true
      fs.existsSync('build/splitted/es.json', 'utf8').should.equal true
      resultStr = '[' + ROW_SHEET_1_JSON + ',' + ROW_SHEET_2_JSON + ',' + ROW_SHEET_4_JSON + ']'
      JSON.stringify(data).should.equal resultStr
      done()




