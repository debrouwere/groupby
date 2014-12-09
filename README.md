# groupby

[![Build Status](https://travis-ci.org/debrouwere/groupby.svg)](https://travis-ci.org/debrouwere/groupby)

Split up JSON data into multiple files based on shared characteristics. Groupby is a command-line utility but can also be used from [node.js](http://nodejs.org/).

```shell
groupby staff.json 'staff/{department}.json'
```

In the example above, the resulting output will one file for each department, 
each file containing an array of staff member objects for that department.

## Installation

```shell
npm install groupby-cli -g
```

## Usage

Groupby expects an input JSON file that contains an array of similarly-structured
objects, and will group those objects when they have matching values for whatever 
keys you specify as placeholders in the output pattern.

For example, `staff/{department}.json` will group objects together into 
the same file if their `department` key matches.

Grouping on multiple keys is supported too: 

```shell
groupby staff.json 'staff/{department}/{country}/{role}.json'
```

The only requirement for groups is that values can be turned into a string 
(and thus into a filename to which we can write the resulting JSON.) Values
will be [slugified](https://github.com/dodo/node-slug) for use in filenames
but will be left as-is in the JSON.

In some cases, your output pattern uniquely identifies each 
individual object, e.g. 

```shell
groupby staff.json 'staff/{username}.json'
```

To save just the objects without wrapping each of them in an array, use the 
`--unique` flag. In `--unique` mode, Groupby will throw an error if your 
output pattern does unexpectedly lead to groups that contain more than one item.

## Use from node.js

```javascript
// basic usage
var groupby = require('groupby-cli');
var groups = groupby.group(list, facets);

// usage that is more advanced, and more 
// similar to the command-line
var keyPattern = 'staff/{departments}';
var staffByDepartment = groupby.group(staff, keyPattern);
var sales = staffByDepartment['staff/sales'];
```

`groupby.group` takes an options object as a third argument: 

* **underscore** to underscore the slugified keys
    * `false` by default
    * when using the command-line interface, this is always set to `true`
* **catch**
    * `false` (default) to throw an error when encountering an uncategorizable object (this happens when not all objects contain a value for the specified facets)
    * `true`: don't throw such errors and just get rid of any uncategorizable objects
    * `"destination"`: create a group with all uncategorizable objects at the specified key

## License

Groupby comes with a permissive [ISC license](http://en.wikipedia.org/wiki/ISC_license).

The `countries.json` dataset included among the examples comes with an 
[Open Database License](http://opendatacommons.org/licenses/odbl/1.0/).
For the latest version, see @mledoze's [countries repository](https://github.com/mledoze/countries)
on GitHub.
