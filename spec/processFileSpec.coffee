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
COL_JSON_NESTED = 'build/newDir/col-oriented.json'

ROW_SHEET_1_JSON = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615}},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657}}]'
ROW_SHEET_2_JSON = '[{"firstName":"Max","lastName":"Irwin","address":{"street":"123 Fake Street","city":"Rochester","state":"NY","zip":99999}}]'
COL_SHEET_1_JSON = '[{"firstName":"Jihad","lastName":"Saladin","address":{"street":"12 Beaver Court","city":"Snowmass","state":"CO","zip":81615},"isEmployee":true,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"098.765.4321"}],"aliases":["stormagedden","bob"]},{"firstName":"Marcus","lastName":"Rivapoli","address":{"street":"16 Vail Rd","city":"Vail","state":"CO","zip":81657},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7891"},{"type":"work","number":"098.765.4322"}],"aliases":["mac","markie"]}]'
COL_SHEET_2_JSON = '[{"firstName":"Max","lastName":"Irwin","address":{"street":"123 Fake Street","city":"Rochester","state":"NY","zip":99999},"isEmployee":false,"phones":[{"type":"home","number":"123.456.7890"},{"type":"work","number":"505-505-1010"}],"aliases":["binarymax","arch"]}]'

TEST_OPTIONS =
  sheet: '1'
  isColOriented: false
  omitEmptyFields: false


describe 'process file', ->

  it 'should notify on file does not exist', (done) ->
    processFile 'data/doesNotExist.xlsx', null, TEST_OPTIONS, (err, data) ->
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
    processFile 'data/row-oriented.csv', null, TEST_OPTIONS, (err, data) ->
      err.should.be.a 'string'
      expect(data).to.be.an 'undefined'
      done()


  # NOTE: current excel package impl simply times out if sheet index is OOR
#  it 'should show error on invalid sheet id', (done) ->
#    options =
#      sheet: '20'
#      isColOriented: false
#      omitEmptyFields: false
#
#    processFile ROW_XLSX, null, options, (err, data) ->
#      err.should.be.a 'string'
#      expect(data).to.be.an 'undefined'
#      done()


  it 'should use defaults when caller specifies no options', (done) ->
    processFile ROW_XLSX, null, null, (err, data) ->
      expect(err).to.be.an 'undefined'
      JSON.stringify(data).should.equal ROW_SHEET_1_JSON
      done()


  it 'should process row oriented Excel files, write the result, and return the parsed object', (done) ->
    options =
      sheet:'1'
      isColOriented: false
      omitEmptyFields: false

    processFile ROW_XLSX, ROW_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      JSON.stringify(result).should.equal ROW_SHEET_1_JSON
      JSON.stringify(data).should.equal ROW_SHEET_1_JSON
      done()


  it 'should process sheet 2 of row oriented Excel files, write the result, and return the parsed object', (done) ->
    options =
      sheet:'2'
      isColOriented: false
      omitEmptyFields: false

    processFile ROW_XLSX, ROW_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(ROW_JSON, 'utf8'))
      JSON.stringify(result).should.equal ROW_SHEET_2_JSON
      JSON.stringify(data).should.equal ROW_SHEET_2_JSON
      done()


  it 'should process col oriented Excel files, write the result, and return the parsed object', (done) ->
    options =
      sheet:'1'
      isColOriented: true
      omitEmptyFields: false

    processFile COL_XLSX, COL_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      JSON.stringify(result).should.equal COL_SHEET_1_JSON
      JSON.stringify(data).should.equal COL_SHEET_1_JSON
      done()


  it 'should process sheet 2 of col oriented Excel files, write the result, and return the parsed object', (done) ->
    options =
      sheet:'2'
      isColOriented: true
      omitEmptyFields: false

    processFile COL_XLSX, COL_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      result = JSON.parse(fs.readFileSync(COL_JSON, 'utf8'))
      JSON.stringify(result).should.equal COL_SHEET_2_JSON
      JSON.stringify(data).should.equal COL_SHEET_2_JSON
      done()


  it 'should create the destination directory if it does not exist', (done) ->
    options =
      sheet:'1'
      isColOriented: true
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
      sheet:'1'
      isColOriented: false
      omitEmptyFields: false

    processFile ROW_XLSX, undefined, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      fs.existsSync(ROW_JSON).should.equal false
      JSON.stringify(data).should.equal ROW_SHEET_1_JSON
      done()


  it 'should not convert text that looks like a number to a number when directed', (done) ->
    options =
      sheet:'1'
      isColOriented: false
      omitEmptyFields: false
      convertTextToNumber: false

    processFile ROW_XLSX, undefined, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      data[0].address.should.have.property('zip', '81615')
      data[1].address.should.have.property('zip', '81657')
      done()


  it 'should notify on write error', (done) ->
    processFile ROW_XLSX, 'build', TEST_OPTIONS, (err, data) ->
      expect(err).to.be.an 'string'
      done()


#=============================== Coverage summary ===============================
#  Statements   : 100% ( 133/133 )
#  Branches     : 100% ( 61/61 )
#  Functions    : 100% ( 14/14 )
#  Lines        : 100% ( 106/106 )
#================================================================================
