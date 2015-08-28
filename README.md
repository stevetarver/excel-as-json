# Convert Excel Files to JSON

### Why?

* Your application serves static data obtained as Excel reports from
  another application
* Whoever manages your static data finds Excel more pleasant
* Your data is the result of calculations or formatting that is
  more simply done in Excel
  
### What's the challenge?

Excel stores tabular data. Converting that to JSON using only
a couple of assumptions is straight-forward. Most interesting
JSON contains nested lists and objects. How do you map a
flat data square into these nested lists and objects?

### Solving the challenge

- Use a key row to name JSON keys
- Allow data to be stored in row or column orientation.
- Use javascript notation for keys and arrays
  - Allow dotted key notation
  - Allow array subscripts

### Excel Data

What is the easiest way to organize and edit your Excel data? Lists of 
simple objects seem a natural fit for a row oriented sheets. Single objects
with more complex structure seem more naturally presented as column
oriented sheets. Doesn't really matter which orientation you use, the
module allows you to speciy a row or column orientation; basically, where
your key row is located: row 0 or column 0.

Keys and values:

* Row/column 0 contains JSON element key paths
* Remaining rows/columns contain values for those keys
* Multiple value rows/columns represent multiple objects stored as a list
* Within an object, lists of objects have keys like phones[1].type 
* Within an object, flat lists have keys like aliases[]

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

|phones[1].number 
|---
|123.456.7890

and looks like 

```
[{
  "phones": [
    {},
    {
      "number": "123.456.7890"
    }]
}]
```

An embedded array key name looks like this and has ';' delimited values

| aliases[]
|---
| stormagedden;bob

and looks like

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

You can do something similar in column oriented sheets. Note that a indexed 
and flat arrays are added.

|firstName | Jihad | Marcus |
| :--- | --- | --- |
|**lastName** | Saladin | Rivapoli |
|**address.street** |12 Beaver Court | 16 Vail Rd
|**address.city** | Snowmass | Vail
|**address.state** | CO | CO
|**address.zip**| 81615 | 81657
|**phones.[0].type**| home | home
|**phones.[0].number** |123.456.7890 | 123.456.7891
|**phones.[1].type**| work | work
|**phones.[1].number** | 098.765.4321 | 098.765.4322
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

## Use

### Config Object

#### files

* src: relative path to source Excel file
* dest: relative path to destination JSON file
* col-oriented: is sheet column oriented (Default: false)

```CoffeeScript
FILES = [
  {src: 'row-oriented.xlsx', dst: 'row-oriented.json', col-oriented: false}
  {src: 'col-oriented.xlsx', dst: 'col-oriented.json', col-oriented: true}
  ]
```

## TODO

- Make 1 column values a single object?
- Make work on command line
- Make work with grunt
- Detect and convert dates