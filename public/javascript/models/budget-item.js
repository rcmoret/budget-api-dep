var app = app || {};

app.BudgetItem = Backbone.Model.extend({
  initialize: function() {},
  url: function() {
    if (_.isUndefined(this.id)) {
      return '/items'
    } else {
      return '/items/' + this.id
    }
  },
  freq: function() {
    return this.get('monthly') ? 'monthly' : 'weekly'
  },
  searchMatch: function(terms) {
    var primary = terms['primary']
    var secondary = terms['secondary']
    if (!this.get('name').match(secondary)) { return false }
    if (this.hasCurrentWeeklyAmount()) { return 'budgeted' }
    return this.get('name').match(primary) ? 'primary' : 'secondary'
  },
  hasCurrentWeeklyAmount: function() {
    if (this.freq() === 'weekly') {
      return app.WeeklyAmounts.where({item_id: this.id}).length > 0
    } else {
      return false
    }
  }
})
