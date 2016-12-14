var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function() {
    this.renderSidebar();
    this.monthlyAmounts = new app.MonthlyAmountsView()
    this.weeklyAmounts = new app.WeeklyAmountsView()
    this.discretionary = new app.DiscretionaryView();
  },
  render: function() {
    $('#content').prepend(this.monthlyAmounts.render());
    $('#content').prepend(this.weeklyAmounts.render());
  },
  renderSidebar: function() {
    var budgetSidebar = new app.BudgetSidebarView(app.dateParams)
    $('#content').append(budgetSidebar.render());
  },
  rerender: function() {
    this.monthlyAmount.rerender()
    this.weeklyAmount.rerender()
  }
})
