var app = app || {};

app.Transactions = Backbone.Collection.extend({
  model: app.Transaction,
  initialize: function(accountId) {
    this.url = '/accounts/' + accountId + '/transactions'
    this.accountId = accountId
  },
  parse: function(resp) {
    this.metadata = resp['metadata']
    return resp['transactions'];
  }
});
