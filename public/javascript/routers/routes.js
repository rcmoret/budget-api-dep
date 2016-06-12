var app = app || {};

var Workspace = Backbone.Router.extend({
  initialize: function() {
    this.accountsView = new app.AccountsView();
    new app.BudgetView();
    Backbone.history.start();
  },
  routes: {
    '': 'pageLoad',
    'accounts': 'renderAccounts',
    'budget-items': 'renderBudget'
  },
  pageLoad: function() {
    this.selectAccounts();
  },
  renderAccounts: function(opts = {reset: true}) {
    $('.title').removeClass('focused')
    $('.title.accounts').addClass('focused')
    $('#content').html('')
    app.Accounts.fetch({reset: true});
  },
  renderBudget: function() {
    $('#content').html('')
    $('#tab-list').html('')
    $('.title').removeClass('focused')
    $('.title.budget-items').addClass('focused')
    var budgetView = new app.BudgetView;
    budgetView.render();
  }
});
