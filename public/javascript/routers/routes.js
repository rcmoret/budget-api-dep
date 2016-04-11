var app = app || {};

var Workspace = Backbone.Router.extend({
  routes: {
    'filter': 'pageLoad'
  },

  pageLoad: function( param ) {
    new app.AccountView();
    if (param) {
      param = param.trim();
    }
    // app.AccountFilter = param || '';
    // app.Accounts.fetch();
    // app.Accounts.trigger('all');
  }
});

app.BudgetRouter = new Workspace();
app.BudgetRouter.on('route:defaultRoute', app.BudgetRouter.pageLoad());
Backbone.history.start();
