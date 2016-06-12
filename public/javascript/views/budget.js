var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function() {
  },
  render: function() {
    var weeklyAmounts = new app.WeeklyAmountsView()
    $('#content').append(weeklyAmounts.$el);
    weeklyAmounts.renderDiscretionary();
    var monthlyAmounts = new app.MonthlyAmountsView()
    $('#content').append(monthlyAmounts.render());
  }
})
