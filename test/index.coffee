_ = require 'underscore'
fs = require 'fs'
{exec} = require 'child_process'
should = require 'should'
groupby = require '../src'

getData = (path) ->
    JSON.parse fs.readFileSync path, encoding: 'utf8'

countries = getData 'examples/countries.json'

describe 'programmatic interface', ->
    it 'can generate an index that enumerates all possible values for selected facets', ->
        index = groupby.enumerate countries, ['region'], catch: yes
        index.should.have.key 'region'
        index.region.should.containEql \
            "Asia": "Asia"
            "Europe": "Europe"
            "Africa": "Africa"
            "Oceania": "Oceania"
            "Americas": "Americas"

    it 'can group on a list of facets', ->
        groups = groupby.group countries, ['region'], catch: yes
        groups.should.have.keys [
            'Asia'
            'Europe'
            'Africa'
            'Oceania'
            'Americas'
            ]

    it 'can group on a grouper function', ->
        groups = 
            underscore: _.groupBy countries, (country) -> country.region
            groupby: groupby.group countries, ['region'], catch: yes

        delete groups.underscore['']
        groups.underscore.should.eql groups.groupby

    it 'can group on a pattern string', ->
        groups = groupby.group countries, 'regions/{region}', catch: yes
        groups.should.have.keys [
            'regions/Asia'
            'regions/Europe'
            'regions/Africa'
            'regions/Oceania'
            'regions/Americas'
            ]        

    it 'will throw an error when not every object can be categorized', ->
        groupWithMissingFacets = ->
            groups = groupby.group countries, ['region']
        groupWithMissingFacets.should.throw()

    it 'can lowercase the slugified key values', ->
        groups = groupby.group countries, ['region'], 
            catch: yes
            lowercase: yes
        groups.should.have.keys [
            'asia'
            'europe'
            'africa'
            'oceania'
            'americas'
            ]

    it 'can catch uncategorizable objects and put them in a group of their own', ->
        groups = groupby.group countries, ['region'], catch: 'other'
        groups.should.have.keys [
            'Asia'
            'Europe'
            'Africa'
            'Oceania'
            'Americas'
            'other'
            ]

describe 'command-line interface', ->
    it 'has a command-line interface', (done) ->
        command = "./bin/groupby examples/countries.json 'examples/regions/{region}.json' \
            --catch examples/regions/other.json \
            --indent
        "

        exec command, (err, stdout, stderr) ->
            (fs.existsSync 'examples/regions/oceania.json').should.be.ok
            (fs.existsSync 'examples/regions/other.json').should.be.ok
            done err
