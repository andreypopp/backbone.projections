{Collection, Model} = require 'backbone'
{CappedCollection, FilteredCollection,
  SortedCollection, ReversedCollection} = require './src/index'
{equal, deepEqual, ok} = require 'assert'

describe 'CappedCollection', ->

  describe 'initialization from a collection', ->

    underlying = new Collection [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    it 'caps a collection', ->
      c = new CappedCollection(underlying, cap: 2)
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 2
      equal c.at(2), undefined
      assertUnderlying(underlying)

    it 'uses a comparator if provided', ->
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1
      equal c.at(2), undefined
      assertUnderlying(underlying)

  describe 'responding to an underlying reset event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    it 'caps on reset', ->
      underlying = new Collection []
      c = new CappedCollection(underlying, cap: 2)
      equal c.length, 0
      underlying.reset(underlyingItems)
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 2
      equal c.at(2), undefined
      assertUnderlying(underlying)

    it 'uses a comparator if provided', ->
      underlying = new Collection []
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 0
      underlying.reset(underlyingItems)
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1
      equal c.at(2), undefined
      assertUnderlying(underlying)

  describe 'responding to an underlying add event', ->

    it 'responds to an add event', ->
      underlying = new Collection []
      c = new CappedCollection(underlying, cap: 2)
      equal c.length, 0

      underlying.add {a: 1}
      equal underlying.length, 1
      equal c.length, 1

      underlying.add [{a: 2}, {a: 3}]
      equal underlying.length, 3
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 2
      equal c.at(1).get('a'), underlying.at(1).get('a')
      equal c.at(2), undefined

      underlying.add {a: 4}, at: 1
      equal underlying.length, 4
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 4
      equal c.at(1).get('a'), underlying.at(1).get('a')

      underlying.add {a: 5}, at: 0
      equal underlying.length, 5
      equal c.length, 2
      equal c.at(0).get('a'), 5
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 1
      equal c.at(1).get('a'), underlying.at(1).get('a')

    it 'responds to an add event w/ comparator provided', ->
      underlying = new Collection []
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 0

      underlying.add {a: 1, b: 3}
      equal underlying.length, 1
      equal c.length, 1

      underlying.add [{a: 2, b: 1}, {a: 3, b: 2}]
      equal underlying.length, 3
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3

      underlying.add {a: 4, b: 4}, at: 1
      equal underlying.length, 4
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3

      underlying.add {a: 5, b: 1.5}, at: 0
      equal underlying.length, 5
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 5

  describe 'responding to an underlying remove event', ->

    it 'responds to an remove event', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new CappedCollection(underlying, cap: 2)
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 2
      equal c.at(1).get('a'), underlying.at(1).get('a')

      underlying.remove(underlying.at(2))
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 2
      equal c.at(1).get('a'), underlying.at(1).get('a')

      underlying.remove(underlying.at(0))
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 4
      equal c.at(1).get('a'), underlying.at(1).get('a')

    it 'responds to a remove event w/ comparator provided', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1

      underlying.remove(underlying.at(2))
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 2

      underlying.remove(underlying.at(1))
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 4

  describe 'handling of an underlying sort event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    it 'responds to a sort event if no comparator is provided', ->
      underlying = new Collection [],
        comparator: (model) -> model.get('b')
      underlying.add underlyingItems, sort: false
      c = new CappedCollection underlying, cap: 2
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 2
      equal c.at(1).get('a'), underlying.at(1).get('a')
      underlying.sort()
      equal c.at(0).get('a'), 3
      equal c.at(0).get('a'), underlying.at(0).get('a')
      equal c.at(1).get('a'), 1
      equal c.at(1).get('a'), underlying.at(1).get('a')

    it 'ignores a sort event if comparator is provided', ->
      underlying = new Collection [],
        comparator: (model) -> model.get('b')
      underlying.add underlyingItems, sort: false
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1
      underlying.sort()
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1

  describe 'resizing', ->

    it 'upsizes', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new CappedCollection underlying, cap: 2
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 2
      c.resize(4)
      equal c.length, 4
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 2
      equal c.at(2).get('a'), 3
      equal c.at(3).get('a'), 4

    it 'upsizes w/ comparator', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1
      c.resize(4)
      equal c.length, 4
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1
      equal c.at(2).get('a'), 2
      equal c.at(3).get('a'), 4

    it 'downsizes', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new CappedCollection underlying, cap: 2
      equal c.length, 2
      equal c.at(0).get('a'), 1
      equal c.at(1).get('a'), 2
      c.resize(1)
      equal c.length, 1
      equal c.at(0).get('a'), 1

    it 'downsizes w/ comparator', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new CappedCollection underlying,
        cap: 2
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1
      c.resize(1)
      equal c.length, 1
      equal c.at(0).get('a'), 3

describe 'FilteredCollection', ->

  describe 'initialization from a collection', ->

    underlying = new Collection [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    it 'filters a collection', ->
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3
      equal c.at(2), undefined
      assertUnderlying(underlying)

    it 'uses a comparator if provided', ->
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 2
      equal c.at(2), undefined
      assertUnderlying(underlying)

  describe 'responding to an underlying reset event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    it 'filters on reset', ->
      underlying = new Collection []
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
      equal c.length, 0
      underlying.reset(underlyingItems)
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3
      equal c.at(2), undefined
      assertUnderlying(underlying)

    it 'uses a comparator if provided', ->
      underlying = new Collection []
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
        comparator: (model) -> model.get('b')
      equal c.length, 0
      underlying.reset(underlyingItems)
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 2
      equal c.at(2), undefined
      assertUnderlying(underlying)

  describe 'responding to an underlying remove event', ->

    it 'responds to an remove event', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3

      underlying.remove(underlying.at(2))
      equal c.length, 1
      equal c.at(0).get('a'), 2

      underlying.remove(underlying.at(0))
      equal c.length, 1
      equal c.at(0).get('a'), 2

    it 'responds to a remove event w/ comparator provided', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 2

      underlying.remove(underlying.at(2))
      equal c.length, 1
      equal c.at(0).get('a'), 2

      underlying.remove(underlying.at(1))
      equal c.length, 0

  describe 'responding to an underlying add event', ->

    it 'responds to an add event', ->
      underlying = new Collection []
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
      equal c.length, 0

      underlying.add {a: 1}
      equal underlying.length, 1
      equal c.length, 0

      underlying.add [{a: 2}, {a: 3}]
      equal underlying.length, 3
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3
      equal c.at(2), undefined

      underlying.add {a: 4}, at: 1
      equal underlying.length, 4
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3

    it 'responds to an add event w/ comparator provided', ->
      underlying = new Collection []
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
        comparator: (model) -> model.get('b')
      equal c.length, 0

      underlying.add {a: 1, b: 3}
      equal underlying.length, 1
      equal c.length, 0

      underlying.add [{a: 2, b: 1}, {a: 3, b: 2}]
      equal underlying.length, 3
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3

      underlying.add {a: 4, b: 4}, at: 1
      equal underlying.length, 4
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3

  describe 'handling model change events', ->

    it 'responds to an underlying change event', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
      equal c.length, 2
      underlying.at(0).set('a', 1.5)
      equal c.length, 3
      equal c.at(0).get('a'), 1.5
      equal c.at(1).get('a'), 2
      equal c.at(2).get('a'), 3
      underlying.at(1).set('a', 5)
      equal c.length, 2
      equal c.at(0).get('a'), 1.5
      equal c.at(1).get('a'), 3

    it 'responds to an underlying change event w/ comparator', ->
      underlying = new Collection [
        {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
      ]
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
        comparator: (model) -> model.get('b')
      equal c.length, 2
      underlying.at(0).set('a', 1.5)
      equal c.length, 3
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 1.5
      equal c.at(2).get('a'), 2
      underlying.at(2).set('a', 5)
      equal c.length, 2
      equal c.at(0).get('a'), 1.5
      equal c.at(1).get('a'), 2

  describe 'handling of an underlying sort event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    it 'responds to a sort event if no comparator is provided', ->
      underlying = new Collection [],
        comparator: (model) -> model.get('b')
      underlying.add underlyingItems, sort: false
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
      equal c.length, 2
      equal c.at(0).get('a'), 2
      equal c.at(1).get('a'), 3
      underlying.sort()
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 2

    it 'ignores a sort event if comparator is provided', ->
      underlying = new Collection [],
        comparator: (model) -> model.get('b')
      underlying.add underlyingItems, sort: false
      c = new FilteredCollection underlying,
        filter: (model) -> model.get('a') < 4 and model.get('a') > 1
        comparator: (model) -> model.get('b')
      equal c.length, 2
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 2
      underlying.sort()
      equal c.at(0).get('a'), 3
      equal c.at(1).get('a'), 2

  describe 'implementation of a difference between two collections', ->

    class Difference extends FilteredCollection
      constructor: (underlying, subtrahend, options = {}) ->
        options.filter = (model) -> not subtrahend.contains(model)
        super(underlying, options)
        this.listenTo subtrahend, 'add remove reset', this.update.bind(this)

    a = new Model()
    b = new Model()
    c = new Model()
    d = new Model()

    underlying = new Collection [a, b, c]
    subtrahend = new Collection [b, c, d]

    diff = new Difference(underlying, subtrahend)

    it 'contains models from minuend', ->
      equal diff.length, 1
      ok diff.contains(a)

    it 'does not contain models from subtrahend', ->
      ok not diff.contains(b)
      ok not diff.contains(c)

    it 'updates on changes in subtrahend', ->
      subtrahend.remove(b)
      equal diff.length, 2
      ok diff.contains(b)

      subtrahend.add(a)
      equal diff.length, 1
      ok not diff.contains(a)

      subtrahend.reset([d])
      equal diff.length, 3
      ok diff.contains(a)
      ok diff.contains(b)
      ok diff.contains(c)
  
  describe 'implementation of an efficient difference between two collections', ->

    class EfficientDifference extends FilteredCollection
      constructor: (underlying, subtrahend, options = {}) ->
        options.filter = (model) -> not subtrahend.contains(model)
        super(underlying, options)
        this.listenTo subtrahend,
          add: (model) =>
            this.remove(model) if this.contains(model)
          remove: (model) =>
            this.add(model) if this.underlying.contains(model)
          reset: this.update.bind(this)

    a = new Model()
    b = new Model()
    c = new Model()
    d = new Model()

    underlying = new Collection [a, b, c]
    subtrahend = new Collection [b, c, d]

    diff = new EfficientDifference(underlying, subtrahend)

    it 'contains models from minuend', ->
      equal diff.length, 1
      ok diff.contains(a)

    it 'does not contain models from subtrahend', ->
      ok not diff.contains(b)
      ok not diff.contains(c)

    it 'updates on changes in subtrahend', ->
      subtrahend.remove(b)
      equal diff.length, 2
      ok diff.contains(b)

      subtrahend.add(a)
      equal diff.length, 1
      ok not diff.contains(a)

      subtrahend.reset([d])
      equal diff.length, 3
      ok diff.contains(a)
      ok diff.contains(b)
      ok diff.contains(c)

describe 'SortedCollection', ->

  it 'initializes from a collection', ->

    underlying = new Collection [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    c = new SortedCollection underlying,
      comparator: (model) -> model.get('b')
    equal c.length, 4
    equal c.at(0).get('a'), 3
    equal c.at(1).get('a'), 1
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 4
    assertUnderlying(underlying)

  it 'responds to an underlying reset event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    underlying = new Collection []
    c = new SortedCollection underlying,
      comparator: (model) -> model.get('b')
    equal c.length, 0
    underlying.reset(underlyingItems)
    equal c.length, 4
    equal c.at(0).get('a'), 3
    equal c.at(1).get('a'), 1
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 4
    assertUnderlying(underlying)

  it 'responds to an underlying remove event', ->
    underlying = new Collection [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]
    c = new SortedCollection underlying,
      comparator: (model) -> model.get('b')
    equal c.length, 4
    equal c.at(0).get('a'), 3
    equal c.at(1).get('a'), 1
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 4

    underlying.remove(underlying.at(2))
    equal c.length, 3
    equal c.at(0).get('a'), 1
    equal c.at(1).get('a'), 2
    equal c.at(2).get('a'), 4

    underlying.remove(underlying.at(0))
    equal c.length, 2
    equal c.at(0).get('a'), 2
    equal c.at(1).get('a'), 4

  it 'responds to an underlying add event', ->
    underlying = new Collection []
    c = new SortedCollection underlying,
      comparator: (model) -> model.get('b')
    equal c.length, 0

    underlying.add {a: 1, b: 2}
    equal underlying.length, 1
    equal c.length, 1

    underlying.add [{a: 2, b: 3}, {a: 3, b: 1}]
    equal underlying.length, 3
    equal c.length, 3
    equal c.at(0).get('a'), 3
    equal c.at(1).get('a'), 1
    equal c.at(2).get('a'), 2

    underlying.add {a: 4, b: 4}, at: 1
    equal underlying.length, 4
    equal c.length, 4
    equal c.at(0).get('a'), 3
    equal c.at(1).get('a'), 1
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 4

describe 'ReversedCollection', ->

  it 'initializes from a collection', ->

    underlying = new Collection [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    c = new ReversedCollection(underlying)
    equal c.length, 4
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 3
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 1
    assertUnderlying(underlying)

  it 'responds to an underlying reset event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    assertUnderlying = (underlying) ->
      equal underlying.length, 4
      equal underlying.at(0).get('a'), 1
      equal underlying.at(1).get('a'), 2
      equal underlying.at(2).get('a'), 3
      equal underlying.at(3).get('a'), 4

    underlying = new Collection []
    c = new ReversedCollection(underlying)
    equal c.length, 0
    underlying.reset(underlyingItems)
    equal c.length, 4
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 3
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 1
    assertUnderlying(underlying)

  it 'responds to an underlying remove event', ->
    underlying = new Collection [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]
    c = new ReversedCollection(underlying)
    equal c.length, 4
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 3
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 1

    underlying.remove(underlying.at(2))
    equal c.length, 3
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 2
    equal c.at(2).get('a'), 1

    underlying.remove(underlying.at(0))
    equal c.length, 2
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 2

  it 'responds to an underlying add event', ->
    underlying = new Collection []
    c = new ReversedCollection(underlying)
    equal c.length, 0

    underlying.add {a: 1, b: 2}
    equal underlying.length, 1
    equal c.length, 1

    underlying.add [{a: 2, b: 3}, {a: 3, b: 1}]
    equal underlying.length, 3
    equal c.length, 3
    equal c.at(0).get('a'), 3
    equal c.at(1).get('a'), 2
    equal c.at(2).get('a'), 1

    underlying.add {a: 4, b: 4}
    equal underlying.length, 4
    equal c.length, 4
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 3
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 1

  it 'responds to an underlying sort event', ->

    underlyingItems = [
      {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 1}, {a: 4, b: 4}
    ]

    underlying = new Collection [],
      comparator: (model) -> model.get('b')
    underlying.add underlyingItems, sort: false
    c = new ReversedCollection(underlying)
    equal c.length, 4
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 3
    equal c.at(2).get('a'), 2
    equal c.at(3).get('a'), 1
    underlying.sort()
    equal c.at(0).get('a'), 4
    equal c.at(1).get('a'), 2
    equal c.at(2).get('a'), 1
    equal c.at(3).get('a'), 3
