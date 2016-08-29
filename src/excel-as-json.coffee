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
#    coffee src/ExcelToJson.coffee
#
csv = require 'csv-parse'
csvSync = require 'csv-parse/lib/sync'
excel = require 'excel'
fs = require 'fs'
mime = require 'mime'
path = require 'path'

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
# Assume: all values from the excel module are text
convertValue = (value) ->
  if isFinite(value)
    Number(value)
  else
    testVal = value.toLowerCase()
    if testVal in BOOLTEXT
      BOOLVALS[testVal]
    else
      value


# Assign a value to a dotted property key - set values on sub-objects
assign = (obj, key, value) ->
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
      assign obj[keyName][index], key, value
    else
      obj[keyName] ?= {}
      assign obj[keyName], key, value
  else
    if keyIsList and index?
      console.error "WARNING: Unexpected key path terminal containing an indexed list for <#{keyName}>"
      console.error "WARNING: Indexed arrays indicate a list of objects and should not be the last element in a key path"
      console.error "WARNING: The last element of a key path should be a key name or flat array. E.g. alias, aliases[]"
    if (keyIsList and not index?)
      obj[keyName] = convertValueList(value.split ';')
    else
      obj[keyName] = convertValue value


# Transpose a 2D array
transpose = (matrix) ->
  (t[i] for t in matrix) for i in [0...matrix[0].length]


# Convert 2D array to nested objects. If row oriented data, row 0 is dotted key names.
# Column oriented data is transposed
convert = (data, isColOriented = false) ->
  data = transpose data if isColOriented

  keys = data[0]
  rows = data[1..]

  result = []
  for row in rows
    item = {}
    assign(item, keys[index], value) for value, index in row
    result.push item
  return result


# Write array as JSON data to file
# call back is callback(err)
write = (data, dst, callback) ->
  # Create the target directory if it does not exist
  dir = path.dirname(dst)
  fs.stat dir, (err) ->
    if err
      # file does not exist or is not accessible
      fs.mkdir dir, (err) ->
        if err
          callback err
        else
          writeCallback data, dst, callback
    else
      process.nextTick ->
        writeCallback data, dst, callback

writeCallback = (data, dst, callback) ->
  fs.writeFile dst, JSON.stringify(data, null, 2), (err) ->
    if err then callback new Error("Error writing file #{dst}: #{err}")
    else callback undefined


# Synchronous version of write
writeSync = (data, dst) ->
  # Create the target directory if it does not exist
  dir = path.dirname(dst)
  try
    fs.statSync dir
  catch
    fs.mkdirSync dir
  fs.writeFileSync dst, JSON.stringify(data, null, 2)


# src: xlsx file that we will read sheet 0 of
# dst: file path to write json to. If null, simply return the result
# isColOriented: are objects stored in excel rows or columns
# callback(err, data): callback for completion notification
#
# process(src, dst)
#   will write a row oriented xlsx to file with no notification
# process(src, dst, true)
#   will write a col oriented xlsx to file with no notification
# process(src, null, true, callback)
#   will return the parsed object tree in the callback
processFile = (src, dst, isColOriented=false, callback=undefined) ->
  # provide a callback if the user did not
  if !callback then callback = (err, data) ->
  # NOTE: 'excel' does not properly bubble file not found and prints
  #       an ugly error we can't trap, so check for file existence first
  fs.stat src, (err) ->
    if err
      # File probably does not exist
      callback new Error("Cannot read src file #{src}: #{err}")
    else
      type = mime.lookup src
      if type is "text/csv"
        fs.createReadStream(src).pipe csv (err, data) ->
          processFileCallback err, data, src, dst, isColOriented, callback
      else
        excel src, (err, data) ->
          processFileCallback err, data, src, dst, isColOriented, callback

processFileCallback = (err, data, src, dst, isColOriented, callback) ->
  if err
    callback new Error("Error reading #{src}: #{err}")
  else
    result = convert data, isColOriented
    if dst
      write result, dst, (err) ->
        if err then callback err
        else callback undefined, result
    else
      process.nextTick ->
        callback undefined, result

processFileSync = (src, dst, isColOriented) ->
  fs.statSync src  # throws an error if file does not exist
  type = mime.lookup src
  data = null
  if type is "text/csv"
    dataStr = fs.readFileSync src, "utf-8"
    data = csvSync dataStr
  else
    # The excel.js module doesn't expose a synchronous API.
    # For now, throw an exception.
    throw new Error("Cannot read XLSX via sync API")
  result = convert data, isColOriented
  if dst
    writeSync result, dst
  return result



# Exposing nearly everything for testing
exports.assign = assign
exports.convert = convert
exports.convertValue = convertValue
exports.parseKeyName = parseKeyName
exports.processFile = processFile
exports.processFileSync = processFileSync
exports.transpose = transpose
