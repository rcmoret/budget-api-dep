var app = app || {};

var Workspace = Backbone.Router.extend({
  routes: {
    'filter': 'pageLoad'
  },

  pageLoad: function( param ) {
  }
});

app.BudgetRouter = new Workspace();
app.BudgetRouter.on('route:defaultRoute', app.BudgetRouter.pageLoad());
Backbone.history.start();
