var app = app || {};

app.ActiveItemsCollection = Backbone.Collection.extend({
  url: '/items/active',
  model: app.BudgetItem
});

app.ActiveItems = new app.ActiveItemsCollection();
