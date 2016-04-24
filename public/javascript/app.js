var app = app || {};
var ENTER_KEY = 13;

$(function() {
  new app.AccountsView();
  app.Accounts.fetch({reset: true});
});
