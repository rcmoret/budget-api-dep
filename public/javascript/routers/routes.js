var app = app || {};

var Workspace = Backbone.Router.extend({
  initialize: function() {
    Backbone.history.start();
    this.setDateParams(null, null)
    this.accountsView = new app.AccountsView();
    this.accountsView.render()
    this.budgetView = new app.BudgetView();
    this.budgetView.render();
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
    this.setDateParams(null, null)
    if (this.selected === 'budget_items') {
      $('#budget-content').slideToggle(500)
      $('#account-wrapper').slideToggle(500)
    } else if (_.isUndefined(this.selected)) {
      $('#account-wrapper').slideToggle(100)
    }
    this.selected = 'accounts'
  },
  renderAccount: function(id, month, year) {
    this.setDateParams(month, year)
    if (app.Accounts.length === 0) {
      this.renderAccounts()
    }
    $('#account-content').html('')
    this.renderTransactions(id)
  },
  renderTransactions: function(id) {
    app.Accounts.fetch().then(function() {
      app.Accounts.get(id).trigger('render')
    })
  },
  renderBudget: function(month, year) {
    this.setDateParams(month, year)
    $('.title').removeClass('focused')
    if (this.selected === 'accounts') {
      $('#account-wrapper').slideToggle(1000)
      $('#budget-content').slideToggle(1000)
    } else if (_.isUndefined(this.selected)) {
      $('#budget-content').slideToggle(100)
    }
    debugger
    this.selected = 'budget_items'
  },
  setDateParams: function(mon, yr) {
    var today = new Date
    var month = parseInt(mon) || (today.getMonth() + 1)
    var year = parseInt(yr) || today.getFullYear()
    app.dateParams = { month: month, year: year }
  }
});
