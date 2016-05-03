var app = app || {};

app.BudgetView = Backbone.View.extend({
  initialize: function() {
    new app.WeeklyAmountsView;
    new app.MonthlyAmountsView;
  }
})
