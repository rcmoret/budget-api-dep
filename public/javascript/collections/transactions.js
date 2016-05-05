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
    this.metadata = resp['metadata']
    return resp['transactions'];
  }
});
