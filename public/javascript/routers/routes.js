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
    app.Accounts.fetch({reset: true});
    this.selectAccounts();
  },
  selectAccounts: function() {
    $('.title').removeClass('focused')
    $('.title.accounts').addClass('focused')
  },
  renderTransactions: function(id) {
    this.selectAccounts();
    var self = this
    app.Accounts.fetch({
      reset: true,
      success: function() {
        if ($('li.selected').length > 0  ) {
          $('li.selected .transactions').slideToggle(1000, function() {
            $('li.selected').removeClass('selected');
            if ($('#account-' + id + ' .transactions').is(':hidden')) {
              ($('#account-' + id + ' .transactions')).slideToggle(1000)
            }
            self.accountsView.renderTransactions(id)
          });
        } else {
          self.accountsView.renderTransactions(id)
        }
      }
    })
  },
  renderBudgetItems: function() {
    app.Accounts.fetch({reset: true});
    this.togglePane('budget-items');
    app.WeeklyAmounts.fetch({reset: true});
    app.MonthlyAmounts.fetch({reset: true});
    $('#budget-items ul').addClass('selected');
  },
  togglePane: function(name) {
    if ($('#' + name + ' .pane').hasClass('focused')) {
      return
    } else if ($('.pane.focused').size() > 0) {
      $('.pane.focused .selected').slideUp();
      $('.pane.focused .selected').removeClass('selected');
      $('.pane.focused').removeClass('focused');
    }
    $('#' + name + '.pane').addClass('focused');
  }
});
