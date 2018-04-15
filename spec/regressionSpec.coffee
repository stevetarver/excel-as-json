processFile = require('../src/excel-as-json').processFile
fs = require 'fs'

# TODO: How to get chai defined in a more global way
chai = require 'chai'
chai.should()
expect = chai.expect;

# Test constants
RGR_SRC_XLSX = 'data/regression.xlsx'

RGR23_SHEET = 1
RGR23_IS_COL_ORIENTED = true
RGR23_OUT_JSON = 'build/rgr23.json'


describe 'regression 23', ->

  it 'flat arrays should be empty when value list is blank', (done) ->
    options =
      sheet: RGR23_SHEET
      isColOriented: RGR23_IS_COL_ORIENTED
      omitEmptyFields: false

    processFile RGR_SRC_XLSX, RGR23_OUT_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      expect(data[0]).to.have.property('emptyArray').with.lengthOf(0)
      done()

  it 'flat arrays should be removed when omitEmptyFields and value list is blank', (done) ->
    options =
      sheet: RGR23_SHEET
      isColOriented: RGR23_IS_COL_ORIENTED
      omitEmptyFields: true

    processFile RGR_SRC_XLSX, RGR23_OUT_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      expect(data[0].emptyArray).to.be.an 'undefined'
      done()


