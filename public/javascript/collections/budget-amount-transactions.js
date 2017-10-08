var app = app || {};

app.BudgetAmountTransactions = Backbone.Collection.extend({
  model: app.Transaction,
  initialize: function(itemId, amountId) {
    this.url = '/items/' + itemId + '/amounts/' + amountId + '/transactions'
  }
});

