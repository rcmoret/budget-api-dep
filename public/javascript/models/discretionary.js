app = app || {};

app.Discretionary = Backbone.Model.extend({
  initialize: function() {
    this.url = 'items/amounts/discretionary'
    this.transactions = new app.DiscretionaryTransactions()
  }
})
