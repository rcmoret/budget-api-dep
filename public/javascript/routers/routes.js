var app = app || {};

var Workspace = Backbone.Router.extend({
  initialize: function() {
    this.accountsView = new app.AccountsView();
    new app.BudgetView();
    _.bindAll(this, 'selectAccount')
    Backbone.history.start();
  },
  routes: {
    '': 'pageLoad',
    'accounts': 'renderAccounts',
    'accounts/:id': 'renderAccount',
    'budget-items(/:month)(/:year)': 'renderBudget',
  },
  pageLoad: function() {
  },
  renderAccounts: function() {
    $('.title').removeClass('focused')
    $('.title.accounts').addClass('focused')
    $('#content').html('')
    app.Accounts.fetch({
      reset: true,
      success: this.selectAccount
    });
  },
  renderAccount: function(id) {
    this.account_id = id
    $('.title').removeClass('focused')
    $('.title.accounts').addClass('focused')
    $('#content').html('')
    app.Accounts.fetch({
      reset: true,
      success: this.selectAccount
    });
  },
  selectAccount: function() {
    if (_.isUndefined(this.account_id)) {
    } else {
      var acct = app.Accounts.get(this.account_id)
      acct.trigger('render')
    }
  },
  renderBudget: function(month, year) {
    $('#content').html('')
    $('#tab-list').html('')
    $('.title').removeClass('focused')
    $('.title.budget-items').addClass('focused')
    var budgetView = new app.BudgetView(month, year);
    budgetView.render();
  }
});
