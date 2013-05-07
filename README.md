backbone.projections is a set of projections for Backbone.Collection

  * CappedCollection project underlying collection into a read-only collection
    of capped size

        {CappedCollection} = require 'backbone.projections'

        collection = new Collection [...]
        capped = new CappedCollection(collection, cap: 5)

    this way `capped` will contain no more than 5 models and will behave as a
    Backbone.Collection and will be in sync with underlying `collection`.
    CappedCollection supports `comparator` but if no comparator is provided then
    `capped` will have an order induced by underlying collection.

  * FilteredCollection project underlying collection into a read-only collection
    of models which match some predicate

        {FilteredCollection} = require 'backbone.projections'

        collection = new Collection [...]
        filtered = new FilteredCollection collection,
          filter: (model) -> model.get('date').isToday()

    this way `filtered` will contain only models which have "today's date" and
    will behave as a Backbone.Collection and will be in sync with underlying
    `collection`. FilteredCollection supports `comparator` but if no comparator
    is provided then `capped` will have an order induced by underlying
    collection.
