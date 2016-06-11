var app = app || {};

var Workspace = Backbone.Router.extend({
  initialize: function() {
    this.accountsView = new app.AccountsView();
    new app.BudgetView();
    Backbone.history.start();
  },
  routes: {
    '': 'pageLoad',
    'accounts/:id': 'renderTransactions',
    'accounts': 'selectAccounts',
    'budget-items': 'renderBudgetItems'
  },
  pageLoad: function() {
    this.selectAccounts();
  },
  selectAccounts: function() {
    $('.title').removeClass('focused')
    $('.title.accounts').addClass('focused')
    $('#content').html('')
    app.Accounts.fetch({reset: true});
  },
  renderTransactions: function(id) {
    this.selectAccounts();
    var self = this
    app.Accounts.fetch({
      reset: true,
      success: function() {
        self.accountsView.renderTransactions(id)
      }
    })
  },
  renderBudgetItems: function() {
    $('#content').html('')
    $('#tab-list').html('')
    this.selectBudget()
  },
  selectBudget: function() {
    $('.title').removeClass('focused')
    $('.title.budget-items').addClass('focused')
    var budgetView = new app.BudgetView;
    budgetView.render();
  }
});
