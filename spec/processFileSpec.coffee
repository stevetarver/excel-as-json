processFile = require('../src/excel-as-json').processFile
fs = require 'fs'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

ROW_XLSX = 'data/row-oriented.xlsx'
ROW_JSON = 'build/row-oriented.json'
COL_XLSX = 'data/col-oriented.xlsx'
COL_JSON = 'build/col-oriented.json'

describe 'process file', ->

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


  it 'should notify on write error', (done) ->
    processFile ROW_XLSX, 'build', false, (err, data) ->
      expect(err).to.be.an 'string'
      done()




