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
    'accounts/:id(/:month)(/:year)': 'renderAccount',
    'budget-items(/:month)(/:year)': 'renderBudget',
  },
  pageLoad: function() {
  },
  renderAccounts: function() {
    $('.title').removeClass('focused')
    $('.title.accounts').addClass('focused')
    $('#content').html('')
    this.accountsView.render()
    this.selected = 'accounts'
  },
  renderAccount: function(id, month, year) {
    this.setDateParams(month, year)
    if (app.Accounts.length === 0) {
      this.renderAccounts()
    }
    $('#content').html('')
    this.renderTransactions(id)
  },
  renderTransactions: function(id) {
    app.Accounts.fetch().then(function() {
      app.Accounts.get(id).trigger('render')
    })
  },
  renderBudget: function(month, year) {
    this.selected = 'budget_items'
    $('#content').html('')
    $('#tab-list').html('')
    $('.title').removeClass('focused')
    $('.title.budget-items').addClass('focused')
    var budgetView = new app.BudgetView(month, year);
    budgetView.render();
  },
  setDateParams: function(mon, yr) {
    var today = new Date
    var month = parseInt(mon) || (today.getMonth() + 1)
    var year = parseInt(yr) || today.getFullYear()
    app.dateParams = { month: month, year: year }
  }
});
