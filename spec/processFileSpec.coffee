processFile = require('../src/excel-as-json').processFile
processFileSync = require('../src/excel-as-json').processFileSync
fs = require 'fs'
path = require 'path'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

ROW_XLSX = 'data/row-oriented.xlsx'
ROW_CSV = 'data/row-oriented.csv'
ROW_JSON = 'build/row-oriented.json'
COL_XLSX = 'data/col-oriented.xlsx'
COL_JSON = 'build/col-oriented.json'
DIRECTORY = 'build/dir'

describe 'process file', ->

  it 'should notify on file does not exist', (done) ->
    processFile 'data/doesNotExist.xlsx', null, false, (err, data) ->
      err.should.be.an 'error'
      expect(data).to.be.an 'undefined'

      # Test sync API
      expect(() ->
        processFileSync 'data/doesNotExist', null, false
      ).to.throw(Error)
      done()


  it 'should not blow up when a file does not exist and no callback is provided', (done) ->
    processFile 'data/doesNotExist.xlsx', ->
    done()


  it 'should notify on read error', (done) ->
    processFile 'data/image.gif', null, false, (err, data) ->
      err.should.be.an 'error'
      expect(data).to.be.an 'undefined'
      done()


  it 'should not blow up on read error when no callback is provided', (done) ->
    processFile 'data/image.gif', ->
    done()


  it 'should process row oriented Excel files and return the parsed object', (done) ->
    processFile ROW_XLSX, ROW_JSON, false, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should process col oriented Excel files', (done) ->
    processFile COL_XLSX, COL_JSON, true, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615},"isEmployee":true,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"098.765.4321"}],"aliases":["stormagedden","bob"]},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7891"},{"type":"work","number":"098.765.4322"}],"aliases":["mac","markie"]}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should produce the same result on csv as equivalent xlsx file', (done) ->
    processFile ROW_XLSX, null, false, (err, xlsxData) ->
      expect(err).to.be.an 'undefined'
      processFile ROW_CSV, null, false, (err, csvData) ->
        expect(err).to.be.an 'undefined'
        expect(xlsxData.length).to.equal(2)
        expect(xlsxData).to.eql(csvData)
        done()

  it 'should return a parsed object without writing a file', (done) ->
    # Ensure result file does not exit
    try fs.unlinkSync ROW_JSON
    catch # ignore file does not exist

    processFile ROW_XLSX, undefined, false, (err, data) ->
      expect(err).to.be.an 'undefined'
      fs.existsSync(ROW_JSON).should.equal false
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}]'
      JSON.stringify(data).should.equal resultStr
      done()

  it 'should create directory if directory does not exist', (done) ->
    path = path.join(DIRECTORY, "out.json")
    processFile ROW_CSV, path, false, (err, data) ->
      expect(err).to.be.an 'undefined'
      fs.existsSync(path).should.equal true

      # Cleanup
      fs.unlinkSync(path)
      fs.rmdirSync(DIRECTORY)

      # Synchronous version
      processFileSync ROW_CSV, path, false
      fs.existsSync(path).should.equal true

      # Cleanup
      fs.unlinkSync(path)
      fs.rmdirSync(DIRECTORY)
      done()


  it 'should notify on write error', (done) ->
    processFile ROW_XLSX, 'build', false, (err, data) ->
      expect(err).to.be.an 'error'
      done()

  it 'should produce same results in sync and async APIs for CSV', (done) ->
    processFile ROW_CSV, ROW_JSON, false, (err, dataAsync) ->
      expect(err).to.be.an 'undefined'
      jsonAsync = fs.readFileSync ROW_JSON, "utf-8"
      dataSync = processFileSync ROW_CSV, ROW_JSON, false
      jsonSync = fs.readFileSync ROW_JSON, "utf-8"
      expect(dataAsync).to.eql(dataSync)
      expect(jsonAsync).to.equal(jsonSync)
      done()

  it 'should throw an error when attempting xlsx sync API', () ->
    expect(() ->
      processFileSync ROW_XLSX, ROW_JSON, false
    ).to.throw(Error, /Cannot read XLSX via sync API/)




