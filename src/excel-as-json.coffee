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
fs = require 'fs-extra'
path = require 'path'
async = require 'async'
math = require 'mathjs'
_ = require 'lodash'
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
convertValueList = (list) ->
  (convertValue(item) for item in list)


# Convert values to native types
# Note: all values from the excel module are text
convertValue = (value) ->
  # isFinite returns true for empty or blank strings, check for those first
  if value.length == 0 || !/\S/.test(value)
    value
  else if isFinite(value)
    Number(value)
  else
    testVal = value.toLowerCase()
    if testVal in BOOLTEXT
      BOOLVALS[testVal]
    else
      value


# Assign a value to a dotted property key - set values on sub-objects
assign = (obj, key, value, options) ->
  options = options || {}
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
      if !(options.omitEmptyFields && value == '')
        obj[keyName] = convertValueList(value.split ';')
    else
      if !(options.omitEmptyFields && value == '')
        obj[keyName] = convertValue value


# Convert 2D array to nested objects. If row oriented data, row 0 is dotted key names.
# Column oriented data is transposed
convert = (data, options) ->
  options = options || {}
  matrix = math.matrix data
  if options.skipRows or options.skipColumns
    size = matrix.size()
    sizeRows = size[0]
    sizeColumns = size[1]
    rangeRows = math.range(options.skipRows or 0, sizeRows)
    rangeColumns = math.range(options.skipColumns or 0, sizeColumns)
    matrix = matrix.subset math.index rangeRows, rangeColumns
  matrix = math.transpose matrix if options.isColumnsOriented
  data = matrix._data
  
  keys = data[0]
  rows = data[1..]
  
  result = []
  for row in rows
    item = {}
    assign(item, keys[index], value, options) for value, index in row
    result.push item
  return result
  
# Generate one file per column
# @param {Object|Array} result The data read from excel sheet 
# @options options {Object}
# @params {String} filenameFromField name of field that identify the name of file
generateOneFilePerColumn = (result, options) ->
  for data, i in result
    filenameFromField = options.filenameFromField if options.filenameFromField
    filename = data[filenameFromField] + '.json'
    delete data[filenameFromField]
    sheetOptions = _.clone(options)
    sheetOptions.name = filename
    {data: data, options: sheetOptions}

    



# Write array as JSON data to file
write = (data, dst, options, callback) ->
  if typeof options is 'function'
    callback = options
    options = {}

  extName = path.extname(dst)
  # Verify if destination contain a full path
  if extName is '.json'
    # Create the target directory if it does not exist
    dir = path.dirname(dst)
  else if options.name
    subfolder = options.subfolder or '/'
    dst = dst + subfolder + options.name
  else
    return callback "Error destination without name of file #{dst}"
    
  dir = path.dirname(dst)
  fs.mkdirsSync dir
  fs.writeFile dst, JSON.stringify(data, null, 2), (err) ->
    if err then callback "Error writing file #{dst}: #{err}"
    else callback()


# @param {String} src xlsx file that we will read sheet 0 of
# @param {String} dst file path to write json to. If null, simply return the result
# @options options {Object}
# @params {Number | Array[Object]} sheets The number or array of object that specify sheet/s to read
# @params {Boolean} isColumnsOriented are objects stored in excel rows or columns
# @params {String} omitEmptyFields: do not include keys with empty values in json output. empty values are stored as ''
# @params {Number} skipRows number of rows to skip
# @params {Number} skipColumns number of columns to skip
# @callback {Function} callback The callback function
# @param {Error} err
#
# process(src, dst)
#   will write a row oriented xlsx to file with no notification
# process(src, dst, options)
#   will write a with options xlsx to file with no notification
# process(src, null, options, callback)
#   will return the parsed object tree in the callback
#
processFile = (src, dst, options, callback) ->
  if typeof options is 'function' and typeof callback is 'undefined'
    callback = options
    options = {}
  # provide a callback if the user did not
  if !callback then callback = () ->
  # NOTE: 'excel' does not properly bubble file not found and prints
  #       an ugly error we can't trap, so look for this common error first
  if not fs.existsSync src
    callback "Cannot find src file #{src}"
  else
    results = []
    options = options || {}
    sheets = options.sheets
    delete options.sheets
    if sheets
      if typeof sheets is 'number' or typeof sheets is 'string'
        sheets = [].concat({index: sheets})
    else
      # Default sheet is one
      sheets = [].concat({index: 1})

    async.eachSeries sheets, (sheet, cb) ->
      excel src, sheet.index, (err, data) ->
        if err
          cb "Error reading file #{src}: #{err}"
        else
          globalOptions = _.clone options
          sheetOptions = _.merge globalOptions, sheet
          result = convert data, sheetOptions
          if dst
            if sheetOptions.oneFilePerColumn
              result = generateOneFilePerColumn(result, sheetOptions)
              async.eachSeries result, (r, cbMultipleFiles) =>
                write r.data, dst, r.options, (err) ->
                  if err then return cbMultipleFiles err
                  results.push(r.data)
                  cbMultipleFiles()
              , cb
            else
              write result, dst, sheetOptions, (err) ->
                if err then return cb err
                results.push(result)
                cb()
          else
            results.push(result)
            cb()
    , (err) ->
      if (err) then return callback err
      if (results.length is 1) then return callback undefined, results[0]
      callback undefined, results


# Exposing nearly everything for testing
exports.assign = assign
exports.convert = convert
exports.convertValue = convertValue
exports.parseKeyName = parseKeyName
exports.processFile = processFile
