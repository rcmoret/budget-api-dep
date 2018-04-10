var app = app || {};

var Workspace = Backbone.Router.extend({
  initialize: function() {
    this.setDateParams(null, null)
    this.accountsView = new app.AccountsView();
    Backbone.history.start();
  },
  routes: {
    '': 'pageLoad',
    'accounts': 'renderAccounts',
    'accounts/:id(/:month)(/:year)': 'renderAccount',
    'budget(/:month)(/:year)': 'renderBudget',
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
    this.setDateParams(month, year)
    if (this.selected === 'budget_items') {
      this.budgetView.render();
    } else {
      this.selected = 'budget_items'
      $('#content').html('')
      $('#tab-list').html('')
      $('.title').removeClass('focused')
      $('.title.budget-items').addClass('focused')
      this.budgetView = new app.BudgetView();
      this.budgetView.render();
    }
  },
  setDateParams: function(mon, yr) {
    var today = new Date
    var month = parseInt(mon) || (today.getMonth() + 1)
    var year = parseInt(yr) || today.getFullYear()
    app.dateParams = { month: month, year: year }
  },
});
