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

RGR28_SHEET = 2
RGR28_IS_COL_ORIENTED = false
RGR28_OUT_JSON = 'build/rgr28.json'

describe 'regression 23', ->

  it 'should produce empty arrays for flat arrays without values', (done) ->
    options =
      sheet: RGR23_SHEET
      isColOriented: RGR23_IS_COL_ORIENTED
      omitEmptyFields: false

    processFile RGR_SRC_XLSX, RGR23_OUT_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      expect(data[0]).to.have.property('emptyArray').with.lengthOf(0)
      done()

  it 'should remove flat arrays when omitEmptyFields and value list is blank', (done) ->
    options =
      sheet: RGR23_SHEET
      isColOriented: RGR23_IS_COL_ORIENTED
      omitEmptyFields: true

    processFile RGR_SRC_XLSX, RGR23_OUT_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      expect(data[0].emptyArray).to.be.an 'undefined'
      done()


describe 'regression 28', ->

  it 'should produce an empty array when no value rows are provided', (done) ->
    options =
      sheet: RGR28_SHEET
      isColOriented: RGR28_IS_COL_ORIENTED
      omitEmptyFields: false

    processFile RGR_SRC_XLSX, RGR28_OUT_JSON, options, (err, data) ->
      expect(err).to.be.an 'undefined'
      expect(data).to.be.an('array').with.lengthOf(0)
      done()

