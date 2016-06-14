var app = app || {};

var MonthlyAmountCollection = Backbone.Collection.extend({
  model: app.BudgetAmount,
  url: '/items/amounts/monthly',
  comparator: function(model1, model2) {
    var amt1 = Math.abs(model1.get('remaining'))
    var amt2 = Math.abs(model2.get('remaining'))
    return amt1 < amt2 ? 1 : -1
  }
});

var WeeklyAmountCollection = Backbone.Collection.extend({
  model: app.BudgetAmount,
  url: '/items/amounts/weekly',
  comparator: function(model1, model2) {
    var amt1 = Math.abs(model1.get('remaining'))
    var amt2 = Math.abs(model2.get('remaining'))
    return amt1 < amt2 ? 1 : -1
  }
});

app.WeeklyAmounts = new WeeklyAmountCollection
app.MonthlyAmounts = new MonthlyAmountCollection
