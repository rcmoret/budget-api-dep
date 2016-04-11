var app = app || {};
var ENTER_KEY = 13;

$(function() {
  new app.AccountView();
  app.Accounts.fetch({reset: true});
});
