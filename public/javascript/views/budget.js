var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function(month, year) {
    this.month = month
    this.year = year
  },
  render: function() {
    var weeklyAmounts = new app.WeeklyAmountsView(this.dateParams())
    $('#content').append(weeklyAmounts.render());
    var discretionary = new app.DiscretionaryView(this.dateParams());
    $('#discretionary').append(discretionary.render());
    var monthlyAmounts = new app.MonthlyAmountsView(this.dateParams())
    $('#content').append(monthlyAmounts.render());
    var budgetSidebar = new app.BudgetSidebarView(this.dateParams())
    $('#content').append(budgetSidebar.render());
  },
  dateParams: function() {
    if (!_.isNull(this.month)) {
      if (!_.isNull(this.year)) {
        return { month: this.month, year: this.year }
      } else {
        return { month: this.month }
      }
    } else {
      return {}
    }
  }
})
