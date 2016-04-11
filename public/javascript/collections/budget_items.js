var app = app || {};

var MonthlyAmountCollection = Backbone.Collection.extend({
  model: app.BudgetAmount,
  url: '/items/amounts/monthly'
});

var WeeklyAmountCollection = Backbone.Collection.extend({
  model: app.BudgetAmount,
  url: '/items/amounts/weekly'
});

app.WeeklyAmounts = new WeeklyAmountCollection
app.MonthlyAmounts = new MonthlyAmountCollection
