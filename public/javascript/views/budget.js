var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function() {
  },
  render: function() {
    var weeklyAmounts = new app.WeeklyAmountsView()
    $('#content').append(weeklyAmounts.render());
    var monthlyAmounts = new app.MonthlyAmountsView()
    $('#content').append(monthlyAmounts.render());
  }
})
