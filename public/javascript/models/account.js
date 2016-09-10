var app = app || {};

app.Account = Backbone.Model.extend({
  initialize: function(month, year) {
    this.transactions = new app.Transactions(this.id);
    this.url = this.urlRoot + '/' + this.id;
  },
  urlRoot: '/accounts',
  defaults: {
    'name': 'default'
  }
});
