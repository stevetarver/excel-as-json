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
fs = require "fs"
excel = require 'excel'


isObject = (obj) ->
  Object.prototype.toString.call(obj) is '[object Object]'

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
    obj[keyName] = if (keyIsList and not index?) then value.split ';' else value
    return obj


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
    assign item, keys[index], value for value, index in row
    result.push item
  return result


# Write array as JSON data to file
write = (data, dst) ->
  fs.writeFile dst, JSON.stringify(data, null, 2), (err) ->
    if err then console.error("Error writing file #{dst}", err)
    else console.log "Updated #{dst}"


# The excel module reads sheet 0 from specified xlsx file
process = (src, dst, isColOriented = false) ->
  # NOTE: 'excel' does not properly bubble file not found and prints
  #       an ugly error we can't trap, so look for this common error first
  if not fs.existsSync src
    console.error "Cannot find src file #{src}"
  else
    excel src, (err, data) ->
      if err then console.error "Error reading #{src}", err
      else write convert(data, isColOriented), dst

# Exposing nearly everything for testing
exports.assign = assign
exports.convert = convert
exports.parseKeyName = parseKeyName
exports.process = process
exports.transpose = transpose
