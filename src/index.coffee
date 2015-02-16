_ = require 'underscore'
slug = require 'slug'
{PathExp, InterpolationError} = require 'simple-path-expressions'


UNCATEGORIZABLE = '__uncategorizable__'


slugify = (value, lowercase=no) ->
    slugified = slug value
    if lowercase
        slugified.toLowerCase()
    else
        slugified

# fill in a pattern string, using slugified 
# values from an object as context
fill = (pattern, obj, options) ->
    slugifiedObj = _.object _.compact _.map obj, (value, key) ->
        if not value?
            undefined
        else if _.contains [Object, Array], value.constructor
            undefined
        else
            [key, (slugify value, options.lowercase)]
    try
        pattern.fill slugifiedObj
    catch err
        if options.catch
            if typeof options.catch is 'string'
                options.catch
            else
                UNCATEGORIZABLE
        else
            throw new Error err.message + 
            " for one or more objects. Consider using --catch."

# Provide all possible values for each facet, 
# a sort of table of contents to our data.
# Returns a `facet => [slug => value]` mapping.
exports.enumerate = (list, facets, options) ->
    _.object _.map facets, (facet) ->
        values = _.pluck list, facet
        keys = _.map values, (value) ->
            slugify value, options.lowercase
        subIndex = _.object keys, values
        [facet, subIndex]


# Group a list of objects by a pattern string, 
# an array or facets or a grouping function.
# 
# When used with a grouping function, this 
# function is equivalent to underscore's
# `_.groupBy`
exports.group = (list, grouper, options={}) ->
    switch grouper.constructor
        when String
            pattern = new PathExp grouper
        when Array
            facetList = grouper
                .map (facet) -> "<#{facet}>"
                .join ', '
            pattern = new PathExp facetList, 'unix'
        when Function
            predicate = grouper
        else
            throw new Error \
            "Grouper should be a pattern string, an array of facets 
            or a grouping function. Instead got: 
            #{grouper.constructor.name}"

    predicate ?= _.partial fill, pattern, _, options
    groups = _.groupBy list, predicate

    # similar to _.indexBy, except we make sure to
    # check for uniqueness
    if options.unique
        if offenders = groupsContainClashes groups
            offenders = offenders.join '\n'
            throw new Error \
            "Some groups contain more than one object: 

            #{offenders}

            Either disable the --unique option or specify
            a pattern string that produces unique groups."
        groups = _.object _.map groups, (values, key) ->
            [key, values[0]]
    
    _.omit groups, UNCATEGORIZABLE


exports.groupsContainClashes = groupsContainClashes = (groups) ->
    _.keys _.pick groups, (group, key) ->
        group.length > 1

exports.clashes = (list, grouper, options) ->
    groups = exports.group list, grouper, options
    groupsContainClashes groups
