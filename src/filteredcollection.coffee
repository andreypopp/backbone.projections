{Collection} = require 'backbone'
{extend} = require 'underscore'

inducedOrdering = (collection) ->
  func = (model) -> collection.indexOf(model)
  func.induced = true
  func

class exports.FilteredCollection extends Collection

  constructor: (underlying, options = {}) ->
    this.underlying = underlying
    this.model = underlying.model
    this.comparator = options.comparator or inducedOrdering(underlying)
    this.options = extend {}, underlying.options, options
    super(this.underlying.models.filter(this.options.filter), options)

    this.listenTo this.underlying,
      reset: =>
        this.reset(this.underlying.models.filter(this.options.filter))
      remove: (model) =>
        this.remove(model) if this.contains(model)
      add: (model) =>
        this.add(model) if this.options.filter(model)
      change: (model) =>
        if this.contains(model)
          this.remove(model) unless this.options.filter(model)
        else
          this.add(model) if this.options.filter(model)
      sort: =>
        this.sort() if this.comparator.induced
