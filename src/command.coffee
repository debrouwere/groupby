_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
fs.mkdirp = require 'mkdirp'
program = require 'commander'
groupby = require './'

program
    .usage '<source> <destination> [options]'
    .option '-u, --unique', 
        'The output pattern uniquely identifies each object.'
    .option '-I --indent [n]', 
        'Indent the JSON output.', parseInt, 2
    .option '-f --force', 
        'Save grouped output even if up to date.'
    .option '-c --catch [file]', 
        'Soak up objects that do not belong anywhere, or redirect them to a file.'
    .option '-d --dry-run', 
        'Print the output paths but do not write any data.'
    .option '-v --verbose', 
        'Print the path to each file that is written.'
    .option '-i --index',
        'Print an index to each group: its range of values.'
    .parse process.argv

destinationPattern = fs.path.resolve program.args[1]
source = fs.path.resolve program.args[0]
rawData = fs.readFileSync source, encoding: 'utf8'
data = JSON.parse rawData

serialize = _.partial JSON.stringify, _, undefined, program.indent

if program.index
    facets = _.pluck output.placeholders, 'name'
    index = groupby.enumerate data, facets
    console.log serialize index

if typeof program.catch is 'string'
    program.catch = fs.path.resolve program.catch

options = 
    lowercase: yes
    catch: program.catch
    unique: program.unique

groups = groupby.group data, destinationPattern, options

sourceChanged = (fs.statSync source).mtime.getTime()
isStale = (path) ->
    try
        destinationChanged = (fs.statSync path).mtime.getTime()
        sourceChanged > destinationChanged
    catch
        yes

for path, members of groups
    if program.dryRun or program.verbose
        console.log path
    
    unless program.dryRun
        unless program.force or isStale path
            continue
        dir = fs.path.dirname path
        fs.mkdirp.sync dir
        fs.writeFileSync path, (serialize members), encoding: 'utf8'
