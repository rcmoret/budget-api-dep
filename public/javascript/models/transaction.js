app = app || {};

app.Transaction = Backbone.Model.extend({
  initialize: function() {
    // this.accountId = accountId;
  },
  baseUrl: function() {
    return '/accounts/' + this.account_id + '/transactions/'
  },
  url: function() {
    return baseUrl + this.id
  }
});
