excelAsJson = require '../src/excel-as-json'
fs = require 'fs'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

ROW_XLSX = 'data/row-oriented.xlsx'
ROW_JSON = 'build/row-oriented.json'
COL_XLSX = 'data/col-oriented.xlsx'
COL_JSON = 'build/col-oriented.json'

describe 'process', ->

  it 'should notify on file does not exist', (done) ->
    excelAsJson.process 'data/doesNotExist.xlsx', null, false, (err, data) ->
      err.should.be.a 'string'
      expect(data).to.be.an 'undefined'
      done()


  it 'should not blow up when a file does not exist and no callback is provided', (done) ->
    excelAsJson.process 'data/doesNotExist.xlsx', ->
    done()


  it 'should notify on read error', (done) ->
    excelAsJson.process 'data/row-oriented.csv', null, false, (err, data) ->
      err.should.be.a 'string'
      expect(data).to.be.an 'undefined'
      done()


  it 'should not blow up on read error when no callback is provided', (done) ->
    excelAsJson.process 'data/row-oriented.csv', ->
    done()


  it 'should process row oriented Excel files and return the parsed object', (done) ->
    # ensure the build dir exists
    try fs.mkdirSync 'build'
    catch # ignore dir exists

    excelAsJson.process ROW_XLSX, ROW_JSON, false, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":"81615"}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":"81657"}}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should process col oriented Excel files', (done) ->
    # ensure the build dir exists
    try fs.mkdirSync 'build'
    catch # ignore dir exists

    excelAsJson.process COL_XLSX, COL_JSON, false, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      resultStr = '[{"firstName":"lastName","Jihad":"Saladin","Marcus":"Rivapoli"},{"firstName":"address.street","Jihad":"12 Beaver Court","Marcus":"16 Vail Rd"},{"firstName":"address.city","Jihad":"Snowmass","Marcus":"Vail"},{"firstName":"address.state","Jihad":"CO","Marcus":"CO"},{"firstName":"address.zip","Jihad":"81615","Marcus":"81657"},{"firstName":"phones[0].type","Jihad":"home","Marcus":"home"},{"firstName":"phones[0].number","Jihad":"123.456.7890","Marcus":"123.456.7891"},{"firstName":"phones[1].type","Jihad":"work","Marcus":"work"},{"firstName":"phones[1].number","Jihad":"098.765.4321","Marcus":"098.765.4322"},{"firstName":"aliases[]","Jihad":"stormagedden;bob","Marcus":"mac;markie"}]'
      JSON.stringify(result).should.equal resultStr
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should return a parsed object without writing a file', (done) ->
    # Ensure result file does not exit
    try fs.unlinkSync ROW_JSON
    catch # ignore file does not exist

    excelAsJson.process ROW_XLSX, undefined, false, (err, data) ->
      expect(err).to.be.an 'undefined'
      fs.existsSync(ROW_JSON).should.equal false
      resultStr = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":"81615"}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":"81657"}}]'
      JSON.stringify(data).should.equal resultStr
      done()


  it 'should notify on write error', (done) ->
    # Create a directory and use it as a file to simulate a write error
    # ensure the build dir exists
    try fs.mkdirSync 'build'
    catch # ignore dir exists

    excelAsJson.process ROW_XLSX, 'build', false, (err, data) ->
      expect(err).to.be.an 'string'
      done()


  it 'should not blow up on write error when no callback is provided', (done) ->
    # Create a directory and use it as a file to simulate a write error
    # NOTE: we cannot really test this because we have to wait for the callback
    #       to tell that it did not fail, but we are not providing a callback
    # ensure the build dir exists
    try fs.mkdirSync 'build'
    catch # ignore dir exists

    excelAsJson.process ROW_XLSX, 'build', false, ->
    done()




