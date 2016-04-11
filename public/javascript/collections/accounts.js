var app = app || {};

app.AccountCollection = Backbone.Collection.extend({
  model: app.Account,
  url: '/accounts',
});

app.Accounts = new app.AccountCollection();
