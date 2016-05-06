var app = app || {};

app.Account = Backbone.Model.extend({
  intialize: function() {
    this.url = this.urlRoot() + '/' + this.id;
  },
  urlRoot: '/accounts',
  defaults: {
    'name': 'default'
  },
  initialize: function() {
    this.transactions = new app.Transactions(this.id);
    return this;
  }
});
