var app = app || {};

app.ActiveItemsCollection = Backbone.Collection.extend({
  url: '/items/active'
});

app.ActiveItems = new app.ActiveItemsCollection();
