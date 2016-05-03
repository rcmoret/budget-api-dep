var app = app || {};

app.Account = Backbone.Model.extend({
  urlRoot: '/accounts',
  url: function() {
    return this.urlRoot + '/' + this.id;
  },
  defaults: {
    'name': 'default'
  },
  initialize: function() {
    this.transactions = new app.Transactions(this.id);
    return this;
  }
});
