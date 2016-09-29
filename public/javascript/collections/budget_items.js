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

var ActiveMonthlyItemsCollection = Backbone.Collection.extend({
  model: app.BudgetItem,
  url: '/items',
  search: function(term, tabSelected) {
    if (_.isEmpty(tabSelected)) {
     var results = { set:  _.sortBy(this.models, function(model) { return model.hasCurrentWeeklyAmount() }) }
    } else {
      var results = _.reduce(this.models, function(memo, model) {
        if (model.freq() === memo.freq) {
          memo['set'].push(model)
        }
        return memo
      }, {freq: tabSelected, set: []})
    }
    var searchTerms = { primary: (new RegExp('^' + term, 'i')),
                        secondary: (new RegExp(term, 'i')),
                        freq: tabSelected }
    var refined = _.groupBy(results['set'], function(model) {
      return model.searchMatch(searchTerms)
    })
    return refined
  }
})

app.WeeklyAmounts = new WeeklyAmountCollection
app.MonthlyAmounts = new MonthlyAmountCollection
app.ActiveMonthlyItems = new ActiveMonthlyItemsCollection
