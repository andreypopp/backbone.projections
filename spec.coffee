{Collection} = require 'backbone'
{CappedCollection} = require './src/index'
{equal, deepEqual} = require 'assert'

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

    it 'responds to un remove event w/ comparator provided', ->
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
      return

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
