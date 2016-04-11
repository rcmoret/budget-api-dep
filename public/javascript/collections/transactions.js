var app = app || {};

app.Transactions = Backbone.Collection.extend({
  model: app.Transaction,
  initialize: function(accountId) {
    this.accountId = accountId;
  },
  url: function() {
    return '/accounts/' + this.accountId + '/transactions'
  },
  parse: function(resp) {
    this.initial_balance = resp['metadata']['prior_balance'];
    return resp['transactions'];
  }
});
