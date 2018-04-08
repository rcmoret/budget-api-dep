var app = app || {};

app.DiscretionaryTransactions = Backbone.Collection.extend({
  model: app.Transaction,
  initialize: function() {
    this.url = '/items/amounts/discretionary/transactions'
  }
});
