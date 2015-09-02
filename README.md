[![tag:?](https://img.shields.io/github/tag/stevetarver/excel-as-json.svg)](https://github.com/stevetarver/excel-as-json/releases)
[![license:mit](https://img.shields.io/badge/license-mit-green.svg)](#license)
[![build:?](https://img.shields.io/travis/stevetarver/excel-as-json/master.svg)](https://travis-ci.org/stevetarver/excel-as-json)
[![coverage:?](https://img.shields.io/coveralls/stevetarver/excel-as-json/master.svg?style=flat-square)](https://coveralls.io/r/stevetarver/excel-as-json)
[![codecov.io](http://codecov.io/github/stevetarver/excel-as-json/coverage.svg?branch=master)](http://codecov.io/github/stevetarver/excel-as-json?branch=master)
<br>
[![npm:](https://img.shields.io/npm/v/excel-as-json.svg)](https://www.npmjs.com/package/excel-as-json)
[![dependencies:?](https://img.shields.io/david/stevetarver/excel-as-json.svg)](https://david-dm.org/stevetarver/excel-as-json.svg)
[![devDependency Status](https://david-dm.org/stevetarver/excel-as-json/dev-status.svg)](https://david-dm.org/stevetarver/excel-as-json#info=devDependencies)


# Convert Excel Files to JSON

## Install

Expected use is offline translation of Excel data to JSON files, although
async facilities are provided.

```$ npm install excel-as-json --save-dev```

## Use

```js
convertExcel = require('excel-as-json').processFile;
convertExcel(<src>, <dst>, isColOriented, callback);
```

* src: path to source Excel file (xlsx only) - will read sheet 0
* dst: path to destination JSON file. If null, simply return the parsed object tree
* isColOriented: is an Excel row an object, or is a column an object (Default: false)
* callback(err, data): callback for completion notification

With these arguments, you can:

* convertExcel(src, dst)
  will write a row oriented xlsx to file with no notification
* convertExcel(src, dst, true)
  will write a col oriented xlsx to file with no notification
* convertExcel(src, dst, true, callback)
  will write a col oriented xlsx to file and notify with errors and data
* convertExcel(src, null, true, callback)
  will return errors and the parsed object tree in the callback

Convert a row/col oriented Excel file to JSON as a development task and
log errors:

```CoffeeScript
convertExcel = require('excel-as-json').processFile

convertExcel 'row.xlsx', 'row.json', false, (err, data) ->
	if err then console.log "JSON conversion failure: #{err}"
convertExcel 'col.xlsx', 'col.json', true, (err, data) ->
	if err then console.log "JSON conversion failure: #{err}"
```
Convert Excel file to an object tree and use that tree. Note that 
properly formatted data will convert to the same object tree whether
row or column oriented.

```CoffeeScript
convertExcel = require('excel-as-json').processFile

convertExcel 'row.xlsx', undefined, false, (err, data) ->
	if err throw err
	doSomethingInteresting data
convertExcel 'col.xlsx', undefined, true, (err, data) ->
	if err throw err
	doSomethingInteresting data
```

### Why?

* Your application serves static data obtained as Excel reports from
  another application
* Whoever manages your static data finds Excel more pleasant than editing JSON
* Your data is the result of calculations or formatting that is
  more simply done in Excel
  
### What's the challenge?

Excel stores tabular data. Converting that to JSON using only
a couple of assumptions is straight-forward. Most interesting
JSON contains nested lists and objects. How do you map a
flat data square that is easy for anyone to edit into these 
nested lists and objects?

### Solving the challenge

- Use a key row to name JSON keys
- Allow data to be stored in row or column orientation.
- Use javascript notation for keys and arrays
  - Allow dotted key path notation
  - Allow arrays of objects and literals

### Excel Data

What is the easiest way to organize and edit your Excel data? Lists of 
simple objects seem a natural fit for a row oriented sheets. Single objects
with more complex structure seem more naturally presented as column
oriented sheets. Doesn't really matter which orientation you use, the
module allows you to speciy a row or column orientation; basically, where
your keys are located: row 0 or column 0.

Keys and values:

* Row or column 0 contains JSON key paths
* Remaining rows/columns contain values for those keys
* Multiple value rows/columns represent multiple objects stored as a list
* Within an object, lists of objects have keys like phones[1].type 
* Within an object, flat lists have keys like aliases[]

### Examples

A simple, row oriented key

|firstName
|---------
| Jihad	

produces

```
[{
  "firstName": "Jihad"
}]
```

A dotted key name looks like

| address.street
|---
| 12 Beaver Court

and produces

```
[{
  "address": {
    "street": "12 Beaver Court"
    }
}]
```

An indexed array key name looks like

|phones[0].number 
|---
|123.456.7890

and produces 

```
[{
  "phones": [{
      "number": "123.456.7890"
    }]
}]
```

An embedded array key name looks like this and has ';' delimited values

| aliases[]
|---
| stormagedden;bob

and produces

```
[{
  "aliases": [
    "stormagedden",
    "bob"
  ]
}]
```

A more complete row oriented example

|firstName| lastName | address.street  | address.city|address.state|address.zip |
|---------|----------|-----------------|-------------|-------------|------------|
| Jihad	| Saladin  | 12 Beaver Court | Snowmass    | CO          | 81615      |
| Marcus  | Rivapoli | 16 Vail Rd      | Vail        | CO          | 81657      |

would produce

```JSON
[{
    "firstName": "Jihad",
    "lastName": "Saladin",
    "address": {
      "street": "12 Beaver Court",
      "city": "Snowmass",
      "state": "CO",
      "zip": "81615"
    }
  },
  {
    "firstName": "Marcus",
    "lastName": "Rivapoli",
    "address": {
      "street": "16 Vail Rd",
      "city": "Vail",
      "state": "CO",
      "zip": "81657"
    }
  }]
```

You can do something similar in column oriented sheets. Note that indexed 
and flat arrays are added.

|firstName | Jihad | Marcus |
| :--- | :--- | :--- |
|**lastName** | Saladin | Rivapoli |
|**address.street** |12 Beaver Court | 16 Vail Rd
|**address.city** | Snowmass | Vail
|**address.state** | CO | CO
|**address.zip**| 81615 | 81657
|**phones[0].type**| home | home
|**phones[0].number** |123.456.7890 | 123.456.7891
|**phones[1].type**| work | work
|**phones[1].number** | 098.765.4321 | 098.765.4322
|**aliases[]** | stormagedden;bob | mac;markie

would produce

```
[
  {
    "firstName": "Jihad",
    "lastName": "Saladin",
    "address": {
      "street": "12 Beaver Court",
      "city": "Snowmass",
      "state": "CO",
      "zip": "81615"
    },
    "phones": [
      {
        "type": "home",
        "number": "123.456.7890"
      },
      {
        "type": "work",
        "number": "098.765.4321"
      }
    ],
    "aliases": [
      "stormagedden",
      "bob"
    ]
  },
  {
    "firstName": "Marcus",
    "lastName": "Rivapoli",
    "address": {
      "street": "16 Vail Rd",
      "city": "Vail",
      "state": "CO",
      "zip": "81657"
    },
    "phones": [
      {
        "type": "home",
        "number": "123.456.7891"
      },
      {
        "type": "work",
        "number": "098.765.4322"
      }
    ],
    "aliases": [
      "mac",
      "markie"
    ]
  }
]
```
## Data Conversions

All values from the 'excel' package are returned as text. This module detects numbers and booleans and converts them to javascript types. Booleans must be text 'true' or 'false'. Excel FALSE and TRUE are provided 
from 'excel' as 0 and 1 - just too confusing.

## Caveats

During install (mac), you may see compiler warnings while installing the
excel dependency - although questionable, they appear to be benign.


## TODO

- provide processSync - using 'async' module
- Detect and convert dates
- Make 1 column values a single object?


## Change History

### 1.0.0
- Changed process() to processFile() to avoid name collision with node's process object
- Automatically convert text numbers and booleans to native values
- Create destination directory if it does not exist