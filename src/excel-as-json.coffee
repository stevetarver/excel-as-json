# Create a list of json objects; 1 object per excel sheet row
#
# Assume: Excel spreadsheet is a rectangle of data, where the first row is
# object keys and remaining rows are object values and the desired json 
# is a list of objects. Alternatively, data may be column oriented with
# col 0 containing key names.
#
# Dotted notation: Key row (0) containing firstName, lastName, address.street, 
# address.city, address.state, address.zip would produce, per row, a doc with 
# first and last names and an embedded doc named address, with the address.
#
# Arrays: may be indexed (phones[0].number) or flat (aliases[]). Indexed
# arrays imply a list of objects. Flat arrays imply a semicolon delimited list.
#
# USE:
#  From a shell
#    coffee src/excel-as-json.coffee
#
fs = require 'fs'
path = require 'path'
excel = require 'excel'

BOOLTEXT = ['true', 'false']
BOOLVALS = {'true': true, 'false': false}

isArray = (obj) ->
  Object.prototype.toString.call(obj) is '[object Array]'


# Extract key name and array index from names[1] or names[]
# return [keyIsList, keyName, index]
# for names[1] return [true,  keyName,  index]
# for names[]  return [true,  keyName,  undefined]
# for names    return [false, keyName,  undefined]
parseKeyName = (key) ->
  index = key.match(/\[(\d+)\]$/)
  switch
    when index             then [true, key.split('[')[0], Number(index[1])]
    when key[-2..] is '[]' then [true, key[...-2], undefined]
    else                        [false, key, undefined]


# Convert a list of values to a list of more native forms
convertValueList = (list, options) ->
  (convertValue(item, options) for item in list)


# Convert values to native types
# Note: all values from the excel module are text
convertValue = (value, options) ->
  # isFinite returns true for empty or blank strings, check for those first
  if value.length == 0 || !/\S/.test(value)
    value
  else if isFinite(value)
    if options.convertTextToNumber
      Number(value)
    else
      value
  else
    testVal = value.toLowerCase()
    if testVal in BOOLTEXT
      BOOLVALS[testVal]
    else
      value


# Assign a value to a dotted property key - set values on sub-objects
assign = (obj, key, value, options) ->
  # On first call, a key is a string. Recursed calls, a key is an array
  key = key.split '.' unless typeof key is 'object'
  # Array element accessors look like phones[0].type or aliases[]
  [keyIsList, keyName, index] = parseKeyName key.shift()

  if key.length
    if keyIsList
      # if our object is already an array, ensure an object exists for this index
      if isArray obj[keyName]
        unless obj[keyName][index]
          obj[keyName].push({}) for i in [obj[keyName].length..index]
      # else set this value to an array large enough to contain this index
      else
        obj[keyName] = ({} for i in [0..index])
      assign obj[keyName][index], key, value, options
    else
      obj[keyName] ?= {}
      assign obj[keyName], key, value, options
  else
    if keyIsList and index?
      console.error "WARNING: Unexpected key path terminal containing an indexed list for <#{keyName}>"
      console.error "WARNING: Indexed arrays indicate a list of objects and should not be the last element in a key path"
      console.error "WARNING: The last element of a key path should be a key name or flat array. E.g. alias, aliases[]"
    if (keyIsList and not index?)
      if value != ''
        obj[keyName] = convertValueList(value.split(';'), options)
      else if !options.omitEmptyFields
        obj[keyName] = []
    else
      if !(options.omitEmptyFields && value == '')
        obj[keyName] = convertValue(value, options)


# Transpose a 2D array
transpose = (matrix) ->
  (t[i] for t in matrix) for i in [0...matrix[0].length]


# Convert 2D array to nested objects. If row oriented data, row 0 is dotted key names.
# Column oriented data is transposed
convert = (data, options) ->
  data = transpose data if options.isColOriented

  keys = data[0]
  rows = data[1..]

  result = []
  for row in rows
    item = {}
    assign(item, keys[index], value, options) for value, index in row
    result.push item
  return result


# Write JSON encoded data to file
# call back is callback(err)
write = (data, dst, callback) ->
  # Create the target directory if it does not exist
  dir = path.dirname(dst)
  fs.mkdirSync dir if !fs.existsSync(dir)
  fs.writeFile dst, JSON.stringify(data, null, 2), (err) ->
    if err then callback "Error writing file #{dst}: #{err}"
    else callback undefined


# src: xlsx file that we will read sheet 0 of
# dst: file path to write json to. If null, simply return the result
# options: see below
# callback(err, data): callback for completion notification
#
# options:
#   sheet:              string;  1:     numeric, 1-based index of target sheet
#   isColOriented:      boolean: false; are objects stored in excel columns; key names in col A
#   omitEmptyFields:    boolean: false: do not include keys with empty values in json output. empty values are stored as ''
#                                       TODO: this is probably better named omitKeysWithEmptyValues
#   convertTextToNumber boolean: true;  if text looks like a number, convert it to a number
#
# convertExcel(src, dst) <br/>
#   will write a row oriented xlsx sheet 1 to `dst` as JSON with no notification
# convertExcel(src, dst, {isColOriented: true}) <br/>
#   will write a col oriented xlsx sheet 1 to file with no notification
# convertExcel(src, dst, {isColOriented: true}, callback) <br/>
#   will write a col oriented xlsx to file and notify with errors and parsed data
# convertExcel(src, null, null, callback) <br/>
#   will parse a row oriented xslx using default options and return errors and the parsed data in the callback
#
_DEFAULT_OPTIONS =
  sheet: '1'
  isColOriented: false
  omitEmptyFields: false
  convertTextToNumber: true

# Ensure options sane, provide defaults as appropriate
_validateOptions = (options) ->
  if !options
    options = _DEFAULT_OPTIONS
  else
    if !options.hasOwnProperty('sheet')
      options.sheet = '1'
    else
      # ensure sheet is a text representation of a number
      if !isNaN(parseFloat(options.sheet)) && isFinite(options.sheet)
        if options.sheet < 1
          options.sheet = '1'
        else
          # could be 3 or '3'; force to be '3'
          options.sheet = '' + options.sheet
      else
        # something bizarre like true, [Function: isNaN], etc
        options.sheet = '1'
    if !options.hasOwnProperty('isColOriented')
      options.isColOriented = false
    if !options.hasOwnProperty('omitEmptyFields')
      options.omitEmptyFields = false
    if !options.hasOwnProperty('convertTextToNumber')
      options.convertTextToNumber = true
  options


processFile = (src, dst, options=_DEFAULT_OPTIONS, callback=undefined) ->
  options = _validateOptions(options)

  # provide a callback if the user did not
  if !callback then callback = (err, data) ->

  # NOTE: 'excel' does not properly bubble file not found and prints
  #       an ugly error we can't trap, so look for this common error first
  if not fs.existsSync src
    callback "Cannot find src file #{src}"
  else
    excel src, options.sheet, (err, data) ->
      if err
        callback "Error reading #{src}: #{err}"
      else
        result = convert data, options
        if dst
          write result, dst, (err) ->
            if err then callback err
            else callback undefined, result
        else
          callback undefined, result

# This is the single expected module entry point
exports.processFile = processFile

# Unsupported use
# Exposing remaining functionality for unexpected use cases, testing, etc.
exports.assign = assign
exports.convert = convert
exports.convertValue = convertValue
exports.parseKeyName = parseKeyName
exports._validateOptions = _validateOptions
exports.transpose = transpose
