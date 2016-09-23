var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function() {
  },
  render: function() {
    var weeklyAmounts = new app.WeeklyAmountsView(app.dateParams)
    $('#content').append(weeklyAmounts.render());
    var discretionary = new app.DiscretionaryView(app.dateParams);
    var monthlyAmounts = new app.MonthlyAmountsView(app.dateParams)
    $('#content').append(monthlyAmounts.render());
    var budgetSidebar = new app.BudgetSidebarView(app.dateParams)
    $('#content').append(budgetSidebar.render());
  }
})
