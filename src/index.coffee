{Collection} = require 'backbone'
{toArray, extend} = require 'underscore'

class CollectionProjection extends Collection

  # TODO: need to disable mutations on CollectionProjection
  # add: -> throw new Error('collection projection cannot be modified')
  # remove: -> throw new Error('collection projection cannot be modified')
  # reset: -> throw new Error('collection projection cannot be modified')
  # sync: -> throw new Error('collection projection cannot be synced')
  # fetch: -> throw new Error('collection projection cannot be fetched')

class exports.CappedCollection extends CollectionProjection

  constructor: (underlying, options = {}) ->
    this.underlying = underlying
    this.model = underlying.model
    this.comparator = options.comparator
    this.options = extend {cap: 5}, underlying.options, options
    super(this._capped(this.underlying.models), options)

    this.listenTo this.underlying,
      reset: =>
        this.reset(this._capped(this.underlying.models))

      remove: (model) =>
        if this.contains(model)
          this.remove(model)
          if this.comparator
            capped = this._capped(this.underlying.models)
            this.add(capped[this.options.cap - 1])
          else
            this.add(this.underlying.at(this.options.cap - 1))

      add: (model) =>
        if this.length < this.options.cap
          if this.comparator
            this.add(model)
          else
            this.add(model, at: this.underlying.indexOf(model))
        else
          if this.comparator
            # TODO: check if Backbone.Collection does a stable sort
            if this.comparator(model) < this.comparator(this.last())
              this.add(model)
              this.remove(this.at(this.options.cap))
          else
            this.add(model, at: this.underlying.indexOf(model))
            this.remove(this.at(this.options.cap))

  _capped: (models) ->
    models = toArray(models)
    if this.comparator
      models.sort (a, b) =>
        a = this.comparator(a)
        b = this.comparator(b)
        if a > b then 1
        else if a < b then -1
        else 0
    models.slice(0, this.options.cap)

  resize: (cap) ->
    if this.options.cap > cap
      this.options.cap = cap
      for model, idx in this.models by -1
        break if idx < cap
        this.remove(model)
    else if this.options.cap < cap
      this.options.cap = cap
      if this.comparator
        capped = this._capped(this.underlying.models)
        this.add(capped.slice(this.length, this.options.cap))
      else
        this.add(this.underlying.models.slice(this.length, this.options.cap))
