var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function() {
  },
  render: function(month, year) {
    var weeklyAmounts = new app.WeeklyAmountsView(month, year)
    $('#content').append(weeklyAmounts.render());
    weeklyAmounts.renderDiscretionary();
    var monthlyAmounts = new app.MonthlyAmountsView(month, year)
    $('#content').append(monthlyAmounts.render());
    var budgetSidebar = new app.BudgetSidebarView()
    $('#content').append(budgetSidebar.render());
  }
})
